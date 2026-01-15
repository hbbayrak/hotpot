# Helpers

## Purpose

Utility classes, extensions, attributes, and infrastructure components used across the application.

## Files Overview

| Category | Files |
|----------|-------|
| **Authentication** | AuthenticationHelper, ApiKeyProvider, IHasPassword |
| **Authorization** | PermissionLevelAttribute, PermissionLevelMiddleware, ControllerBaseExtended |
| **API Response** | PagedApiResponse, RequestParameters, PatchRequest |
| **Configuration** | StaticConfiguration |
| **Exceptions** | CustomExceptions, ExceptionHandler |
| **JSON** | Json, CamelCaseStringEnumConverter |
| **Utilities** | IdProvider, GuidHelper, DateTimeProvider, EmailValidationHelper, Mod10Handler |
| **Attributes** | QuickSearchableAttribute, SortAsNumberAttribute |
| **Other** | CustomContent, HttpResponseMessageResult, StringList |

---

## Authentication

### AuthenticationHelper

JWT token generation and password hashing.

| Method | Description |
|--------|-------------|
| `GenerateToken(user, roles)` | Creates JWT with user ID, email, and organization roles |
| `HashPassword<T>(user, password)` | Hashes password using ASP.NET Identity's PasswordHasher |
| `VerifyPassword<T>(user, password)` | Verifies password against stored hash |

**JWT Claims:**
- `NameIdentifier` - User ID
- `Email` - User email
- `Role` - JSON-serialized organization roles dictionary

**Token expiration:** Configured via `AppSettingsExpirationDays`

### ApiKeyProvider

Implements `IApiKeyProvider` for API key authentication. Currently throws `UnauthorizedException` (placeholder).

### IHasPassword

Interface for entities with password field:
```csharp
public interface IHasPassword
{
    string Password { get; set; }
}
```

---

## Authorization

### PermissionLevelMiddleware

Extracts authentication data from requests and stores in `HttpContext.Items`:

| Item Key | Source | Description |
|----------|--------|-------------|
| `OrganizationId` | `organization-id` header | Current organization context |
| `UserId` | JWT `NameIdentifier` claim | Authenticated user ID |
| `OrganizationRoles` | JWT `Role` claim | JSON dictionary of org → role |

**Registration:**
```csharp
app.UsePermissionLevel();
```

### PermissionLevelAttribute

Action filter for role-based authorization on controller endpoints.

**Usage:**
```csharp
[HttpGet]
[PermissionLevel(UserRole.Admin)]
public async Task<ActionResult> AdminOnly() { }

[HttpGet]
[PermissionLevel(UserRole.User)]
public async Task<ActionResult> AllUsers() { }
```

**Role hierarchy:**
- `Admin` - Admin only
- `User` - Admin or User

**Special case:** SYSTEM_USER bypasses all role checks.

### ControllerBaseExtended

Base controller with helper properties extracted from `HttpContext.Items`:

| Property | Type | Description |
|----------|------|-------------|
| `OrganizationId` | Guid | Current organization (required) |
| `OrganizationIdOrNull` | Guid? | Current organization (nullable) |
| `Organization` | Organization | Full organization entity |
| `UserId` | Guid | Current user ID |
| `IsSuperAdmin` | bool | Is SYSTEM_USER |
| `IsUser` | bool | Is authenticated |
| `IsAdmin` | bool | Has admin role in current org |

---

## API Response

### PagedApiResponse<T>

Standard paginated API response with search, filter, and sort capabilities.

**Response Structure:**
```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "totalRows": 100,
    "totalPages": 5,
    "sortBy": "name",
    "sortDirection": "asc"
  }
}
```

**Usage:**
```csharp
var result = await PagedApiResponse<UserResponse>.GetFromSql(
    _context,
    selectSql,
    sqlParams,
    requestParameters,
    resolveDependencies
);
```

**Features:**
- Automatic search across `[QuickSearchable]` properties
- Filter parsing with operators: `[gt]`, `[lt]`, `[not]`, `[like]`, `[in]`, `[or]`, `[contains]`
- Special values: `$null`, `$notnull`
- Sort with `[SortAsNumber]` support for numeric string columns
- Pagination with configurable page size (default: 20)

### RequestParameters

Query parameters for paginated endpoints:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Page` | int | 1 | Current page number |
| `PageSize` | int | 20 | Items per page |
| `Search` | string | null | Quick search text |
| `SortBy` | string | null | Sort column |
| `SortDirection` | string | null | "asc" or "desc" |
| `Filter` | string | null | Comma-separated filters |

**Filter format:** `column=value,column[operator]=value`

**Examples:**
```
?filter=status=active,created_at[gt]=2024-01-01
?filter=name[like]=john,is_deleted[not]=true
?filter=id[in]=guid1|guid2|guid3
```

### PatchRequest

Base class for PATCH request models with auto-mapping of non-null properties:

```csharp
public class UserPatchRequest : PatchRequest
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
}

