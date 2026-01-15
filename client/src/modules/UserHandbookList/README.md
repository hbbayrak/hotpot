# UserHandbookList Module

## Purpose

Read-only view of handbook entries for regular users. Displays help documentation and user guides created by administrators.

## Route

`/handbook-list`

## Structure

```
UserHandbookList/
├── UserHandbookListPage.tsx           # Main page
├── components/
│   └── HandbookItem/
│       └── HandbookItem.tsx           # Individual handbook card
└── index.ts                           # Public exports
```

## Page Features

### UserHandbookListPage

Simple list of all published handbook entries:

**Features:**
- Fetches all handbooks (pageSize: 999)
- Sorted by creation date (ascending)
- Loading state indicator
- Card-based display

**Layout:**
```
Handbook
Handbook List
├── HandbookItem 1
├── HandbookItem 2
├── HandbookItem 3
└── ...
```

## Components

### HandbookItem

Individual handbook entry card displaying:
- Title
- Content (Markdown rendered)
- Expandable/collapsible sections

**Props:**
Receives full handbook object with `id`, `title`, `content`, etc.

## Services Used

- `useHandbooks` - Fetch all handbook entries
- `usePagination` - Pagination context (though fetching all)

## Pagination

Fetches all entries at once:
```typescript
const { data: handbooksData, isLoading } = useHandbooks({
  ...pagination,
  pageSize: 999,
  sortBy: 'createdAt',
  sortDirection: SortDirection.Asc,
});
```

## Styling

- Max width container (`max-w-[700px]`)
- Vertical card stack with gap
- Bottom padding for last item

## Breadcrumbs

```
Handbook → Current page
```

## Related Module

- **HandbookPage** - Admin module for creating/editing handbooks

## Access

Available to all authenticated users (User and Admin roles).
