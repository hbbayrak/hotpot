# Handbook Area

## Purpose

Manages help documentation and user guides within the platform. Allows admins to create and maintain handbook articles that users can reference.

## Route

`/api/v1/handbooks`

## Controller

### HandbookController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| GET | `/` | User | Get all handbooks (paginated) |
| GET | `/{id}` | User | Get single handbook |
| POST | `/` | Admin | Create new handbook |
| PUT | `/{id}` | Admin | Update existing handbook |
| DELETE | `/{id}` | Admin | Delete handbook |

## Services

### HandbookService

- `GetHandbooksApi(requestParameters)` - Paginated list of all handbooks
- `GetHandbookApi(id)` - Single handbook by ID
- `GetHandbookById(id)` - Raw entity lookup
- `AddHandbook(handbook)` - Create new handbook
- `UpdateHandbook(handbook)` - Update existing handbook
- `DeleteHandbook(handbook)` - Remove handbook

## Models

### Handbook

| Property | Type | Description |
|----------|------|-------------|
| Id | Guid | Primary key |
| Title | string | Handbook title (required) |
| Content | string | Markdown/HTML content |
| CreatedAt | DateTime | Creation timestamp |
| UpdatedAt | DateTime | Last update timestamp |

## Request Models

### HandbookAddRequest
- `Title` - Required title
- `Content` - Article content

### HandbookUpdateRequest
- `Title` - Updated title
- `Content` - Updated content

## Notes

- Handbooks are global (not organization-scoped)
- Content supports rich text (markdown/HTML)
- Users can view, only admins can manage
