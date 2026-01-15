# Client

React frontend for the CCD Data Stewardship Platform.

## Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | React 18.2 |
| **Build Tool** | Vite 5.0 |
| **Language** | TypeScript 5.2 |
| **Routing** | React Router DOM 6.8 |
| **State Management** | TanStack React Query 4.29 |
| **Forms** | React Hook Form 7.49 + Zod |
| **UI Components** | Radix UI + Headless UI |
| **Styling** | Tailwind CSS 3.3 |
| **HTTP Client** | Axios |
| **CMS** | Directus SDK 18.0 |

## Commands

```bash
# Development server (port 3000)
yarn dev

# Production build
yarn build

# Lint (ESLint + Stylelint)
yarn lint

# Fix lint issues
yarn lint:fix

# Type check only
yarn typecheck

# Type check watch mode
yarn typecheck:watch
```

## Environment Variables

Create `.env` from `.env.example`:

```bash
VITE_API_URL=https://api.example.com    # Backend API URL
VITE_DIRECTUS_URL=https://cms.example.com  # Directus CMS URL
VITE_DIRECTUS_TOKEN=token               # Directus API token
```

---

## Project Structure

```
client/
├── src/
│   ├── App.tsx              # Root component with providers
│   ├── router.tsx           # Route definitions
│   ├── main.tsx             # Entry point
│   ├── modules/             # Feature modules (pages)
│   ├── components/          # Reusable components
│   ├── services/            # API layer
│   ├── providers/           # React context providers
│   ├── layouts/             # Route layouts
│   ├── helpers/             # Utilities
│   ├── hooks/               # Custom hooks
│   └── styles/              # Global CSS
├── public/                  # Static assets
├── vite.config.ts           # Vite configuration
├── tailwind.config.cjs      # Tailwind configuration
└── tsconfig.json            # TypeScript configuration
```

---

## Modules

Feature-based pages with their own components and providers.

