# BeneficiaryList Module

## Purpose

Manages and displays potential duplicate beneficiaries detected during deduplication. Allows administrators to review, compare, and resolve duplicate records.

## Route

`/beneficiary-list` and `/beneficiary-list/:id`

## Structure

```
BeneficiaryList/
├── BeneficiaryListPage/
│   ├── BeneficiaryListPage.tsx    # Main list page with tabs
│   └── columns.tsx                 # DataTable column definitions
├── SingleBeneficiaryPage/
│   ├── SingleBeneficiaryPage.tsx  # Individual beneficiary detail view
│   └── DuplicateCard.tsx          # Duplicate comparison card
└── index.ts                        # Public exports
```

## Pages

### BeneficiaryListPage

Displays a paginated table of potential duplicate beneficiaries with two tabs:

| Tab | Filter | Description |
|-----|--------|-------------|
| **Unresolved** | `isPrimary=false, status=$null` | Duplicates awaiting review |
| **Resolved** | `isPrimary=false, status[not]=null` | Already processed duplicates |

**Features:**
- Tabbed interface (Unresolved/Resolved)
- Paginated DataTable with sorting
- Click-through to individual beneficiary details
- Dynamic column visibility based on tab

### SingleBeneficiaryPage

Detail view for managing a single potential duplicate:

**Features:**
- Displays beneficiary information
- Shows list of matched duplicate records via `DuplicateCard`
- Allows status resolution

## Components

### DuplicateCard

Card component displaying a potential duplicate match with:
- Beneficiary details (name, DOB, Tax ID, etc.)
- Organization that uploaded the record
- Matched fields highlighting
- Comparison functionality

## Services Used

- `useBeneficiaryList` - Fetches paginated beneficiary list with filters
- `usePagination` - Pagination state management

## State Management

Uses React Router for navigation and local state for:
- `beneficiaryFilters` - Current filter criteria
- `hiddenColumns` - Column visibility state per tab

## Column Definitions

Standard columns include:
- First Name
- Family Name
- Date of Birth
- Tax ID
- Status (shown only on Resolved tab)
- Organization

## Permission

Requires `deduplication` permission.
