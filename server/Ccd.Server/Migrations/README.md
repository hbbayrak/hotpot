# Migrations

Entity Framework Core database migrations for the CCD platform.

## Overview

- **Total migrations**: 105+
- **Database**: PostgreSQL
- **Date range**: March 2024 - Present
- **Auto-run**: Pending migrations apply automatically on server startup

## Creating a Migration

Use the provided script:

```bash
cd server/Ccd.Server
./create-migration.sh AddNewFeature
```

This runs:
```bash
dotnet ef migrations add $1 --verbose --context=CcdContext && dotnet ef database update
```

The script:
1. Creates a new migration with timestamp prefix
2. Automatically applies it to the database

## Naming Convention

Format: `YYYYMMDDHHmmss_DescriptiveName`

**Examples:**
- `20240330175522_InitialMigration`
- `20240422065010_AddReferrals`
- `20241120100735_AddAdminLevelsToBeneficiary`
- `20260114083412_AddBookingLog`

**Best practices:**
- Use PascalCase for the descriptive name
- Start with a verb: `Add`, `Remove`, `Rename`, `Update`, `Fix`
- Be specific: `AddBookingLog` not `UpdateBookings`

## Migration Files

Each migration creates two files:

```
Migrations/
├── 20260114083412_AddBookingLog.cs           # Migration logic (Up/Down methods)
├── 20260114083412_AddBookingLog.Designer.cs  # Generated metadata
└── CcdContextModelSnapshot.cs                # Current model state
```

## PostgreSQL Conventions

Migrations follow these conventions (handled by `DbFormatter`):

| Convention | Example |
|------------|---------|
| Table names | `snake_case`, singular: `user`, `referral` |
| Column names | `snake_case`: `created_at`, `user_id` |
| Primary keys | `pk_tablename` |
| Foreign keys | `fk_tablename_columnname` |
| Indexes | `ix_tablename_columnname` |

## Common Patterns

### Adding a New Table

```csharp
migrationBuilder.CreateTable(
    name: "booking_log",
    columns: table => new
    {
        id = table.Column<Guid>(type: "uuid", nullable: false),
        household_id = table.Column<string>(type: "text", nullable: true),
        created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false,
            defaultValueSql: "current_timestamp"),
        // ... more columns
    },
    constraints: table =>
    {
        table.PrimaryKey("pk_booking_log", x => x.id);
        table.ForeignKey(
            name: "fk_booking_log_user_uploaded_by_id",
            column: x => x.uploaded_by_id,
            principalTable: "user",
            principalColumn: "id",
            onDelete: ReferentialAction.Restrict);
    });
```

### Adding a Column

```csharp
migrationBuilder.AddColumn<string>(
    name: "modality",
    table: "booking",
    type: "text",
    nullable: true);
```

### Adding an Index

```csharp
migrationBuilder.CreateIndex(
    name: "ix_booking_log_uploaded_by_id",
    table: "booking_log",
    column: "uploaded_by_id");
```

## Auto-Migration on Startup

In `Startup.cs`:

```csharp
if (ccdContext.Database.GetPendingMigrations().Any())
{
    Console.WriteLine("Applying DB migrations");
    ccdContext.Database.Migrate();
}
```

## Manual Commands

```bash
# List pending migrations
dotnet ef migrations list --context=CcdContext

# Apply all pending migrations
dotnet ef database update --context=CcdContext

# Revert to a specific migration
dotnet ef database update MigrationName --context=CcdContext

# Generate SQL script (for production)
dotnet ef migrations script --context=CcdContext -o migration.sql
```

## Troubleshooting

### Migration failed to apply

1. Check the error message in server logs
2. Verify database connection
3. Try manual apply: `dotnet ef database update --verbose`

### Need to fix a migration

**If not yet committed/shared:**
```bash
# Remove last migration
dotnet ef migrations remove --context=CcdContext

# Make changes to entity
# Create new migration
./create-migration.sh FixedMigrationName
```

**If already in production:**
- Create a new migration to fix the issue
- Never modify existing migrations that have been applied

### Conflicting migrations

If multiple developers create migrations simultaneously:
1. Pull latest changes
2. Remove your local migration: `dotnet ef migrations remove`
3. Recreate with latest snapshot: `./create-migration.sh YourFeature`

## Notes

- Always test migrations locally before deploying
- Migrations are applied in timestamp order
- The `CcdContextModelSnapshot.cs` represents the current expected database state
- Cascade delete is disabled by default (uses `ReferentialAction.Restrict`)
