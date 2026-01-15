# Data Layer

## Purpose

Core data access infrastructure including the Entity Framework DbContext, Dapper type handlers, naming conventions, soft delete, and user change tracking.

## Files Overview

| File | Purpose |
|------|---------|
| `CcdContext.cs` | Main EF Core DbContext |
| `DbFormatter.cs` | Snake_case naming conventions |
| `SoftDelete.cs` | Soft delete interceptor |
| `UserChangeTracker.cs` | Audit trail for entity changes |
| `DbUserTrackingService.cs` | Current user resolution from HTTP context |
| `DapperDateTime.cs` | Dapper UTC DateTime handler |
| `DapperJson.cs` | Dapper JSONB column handler |
| `ExtensionMethods.cs` | String extension for snake_case |
| `IIsDeleted.cs` | Soft delete interface |

---

## CcdContext

Main Entity Framework Core DbContext for the application.

### DbSets

```csharp
DbSet<User> Users
DbSet<File> Files
DbSet<Organization> Organizations
DbSet<Activity> Activities
DbSet<UserOrganization> UserOrganizations
DbSet<Beneficary> Beneficaries
DbSet<BeneficaryDeduplication> BeneficaryDeduplications
DbSet<Booking> Bookings
DbSet<BookingLog> BookingLogs
DbSet<BeneficiaryAttribute> BeneficiaryAttributes
DbSet<BeneficiaryAttributeGroup> BeneficiaryAttributeGroups
DbSet<BaBag> BaBags
DbSet<List> Lists
DbSet<Referral> Referrals
DbSet<Discussion> Discussions
DbSet<Template> Templates
DbSet<Settings> Settings
DbSet<AdministrativeRegion> AdministrativeRegions
DbSet<Handbook> Handbooks
```

### Configuration (OnModelCreating)

1. **DbFormatter.SetDefaultValues** - Sets `current_timestamp` default for CreatedAt/UpdatedAt
2. **DbFormatter.FormatTableNames** - Converts table names to snake_case
3. **DbFormatter.FormatColumnsSnakeCase** - Converts column names to snake_case
4. **disableCascadeDeletes** - Changes cascade delete to restrict for all foreign keys
5. **seedData** - Seeds initial data (SYSTEM_USER, DEFAULT_SETTINGS, BeneficiaryAttributes)

### SaveChanges Override

Both `SaveChanges()` and `SaveChangesAsync()` are overridden to:
1. Process soft deletes via `SoftDelete.ProcessSoftDeletedItems()`
2. Process user change tracking via `UserChangeTracker.ProcessUserChangeTrackedItems()`

### Seeded Data

- **User.SYSTEM_USER** - Built-in superadmin account
- **Settings.DEFAULT_SETTINGS** - Default deployment configuration
- **BeneficiaryAttributes** - 21 predefined beneficiary field definitions (FirstName, FamilyName, Gender, etc.)

---

## DbFormatter

Handles PostgreSQL naming conventions and default values.

### Methods

| Method | Description |
|--------|-------------|
| `FormatColumnsSnakeCase(modelBuilder)` | Converts all column, key, foreign key, and index names to snake_case |
| `FormatTableNames(modelBuilder)` | Converts table names to singular snake_case |
| `SetDefaultValues(modelBuilder)` | Sets `current_timestamp` SQL default for CreatedAt/UpdatedAt columns |
| `FormatNumberOrQuotedString(value)` | Escapes values for JSONB filtering |

### Example Conversions

```
PascalCase → snake_case
CreatedAt  → created_at
UserId     → user_id
OrganizationReferredToId → organization_referred_to_id
```

---

## SoftDelete

Intercepts entity deletions and converts them to soft deletes.

### IIsDeleted Interface

```csharp
public interface IIsDeleted
{
    bool IsDeleted { get; set; }
}
```

### Behavior

When `SaveChanges()` is called:
1. Detects entities marked as `EntityState.Deleted`
2. If entity implements `IIsDeleted`:
   - Changes state to `EntityState.Unchanged`
   - Sets `IsDeleted = true`
