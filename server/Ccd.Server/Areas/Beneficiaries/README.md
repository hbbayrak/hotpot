# Beneficiaries Area

## Purpose

Manages individual beneficiary records - people receiving humanitarian aid. Handles beneficiary CRUD operations and duplicate status management.

## Route

`/api/v1/beneficiaries`

## Controller

### BeneficiaryController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | Get paginated list of beneficiaries for organization |
| GET | `/{id}` | User | Get single beneficiary with duplicates |
| PATCH | `/{id}/status` | User | Update beneficiary duplicate status |
| DELETE | `/{id}` | User | Delete beneficiary |

## Services

### BeneficaryService

- `GetBeneficiariesApi()` - Paginated list filtered by organization
- `GetBeneficiaryApi()` - Single beneficiary with uploader info and duplicate references
- `GetBeneficiary()` - Raw entity lookup
- `PatchBeneficiaryStatus()` - Update duplicate status
- `DeleteBeneficiary()` - Remove beneficiary record
- `GetDuplicates()` - Resolve duplicate beneficiary references with organization and point of contact info

## Models

### Beneficary

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| FirstName, FamilyName | string | Name fields |
| Gender | string | Gender |
| DateOfBirth | string | Date of birth |
| AdminLevel1-4 | string | Administrative region names |
| GovIdType, GovIdNumber | string | Government ID |
| OtherIdType, OtherIdNumber | string | Alternative ID |
| AssistanceDetails | string | Assistance information |
| Activity, Currency, CurrencyAmount | string | Assistance details |
| StartDate, EndDate, Frequency | string | Assistance timing |
| IsPrimary | bool | Primary record indicator |
| MatchedFields | List<string> | Fields that matched during deduplication (JSONB) |
| DuplicateOfIds | List<Guid> | References to duplicate records (JSONB) |
| Status | string | Duplicate status |
| OrganizationId | Guid | Owning organization |
| ListId | Guid | Source upload list |
| UploadedById | Guid? | User who uploaded |

### BeneficaryStatus

Constants for duplicate status:
- `NotDuplicate`
- `AcceptedDuplicate`
- `RejectedDuplicate`

## Notes

- All queries are organization-scoped
- Duplicates are resolved with organization info and point of contact
- Uses JSONB columns for matched fields and duplicate IDs
