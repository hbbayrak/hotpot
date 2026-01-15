# Architecture

System architecture overview for the CCD Data Stewardship Platform.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (React)                          │
│                    http://localhost:3000                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    .NET 8 Backend (API)                         │
│                    http://localhost:5000                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │ Controllers │──│  Services   │──│ EF Core / Dapper        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   PostgreSQL    │  │    SendGrid     │  │  File Storage   │
│    Database     │  │     (Email)     │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## Authentication Flow

### JWT Bearer Authentication

```
1. User submits credentials
   POST /api/v1/authentication/login
   { "email": "...", "password": "..." }

2. Server validates and generates JWT
   - Claims: NameIdentifier (userId), Email, Role (organization roles)
   - Expiry: 365 days (configurable via JWT_EXPIRATION_DAYS)
   - Algorithm: HMAC SHA256

3. Client stores token
   - LocalStorage: token, user, organization

4. Subsequent requests include token
   Authorization: Bearer <token>
   organization-id: <guid>

5. Server validates on each request
   Startup.cs → JWT middleware → PermissionLevelMiddleware
```

### JWT Token Structure

```json
{
  "nameid": "user-guid",
  "email": "user@example.com",
  "role": "{\"org-guid\": \"admin\", \"org2-guid\": \"user\"}",
  "exp": 1234567890
}
```

### API Key Authentication

Alternative auth for programmatic access:
- Header: `x-api-key: <key>` or query: `?apiKey=<key>`
- Used for service-to-service communication
- Bypasses organization role checks

## Multi-Tenancy

The platform supports multiple organizations sharing one database.

### Request Flow

```
1. Client sends request with header
   organization-id: <guid>

2. PermissionLevelMiddleware extracts
   HttpContext.Items["OrganizationId"] = Guid

3. Controllers/Services use OrganizationId
   var orgId = (Guid)HttpContext.Items["OrganizationId"];

4. All queries filtered by organization
   .Where(x => x.OrganizationId == orgId)
```

### Organization Roles

Each user has roles per organization (stored in JWT):

```json
{
  "organization-guid-1": "admin",
  "organization-guid-2": "user"
}
```

| Role | Access Level |
|------|--------------|
| `user` | Standard access within organization |
| `admin` | Full admin access within organization |
| `superadmin` | SYSTEM_USER only, deployment-wide access |

## Authorization

### PermissionLevelAttribute

```csharp
[HttpGet]
[PermissionLevel(UserRole.Admin)]  // Admin only
public async Task<ActionResult> AdminEndpoint() { }

[HttpGet]
[PermissionLevel(UserRole.User)]   // Admin or User
public async Task<ActionResult> UserEndpoint() { }
```

### SYSTEM_USER

Special superadmin account:
- Bypasses all role checks
- Has access to `/api/v1/settings`
- Created on database seed
- Password from `SUPERADMIN_PASSWORD` env var

## Data Patterns

### Soft Delete

Entities implement `IIsDeleted` interface:

```csharp
public class User : IIsDeleted
{
    public bool IsDeleted { get; set; } = false;
}
```

On delete:
- `SaveChanges()` intercepts delete
- Changes `IsDeleted = true` instead
- Record remains in database

Query pattern:
```csharp
_context.Users.Where(u => !u.IsDeleted)
```

### User Change Tracking

Entities inherit `UserChangeTracked`:

```csharp
public class Template : UserChangeTracked
{
    public Guid Id { get; set; }
    // Inherited: CreatedAt, UserCreatedId, UpdatedAt, UserUpdatedId
}
```

Automatically set on:
- **Create**: `UserCreatedId`, `UserUpdatedId` = current user
- **Update**: `UserUpdatedId` = current user, `UpdatedAt` = now

### Pagination

All list endpoints use `PagedApiResponse<T>`:

```csharp
var result = await PagedApiResponse<UserResponse>.GetFromSql(
    _context,
    selectSql,
    parameters,
    requestParams
);
```

Response:
```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "totalRows": 100,
    "totalPages": 5
  }
}
```

## Request Pipeline

```
Request
   │
   ▼
Developer Exception Page (dev)
   │
   ▼
Exception Handler (/error)
   │
   ▼
Routing
   │
   ▼
CORS (allow any)
   │
   ▼
Authentication (JWT validation)
   │
   ▼
Authorization (policy check)
   │
   ▼
Permission Level Middleware
   │  - Extract organization-id header
   │  - Extract user ID from JWT
   │  - Store in HttpContext.Items
   │
   ▼
Controllers
   │
   ▼
Response
```

## Service Layer

### Pattern

```
Controller → Service → Repository (EF Core/Dapper)
```

### Dependency Injection

All services registered as **Scoped** (per-request):

```csharp
services.AddScoped<UserService>();
services.AddScoped<ReferralService>();
// etc.
```

### Database Access

**EF Core** for:
- Simple CRUD operations
- Entity tracking
- Migrations

**Dapper** for:
- Complex queries
- Reporting
- Performance-critical reads

## Error Handling

### Custom Exceptions

```csharp
throw new NotFoundException("User not found");
throw new BadRequestException("Invalid input");
throw new UnauthorizedException("Not authenticated");
throw new ForbiddenException("Access denied");
throw new ConflictException("Already exists");
```

### Error Response

```json
{
  "errorMessage": "User not found"
}
```

### HTTP Status Mapping

| Exception | HTTP Status |
|-----------|-------------|
| `BadRequestException` | 400 |
| `UnauthorizedException` | 401 |
| `ForbiddenException` | 403 |
| `NotFoundException` | 404 |
| `ConflictException` | 409 |

## Key Domain Entities

```
Organization (1) ─────┬───── (N) User
                      │
                      ├───── (N) Beneficiary
                      │
                      ├───── (N) Referral
                      │            │
                      │            └───── (N) Discussion
                      │
                      ├───── (N) List (uploaded datasets)
                      │
                      ├───── (N) Booking
                      │
                      └───── (N) Template

Settings ────── Deployment-wide configuration (single record)

BeneficiaryAttribute ────── Field definitions for deduplication
```

## File Storage

Files stored locally or on external storage:
- Path: `STORAGE_PATH` environment variable
- URL: `STORAGE_URL` environment variable
- Supports image resizing
- File metadata in `Files` table
