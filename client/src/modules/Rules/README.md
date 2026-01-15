# Rules Module

## Purpose

Admin module for managing deduplication rules. Rules define which beneficiary fields are used to detect potential duplicates during data uploads.

## Route

`/rules`

## Structure

```
Rules/
├── RulesPage/
│   ├── RulesPage.tsx                    # Main rules list
│   └── components/
│       ├── RuleModal/
│       │   ├── RuleModal.tsx            # Create/edit rule modal
│       │   └── columns.tsx              # Attribute selection columns
│       └── RulesInformationBox.tsx      # Help information
├── RulesProvider.tsx                    # Context provider
└── index.ts                             # Public exports
```

## Page Features

### RulesPage

Drag-and-drop reorderable list of deduplication rules:

**Features:**
- Drag-and-drop reordering via `react-beautiful-dnd`
- Create new rules via modal
- Edit existing rules
- Delete rules with confirmation
- Visual status indicators

**Table Columns:**
| Column | Description |
|--------|-------------|
| Name | Rule name |
| Status | Active/Inactive badge |
| Fuzzy Matching | Enabled/Disabled badge |
| Created On | Creation date |
| Updated On | Last modification |
| Actions | Edit/Delete buttons |

**Drag and Drop:**
- Rules can be reordered by dragging
- Order determines priority in duplicate detection
- Optimistic update with API sync

## Components

### RuleModal

Modal for creating or editing rules:

**Fields:**
- Name (required)
- Active status toggle
- Fuzzy matching toggle
- Attribute selection (multi-select)

**Modes:**
| Mode | Trigger |
|------|---------|
| Create | "New Rule" button |
| Edit | Edit icon on rule row |

### RulesInformationBox

Informational component explaining how rules work (currently commented out).

## Services Used

- `useAttributeGroups` - Fetch rules list
- `useAttributeGroupsMutation` - CRUD operations
  - `removeAttributeGroup` - Delete rule
  - `reorderAttributeGroups` - Update rule order

## State Management

```typescript
const { pagination } = useRulesProvider();
```

## Drag and Drop Implementation

Uses `react-beautiful-dnd` with:
- `DragDropContext` - Root context
- `StrictModeDroppable` - Drop zone (React 18 compatible)
- `Draggable` - Individual draggable items

**Order Update Flow:**
1. User drags rule to new position
2. Optimistic UI update via `queryClient.setQueriesData`
3. API call to persist new order
4. Toast notification on error

## Visual States

**Status Badge:**
| State | Color |
|-------|-------|
| Active | Primary (blue) |
| Inactive | Destructive (red) |

**Fuzzy Matching Badge:**
| State | Color |
|-------|-------|
| Enabled | Primary (blue) |
| Disabled | Destructive (red) |

## Permission

Admin only.
