# Templates Area

## Purpose

Manages column mapping templates for Excel file imports. Templates define how Excel columns map to beneficiary fields during deduplication.

## Route

`/api/v1/templates`

## Controller

### TemplateController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | Get all templates for organization |
| GET | `/{id}` | User | Get single template |
| POST | `/` | User | Create new template |
| PATCH | `/{id}` | User | Update template |
| DELETE | `/{id}` | User | Delete template |

## Services

### TemplateService

- `GetTemplatesApi(orgId, params)` - Paginated templates for organization
- `GetTemplateApi(orgId, id)` - Single template with creator info
- `GetTemplateById(orgId, id)` - Raw entity lookup
- `AddTemplate(orgId, model)` - Create template
- `UpdateTemplate(template)` - Update template
- `DeleteTemplate(template)` - Remove template

## Models

### Template

Defines Excel column name mappings for each beneficiary field:

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| Name | string | Template name |
| FirstName | string | Column name for first name |
| FamilyName | string | Column name for family name |
| Gender | string | Column name for gender |
| DateOfBirth | string | Column name for DOB |
| AdminLevel1-4 | string | Column names for admin regions |
| HHID | string | Column name for household ID |
| MobilePhoneID | string | Column name for mobile phone |
| GovIdType | string | Column name for gov ID type |
| GovIdNumber | string | Column name for gov ID number |
| OtherIdType | string | Column name for other ID type |
| OtherIdNumber | string | Column name for other ID number |
| AssistanceDetails | string | Column name for assistance details |
| Activity | string | Column name for activity |
| Currency | string | Column name for currency |
| CurrencyAmount | string | Column name for amount |
| StartDate | string | Column name for start date |
| EndDate | string | Column name for end date |
| Frequency | string | Column name for frequency |
| OrganizationId | Guid | Owning organization |

## Request Models

### TemplateAddRequest
All column mapping fields.

### TemplatePatchRequest
Optional fields for partial updates using `Patch()` method.

## Usage

Templates are used during deduplication:
1. User creates template mapping their Excel columns to system fields
2. During upload, system uses template to locate data in correct columns
3. Allows different organizations to use their own Excel formats

## Notes

- Organization-scoped (each org has own templates)
- Implements `UserChangeTracked` for audit trail
- Column names must exactly match Excel header row
- Used by `DeduplicationService.GetHeaderIndex()` to find column positions
