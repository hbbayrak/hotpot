# AdministrativeRegions Area

## Purpose

Manages hierarchical geographic/administrative regions (e.g., Oblast, Rayon, Hromada, Settlement) used for location data in beneficiaries and referrals.

## Route

`/api/v1/admin-regions`

## Controller

### AdministrativeRegionController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | Get all regions with filtering by level, parentId, id, searchText |
| GET | `/{id}` | User | Get a single administrative region by ID |

**Query Parameters for GET `/`:**
- `level` (required): 1-4, represents the administrative hierarchy level
- `parentId`: Filter by parent region
- `id`: Filter by specific ID
- `searchText`: Search by name prefix

## Services

### AdministrativeRegionService

- `GetAdministrativeRegionsApi()` - Paginated list of regions with path resolution
- `GetAdministrativeRegionApi(id)` - Single region by ID
- `GetAdministrativeRegionByNameApi(name, level)` - Find region ID by name and level
- `BuildRegionPath()` - Recursively builds full path string (e.g., "Oblast > Rayon > Hromada")

## Models

### AdministrativeRegion

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| ParentId | Guid? | Parent region reference |
| Level | int | Hierarchy level (1-4) |
| Name | string | Region name |
| Code | string? | Optional region code |
| Path | string? | Full hierarchical path |

## Notes

- Uses raw SQL with Dapper for efficient querying
- Supports 4 levels of administrative hierarchy
- Path is computed dynamically by traversing parent references
