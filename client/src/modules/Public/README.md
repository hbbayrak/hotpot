# Public Module

## Purpose

Collection of public-facing pages that don't require authentication. Handles sign-in, password management, and public data access for beneficiaries.

## Routes

| Route | Page | Description |
|-------|------|-------------|
| `/sign-in` | SignInPage | User login |
| `/request-new-password` | RequestNewPasswordPage | Password reset request |
| `/set-new-password` | SetNewPasswordPage | Set new password (from email link) |
| `/permission-denied` | PermissionDeniedPage | Access denied message |
| `/beneficiary-data` | BeneficiaryDataViewPage | Public beneficiary data lookup |
| `/beneficiary-referral-data` | BeneficiaryReferralDataPage | Public referral data lookup |

## Structure

```
Public/
├── SignInPage/
│   ├── SignInPage.tsx          # Login form
│   └── validations.ts          # Zod schema
├── RequestNewPasswordPage/
│   └── RequestNewPasswordPage.tsx
├── SetNewPasswordPage/
│   └── SetNewPasswordPage.tsx
├── PermissionDeniedPage/
│   └── PermissionDeniedPage.tsx
├── BeneficiaryDataView/
│   ├── BeneficiaryDataViewPage.tsx
│   ├── api.ts                  # Fetch beneficiary data
│   └── types.ts
├── BeneficiaryReferralDataPage/
│   └── BeneficiaryReferralDataPage.tsx
└── index.ts                    # Public exports
```

## Pages

### SignInPage

User authentication form:

**Fields:**
- Username (email)
- Password

**Features:**
- Form validation with Zod
- "Forgot password?" link
- Login via `useAuthMutation`
- Stores auth data via `loginUser` from GlobalProvider

### RequestNewPasswordPage

Password reset request form:

**Fields:**
- Email address

**Flow:**
1. User enters email
2. API sends password reset link
3. User receives email with reset token

### SetNewPasswordPage

Set new password form (accessed via email link):

**Fields:**
- New password
- Confirm password

**Features:**
- Token validation from URL params
- Password confirmation matching

### PermissionDeniedPage

Simple error page shown when user lacks required permissions:
- Message explaining access denial
- Navigation back to safe area

### BeneficiaryDataViewPage

Public page allowing beneficiaries to view their own data:

**Features:**
- Tax ID input form
- Displays both referral and deduplication data
- Shows which organization holds the data
- No authentication required

**Data Display:**
| Section | Source | Fields |
|---------|--------|--------|
| Referral Data | `referralData` | Name, DOB, Gender, Tax ID, Address, Contact |
| Beneficiary Data | `duplicateBeneficiaryData` | Activity, Admin Levels, Dates, Status |

### BeneficiaryReferralDataPage

Similar to BeneficiaryDataViewPage but focused on referral data lookup.

## Layout

All public pages use the `PublicPage` layout component which provides:
- Centered card design
- Title and subtitle
- Theme toggle
- Optional redirect behavior for authenticated users

## Services Used

- `useAuthMutation` - Login mutation
- `fetchBeneficiaryData` - Public beneficiary lookup API

## Form Validation

All forms use React Hook Form with Zod validation:

```typescript
const form = useForm<SignInFormData>({
  resolver: zodResolver(SignInFormSchema),
});
```

## Access

All pages in this module are publicly accessible without authentication.
