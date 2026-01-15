# Users Module

## Purpose

Admin module for managing user accounts within the organization. Allows creating users, assigning roles, and managing permissions.

## Route

`/users` and `/users/:id`

## Structure

```
Users/
├── UsersPage/
│   ├── UsersPage.tsx                  # User list
│   ├── columns.tsx                    # DataTable columns
│   └── components/
│       └── AddUserModal/
│           └── AddUserModal.tsx       # Create user modal
├── UserPage/
│   ├── UserPage.tsx                   # Edit user
│   ├── const.ts                       # Default form values
│   ├── form-transformation.ts         # Data transformations
│   └── validations.ts                 # Zod schema
├── UsersProvider.tsx                  # Context provider
└── index.ts                           # Public exports
```

## Pages

### UsersPage

Paginated list of organization users:

**Features:**
- DataTable with sorting, pagination, search
- "Add User" modal in header
- Click-through to edit user
- Delete with confirmation dialog
- Filters by role (`admin|user` only, excludes superadmin)

**Columns:**
| Column | Description |
|--------|-------------|
| First Name | User first name |
| Last Name | User last name |
| Email | User email address |
| Role | Admin or User |
| Created At | Account creation date |
| Actions | Edit/Delete buttons |

### UserPage

Form for editing user details and permissions:

**Sections:**

1. **Basic Information**
   - First Name (required)
   - Last Name (required)
   - Email (read-only)

2. **Permissions** (only for User role)
   - Deduplication checkbox
   - Referrals checkbox

3. **Password**
   - New Password
   - Confirm Password

## Components

### AddUserModal

Modal for inviting new users:

**Fields:**
- Email address
- First Name
- Last Name
- Role selection (Admin/User)
- Initial permissions (for User role)

**Flow:**
1. Admin fills user details
2. System sends invitation email
3. User sets password via email link
4. User activates account

## Services Used

- `useUsers` - Fetch paginated user list
- `useUser` - Fetch single user
- `useUserMutation` - CRUD operations
  - `patchUser` - Update user details
  - `deleteUser` - Remove user

## Permission Management

**User Role Permissions:**
| Permission | Description |
|------------|-------------|
| `deduplication` | Access to deduplication features |
| `referral` | Access to referral features |

**Admin Role:**
- Full access to all features
- No permission checkboxes shown

**Implementation:**
```typescript
const onPermissionClick = (permission: string) => {
  if (currentFormPermissions?.includes(permission)) {
    // Remove permission
    setValue('permissions', currentFormPermissions.filter(i => i !== permission));
  } else {
    // Add permission
    setValue('permissions', [...currentFormPermissions, permission]);
  }
};
```

## Form Validation

**Schema:** `UserEditFormSchema` with Zod

**Fields:**
- firstName: Required string
- lastName: Required string
- email: Email format (read-only)
- password: Optional, min 6 chars if provided
- confirmPassword: Must match password

## Toast Notifications

| Event | Type | Message |
|-------|------|---------|
| Update success | Success | "User successfully updated." |
| Delete success | Success | "User successfully deleted!" |
| Error | Destructive | API error message |

## Breadcrumbs

**List:** `Users → Current page`
**Edit:** `Users → {firstName} {lastName}`

## Permission

Admin only.
