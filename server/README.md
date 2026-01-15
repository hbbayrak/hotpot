# Server

.NET 8 backend for the CCD Data Stewardship Platform.

## Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | .NET 8 |
| **ORM** | Entity Framework Core 8 |
| **Database** | PostgreSQL |
| **Raw SQL** | Dapper (alongside EF Core) |
| **Authentication** | JWT Bearer + API Key |
| **Email** | SendGrid |
| **API Docs** | Swagger/OpenAPI |

## Project Structure

```
Ccd.Server/
├── Areas/                  # Feature modules (15 areas)
│   ├── Authentication/     # JWT login, password reset
│   ├── Beneficiaries/      # Beneficiary CRUD
│   ├── Deduplication/      # Duplicate detection, bookings
│   ├── Referrals/          # Inter-org referral workflow
│   ├── Organizations/      # Multi-tenant org management
│   └── ...                 # See Areas/README.md
├── Data/                   # DbContext, soft delete, change tracking
├── Helpers/                # Auth, pagination, exceptions, utilities
├── Mappings/               # AutoMapper profiles
├── Migrations/             # EF Core migrations (105+)
├── Emails/                 # HTML email templates
├── Startup.cs              # Service registration, middleware
└── Program.cs              # Entry point
```

## Commands

```bash
# From server/ directory

# Run locally (port 5000)
cd Ccd.Server && dotnet run

# Build for production (Linux x64)
npm run build

# Run tests
npm run test

# Check C# formatting
npm run check-formatting

# Initial setup (tools, husky, csharpier)
npm run initial-setup
```

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Returns "Ccd API" |
| `/health` | Health check, returns "ok" |
| `/version` | Version from version.txt or "non-production" |
| `/swagger/ui` | Swagger API documentation |
| `/api/v1/*` | API endpoints |

## Services Registered

19 services registered in DI container:

**Domain Services:**
- `OrganizationService`, `UserService`, `AuthenticationService`
- `DeduplicationService`, `BookingService`
- `BeneficiaryAttributeService`, `BeneficiaryAttributeGroupService`
- `BeneficaryService`, `BeneficaryDataService`
- `ReferralService`, `ExportService`
- `TemplateService`, `HandbookService`, `SettingsService`
- `AdministrativeRegionService`

**Infrastructure Services:**
- `EmailManagerService`, `SendGridService`
- `IStorageService` → `StorageService`
- `INotificationService` → `NotificationService`

**Utilities:**
- `DbUserTrackingService`, `DateTimeProvider`

## Middleware Pipeline

Order (request flows top to bottom):

1. Developer Exception Page (dev only)
2. Exception Handler (`/error`)
3. Routing
4. CORS (allow any origin/method/header)
5. Authentication (JWT)
6. Authorization
7. Permission Level (custom middleware)
8. Endpoints
9. Controllers
10. Swagger

## Adding a New Area

1. Create folder structure:
   ```
   Areas/NewArea/
   ├── Controllers/
   │   └── NewAreaController.cs
   ├── Services/
   │   └── NewAreaService.cs
   └── Models/
       ├── NewEntity.cs
       └── NewEntityRequest.cs
   ```

2. Add DbSet to `Data/CcdContext.cs`:
   ```csharp
   public DbSet<NewEntity> NewEntities { get; set; }
   ```

3. Register service in `Startup.cs`:
   ```csharp
   services.AddScoped<NewAreaService>();
   ```

4. Add AutoMapper mappings in `Mappings/Mappings.cs`

5. Create migration:
   ```bash
   ./create-migration.sh AddNewEntity
   ```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_CONNECTION_STRING` | Yes | PostgreSQL connection string |
| `JWT_SECRET_KEY` | Yes | JWT signing key |
| `API_KEY` | Yes | API key for auth |
| `WEB_APP_URL` | No | Frontend URL |
| `API_URL` | No | API base URL |
| `STORAGE_URL` | No | File storage URL |
| `STORAGE_PATH` | No | File storage path |
| `SENDGRID_API_KEY` | No | SendGrid API key |
| `SENDGRID_SENDER_EMAIL` | No | Email sender address |
| `SENDGRID_INVITATION_EMAIL_TEMPLATE_ID` | No | Invitation template |
| `SENDGRID_PASSWORD_RESET_EMAIL_TEMPLATE_ID` | No | Password reset template |
| `SENTRY_DSN` | No | Sentry error tracking |
| `SUPERADMIN_PASSWORD` | No | System user password |

## Related Documentation

- [Areas Overview](./Ccd.Server/Areas/README.md)
- [Data Layer](./Ccd.Server/Data/README.md)
- [Helpers & Utilities](./Ccd.Server/Helpers/README.md)
- [AutoMapper Mappings](./Ccd.Server/Mappings/README.md)
- [EF Core Migrations](./Ccd.Server/Migrations/README.md)
- [Email Templates](./Ccd.Server/Emails/README.md)
