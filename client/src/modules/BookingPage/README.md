# BookingPage Module

## Purpose

Provides a wizard-based interface for creating beneficiary booking records. Allows organizations to upload beneficiary data via Excel files using predefined templates.

## Route

`/booking`

## Structure

```
BookingPage/
├── BookingPage.tsx           # Main booking wizard page
├── components/
│   └── DeduplicationWizard/  # Multi-step wizard component
└── index.ts                  # Public exports
```

## Page Features

### BookingPage

Entry point for the booking process with:

**Header Actions:**
- Download template dropdown with two options:
  - Empty template (`/booking-empty-upload-template.xlsx`)
  - Template with readme (`/booking-template-with-readme.xlsx`)

**Main Content:**
- Launches `DeduplicationWizard` component for step-by-step booking creation

## Template Downloads

| Template | File | Description |
|----------|------|-------------|
| Empty Template | `booking-empty-upload-template.xlsx` | Blank Excel file with proper column headers |
| With Readme | `booking-template-with-readme.xlsx` | Includes instructions and field descriptions |

## Wizard Flow

The booking process uses the shared `DeduplicationWizard` component which guides users through:

1. **File Upload** - Upload Excel file with beneficiary data
2. **Column Mapping** - Match Excel columns to system fields
3. **Validation** - Review data validation results
4. **Confirmation** - Finalize booking creation

## Components

### DeduplicationWizard

Multi-step wizard handling:
- File upload via drag-and-drop
- Template selection
- Column mapping interface
- Data preview and validation
- Submission handling

## Services Used

- Deduplication service for booking creation
- Template service for column mappings

## Breadcrumbs

```
Booking → Current page
```

## Permission

Requires `booking` permission.
