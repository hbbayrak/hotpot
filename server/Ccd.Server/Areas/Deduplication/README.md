# Deduplication Area

## Purpose

Core deduplication functionality - detects and manages duplicate beneficiary records. Handles both internal (within dataset/organization) and cross-organization duplicate detection. Also manages booking records for assistance scheduling.

## Route

`/api/v1/deduplication`

## Controller

### DeduplicationController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/listings` | User | Get all uploaded dataset listings for organization |
| DELETE | `/` | Admin | Delete all listings, beneficiaries, and bookings |
| POST | `/dataset` | User | Step 1: Dataset internal deduplication |
| POST | `/same-organization` | User | Step 2: Check against organization's existing records |
| POST | `/system-organizations` | User | Step 3: Check against all organizations |
| POST | `/finish` | User | Finalize and import deduplicated records |
| POST | `/booking/step-1` | User | Validate booking file and check internal duplicates |
| POST | `/booking/step-2` | User | Check against existing bookings and create records |
| GET | `/bookings` | User | Get all booking listings with activity filter |

## Services

### DeduplicationService

Handles the multi-step deduplication workflow:

1. **DatasetDeduplication** - Checks uploaded Excel file for internal duplicates using attribute groups
2. **SameOrganizationDeduplication** - Compares dataset against organization's existing beneficiaries
3. **SystemOrganizationsDeduplication** - Compares against all other organizations' beneficiaries
4. **FinishDeduplication** - Imports non-duplicate records into beneficiaries table, creates List record

**Key Methods:**
- `AreRecordsEqual()` - Compares records using attribute group rules with optional fuzzy matching (85% threshold)
- `GetHeaderIndex()` - Maps template column names to Excel positions (cached)

### BookingService

Handles booking file validation and creation:

1. **BookingDeduplicationStep1** - Validates row fields and checks for internal Excel duplicates
2. **BookingDeduplicationStep2** - Checks against existing database bookings, creates valid records

**Validation:**
- Required fields: HeadOfHouseholdId, Modality, Amount, Currency, StartDate, EndDate, Frequency
- Date overlap detection for existing bookings
- National ID uniqueness across both HouseholdId and SpouseId columns

## Models

### List

Represents an uploaded dataset:
- `FileName`, `Duplicates`, `UserCreatedId`, `OrganizationId`

### BeneficaryDeduplication

Temporary record during deduplication workflow:
- All beneficiary fields plus `IsOrganizationDuplicate`, `IsSystemDuplicate`, `MarkedForImport`

### Booking

Assistance booking record:
- `HouseholdId`, `SpouseId` - National IDs
- `Amount`, `Currency`, `Frequency`, `Modality`
- `StartDate`, `EndDate` - Assistance period
- `OrganizationId`, `UploadedById`, `FileId`

### BookingLog

Audit record for each booking attempt:
- Same fields as Booking plus `IsSuccess` flag

## Workflow

1. Upload Excel file with `POST /dataset` - marks internal duplicates
2. Call `POST /same-organization` - compares against org's existing data
3. Call `POST /system-organizations` - cross-org comparison
4. Review results, toggle `MarkedForImport` flags
5. Call `POST /finish` - creates Beneficiary records from approved entries

## Notes

- Uses ClosedXML for Excel processing
- FuzzySharp for fuzzy string matching
- Templates define column mappings for different Excel formats
- Deduplication records are cleaned up after 3 days
- Booking activity filter supports: "previous", "current", "upcoming"
