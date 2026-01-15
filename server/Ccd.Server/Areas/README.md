# Areas

## Overview

The application is organized into feature-based Areas, each containing its own Controllers, Services, and Models. This follows the ASP.NET Core Areas pattern for modular organization.

## Areas Summary

| Area | Route | Purpose |
|------|-------|---------|
| [AdministrativeRegions](./AdministrativeRegions/README.md) | `/api/v1/admin-regions` | Hierarchical geographic regions (4 levels: Oblast, Rayon, Hromada, Settlement) |
| [Authentication](./Authentication/README.md) | `/api/v1/authentication` | JWT login, account activation, password reset |
| [Beneficiaries](./Beneficiaries/README.md) | `/api/v1/beneficiaries` | Beneficiary records and duplicate status management |
| [BeneficiaryAttributes](./BeneficiaryAttributes/README.md) | `/api/v1/beneficiary-attribute` | Configurable field definitions and groups for deduplication rules |
| [BeneficiaryData](./BeneficiaryData/README.md) | `/api/v1/beneficiary-data` | Public endpoint for beneficiaries to access their own data |
| [Deduplication](./Deduplication/README.md) | `/api/v1/deduplication` | Multi-step duplicate detection workflow and booking management |
| [Email](./Email/README.md) | - | Email composition and SendGrid integration (no controller) |
| [Handbook](./Handbook/README.md) | `/api/v1/handbooks` | Help documentation and user guides |
| [Notifications](./Notifications/README.md) | - | Notification infrastructure placeholder (no controller) |
| [Organizations](./Organizations/README.md) | `/api/v1/organizations` | Multi-tenant organization management with activities |
| [Referrals](./Referrals/README.md) | `/api/v1/referrals` | Inter-organization beneficiary referral workflow |
| [Settings](./Settings/README.md) | `/api/v1/settings` | Global deployment configuration (superadmin only) |
| [Storage](./Storage/README.md) | `/storage`, `/api/v1/storage` | File upload, storage, and retrieval with image resizing |
| [Templates](./Templates/README.md) | `/api/v1/templates` | Excel column mapping templates for imports |
| [Users](./Users/README.md) | `/api/v1/users` | User accounts, roles, permissions, organization membership |

## Area Structure

Each Area follows a consistent structure:

```
AreaName/
├── Controllers/
│   └── AreaNameController.cs
├── Services/
│   └── AreaNameService.cs
├── Models/
│   ├── EntityModel.cs
│   └── RequestResponse.cs      # DTOs
└── README.md
```

## Core Domain Areas

### Beneficiary Management
- **Beneficiaries** - Core beneficiary CRUD
- **BeneficiaryAttributes** - Dynamic field configuration
- **BeneficiaryData** - Public data access for recipients
- **Deduplication** - Duplicate detection and booking

### Inter-Organization Workflow
- **Referrals** - Transfer beneficiaries between organizations
- **Organizations** - Multi-tenant organization management

### User & Access
- **Users** - User management and permissions
- **Authentication** - Login and password management

### Configuration & Support
- **Settings** - Deployment-wide settings
- **Templates** - Import column mappings
- **Handbook** - User documentation
- **AdministrativeRegions** - Geographic hierarchy

### Infrastructure
- **Storage** - File management
- **Email** - Email services
- **Notifications** - Notification infrastructure

## Permission Levels

Most endpoints require authentication and use role-based access:

| Level | Access |
|-------|--------|
| `User` | All authenticated users |
| `Admin` | Organization administrators |
| `Superadmin` | SYSTEM_USER only (Settings) |
| `Public` | No authentication required |

## Key Patterns

1. **Organization-scoped queries** - Most data filtered by `OrganizationId` header
2. **Soft deletes** - Entities implement `IIsDeleted` interface
3. **User change tracking** - Entities inherit `UserChangeTracked` for audit trail
4. **Paginated responses** - Standard `PagedApiResponse<T>` with search/filter/sort
5. **AutoMapper DTOs** - Request/Response models mapped via AutoMapper