| Module | Route | Purpose |
|--------|-------|---------|
| **BookingPage** | `/booking` | Create booking records |
| **ViewBookingPage** | `/view-booking` | View existing bookings |
| **DeduplicationPage** | `/deduplication` | Upload and deduplicate datasets |
| **BeneficiaryList** | `/beneficiary-list` | View/manage beneficiaries |
| **SentReferrals** | `/sent-referrals` | Manage outgoing referrals |
| **ReceivedReferrals** | `/received-referrals` | Manage incoming referrals |
| **Organizations** | `/organizations` | Admin: manage organizations |
| **Users** | `/users` | Admin: manage users |
| **Templates** | `/templates` | Manage Excel import templates |
| **Rules** | `/rules` | Admin: deduplication rules |
| **HandbookPage** | `/handbook` | Admin: manage handbook entries |
| **UserHandbookList** | `/handbook-list` | User: view handbook |
| **DashboardPage** | `/dashboard` | Analytics dashboard |
| **SettingsPage** | `/settings` | Superadmin: deployment settings |
| **MyProfilePage** | `/my-profile` | User profile management |
| **Public/** | Various | Sign-in, password reset, public data access |

### Module Structure

```
ModuleName/
├── ModulePage/
│   ├── index.tsx           # Main page component
│   ├── components/         # Page-specific components
│   └── validations.ts      # Zod schemas
├── ModuleProvider.tsx      # Context provider (optional)
└── index.ts                # Public exports
```

---

## Components

### UI Components (`components/ui/`)

Radix UI primitives wrapped with Tailwind styling (shadcn/ui pattern):

- `accordion`, `alert-dialog`, `avatar`, `badge`
- `button`, `calendar`, `card`, `checkbox`
- `command`, `dialog`, `dropdown-menu`, `form`
- `input`, `label`, `pagination`, `popover`
- `radio-group`, `scroll-area`, `select`, `separator`
- `sheet`, `skeleton`, `switch`, `table`
- `tabs`, `textarea`, `toast`, `tooltip`

### Feature Components

| Component | Purpose |
|-----------|---------|
| `DataTable/` | Sortable, filterable, paginated tables |
| `FilesDropzone/` | File upload with drag-and-drop |
| `BeneficiaryStatus/` | Status display components |
| `StatusTimeline/` | Timeline visualization |
| `ReferralDiscussions` | Discussion thread UI |
| `MarkdownEditor/` | Rich text editing |
| `DatePicker` | Date selection |
| `Combobox` | Searchable select |
| `AsyncSelect/` | Async data loading select |
| `ConfirmationDialog` | Confirm action modal |

---

## Services

API layer with React Query hooks and transformations.

### Structure

```
services/
├── api.ts                  # Axios instance
├── index.ts                # Exports
├── auth/                   # Authentication
├── users/                  # User management
├── organizations/          # Organization management
├── referrals/              # Referral CRUD
├── deduplication/          # Deduplication workflow
├── beneficiaryList/        # Beneficiary queries
├── beneficiaryAttribute/   # Attribute definitions
├── attributeGroups/        # Attribute groups
├── templates/              # Import templates
├── handbooks/              # Handbook entries
├── settings/               # Deployment settings
├── administrativeRegions/  # Geographic data
└── storage/                # File upload
```

### API Instance (`api.ts`)

```typescript
export const api = axios.create({
  baseURL: `${import.meta.env.VITE_API_URL}/api/v1`,
  timeout: 100000,
});

// Auto-adds Authorization header from LocalStorage
// Auto-adds organization-id header
// Handles 401 responses (logout)
```

### Service Pattern

Each service follows this pattern:

```typescript
// types.ts - TypeScript interfaces
export interface Entity { ... }

// transformations.ts - API ↔ Frontend mapping
export const resToEntity = (data: any): Entity => ({ ... });
export const entityToReq = (data: FormData): RequestPayload => ({ ... });

// api.ts - API calls and React Query hooks
enum QueryKeys {
  Entities = 'entities',
  SingleEntity = 'single_entity',
}

// Fetch functions
const fetchEntities = async (pagination): Promise<DataWithMeta<Entity>> => { ... };
const fetchEntity = async (id: string): Promise<Entity> => { ... };
const postEntity = async (data): Promise<Entity> => { ... };

// Query hooks
export const useEntities = (params) => useQuery([QueryKeys.Entities, ...], () => fetchEntities(...));
export const useEntity = ({ id }) => useQuery([QueryKeys.SingleEntity, id], () => fetchEntity(id));

// Mutation hooks
export const useEntityMutation = () => {
  const queryClient = useQueryClient();
  return {
    createEntity: useMutation(postEntity, {
      onSuccess: () => queryClient.invalidateQueries([QueryKeys.Entities]),
    }),
    // ...
  };
};
```

---

## Providers

### GlobalProvider

Main context provider for authentication and user state.

```typescript
const {
  isLoggedIn,      // Authentication status
  user,            // Current user
  organization,    // Current organization
  token,           // JWT token
  deploymentSettings,  // Deployment config
  loginUser,       // Login function
  logoutUser,      // Logout function
  updateUser,      // Update user state
  updateOrganization,  // Update org state
} = useAuth();
```

### ThemeProvider

Dark/light theme switching.

### LanguageProvider

Multi-language support.

### DirectusProvider

CMS content integration for UI labels.

---

## Layouts

### PrivateLayout

Main authenticated layout with sidebar navigation:
- Desktop: Fixed sidebar
- Mobile: Hamburger menu with slide-out sheet
- Role-based navigation filtering

### ProtectedRoute

Permission-based route guard:

```tsx
<Route element={<ProtectedRoute userPermissions={[UserPermission.Referrals]} />}>
  <Route path="/sent-referrals" element={<SentReferralsPage />} />
</Route>
```

### RoleBasedIndexRoute

Redirects `/` based on user role and permissions.

### DynamicRoute

Wrapper for dynamic routes (`:id` parameters).

### PublicPage

Layout for unauthenticated pages.

---

## Helpers

### constants.ts

Route definitions and navigation configuration:

```typescript
export enum APP_ROUTE {
  Users = '/users',
  Deduplication = '/deduplication',
  SentReferrals = '/sent-referrals',
  // ...
}

export const getNavigationItems = (cmsData) => [...]
```

### localStorage.ts

Typed localStorage wrapper:

```typescript
LocalStorage.getToken()
LocalStorage.setToken(token)
LocalStorage.getUser()
LocalStorage.setUser(user)
LocalStorage.getOrganization()
LocalStorage.setOrganization(org)
```

### pagination.ts

Pagination utilities for API requests.

### types.ts

Shared TypeScript types.

### utils.ts

General utility functions.

---

## Permissions

### UserPermission

```typescript
enum UserPermission {
  Deduplication = 'deduplication',
  Referrals = 'referrals',
  Booking = 'booking',
}
```

### UserRole

```typescript
enum UserRole {
  Admin = 'admin',
  User = 'user',
}
```

### Access Control

- **Admin**: Full access to all routes
- **User**: Access based on `permissions` array
- **Superadmin**: Redirected to `/settings`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `vite.config.ts` | Build config, path aliases (`@/`), security headers |
| `tailwind.config.cjs` | Tailwind customization |
| `tsconfig.json` | TypeScript config |
| `.eslintrc.cjs` | ESLint rules |
| `.prettierrc.json` | Code formatting |
| `components.json` | shadcn/ui component registry |

---

## Key Patterns

### Path Alias

Use `@/` for src imports:

```typescript
import { Button } from '@/components/ui/button';
import { useAuth } from '@/providers/GlobalProvider';
```

### Form Handling

React Hook Form + Zod validation:

```typescript
const schema = z.object({
  firstName: z.string().min(1, 'Required'),
  email: z.string().email(),
});

const form = useForm<FormData>({
  resolver: zodResolver(schema),
});
```

### Data Fetching

React Query with automatic cache invalidation:

```typescript
// Query
const { data, isLoading } = useReferrals({ currentPage, pageSize });

// Mutation
const { createReferral } = useReferralMutation();
await createReferral.mutateAsync(data);
```

### Toast Notifications

```typescript
import { useToast } from '@/components/ui/use-toast';

const { toast } = useToast();
toast({ title: 'Success', description: 'Item created' });
```
