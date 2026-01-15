# ReceivedReferrals Module

## Purpose

Manages incoming referrals from other organizations. Allows users to view, accept, reject, and process referrals sent to their organization.

## Route

`/received-referrals` and `/received-referrals/:id`

## Structure

```
ReceivedReferrals/
├── ReceivedReferralsPage/
│   ├── ReceivedReferralsPage.tsx    # Referral list
│   └── columns.tsx                   # DataTable columns
├── ReceivedReferralPage/
│   ├── ReceivedReferralPage.tsx     # Single referral detail
│   └── helpers.ts                    # Helper functions
├── ReceivedReferralsProvider.tsx    # Context provider
└── index.ts                          # Public exports
```

## Pages

### ReceivedReferralsPage

Paginated list of received referrals:

**Features:**
- DataTable with sorting, pagination, search
- Export referrals button
- Multiple filter options
- Click-through to referral details

**Header Actions:**
- Export Referrals (Excel download)

**Filters:**
| Filter | Description |
|--------|-------------|
| Show only urgent | Filter by `isUrgent` flag |
| Filter by Focal Point | Assigned focal point |
| Filter by Step | Referral status |
| Filter by Sender | Sending organization |
| Filter by Activity | Service category |
| Admin Regions | Geographic location filter |
| Date Range | Created date range |

**Columns:**
| Column | Description |
|--------|-------------|
| Case Number | Unique referral identifier |
| First Name | Beneficiary first name |
| Surname | Beneficiary surname |
| Sending Org | Organization that sent referral |
| Service | Service category |
| Status | Current workflow status |
| Created | Creation date |

### ReceivedReferralPage

Detailed view for processing a single referral:

**Tabs:**
| Tab | Content |
|-----|---------|
| Referral | Full referral details |
| Discussion | Communication thread |

**Status Timeline:**
Visual workflow showing: `UnderReview → InAssessment → Registered → Delivered`

**Sections:**
1. **Focal Point Assignment** - Assign user to handle referral
2. **Sending Organization Details** - Organization, funding source, service category
3. **MPCA Information** (if applicable) - Displacement status, household info
4. **Beneficiary Details** - Name, DOB, Tax ID, address, contact info
5. **Minor Information** (if applicable) - Caregiver details
6. **Other Information** - Reason, service explanation, attachments

**Actions:**
| Button | Action |
|--------|--------|
| Move to step | Advance workflow status |
| Reject | Reject referral with reason |
| Cancel | Return to list |

## Components

### StatusTimeline

Visual representation of referral workflow status.

### ReferralDiscussions

Communication thread for referral discussion between organizations.

### StatusReasonModal

Modal for providing reason when rejecting a referral.

## Services Used

- `useReferrals` - Fetch referrals with `received: true`
- `useReferral` - Fetch single referral
- `useReferralMutation` - Status updates
  - `patchReferral` - Update status
  - `updateReferralReason` - Reject with reason
  - `removeReferral` - Delete referral
- `getReferralsExport` - Export to Excel
- `useReferralUsers` - Get users with referral permission

## Workflow Status

```typescript
enum ReferralStatus {
  UnderReview = 'underReview',
  InAssessment = 'inAssessment',
  Registered = 'registered',
  Delivered = 'delivered'
}
```

## Permission

Requires `referrals` permission.
