# DashboardPage Module

## Purpose

Displays an analytics dashboard via embedded Metabase iframe. Provides visual reporting and metrics for the platform.

## Route

`/dashboard`

## Structure

```
DashboardPage/
├── DashboardPage.tsx    # Main dashboard page
└── index.ts             # Public exports
```

## Page Features

### DashboardPage

Simple page that embeds a Metabase dashboard:

**Features:**
- Full-width, full-height iframe embedding
- Loading spinner while iframe loads
- Dark mode support via CSS inversion (`dark:invert dark:hue-rotate-180`)

## Configuration

The Metabase URL is retrieved from deployment settings:

```typescript
const { deploymentSettings } = useAuth();
// Uses deploymentSettings.metabaseUrl
```

## Styling

| Mode | Effect |
|------|--------|
| Light | Normal iframe display |
| Dark | Inverted colors with hue rotation for compatibility |

## Dependencies

- `useAuth` hook from GlobalProvider for deployment settings
- Metabase instance configured via Settings

## Loading State

Shows a centered `Loader2` spinner until the iframe's `onLoad` event fires.

## Access

Available to all authenticated users. The displayed dashboard content depends on the Metabase URL configured in deployment settings.
