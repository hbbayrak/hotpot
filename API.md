# API Reference

REST API documentation for the CCD Data Stewardship Platform.

## Base URL

```
/api/v1
```

## Authentication

### JWT Bearer Token

```
Authorization: Bearer <token>
```

Obtain token via:
```http
POST /api/v1/authentication/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": { ... }
}
```

### API Key

```
x-api-key: <api-key>
```

Or as query parameter:
```
?apiKey=<api-key>
```

## Required Headers

| Header | Description | Required |
|--------|-------------|----------|
| `Authorization` | Bearer token | Yes (for protected endpoints) |
| `organization-id` | Organization GUID | Yes (for most endpoints) |
| `Content-Type` | `application/json` | Yes (for POST/PUT/PATCH) |

## Pagination

All list endpoints support pagination:

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 1 | Page number (1-indexed) |
| `pageSize` | int | 20 | Items per page |
| `sortBy` | string | `id` | Column to sort by (snake_case) |
| `sortDirection` | string | `asc` | Sort direction: `asc` or `desc` |
| `search` | string | - | Quick search across searchable fields |
| `filter` | string | - | Comma-separated filter conditions |

### Response Format

```json
{
  "data": [
    { "id": "guid-1", ... },
    { "id": "guid-2", ... }
  ],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "totalRows": 100,
    "totalPages": 5,
    "sortBy": "created_at",
    "sortDirection": "desc"
  }
}
```

## Filtering

### Basic Syntax

```
?filter=column=value,column2=value2
```

### Operators

| Operator | Syntax | Example | Description |
|----------|--------|---------|-------------|
| Equals | `column=value` | `status=active` | Exact match |
| Not equals | `column[not]=value` | `status[not]=deleted` | Exclude value |
| Greater than | `column[gt]=value` | `created_at[gt]=2024-01-01` | Greater than or equal |
| Less than | `column[lt]=value` | `amount[lt]=1000` | Less than |
| Like | `column[like]=value` | `name[like]=john` | Case-insensitive partial match |
| In | `column[in]=v1\|v2\|v3` | `id[in]=guid1\|guid2` | Match any value |
| Contains | `column[contains]=value` | `tags[contains]=urgent` | Array contains value |
| Or | `column[or]=value` | `status[or]=active` | OR condition |

### Special Values

| Value | Description |
|-------|-------------|
| `$null` | Column is NULL |
| `$notnull` | Column is NOT NULL |

### Examples

```bash
# Filter by status
?filter=status=active

# Multiple conditions (AND)
?filter=status=active,created_at[gt]=2024-01-01

# Partial match
?filter=name[like]=john

# Multiple values (IN)
?filter=id[in]=guid1|guid2|guid3

# NULL check
?filter=deleted_at=$null

# Complex filter
?filter=status[not]=deleted,amount[gt]=100,name[like]=test
```

## Error Responses

### Format

```json
{
  "errorMessage": "Error description"
}
```

### HTTP Status Codes

| Status | Description |
|--------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Missing/invalid token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 500 | Internal Server Error |

## Endpoints by Area

### Authentication (`/api/v1/authentication`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/login` | Authenticate user |
| POST | `/reset-password` | Request password reset |
| POST | `/reset-password/confirm` | Confirm password reset |
| POST | `/activate` | Activate account |

### Organizations (`/api/v1/organizations`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | List organizations |
| GET | `/{id}` | User | Get organization |
| POST | `/` | Admin | Create organization |
| PATCH | `/{id}` | Admin | Update organization |
| DELETE | `/{id}` | Admin | Delete organization |

### Users (`/api/v1/users`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | Admin | List users |
| GET | `/{id}` | User | Get user |
| GET | `/me` | User | Get current user |
| POST | `/` | Admin | Create user |
| PATCH | `/{id}` | Admin | Update user |
| PATCH | `/me` | User | Update current user |
| DELETE | `/{id}` | Admin | Delete user |

### Beneficiaries (`/api/v1/beneficiaries`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | List beneficiaries |
| GET | `/{id}` | User | Get beneficiary |
| PATCH | `/{id}` | User | Update beneficiary |
| DELETE | `/{id}` | Admin | Delete beneficiary |

### Deduplication (`/api/v1/deduplication`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/listings` | User | Get dataset listings |
| POST | `/dataset` | User | Step 1: Internal dedup |
| POST | `/same-organization` | User | Step 2: Org dedup |
| POST | `/system-organizations` | User | Step 3: System dedup |
| POST | `/finish` | User | Finalize import |
| POST | `/booking/step-1` | User | Booking validation |
| POST | `/booking/step-2` | User | Create bookings |
| GET | `/bookings` | User | List bookings |
| DELETE | `/` | Admin | Delete all data |

### Referrals (`/api/v1/referrals`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | List referrals |
| GET | `/{id}` | User | Get referral |
| POST | `/` | User | Create referral |
| PATCH | `/{id}` | User | Update referral |
| DELETE | `/{id}` | Admin | Delete referral |
| GET | `/{id}/discussions` | User | Get discussions |
| POST | `/{id}/discussions` | User | Add discussion |

### Templates (`/api/v1/templates`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | List templates |
| GET | `/{id}` | User | Get template |
| POST | `/` | Admin | Create template |
| PATCH | `/{id}` | Admin | Update template |
| DELETE | `/{id}` | Admin | Delete template |

### Settings (`/api/v1/settings`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | Superadmin | Get settings |
| PATCH | `/` | Superadmin | Update settings |

### Administrative Regions (`/api/v1/admin-regions`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | List regions |
| GET | `/{id}` | User | Get region |

### Handbook (`/api/v1/handbooks`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | List handbooks |
| GET | `/{id}` | User | Get handbook |
| POST | `/` | Admin | Create handbook |
| PATCH | `/{id}` | Admin | Update handbook |
| DELETE | `/{id}` | Admin | Delete handbook |

### Beneficiary Data (`/api/v1/beneficiary-data`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/{id}` | Public | Get beneficiary's own data |

### Storage (`/api/v1/storage`)

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| POST | `/` | User | Upload file |
| GET | `/{id}` | User | Download file |

## Quick Search

Endpoints with `search` parameter search across fields marked with `[QuickSearchable]` attribute plus `id`.

Example:
```
GET /api/v1/users?search=john
```

Searches in: `id`, `email`, `first_name`, `last_name` (and other searchable fields)

## Swagger Documentation

Interactive API documentation available at:
```
http://localhost:5000/swagger/ui
```
