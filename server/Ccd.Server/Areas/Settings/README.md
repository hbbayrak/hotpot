# Settings Area

## Purpose

Manages global system settings for the deployment. Settings include deployment name, country, administrative level names, and other configuration.

## Route

`/api/v1/settings`

## Controller

### SettingsController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | Get current system settings |
| PUT | `/` | Superadmin | Update system settings |

**Note:** Only the superadmin (SYSTEM_USER) can update settings.

## Services

### SettingsService

- `GetSettingsApi()` - Returns the singleton settings record
- `UpdateSettingsApi(model)` - Updates settings using AutoMapper

## Models

### Settings

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key (single record) |
| DeploymentCountry | string | Country name for deployment |
| DeploymentName | string | Platform display name |
| AdminLevel1Name | string | Label for admin level 1 (e.g., "Oblast") |
| AdminLevel2Name | string | Label for admin level 2 (e.g., "Rayon") |
| AdminLevel3Name | string | Label for admin level 3 (e.g., "Hromada") |
| AdminLevel4Name | string | Label for admin level 4 (e.g., "Settlement") |
| MetabaseUrl | string | URL for Metabase analytics |
| FundingSources | List<string> | Available funding source options (JSONB) |

**Default Values:**
```csharp
Id = "00000000-0000-0000-0000-000000000001"
DeploymentCountry = "Country"
DeploymentName = "CCD Data Portal"
AdminLevel1-4Name = "AdminLevel1-4"
MetabaseUrl = "https://default.metabase.url"
FundingSources = ["BHA", "Other"]
```

## Request Models

### SettingsUpdateRequest

All settings fields are optional for partial updates.

## Notes

- Single settings record in database (singleton pattern)
- Implements `UserChangeTracked` for audit trail
- Superadmin-only modification enforced in controller
- AdminLevel names customize labels for the geographic hierarchy
- FundingSources configures dropdown options for referrals