// Usage
model.Patch(existingUser); // Only updates non-null properties
```

---

## Configuration

### StaticConfiguration

Centralized access to environment variables and appsettings.json values.

| Property | Env Variable | Description |
|----------|--------------|-------------|
| `WebAppUrl` | `WEB_APP_URL` | Frontend URL |
| `DbConnectionString` | `DB_CONNECTION_STRING` | PostgreSQL connection |
| `AppSettingsSecret` | `JWT_SECRET_KEY` | JWT signing key |
| `AppSettingsExpirationDays` | `JWT_EXPIRATION_DAYS` | Token expiry |
| `SentryDsn` | `SENTRY_DSN` | Error tracking |
| `ApiKey` | `API_KEY` | API key for auth |
| `ApiUrl` | `API_URL` | API base URL |
| `StorageUrl` | `STORAGE_URL` | File storage URL |
| `StoragePath` | `STORAGE_PATH` | File storage path |
| `SendgridApiKey` | `SENDGRID_API_KEY` | SendGrid API key |
| `SendgridSenderEmail` | `SENDGRID_SENDER_EMAIL` | Email sender |
| `SendgridInvitationEmailTemplateId` | `SENDGRID_INVITATION_EMAIL_TEMPLATE_ID` | Invite template |
| `SendgridPasswordResetEmailTemplateId` | `SENDGRID_PASSWORD_RESET_EMAIL_TEMPLATE_ID` | Reset template |
| `SuperadminPassword` | `SUPERADMIN_PASSWORD` | System user password |

**Initialization:**
```csharp
StaticConfiguration.Initialize(configuration);
```

Validates required settings and throws if missing.

---

## Exceptions

### CustomExceptions

HTTP-mapped exception classes:

| Exception | HTTP Status | Default Message |
|-----------|-------------|-----------------|
| `BadRequestException` | 400 | "Bad request" |
| `UnauthorizedException` | 401 | "Unauthorized" |
| `ForbiddenException` | 403 | "Forbidden" |
| `NotFoundException` | 404 | "Not found" |
| `ConflictException` | 409 | "Conflict" |

### ExceptionHandler (ErrorsController)

Global exception handler that maps exceptions to HTTP responses:

```csharp
app.UseExceptionHandler("/error");
```

**Response format:**
```json
{
  "errorMessage": "Error description"
}
```

---

## JSON

### Json

Centralized JSON serialization with camelCase and number handling:

| Method | Description |
|--------|-------------|
| `Serialize(data)` | Object to JSON string |
| `Deserialize<T>(data)` | JSON string to typed object |
| `DeserializeRecursive(data)` | Nested object deserialization |
| `GetValue(dict, key)` | Safe dictionary value access |

**Options:**
- `PropertyNamingPolicy.CamelCase`
- `PropertyNameCaseInsensitive = true`
- `AllowReadingFromString` for numbers

### CamelCaseStringEnumConverter

JSON converter for enum serialization in camelCase format.

---

## Utilities

### IdProvider

Generates sequential GUIDs optimized for PostgreSQL using RT.Comb:

```csharp
public Guid Id { get; set; } = IdProvider.NewId();
```

### GuidHelper

Converts GUIDs to/from URL-safe short strings (22 characters):

```csharp
GuidHelper.ToShortString(guid)   // → "abcd1234_efgh5678-ij"
GuidHelper.FromShortString(str)  // → Guid
```

Used for case numbers in referrals.

### DateTimeProvider

Testable DateTime wrapper:

```csharp
// Production
var now = _dateTimeProvider.UtcNow;

// Testing
_dateTimeProvider.SetDateTime(fixedDate);
_dateTimeProvider.ResetDateTime();
```

### EmailValidationHelper

Email format validation using regex:

```csharp
EmailValidationHelper.IsValidEmail("test@example.com") // → true
```

Pattern: `^[\w-\.+]+@([\w-]+\.)+[\w-]{2,4}$`

### Mod10Handler

Luhn algorithm (Mod 10) checksum calculation:

```csharp
Mod10Handler.AddMod10Digit("12345") // → "123455"
```

---

## Attributes

### QuickSearchableAttribute

Marks properties for inclusion in quick search:

```csharp
public class User
{
    [QuickSearchable]
    public string Email { get; set; }

    [QuickSearchable]
    public string FirstName { get; set; }
}
```

Search queries automatically include marked columns plus `id`.

### SortAsNumberAttribute

Marks string columns that should sort numerically:

```csharp
[SortAsNumber]
public string CaseNumber { get; set; }
```

Pads with leading zeros for proper numeric ordering.

---

## Other

### CustomContent / CustomField / CustomFieldType

Dictionary wrapper and field definitions for custom/dynamic fields.

### HttpResponseMessageResult

IActionResult wrapper for HttpResponseMessage (proxy responses).

### StringList

Simple `List<string>` subclass for type clarity.

---

## Registration

In `Startup.cs`:

```csharp
// Configuration
StaticConfiguration.Initialize(Configuration);

// Middleware pipeline
app.UsePermissionLevel();
app.UseExceptionHandler("/error");

// Services
services.AddScoped<DateTimeProvider>();
```
