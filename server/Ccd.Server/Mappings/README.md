# Mappings

AutoMapper configuration for mapping between entities and DTOs.

## Overview

The application uses [AutoMapper](https://automapper.org/) to map:
- Request DTOs → Entity models (for create/update operations)
- Entity models → Response DTOs (for API responses)

## Profile

Single profile class: `Mappings.cs`

Registered in `Startup.cs`:
```csharp
services.AddAutoMapper(typeof(Mappings.Mappings));
```

## Current Mappings

### Organization

| Source | Destination |
|--------|-------------|
| `Organization` | `OrganizationResponse` |
| `Organization` | `OrganizationUserResponse` |
| `OrganizationUpdateRequest` | `Organization` |
| `OrganizationAddRequest` | `Organization` |

### Users

| Source | Destination |
|--------|-------------|
| `UserAddRequest` | `User` |
| `UserUpdateRequest` | `User` |
| `UserUpdateMeRequest` | `User` |
| `User` | `UserResponse` |
| `UserResponse` | `UserMeResponse` |
| `UserResponse` | `UserShortResponse` |
| `User` | `UserShortResponse` |

### Beneficiaries

| Source | Destination |
|--------|-------------|
| `BeneficiaryAttribute` | `BeneficiaryAttributeResponse` |
| `DeduplicationRecord` | `Beneficary` |
| `DeduplicationRecord` | `BeneficaryDeduplication` |
| `BeneficaryDeduplication` | `Beneficary` |
| `Beneficary` | `BeneficaryResponse` |

### Beneficiary Attribute Groups

| Source | Destination |
|--------|-------------|
| `BeneficiaryAttributeGroup` | `BeneficiaryAttributeGroupResponse` |
| `BeneficiaryAttributeGroupCreateRequest` | `BeneficiaryAttributeGroup` |

### Referrals

| Source | Destination |
|--------|-------------|
| `Referral` | `ReferralResponse` |
| `Referral` | `ReferralCaseNumberResponse` |
| `ReferralAddRequest` | `Referral` |
| `ReferralPatchRequest` | `Referral` |
| `Discussion` | `DiscussionResponse` |
| `DiscussionAddRequest` | `Discussion` |
| `UserResponse` | `FocalPointUsersResponse` |
| `ReferralResponse` | `ReferralExportResponse` (with `.ForMember()` mappings) |

### Other

| Source | Destination |
|--------|-------------|
| `Handbook` | `HandbookResponse` |
| `HandbookAddRequest` | `Handbook` |
| `HandbookUpdateRequest` | `Handbook` |
| `Template` | `TemplateResponse` |
| `TemplateAddRequest` | `Template` |
| `TemplatePatchRequest` | `Template` |
| `SettingsUpdateRequest` | `Settings` |
| `Settings` | `SettingsResponse` |
| `AdministrativeRegion` | `AdministrativeRegionResponse` |
| `ReferralResponse` | `BeneficaryDataResponse` |

## Complex Mappings

### ReferralExportResponse

Uses `.ForMember()` for flattening nested objects:

```csharp
CreateMap<ReferralResponse, ReferralExportResponse>()
    .ForMember(e => e.AdministrationRegion1, opt => opt.MapFrom(src => src.AdministrativeRegion1.Name))
    .ForMember(e => e.OrganizationReferredTo, opt => opt.MapFrom(src => src.OrganizationReferredTo.Name))
    .ForMember(e => e.HouseholdsVulnerabilityCriteria, opt => opt.MapFrom(src => string.Join(",", src.HouseholdsVulnerabilityCriteria)))
    .ForMember(e => e.FocalPoint, opt => opt.MapFrom(src => src.FocalPoint.FirstName + " " + src.FocalPoint.LastName));
```

## Date Parsing Helper

Private method for parsing dates from various formats (used in deduplication):

**Supported formats:**
- `MM-dd-yyyy`
- `yyyyMMdd`
- `MM/dd/yyyy`
- `MM/dd/yyyy hh:mm:ss`
- `dd/MM/yyyy`
- `MM.dd.yyyy`
- `dd.MM.yyyy. hh:mm:ss`
- `dd/M/yyyy hh:mm:ss tt`
- `d/M/yyyy hh:mm:ss tt`
- `M/d/yyyy hh:mm:ss tt`

All parsed dates are converted to UTC.

## Adding a New Mapping

1. Open `Mappings.cs`

2. Add your mapping in the constructor:
   ```csharp
   // Simple mapping (properties match by name)
   CreateMap<NewEntityAddRequest, NewEntity>();
   CreateMap<NewEntity, NewEntityResponse>();

   // Custom mapping (when property names differ)
   CreateMap<Source, Destination>()
       .ForMember(dest => dest.FullName,
           opt => opt.MapFrom(src => $"{src.FirstName} {src.LastName}"));
   ```

3. Use in your service:
   ```csharp
   public class NewEntityService
   {
       private readonly IMapper _mapper;

       public NewEntityService(IMapper mapper)
       {
           _mapper = mapper;
       }

       public NewEntityResponse Create(NewEntityAddRequest request)
       {
           var entity = _mapper.Map<NewEntity>(request);
           // ... save entity
           return _mapper.Map<NewEntityResponse>(entity);
       }
   }
   ```

## Naming Conventions

- **Request DTOs**: `{Entity}AddRequest`, `{Entity}UpdateRequest`, `{Entity}PatchRequest`
- **Response DTOs**: `{Entity}Response`, `{Entity}ShortResponse`
- **Exports**: `{Entity}ExportResponse`

## Notes

- AutoMapper uses convention-based mapping (properties with same name map automatically)
- Use `.ForMember()` for custom property mappings
- Use `.Ignore()` for properties that shouldn't be mapped
- Mappings are validated at startup (invalid mappings throw exceptions)
