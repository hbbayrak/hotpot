# BeneficiaryData Area

## Purpose

Provides public endpoint for beneficiaries to look up their own data using their tax ID (government ID number). This supports the "access to their own data for aid recipients" feature.

## Route

`/api/v1/beneficiary-data`

## Controller

### BeneficiaryDataController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/{taxId}` | Public | Get beneficiary and referral data by tax ID |

## Services

### BeneficaryDataService

- `GetBeneficiaryAndReferralData(taxId)` - Finds both beneficiary record (by GovIdNumber) and referral record (by TaxId)
- `GetBeneficiaryDataApi(taxId)` - Returns combined response with beneficiary and referral info, including organization details

## Response Model

### BeneficaryDataResponse

| Property | Type | Description |
|----------|------|-------------|
| Referral | ReferralResponse? | Referral data if found |
| Beneficiary | BeneficaryResponse? | Beneficiary data if found |

## Notes

- Public endpoint - no authentication required
- Searches both beneficiaries (by GovIdNumber) and referrals (by TaxId)
- Returns 400 if no data found for the given tax ID
- Includes organization information for referrals
- Includes uploader information for beneficiaries
