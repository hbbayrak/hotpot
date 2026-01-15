# DeduplicationPage Module

## Purpose

Main deduplication workflow page that allows users to upload beneficiary data, detect duplicates, and manage deduplication listings. Provides both a wizard interface for new uploads and a table view of existing listings.

## Route

`/deduplication`

## Structure

```
DeduplicationPage/
├── DeduplicationPage.tsx                    # Main page with wizard and listings
├── components/
│   ├── DeduplicationWizard/                # Multi-step upload wizard
│   │   ├── DeduplicationWizard.tsx
│   │   ├── DeduplicationWizardContainer.tsx
│   │   ├── Steps/                          # Individual wizard steps
│   │   └── validations.ts
│   └── ListingsTable/                      # Existing listings display
│       ├── ListingsTable.tsx
│       └── columns.tsx
├── DeduplicationProvider.tsx               # Context provider
└── index.ts                                # Public exports
```

## Page Features

### DeduplicationPage

Combines wizard and listings table:

**Layout:**
- DeduplicationWizard on left/top
- ListingsTable on right/bottom

## Components

### DeduplicationWizard

Multi-step wizard for uploading and processing beneficiary data:

**Steps:**
1. **Upload** - Select Excel file via drag-and-drop
2. **Template Selection** - Choose column mapping template
3. **Column Mapping** - Map Excel columns to beneficiary attributes
4. **Preview** - Review data before processing
5. **Results** - View deduplication results

**Features:**
- File validation
- Progress tracking
- Error handling with toast notifications

### ListingsTable

DataTable showing existing deduplication listings:

| Column | Description |
|--------|-------------|
| Name | Listing/file name |
| Status | Processing status |
| Created At | Upload timestamp |
| Updated At | Last modification |
| Actions | View/delete options |

**Features:**
- Pagination
- Sorting
- Search
- Click-through to detailed view

### DeduplicationProvider

React context providing:
- Shared state between wizard and listings
- Pagination context
- Refresh triggers

## Services Used

- `useDeduplicationListings` - Fetch existing listings
- `useDeduplicationMutation` - Create/delete listings
- `useTemplates` - Get column mapping templates

## State Management

```typescript
// Provider state
const { pagination, refreshListings } = useDeduplicationProvider();
```

## Filters

ListingsTable supports filtering by:
- Status
- Date range
- Search text

## Permission

Requires `deduplication` permission.