3. Entity remains in database with `is_deleted = true`

### Usage

Implement `IIsDeleted` on any entity:

```csharp
public class User : IIsDeleted
{
    public bool IsDeleted { get; set; } = false;
}
```

---

## UserChangeTracker

Automatically tracks which user created/modified entities.

### UserChangeTracked Base Class

```csharp
public class UserChangeTracked
{
    public DateTime CreatedAt { get; set; }
    public Guid UserCreatedId { get; set; }
    public User UserCreated { get; set; }

    public DateTime UpdatedAt { get; set; }
    public Guid UserUpdatedId { get; set; }
    public User UserUpdated { get; set; }
}
```

### Behavior

When `SaveChanges()` is called:

**For Added entities:**
- Sets `UserCreatedId` to current user
- Sets `UserUpdatedId` to current user

**For Modified entities:**
- Sets `UserUpdatedId` to current user
- Sets `UpdatedAt` to `DateTime.UtcNow`

### Usage

Inherit from `UserChangeTracked`:

```csharp
public class Template : UserChangeTracked
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    // UserCreatedId, UserUpdatedId, CreatedAt, UpdatedAt automatically managed
}
```

---

## DbUserTrackingService

Resolves the current user ID from HTTP context for change tracking.

### GetCurrentUserId(fallbackUserId)

Resolution order:
1. If no HTTP context → use fallback or throw `UnauthorizedException`
2. If no claims → return `SYSTEM_USER.Id`
3. If group claim is "members" or auth method is "apiKey" → return `SYSTEM_USER.Id`
4. Parse user ID from `NameIdentifier` claim

---

## Dapper Type Handlers

Custom type handlers for Dapper (used alongside EF Core for raw SQL queries).

### DateTimeHandler

Ensures all DateTime values parsed from database are marked as UTC:

```csharp
public override DateTime Parse(object value)
{
    return DateTime.SpecifyKind((DateTime)value, DateTimeKind.Utc);
}
```

### JsonHandler<T>

Handles PostgreSQL JSONB columns:

- **Parse**: Deserializes JSON string to type T
- **SetValue**: Serializes to JSON string with `NpgsqlDbType.Jsonb`

Used for columns like:
- `List<string>` (e.g., FundingSources, Permissions)
- `List<Guid>` (e.g., DuplicateOfIds, FileIds)

---

## ExtensionMethods

### ToSnakeCase()

Converts PascalCase/camelCase strings to snake_case:

```csharp
"UserOrganization".ToSnakeCase() // → "user_organization"
"CreatedAt".ToSnakeCase()        // → "created_at"
"_privateField".ToSnakeCase()    // → "_private_field" (preserves leading underscores)
```

Uses regex: `([a-z0-9])([A-Z])` → `$1_$2`

---

## Database Conventions

| Convention | Description |
|------------|-------------|
| Table names | Singular, snake_case (e.g., `user`, `beneficary`, `user_organization`) |
| Column names | snake_case (e.g., `created_at`, `user_id`, `organization_referred_to_id`) |
| Primary keys | snake_case (e.g., `pk_user`) |
| Foreign keys | snake_case (e.g., `fk_referral_organization_created_id`) |
| Cascade delete | Disabled (uses `DeleteBehavior.Restrict`) |
| Timestamps | Auto-set via `current_timestamp` SQL default |
| Soft delete | Via `is_deleted` boolean column |

---

## Registration

In `Startup.cs`:

```csharp
services.AddDbContext<CcdContext>(options =>
    options.UseNpgsql(connectionString));

services.AddScoped<DbUserTrackingService>();

// Dapper handlers
SqlMapper.AddTypeHandler(new DateTimeHandler());
SqlMapper.AddTypeHandler(new JsonHandler<List<string>>());
SqlMapper.AddTypeHandler(new JsonHandler<List<Guid>>());
```
