# HandbookPage Module

## Purpose

Admin module for managing handbook entries - help documentation and user guides displayed in the platform.

## Route

`/handbook`, `/handbook/:id`, and `/handbook/new`

## Structure

```
HandbookPage/
├── HandbookPage/
│   ├── HandbookPage.tsx        # List of handbook entries
│   └── columns.tsx             # DataTable column definitions
├── SingleHandbookPage/
│   └── SingleHandbookPage.tsx  # Create/edit handbook entry
├── HandbookProvider.tsx        # Context provider
└── index.ts                    # Public exports
```

## Pages

### HandbookPage

Paginated list of all handbook entries:

**Features:**
- DataTable with sorting, pagination, search
- "Create Handbook" button in header
- Click-through to edit individual entries
- Delete confirmation dialog

**Columns:**
| Column | Description |
|--------|-------------|
| Title | Entry title |
| Created At | Creation timestamp |
| Updated At | Last modification |
| Actions | Edit/Delete buttons |

### SingleHandbookPage

Form for creating or editing a handbook entry:

**Fields:**
- Title (required)
- Content (Markdown editor)

**Modes:**
- **Create** (`/handbook/new`) - New entry form
- **Edit** (`/handbook/:id`) - Edit existing entry

## Components

### HandbookProvider

React context providing shared pagination state:

```typescript
const { pagination } = useHandbookProvider();
```

## Services Used

- `useHandbooks` - Fetch paginated handbook list
- `useHandbookMutation` - Create, update, delete operations
  - `deleteHandbook` - Remove handbook entry

## Actions

| Action | Method | Description |
|--------|--------|-------------|
| Create | Navigate to `/handbook/new` | Create new entry |
| Edit | Click row → `/handbook/:id` | Edit existing entry |
| Delete | Click trash icon | Delete with confirmation |

## Toast Notifications

| Event | Type | Message |
|-------|------|---------|
| Delete success | Success | "Handbook successfully deleted!" |
| Delete error | Destructive | Error message from API |

## Permission

Admin only - not visible to regular users.

## Related Module

- **UserHandbookList** - Read-only view for regular users
