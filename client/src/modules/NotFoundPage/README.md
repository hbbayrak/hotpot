# NotFoundPage Module

## Purpose

404 error page displayed when users navigate to non-existent routes.

## Route

Catch-all route for unmatched paths (`*`)

## Structure

```
NotFoundPage/
├── NotFoundPage.tsx    # 404 error display
└── index.ts            # Public exports
```

## Page Features

### NotFoundPage

Simple, centered error page with:

**Content:**
- "404" error code
- "Page not found" heading
- Helpful message: "Sorry, we couldn't find the page you're looking for."
- "Go back" button

**Actions:**
| Button | Action |
|--------|--------|
| Go back | `navigate(-1)` - Returns to previous page |

## Styling

- Full viewport height (`h-[100svh]` / `h-screen`)
- Centered content using CSS Grid
- Animated appearance (`animate-appear`)
- Responsive text sizing

## Components Used

- `Button` - Go back action
- `ArrowLeft` icon from lucide-react

## Code

```typescript
<Button onClick={() => navigate(-1)}>
  <ArrowLeft className="mr-2 h-4 w-4" />
  Go back
</Button>
```

## Access

Available to all users (authenticated or not).
