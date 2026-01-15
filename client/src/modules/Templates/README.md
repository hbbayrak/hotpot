# Templates Module

## Purpose

Manages Excel column mapping templates for data imports. Templates define how Excel columns map to system beneficiary attributes during deduplication uploads.

## Route

`/templates` and `/templates/:id`

## Structure

```
Templates/
├── TemplatesPage/
│   ├── TemplatesPage.tsx              # Template list
│   ├── columns.tsx                     # DataTable columns
│   └── components/
│       └── CreateTemplateModal/
│           └── CreateTemplateModal.tsx # Create template modal
├── TemplatePage/
│   ├── TemplatePage.tsx               # Edit template
│   ├── const.ts                       # Default form values
│   └── form-transformation.ts         # Data transformations
├── const.ts                           # Standardized field definitions
├── validation.ts                      # Zod schema
├── TemplatesProvider.tsx              # Context provider
└── index.ts                           # Public exports
```

## Pages

### TemplatesPage

Paginated list of column mapping templates:

**Features:**
- DataTable with sorting, pagination, search
- "Create Template" modal in header
- Click-through to edit template
- Delete with confirmation dialog

**Columns:**
| Column | Description |
|--------|-------------|
| Name | Template name |
| Created At | Creation timestamp |
| Actions | Edit/Delete buttons |

### TemplatePage

Form for editing template column mappings:

**Layout:**
- Template name input
- Two-column mapping table:
  - Left: Standard field name (with type)
  - Right: Your Excel column label

**Standard Fields:**
From `STANDARDIZED_TEMPLATE_FIELDS` constant:

| Field | Type |
|-------|------|
| firstName | string |
| familyName | string |
| dateOfBirth | date |
| gender | string |
| govIdType | string |
| govIdNumber | string |
| otherIdType | string |
| otherIdNumber | string |
| mobilePhoneId | string |
| hhId | string |
| adminLevel1 | string |
| adminLevel2 | string |
| adminLevel3 | string |
| adminLevel4 | string |
| activity | string |
| currency | string |
| currencyAmount | number |
| startDate | date |
| endDate | date |
| frequency | string |
| status | string |
| assistanceDetails | string |

## Components

### CreateTemplateModal

Modal for creating a new template:

**Fields:**
- Template name

### TemplatesProvider

React context providing shared pagination state.

## Services Used

- `useTemplates` - Fetch templates list
- `useTemplate` - Fetch single template
- `useTemplateMutation` - CRUD operations
  - `editTemplate` - Update template
  - `deleteTemplate` - Remove template

## Form Schema

```typescript
const TemplateFormSchema = z.object({
  name: z.string().min(1, 'Template name is required'),
  firstName: z.string().optional(),
  familyName: z.string().optional(),
  // ... all standard fields as optional strings
});
```

## Usage Flow

1. **Create Template** - Name only required initially
2. **Edit Template** - Map Excel column names to standard fields
3. **Use Template** - Select during deduplication upload
4. **System Mapping** - System uses mapping to parse Excel data

## Example Mapping

| Standard Field | Your Column Label |
|----------------|-------------------|
| firstName | `First Name` |
| familyName | `Surname` |
| dateOfBirth | `DOB` |
| govIdNumber | `Tax ID` |

## Toast Notifications

| Event | Type | Message |
|-------|------|---------|
| Update success | Success | "Template successfully updated." |
| Delete success | Success | "Template successfully deleted!" |
| Error | Destructive | API error message |

## Permission

Available to users with `deduplication` permission.
