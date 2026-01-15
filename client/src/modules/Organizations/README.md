# Organizations Module

## Purpose

Admin module for managing organizations registered on the platform. Allows creating, editing, and configuring organizations including their service offerings and activities.

## Route

`/organizations` and `/organizations/:id`

## Structure

```
Organizations/
├── OrganizationsPage/
│   ├── OrganizationsPage.tsx              # Organization list
│   ├── columns.tsx                        # DataTable columns
│   └── components/
│       └── AddOrganizationModal/
│           └── AddOrganizationModal.tsx   # Create org modal
├── OrganizationPage/
│   ├── OrganizationPage.tsx               # Edit organization
│   ├── const.ts                           # Default form values
│   ├── form-transformation.ts             # Data transformations
│   └── validations.ts                     # Zod schemas
├── components/
│   └── ServiceActivities/
│       └── ServiceActivities.tsx          # Service sub-activities
├── OrganizationsProvider.tsx              # Context provider
└── index.ts                               # Public exports
```

## Pages

### OrganizationsPage

Paginated list of all organizations:

**Features:**
- DataTable with sorting, pagination, search
- "Add Organization" modal in header
- Click-through to edit organization
- Delete with confirmation dialog

**Columns:**
| Column | Description |
|--------|-------------|
| Name | Organization name |
| Created At | Creation timestamp |
| Actions | Edit/Delete buttons |

### OrganizationPage

Form for editing organization details and services:

**Sections:**

1. **Basic Information**
   - Organization name (required)

2. **Services** - Toggle switches for available services:
   | Service | Field |
   |---------|-------|
   | MPCA | `isMpcaActive` |
   | WASH | `isWashActive` |
   | Shelter | `isShelterActive` |
   | Food Assistance | `isFoodAssistanceActive` |
   | Livelihoods | `isLivelihoodsActive` |
   | Protection | `isProtectionActive` |

3. **Service Activities** - Sub-activities for each enabled service

## Components

### AddOrganizationModal

Modal dialog for creating new organizations:
- Organization name input
- Initial service configuration

### ServiceActivities

Dynamic list of sub-activities for each service type:
- Add new activities
- Remove existing activities
- Activity title input
- Uses `useFieldArray` for dynamic list management

## Services Used

- `useOrganizations` - Fetch paginated organization list
- `useOrganization` - Fetch single organization
- `useOrganizationMutation` - CRUD operations
  - `editOrganization` - Update organization
  - `deleteOrganization` - Remove organization

## Form Handling

**Schema:** `OrganizationEditFormSchema` with Zod validation

**Fields:**
```typescript
{
  name: string;
  isMpcaActive: boolean;
  isWashActive: boolean;
  isShelterActive: boolean;
  isFoodAssistanceActive: boolean;
  isLivelihoodsActive: boolean;
  isProtectionActive: boolean;
  activities: Activity[];
}
```

## Toast Notifications

| Event | Type | Message |
|-------|------|---------|
| Update success | Success | "Organization successfully updated." |
| Delete success | Success | "Organisation successfully deleted!" |
| Error | Destructive | API error message |

## Permission

Admin only.
