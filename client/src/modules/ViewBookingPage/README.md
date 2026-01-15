# ViewBookingPage Module

## Purpose

Displays a paginated list of all booking records. Allows users to view and filter bookings created through the booking process.

## Route

`/view-booking`

## Structure

```
ViewBookingPage/
├── ViewBookingPage.tsx    # Main page
├── columns.tsx            # DataTable column definitions
└── index.ts               # Public exports
```

## Page Features

### ViewBookingPage

Paginated table of booking records:

**Header Actions:**
- Download template dropdown:
  - Empty template (`/booking-empty-upload-template.xlsx`)
  - Template with readme (`/booking-template-with-readme.xlsx`)

**Filters:**
| Filter | Options | Description |
|--------|---------|-------------|
| Filter by activity | Previous, Current, Upcoming | Booking timeline status |
| Filter by start and end date | Date range picker | Booking period dates |
| Filter by date of booking | Date range picker | Creation date |

## DataTable Columns

Standard columns defined in `columns.tsx`:
- Beneficiary name
- Activity type
- Start date
- End date
- Status
- Created at

## Services Used

- `useBookings` - Fetch paginated booking list with filters
- `usePagination` - Pagination state management

## Filter Implementation

```typescript
const [filters, setFilters] = useState<Record<string, string>>({});

const { data: bookings } = useBookings({
  ...pagination,
  filters: Object.fromEntries(
    Object.entries(filters).filter(([key]) => key !== 'activity')
  ),
  activity: filters['activity'] || '',
});
```

## Activity Filter

| Value | Description |
|-------|-------------|
| `previous` | Past bookings (ended) |
| `current` | Active bookings |
| `upcoming` | Future bookings |

## Date Filters

Two date range pickers:
1. **Start/End Date Filter** - Filters by booking period
   - `startDate[gt]` - After start date
   - `endDate[lt]` - Before end date

2. **Date of Booking Filter** - Filters by creation date
   - Uses default filter names

## Template Downloads

| Template | Path | Description |
|----------|------|-------------|
| Empty | `/booking-empty-upload-template.xlsx` | Blank upload template |
| With readme | `/booking-template-with-readme.xlsx` | Template with instructions |

## Breadcrumbs

```
View Bookings → Current page
```

## Permission

Requires `booking` permission.
