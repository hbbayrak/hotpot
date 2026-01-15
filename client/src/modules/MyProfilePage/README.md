# MyProfilePage Module

## Purpose

User profile management page allowing users to view and update their account information. Admins have additional data management capabilities.

## Route

`/my-profile`

## Structure

```
MyProfilePage/
├── MyProfilePage.tsx                    # Main profile page
├── components/
│   ├── MyProfileForm/
│   │   └── MyProfileForm.tsx           # Account info form
│   └── WipeDataDialog/
│       └── WipeDataDialog.tsx          # Admin data wipe modal
└── index.ts                            # Public exports
```

## Page Features

### MyProfilePage

Profile management with role-based features:

**Layout:**
- Card with "Account Information" header
- Form for editing profile details
- Data wipe button (Admin only)

**Role-based Header:**
| Role | Header Node |
|------|-------------|
| Admin | WipeDataDialog button |
| User | None |

## Components

### MyProfileForm

Form for editing user profile information:

**Fields:**
- First Name
- Last Name
- Email (read-only)
- Password
- Confirm Password

**Validation:**
- React Hook Form with Zod schema
- Password confirmation matching

### WipeDataDialog

Admin-only dialog for wiping organization data:

**Features:**
- Confirmation dialog
- Destructive action warning
- Wipes beneficiary/deduplication data

## Services Used

- `useUserMe` - Fetch current user profile
- `useUserMutation` - Update user profile

## State Management

```typescript
const { user: { role } } = useAuth();
const { data: userProfileData, isLoading } = useUserMe({ queryEnabled: true });
```

## Loading State

Shows page loading indicator while fetching user profile.

## Breadcrumbs

```
My Profile → Current page
```

## Access

Available to all authenticated users. Wipe data feature requires Admin role.
