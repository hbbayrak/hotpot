# Ccd.Tests

## Overview

Integration test project for the CCD Data Stewardship Platform API using xUnit and ASP.NET Core TestHost.

## Technology Stack

| Package | Version | Purpose |
|---------|---------|---------|
| xUnit | 2.7.0 | Test framework |
| Microsoft.AspNetCore.TestHost | 8.0.3 | In-memory test server |
| Microsoft.NET.Test.Sdk | 17.9.0 | Test SDK |
| .NET | 8.0 | Target framework |

## Project Structure

```
Ccd.Tests/
├── ApiFixture.cs           # Test fixture with helper methods
├── ApiCollection.cs        # xUnit collection definition
├── Mocks/
│   ├── MockStorageService.cs
│   └── MockNotificationService.cs
├── Users/
│   └── UserTests.cs
├── Organizations/
│   └── OrganizationTests.cs
├── Referrals/
│   └── ReferralsCrudTest.cs
├── Settings/
│   └── SettingsTests.cs
├── AdministrativeRegion/
│   └── AdministrativeRegionTests.cs
├── appsettings.json        # Test configuration
└── appsettings.ci.json     # CI environment configuration
```

## Running Tests

```bash
# Run all tests
cd server/Ccd.Tests
dotnet test

# Run specific test class
dotnet test --filter "FullyQualifiedName~UserTests"

# Run specific test method
dotnet test --filter "FullyQualifiedName~User_Crud_Success"

# Run with verbose output
dotnet test -v n
```

## Test Configuration

### appsettings.json

```json
{
  "AppSettings": {
    "Secret": "verysecretkey1verysecretkey2verysecretkey",
    "ExpirationDays": 365
  },
  "ConnectionStrings": {
    "CcdServerDB": "Host=localhost;Database=ccd-server;Username=ccd-server;Password=test123"
  },
  "ApiKey": "api_key",
  "SuperadminPassword": "superadmin_password"
}
```

**Note:** Tests run against a real PostgreSQL database. Ensure the database is running and accessible.

---

## ApiFixture

The central test fixture providing helper methods for all tests.

### Setup

Creates an in-memory TestServer with:
- Real application startup via `Startup` class
- Mocked services (Storage, Notifications)
- Configuration from `appsettings.json`

```csharp
[Collection("Api")]
public class MyTests
{
    private readonly ApiFixture _api;

    public MyTests(ApiFixture api)
    {
        _api = api;
    }
}
```

### Core Methods

#### Request<T>

Makes HTTP requests and asserts expected status code:

```csharp
var result = await _api.Request<UserResponse>(
    "/api/v1/users",
    HttpMethod.Post,
    headers,
    payload,
    HttpStatusCode.Created
);
```

**Parameters:**
- `url` - API endpoint
- `method` - HTTP method
- `headers` - Headers object (token, organizationId)
- `payload` - Request body (auto-serialized to JSON)
- `expectedResponseCode` - Expected HTTP status

#### CreateOrganization

Creates a test organization with admin user:

```csharp
var (organization, user, headers) = await _api.CreateOrganization(
    role: UserRole.Admin
);
```

**Returns:**
- `Organization` - Created organization entity
- `User` - Admin user entity
- `Headers` - Pre-configured headers with JWT token

#### CreateUser / CreateOrganizationUser

Creates additional users in an organization:

```csharp
// Create user (returns response only)
var userResponse = await _api.CreateUser(headers);

// Create user with login (returns entity and new headers)
var (user, userHeaders) = await _api.CreateOrganizationUser(headers);
```

#### GetUserHeaders

Generates authenticated headers for a user:

```csharp
var headers = _api.GetUserHeaders(user, organization, UserRole.Admin);
```

#### GetService<T>

Access DI services for direct manipulation:

```csharp
var dateTimeProvider = _api.GetService<DateTimeProvider>();
```

### Date/Time Helpers

Control time in tests:

```csharp
// Set specific date/time
_api.SetDate(new DateTime(2024, 1, 15, 10, 30, 0));

// Set date only (time = 00:00:00)
_api.SetOnlyDate(new DateTime(2024, 1, 15));

// Get current mocked time
var now = _api.GetUtcNow();
```

### Data Helpers

```csharp
// Activate a user account
await _api.ActivateUser(userId);

// Reset settings to defaults
await _api.ResetSettings();

// Add administrative region
var region = await _api.AddAdministrativeRegion(level: 1, name: "Oblast", parentId: null);

// Create file upload form
var form = _api.GetDummyImageForm("image.png", StorageType.Assets.Id);
var file = await _api.AddImage(headers, "image.png", StorageType.Assets.Id);
```

