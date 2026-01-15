# BeneficiaryAttributes Area

## Purpose

Manages the configurable field definitions used for beneficiary data and deduplication rules. Allows admins to define which fields are used for duplicate matching and how they're grouped.

## Route

`/api/v1/beneficiary-attribute`

## Controller

### BeneficiaryAttributeController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | Admin | Get all beneficiary attributes |
| PATCH | `/{id}` | Admin | Update attribute (e.g., toggle deduplication usage) |
| GET | `/groups` | Admin | Get all attribute groups (paginated) |
| GET | `/groups/{id}` | Admin | Get single attribute group with its attributes |
| POST | `/groups` | Admin | Create new attribute group |
| PATCH | `/groups/{id}` | Admin | Update attribute group |
| DELETE | `/groups/{id}` | Admin | Delete attribute group |
| POST | `/groups/reorder` | Admin | Reorder attribute groups |

## Services

### BeneficiaryAttributeService

- `GetBeneficiaryAttributes()` - List all field definitions
- `GetBeneficiaryAttribute(id)` - Single attribute by ID
- `PatchBeneficiaryAttribute(id, model)` - Update attribute settings (e.g., UsedForDeduplication flag)

### BeneficiaryAttributeGroupService

- `GetBeneficiaryAttributeGroupsApi()` - Paginated groups with their attributes
- `GetBeneficiaryAttributeGroupApi(id)` - Single group with attributes
- `CreateBeneficiaryAttributeGroups()` - Create group with specified attributes
- `PatchBeneficiaryAttributeGroups()` - Update group name, active status, fuzzy match setting
- `DeleteBeneficiaryAttributeGroup()` - Remove group and reorder remaining
- `ReorderBeneficiaryAttributeGroups()` - Update group order positions

## Models

### BeneficiaryAttribute

| Property | Type | Description |
|----------|------|-------------|
| Id | int | Primary key |
| Name | string | Display name |
| AttributeName | string | Property name on Beneficiary model |
| Type | string | Field type |
| UsedForDeduplication | bool | Include in dedup matching |

### BeneficiaryAttributeGroup

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| Name | string | Group name |
| Order | int | Display order |
| IsActive | bool | Whether group is used for matching |
| UseFuzzyMatch | bool | Enable fuzzy string matching (85% threshold) |

### BaBag (Join Table)

Links attributes to groups (many-to-many relationship).

## Notes

- Groups define which fields must match together for duplicate detection
- Fuzzy matching uses FuzzySharp library with 85% similarity threshold
- Order property maintains UI display sequence
