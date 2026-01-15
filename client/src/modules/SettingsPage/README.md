# SettingsPage Module

## Purpose

Superadmin-only deployment configuration page. Allows system administrators to configure global platform settings that affect all organizations. Also handles **initial setup** for new deployments (creating first organization and admin user).

## Route

`/settings`

## Structure

```
SettingsPage/
├── SettingsPage.tsx    # Settings form
├── const.ts            # Default values, countries list
├── validations.ts      # Zod schema
├── components/
│   └── InitialSetupSection/  # First org/user creation
│       ├── InitialSetupSection.tsx
│       ├── validation.ts
│       └── index.ts
└── index.ts            # Public exports
```

## Page Features

### InitialSetupSection

Conditional component that appears **only when no organizations exist** in the system. Allows superadmin to bootstrap the platform by creating:

1. **First Organization** - Name and service toggles (MPCA, WASH, Shelter, etc.)
2. **First Admin User** - Name, email, password, and permissions

After initial setup is complete, this section hides automatically and ongoing org/user management happens via `/organizations` and `/users` pages.

**Implementation:**
- Uses `useHasOrganizations()` hook to check if setup is needed
- Creates organization first, then user linked to that org
- Shows success message after completion

### SettingsPage

Standalone settings form (not within standard layout):

**Access Control:**
- Redirects to `/sign-in` if not logged in
- Redirects to `/dashboard` if not superadmin
- Only accessible to SYSTEM_USER

**Layout:**
- Centered card design
- InitialSetupSection at top (conditional)
- Theme toggle in top-right corner
- "Back to Sign In" link (logout)

## Form Fields

| Field | Type | Description |
|-------|------|-------------|
| `deploymentName` | Text | Platform name (e.g., "CCD Data Portal") |
| `deploymentCountry` | Select | Country from predefined list |
| `adminLevel1Name` | Text | Label for admin level 1 (e.g., "Oblast") |
| `adminLevel2Name` | Text | Label for admin level 2 (e.g., "Rayon") |
| `adminLevel3Name` | Text | Label for admin level 3 (e.g., "Hromada") |
| `adminLevel4Name` | Text | Label for admin level 4 (e.g., "Settlement") |
| `metabaseUrl` | Text | Metabase dashboard iframe URL |
| `fundingSources` | Array | List of available funding sources |

## Funding Sources Management

Dynamic list with add/remove functionality:

**Add New Source:**
1. Enter name in input field
2. Click "Add" button
3. Validates uniqueness (case-insensitive)

**Remove Source:**
- Click trash icon on source tag

**Implementation:**
```typescript
const { fields, append, remove } = useFieldArray({
  name: 'fundingSources',
  control,
});
```

## Countries List

Predefined list in `COUNTRIES_LIST` constant with:
- Country name
- Country code

## Services Used

- `useSettings` - Fetch current settings
- `useSettingsMutation` - Update settings
  - `updateSettings` - Save changes

## Form Validation

**Schema:** `SettingsFormSchema` with Zod

All fields are optional strings except fundingSources which is an array.

## Loading State

Shows centered spinner while fetching settings.

## Toast Notifications

| Event | Type | Message |
|-------|------|---------|
| Save success | Success | "Settings successfully updated." |
| Save error | Destructive | API error message |

## Actions

| Button | Action |
|--------|--------|
| Save settings | Submit form |
| Back to Sign In | Logout user |
| Theme toggle | Switch light/dark mode |

## Permission

Superadmin (SYSTEM_USER) only.