### Headers Class

```csharp
public class Headers
{
    public string Token { get; set; }          // JWT token
    public Guid? OrganizationId { get; set; }  // Organization context
    public string Language { get; set; }       // Language header
}
```

---

## Mocks

### MockStorageService

In-memory file storage replacing `IStorageService`:

- Stores files in static `Dictionary<Guid, byte[]>`
- Implements all `IStorageService` methods
- No filesystem access required

### MockNotificationService

Captures notifications instead of sending:

```csharp
// Access sent emails
var email = MockNotificationService.GetLastEmailTo("user@example.com");

// Clear captured emails
MockNotificationService.ClearEmailsTo("user@example.com");

// All captured data
MockNotificationService.Emails              // List<MockEmail>
MockNotificationService.InternalNotifications
MockNotificationService.PushNotifications
```

---

## Test Suites

### UserTests

| Test | Description |
|------|-------------|
| `User_Crud_Success` | Full user lifecycle: create, login, update, password change, delete |
| `User_Permissions_Success` | Role-based access: admin vs user permissions |
| `User_Superadmin_Success` | Superadmin login and identification |

### OrganizationTests

| Test | Description |
|------|-------------|
| `Organization_Create_Success` | Create organization and verify via `/me` endpoint |

### ReferralsCrudTest

| Test | Description |
|------|-------------|
| `Referrals_Crud_Success` | Full referral lifecycle with administrative regions |

### SettingsTests

| Test | Description |
|------|-------------|
| `Settings_CRUD_Success` | Read settings, verify superadmin-only update |

### AdministrativeRegionTests

| Test | Description |
|------|-------------|
| `AdministrativeRegions_CRUD_Success` | Query regions by id, parentId, name, level |

---

## Writing New Tests

### 1. Create Test Class

```csharp
using Xunit;

namespace Ccd.Tests.MyFeature;

[Collection("Api")]
public class MyFeatureTests
{
    private readonly ApiFixture _api;

    public MyFeatureTests(ApiFixture api)
    {
        _api = api;
    }

    [Fact]
    public async void MyFeature_Action_ExpectedResult()
    {
        // Arrange
        var (organization, user, headers) = await _api.CreateOrganization();

        // Act
        var result = await _api.Request<MyResponse>(
            "/api/v1/my-endpoint",
            HttpMethod.Post,
            headers,
            new MyRequest { /* ... */ },
            HttpStatusCode.OK
        );

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expected, result.Property);
    }
}
```

### 2. Test Naming Convention

`{Feature}_{Action}_{ExpectedOutcome}`

Examples:
- `User_Crud_Success`
- `User_Permissions_Success`
- `Referrals_Crud_Success`
- `Settings_CRUD_Success`

### 3. Common Patterns

**Testing Authorization:**
```csharp
// Should fail for regular user
await _api.Request<Response>(url, HttpMethod.Put, userHeaders, data, HttpStatusCode.Forbidden);

// Should succeed for admin
await _api.Request<Response>(url, HttpMethod.Put, adminHeaders, data, HttpStatusCode.OK);
```

**Testing CRUD Operations:**
```csharp
// Create
var created = await _api.Request<T>(url, HttpMethod.Post, headers, data, HttpStatusCode.Created);

// Read
var fetched = await _api.Request<T>($"{url}/{created.Id}", HttpMethod.Get, headers, null, HttpStatusCode.OK);

// Update
var updated = await _api.Request<T>($"{url}/{created.Id}", HttpMethod.Put, headers, updateData, HttpStatusCode.OK);

// Delete
await _api.Request<T>($"{url}/{created.Id}", HttpMethod.Delete, headers, null, HttpStatusCode.OK);

// Verify deleted
await _api.Request<T>($"{url}/{created.Id}", HttpMethod.Get, headers, null, HttpStatusCode.NotFound);
```

**Testing List Endpoints:**
```csharp
var list = await _api.Request<PagedApiResponse<T>>(
    $"{url}?pageSize=99999",
    HttpMethod.Get,
    headers,
    null,
    HttpStatusCode.OK
);

Assert.NotEmpty(list.Data);
Assert.NotNull(list.Data.FirstOrDefault(e => e.Id == expectedId));
```

---

## CI/CD

Tests are run in GitLab CI with PostgreSQL service:

```yaml
test:
  stage: test
  services:
    - postgres:15
  variables:
    POSTGRES_DB: ccd-server
    POSTGRES_USER: ccd-server
    POSTGRES_PASSWORD: test123
  script:
    - cd server/Ccd.Tests
    - dotnet test
```

The `appsettings.ci.json` provides CI-specific configuration overrides.
