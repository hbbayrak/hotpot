# Users Area

## Purpose

Manages user accounts, roles, permissions, and organization membership. Supports the multi-tenant model where users belong to organizations with specific roles.

## Route

`/api/v1/users`

## Controller

### UserController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | Admin | Get all users (optionally filtered by organization) |
| GET | `/{id}` | Admin | Get single user |
| POST | `/` | Admin | Create new user |
| PUT | `/{id}` | Admin | Full update user |
| PATCH | `/{id}` | Admin | Partial update user |
| DELETE | `/{id}` | Admin | Delete user |
| GET | `/me` | User | Get current authenticated user |
| PUT | `/me` | User | Update current user's profile |
| GET | `/email` | Public | Check if email exists |

## Services

### UserService

**User CRUD:**
- `GetUserById(id)` - Get user by ID
- `GetUserByEmail(email)` - Get user by email
- `AddUser(user, password, orgId, adminId)` - Create user with invitation email
- `UpdateUser(user)` - Update user
- `DeleteUser(user)` - Remove user

**Organization Membership:**
- `SetOrganizationRole(userId, orgId, role, permissions)` - Assign user to organization
- `GetOrganizationRole(userId, orgId)` - Get user's role in organization
- `RemoveFromOrganization(user, orgId)` - Remove user from organization
- `GetOrganizationsForUser(userId)` - List user's organizations

**API Methods:**
- `GetUserApi(orgId, id, email)` - Get user DTO with organizations
- `GetUsersApi(orgId, params, permission)` - Paginated users with permission filter

## Models

### User

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| Email | string | Login email (unique, searchable) |
| Password | string | Hashed password |
| FirstName | string | First name (searchable) |
| LastName | string | Last name (searchable) |
| ActivationCode | string | Account activation code |
| PasswordResetCode | string | Password reset code |
| Language | string | Preferred language (default: "en") |
| ActivatedAt | DateTime? | Activation timestamp |
| IsDeleted | bool | Soft delete flag |

**SYSTEM_USER:** Built-in superadmin account with fixed ID.

### UserOrganization

Join table for user-organization membership:

| Property | Type | Description |
|----------|------|-------------|
| UserId | Guid | User reference |
| OrganizationId | Guid | Organization reference |
| Role | string | Role in organization |
| Permissions | List<string> | Specific permissions (JSONB) |

### UserRole

Role constants:
- `User` - Basic user access
- `Admin` - Administrative access

### UserPermission

Permission constants:
- `ViewReferrals`
- `CreateReferrals`
- `EditReferrals`
- `DeleteReferrals`
- `ViewUsers`
- `CreateUsers`
- `EditUsers`
- `DeleteUsers`

## Request Models

### UserAddRequest
- Email, Password, FirstName, LastName
- OrganizationId, Role, Permissions

### UserUpdateRequest / UserPatchRequest
- All user fields plus Role and Permissions

### UserUpdateMeRequest
- Self-update fields (FirstName, LastName, Password)

## Notes

- Passwords hashed using `AuthenticationHelper.HashPassword()`
- New users receive invitation email via SendGrid
- Users can belong to multiple organizations with different roles
- Soft delete via `IsDeleted` flag (implements `IIsDeleted`)
- Permission-based filtering in queries using JSONB `?` operator
