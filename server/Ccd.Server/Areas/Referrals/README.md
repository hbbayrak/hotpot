# Referrals Area

## Purpose

Manages inter-organization beneficiary referrals. Allows organizations to refer beneficiaries to other organizations for services, track referral status, and communicate via discussions.

## Route

`/api/v1/referrals`

## Controller

### ReferralController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | Get sent referrals (or received with `?received=true`) |
| GET | `/{id}` | User | Get single referral with full details |
| GET | `/{caseNumber}/case-number` | Public | Lookup referral by case number |
| POST | `/` | User | Create new referral |
| PATCH | `/{id}` | User | Update referral |
| DELETE | `/{id}` | User | Delete referral |
| PATCH | `/{id}/withdraw` | User | Withdraw referral (returns to draft) |
| PATCH | `/{id}/reject` | User | Reject received referral |
| GET | `/{id}/discussions` | User | Get discussion thread |
| POST | `/{id}/discussions` | User | Add discussion message |
| GET | `/focal-point/users` | User | Get users for focal point assignment |
| POST | `/batch-create` | User | Batch create referrals from Excel |
| GET | `/export` | User | Export referrals to Excel |
| GET | `/template` | User | Download batch upload templates |

## Services

### ReferralService

**CRUD Operations:**
- `GetReferralsApi(orgId, params, received)` - List referrals (sent or received)
- `GetReferralApi(orgId, id)` - Single referral with resolved dependencies
- `GetReferralByCaseNumberApi(caseNumber)` - Public lookup
- `AddReferral(orgId, model)` - Create referral with case number
- `UpdateReferral(referral)` - Update referral
- `DeleteReferral(referral)` - Delete referral and discussions

**Discussions:**
- `GetDiscussionsApi(referralId)` - Get all discussion messages
- `GetDiscussionApi(id)` - Single discussion message
- `AddDiscussion(referralId, model)` - Add user message
- `AddDiscussionBot(referralId, model)` - Add system message (for status changes)

**Batch Operations:**
- `CreateBatchReferrals(orgId, userId, model)` - Process Excel upload with validation
- `GetUpdatedFieldText(model, referral)` - Generate change summary for discussions

### ExportService

- `ExportXls<T, TExport>(data)` - Export data to Excel format

### CsvMapper / BatchReferralsValidators

Helper classes for batch Excel processing and validation.

## Models

### Referral

Core referral entity with 50+ fields:

**Priority:** `IsUrgent`

**Receiving Organization:**
- `ServiceCategory`, `SubactivitiesIds`, `OrganizationReferredToId`, `FundingSource`

**MPCA Specific:**
- `DisplacementStatus`, `HouseholdSize`, `HouseholdMonthlyIncome`, `HouseholdsVulnerabilityCriteria`

**Beneficiary Data:**
- Personal: `FirstName`, `PatronymicName`, `Surname`, `DateOfBirth`, `Gender`, `TaxId`
- Location: `Address`, `AdministrativeRegion1-4Id`
- Contact: `Email`, `Phone`, `ContactPreference`, `Restrictions`, `Consent`

**Child/Minor:**
- `IsSeparated`, `Caregiver`, `RelationshipToChild`, `CaregiverEmail/Phone/ContactPreference`
- `IsCaregiverInformed`, `CaregiverExplanation`, `CaregiverNote`

**Internal:**
- `FocalPointId`, `Status`, `IsDraft`, `IsRejected`, `FileIds`, `CaseNumber`, `IsBatchUploaded`

### ReferralStatus

Status constants:
- `UnderReview`, `Delivered`, `InAssessment`, `Registered`

### Discussion

Discussion thread messages:
- `Id`, `ReferralId`, `UserCreatedId`, `Text`, `IsBot` (system message flag)

## Batch Upload Types

Defined in `BatchType`:
- `BeneficiariesWithMpca` - MPCA-specific fields
- `BeneficiaryMinors` - Child-specific fields

Different worksheet column mappings for each type.

## Notes

- Case numbers are auto-generated short GUIDs
- Withdrawn referrals return to draft status (not a separate status)
- Rejected flag is separate from status
- All status changes logged as bot discussions
- Supports file attachments via `FileIds`
- Administrative regions resolved for display
