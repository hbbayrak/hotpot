# Modules

## Overview

Feature-based modules containing page components, forms, and related functionality. Each module represents a distinct feature area of the application.

## Module Summary

| Module | Route | Purpose | Permission |
|--------|-------|---------|------------|
| [BeneficiaryList](./BeneficiaryList/README.md) | `/beneficiary-list` | Manage potential duplicate beneficiaries | Deduplication |
| [BookingPage](./BookingPage/README.md) | `/booking` | Create beneficiary booking records | Booking |
| [DashboardPage](./DashboardPage/README.md) | `/dashboard` | Analytics dashboard (Metabase) | All users |
| [DeduplicationPage](./DeduplicationPage/README.md) | `/deduplication` | Upload and deduplicate datasets | Deduplication |
| [HandbookPage](./HandbookPage/README.md) | `/handbook` | Admin: manage handbook entries | Admin |
| [MyProfilePage](./MyProfilePage/README.md) | `/my-profile` | User profile management | All users |
| [NotFoundPage](./NotFoundPage/README.md) | `*` | 404 error page | All users |
| [Organizations](./Organizations/README.md) | `/organizations` | Admin: manage organizations | Admin |
| [Public](./Public/README.md) | Various | Sign-in, password reset, public data | Public |
| [ReceivedReferrals](./ReceivedReferrals/README.md) | `/received-referrals` | Manage incoming referrals | Referrals |
| [Rules](./Rules/README.md) | `/rules` | Admin: deduplication rules | Admin |
| [SentReferrals](./SentReferrals/README.md) | `/sent-referrals` | Manage outgoing referrals | Referrals |
| [SettingsPage](./SettingsPage/README.md) | `/settings` | Superadmin: deployment settings | Superadmin |
| [Templates](./Templates/README.md) | `/templates` | Manage Excel import templates | Deduplication |
| [UserHandbookList](./UserHandbookList/README.md) | `/handbook-list` | User: view handbook entries | All users |
| [Users](./Users/README.md) | `/users` | Admin: manage user accounts | Admin |
| [ViewBookingPage](./ViewBookingPage/README.md) | `/view-booking` | View booking records | Booking |

## Module Categories

### Core Functionality

- **Deduplication** - Upload beneficiary data, detect duplicates
- **BeneficiaryList** - Review and resolve duplicates
- **BookingPage** / **ViewBookingPage** - Create and view bookings

### Referral Workflow

- **SentReferrals** - Create and track outgoing referrals
- **ReceivedReferrals** - Process incoming referrals

### Administration

- **Organizations** - Manage organizations and services
- **Users** - Manage user accounts and permissions
- **Rules** - Configure deduplication rules
- **Templates** - Column mapping templates
- **HandbookPage** - Create help documentation
- **SettingsPage** - Global deployment configuration

### User Features

- **DashboardPage** - Analytics and reports
- **MyProfilePage** - Profile management
- **UserHandbookList** - View help documentation

### Public Pages

- **Public** - Sign-in, password management, public data access
- **NotFoundPage** - 404 error handling

## Module Structure

Each module follows a consistent structure:

```
ModuleName/
├── ModulePage/
│   ├── index.tsx           # Main page component
│   ├── columns.tsx         # DataTable columns (if applicable)
│   ├── const.ts            # Constants and defaults
│   ├── validations.ts      # Zod schemas
│   ├── form-transformation.ts  # API data transformations
│   └── components/         # Page-specific components
├── SingleItemPage/         # Detail/edit page (if applicable)
│   └── ...
├── ModuleProvider.tsx      # React context provider (if needed)
├── README.md               # Module documentation
└── index.ts                # Public exports
```

## Common Patterns

### Page Container

All modules use `PageContainer` for consistent layout:
```tsx
<PageContainer
  pageTitle="Page Title"
  pageSubtitle="Description"
  headerNode={<ActionButton />}
  breadcrumbs={[{ href: '/route', name: 'Name' }]}
>
  {/* Content */}
</PageContainer>
```

### Data Tables

List pages use the shared `DataTable` component with:
- Pagination
- Sorting
- Search
- Custom columns

### Forms

Forms use React Hook Form with Zod validation:
```tsx
const form = useForm<FormData>({
  resolver: zodResolver(FormSchema),
  defaultValues: defaultFormValues,
});
```

### Context Providers

Many modules have providers for shared state:
```tsx
const { pagination } = useModuleProvider();
```

## Permission Levels

| Level | Access |
|-------|--------|
| Public | No authentication required |
| All users | Any authenticated user |
| Deduplication | Users with `deduplication` permission |
| Referrals | Users with `referrals` permission |
| Booking | Users with `booking` permission |
| Admin | Organization administrators |
| Superadmin | SYSTEM_USER only |
