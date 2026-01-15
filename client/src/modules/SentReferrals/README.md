# SentReferrals Module

## Purpose

Manages outgoing referrals to other organizations. Provides functionality to create, edit, and track referrals sent by the user's organization.

## Route

`/sent-referrals`, `/sent-referrals/new`, and `/sent-referrals/:id`

## Structure

```
SentReferrals/
├── SentReferralsPage/
│   ├── SentReferralsPage.tsx            # Referral list with tabs
│   ├── columns.tsx                       # DataTable columns
│   └── components/
│       └── BatchCreateModal/
│           └── BatchCreateModal.tsx      # Bulk import modal
├── SentReferralPage/
│   ├── SentReferralPage.tsx             # Create/edit/view referral
│   ├── const.ts                         # Default form values
│   ├── form-transformation.ts           # Data transformations
│   ├── validations.ts                   # Zod schemas
│   └── components/
│       ├── MinorForm/
│       │   └── MinorForm.tsx            # Child beneficiary form
│       ├── MpcaSpecificForm/
│       │   └── MpcaSpecificForm.tsx     # MPCA-specific fields
│       ├── SentReferralPageViewOnly/
│       │   └── SentReferralPageViewOnly.tsx  # Read-only view
│       ├── CancelReferralModal/
│       │   └── CancelReferralModal.tsx
│       └── ImpexLoadingDialog/
│           └── ImpexLoadingDialog.tsx   # Import/export loading
├── SentReferralsProvider.tsx            # Context provider
└── index.ts                              # Public exports
```

## Pages

### SentReferralsPage

Paginated list with tabs for sent and draft referrals:

**Tabs:**
| Tab | Filter | Visible Columns |
|-----|--------|-----------------|
| Sent | `isDraft=false` | Status hidden |
| Drafts | `isDraft=true` | All columns |

**Header Actions (Dropdown):**
| Action | Description |
|--------|-------------|
| New Case | Navigate to create form |
| Import referrals | Open batch import modal |
| Export referrals | Download Excel export |
| Download templates | Download import template ZIP |

**Filters:**
- Show only urgent
- Filter by Creator
- Filter by Step
- Filter by Recipient
- Filter by Activity
- Admin Regions
- Date Range

### SentReferralPage

Comprehensive form for creating, editing, and viewing referrals:

**Tabs:**
| Tab | Content |
|-----|---------|
| Referral | Full referral form |
| Discussion | Communication thread |

**Modes:**
| Mode | Condition | Features |
|------|-----------|----------|
| Create | `/sent-referrals/new` | Full form, Save draft/Send buttons |
| View | Existing referral, `viewOnlyEnabled=true` | Read-only display |
| Edit | Existing referral, `viewOnlyEnabled=false` | Editable form |

**Form Sections:**

1. **Urgent Referral** - Toggle for urgent (24-hour) processing

2. **Recipient Organization**
   - Receiving organisation (async select)
   - Funding source
   - Service category
   - Sub-activities checkboxes

3. **Beneficiary Details**
   - First name, Surname, Patronymic name
   - Gender, Date of birth
   - Tax ID (with "No Tax ID" checkbox)
   - Address
   - Administrative regions (4 levels)
   - Contact preference (email/phone/visit)
   - Email, Phone
   - Restrictions

4. **Minor Information** (if `isMinor=true`)
   - Caregiver details via `MinorForm`

5. **MPCA Information** (if `serviceCategory=mpca`)
   - Displacement status, Household size via `MpcaSpecificForm`

6. **Other Information**
   - Reason (required)
   - Service explanation
   - File attachments

7. **Consent** - Required consent toggle

**Actions:**
| Action | Condition | Function |
|--------|-----------|----------|
| Save draft | Create/Draft mode | Save without sending |
| Send Referral | Create/Draft mode | Send to recipient |
| Edit | View mode | Enable editing |
| Withdraw | Sent referral | Withdraw with reason |
| Submit | Edit mode | Save changes |
| Cancel edits | Edit mode | Reload page |

## Components

### BatchCreateModal

Modal for bulk importing referrals from Excel file.

### MinorForm

Additional fields for child beneficiaries:
- Is separated/unaccompanied
- Caregiver name
- Relationship to child
- Caregiver contact details
- Caregiver informed status

### MpcaSpecificForm

MPCA-specific fields:
- Displacement status
- Household size
- Monthly income
- Vulnerability criteria

### SentReferralPageViewOnly

Read-only display of referral data with formatted sections.

### ImpexLoadingDialog

Loading dialog shown during import/export operations.

## Services Used

- `useReferrals` - Fetch referrals list
- `useReferral` - Fetch single referral
- `useReferralMutation` - CRUD operations
  - `createReferral` - Create new referral
  - `patchReferral` - Update referral
  - `removeReferral` - Delete referral
  - `updateReferralReason` - Withdraw with reason
- `getReferralsExport` - Export to Excel
- `getReferralsTemplateFile` - Download import template
- `useReferralUsers` - Get users with referral permission
- `useOrganizationsInfinite` - Async organization select

## Form Validation

Extensive Zod schema (`SentReferralSchema`) with conditional validation:
- Tax ID required unless `noTaxId=true`
- Tax ID required for MPCA referrals
- Contact info required based on preference
- Minor fields required when `isMinor=true`

## Administrative Region Propagation

Selecting a lower-level region auto-populates parent regions:
```typescript
const propagateParentRegion = async (adminLevel: AdministrativeRegion) => {
  // Fetches and sets parent regions recursively
};
```

## Permission

Requires `referrals` permission.
