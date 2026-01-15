# Organizations Area

## Purpose

Manages organizations (humanitarian aid agencies) in the multi-tenant system. Each organization can have users, beneficiaries, referrals, and activities.

## Route

`/api/v1/organizations`

## Controller

### OrganizationController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | Get all organizations (paginated) |
| GET | `/{id}` | Admin | Get single organization with activities |
| POST | `/` | Admin | Create new organization |
| PUT | `/{id}` | Admin | Update organization |
| DELETE | `/{id}` | Admin | Delete organization |
| GET | `/me` | User | Get current user's organization |
| PUT | `/me` | User | Update current user's organization |

## Services

### OrganizationService

- `GetOrganizationsApi(requestParameters)` - Paginated list of all organizations
- `GetOrganizationApi(id)` - Single organization with activities
- `GetOrganizationById(id)` - Raw entity lookup
- `GetOrganizationByName(name)` - Lookup by name
- `AddOrganization(organization)` - Create organization
- `UpdateOrganization(organization)` - Update organization
- `DeleteOrganization(organization)` - Delete with cascading cleanup

**Activity Management:**
- `AddActivities(activities)` - Add activities to organization
- `UpdateActivities(activities)` - Update existing activities
- `DeleteActivities(activities)` - Remove activities
- `GetActivitiesToDelete(orgId, activitiesToKeep)` - Find activities to remove during update

**Cascade Delete:**
- Deletes users from organization (only if soft-deleted)
- Deletes referrals associated with organization
- Deletes activities

## Models

### Organization

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| Name | string | Organization name (searchable) |
| IsMpcaActive | bool | MPCA service enabled |
| IsWashActive | bool | WASH service enabled |
| IsShelterActive | bool | Shelter service enabled |
| IsFoodAssistanceActive | bool | Food assistance enabled |
| IsLivelihoodsActive | bool | Livelihoods service enabled |
| IsProtectionActive | bool | Protection service enabled |

### Activity

Sub-activities within an organization:

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| Title | string | Activity name |
| ServiceType | string | Service category (mpca, wash, shelter, etc.) |
| OrganizationId | Guid | Parent organization |

### ServiceType

Valid service type constants:
- `mpca`, `wash`, `shelter`, `foodAssistance`, `livelihoods`, `protection`

## Notes

- Organizations are the tenant unit for multi-tenancy
- Service type flags enable/disable different assistance categories
- Activities are sub-categories used in referral workflow
- Cannot delete organization with active (non-deleted) users
