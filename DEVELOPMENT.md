# Local Development Setup

Guide for setting up the CCD Data Stewardship Platform locally.

## Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| .NET SDK | 8.0+ | [dotnet.microsoft.com](https://dotnet.microsoft.com/download) |
| Node.js | 18+ | [nodejs.org](https://nodejs.org/) |
| yarn | 1.22+ | `npm install -g yarn` |
| PostgreSQL | 14+ | Via Docker (recommended) or native install |

## Quick Start

```bash
# 1. Clone the repository
git clone <repo-url>
cd hotpot

# 2. Start PostgreSQL via Docker
cd server && docker-compose up -d

# 3. Run the server (Terminal 1)
cd server/Ccd.Server && dotnet run
# Server runs at http://localhost:5000

# 4. Run the client (Terminal 2)
cd client && yarn install && yarn dev
# Client runs at http://localhost:3000
```

## Database Setup

### Option A: Docker (Recommended)

```bash
cd server
docker-compose up -d
```

This creates:
- Database: `ccd-server`
- User: `ccd-server`
- Password: `test123`
- Port: `5432`

### Option B: Native PostgreSQL

```sql
CREATE DATABASE "ccd-server";
CREATE USER "ccd-server" WITH PASSWORD 'test123';
GRANT ALL PRIVILEGES ON DATABASE "ccd-server" TO "ccd-server";
```

## Environment Variables

### Server

The server uses `appsettings.json` for local development. Environment variables override these settings.

**Required:**

| Variable | Description | Default (appsettings.json) |
|----------|-------------|----------------------------|
| `DB_CONNECTION_STRING` | PostgreSQL connection | `Host=localhost;Database=ccd-server;Username=ccd-server;Password=test123` |
| `JWT_SECRET_KEY` | JWT signing key | Set in appsettings.json |
| `API_KEY` | API key authentication | Set in appsettings.json |

**Optional:**

| Variable | Description | Default |
|----------|-------------|---------|
| `WEB_APP_URL` | Frontend URL | `http://localhost:3000` |
| `API_URL` | API base URL | `http://localhost:5000` |
| `APP_URL` | Application URL | `http://localhost:5000` |
| `STORAGE_URL` | File storage URL | - |
| `STORAGE_PATH` | File storage path | - |
| `JWT_EXPIRATION_DAYS` | Token expiry | `365` |
| `SENDGRID_API_KEY` | SendGrid API key | - |
| `SENDGRID_SENDER_EMAIL` | Email sender | - |
| `SENDGRID_INVITATION_EMAIL_TEMPLATE_ID` | Invitation template | - |
| `SENDGRID_PASSWORD_RESET_EMAIL_TEMPLATE_ID` | Password reset template | - |
| `SENTRY_DSN` | Sentry error tracking | - |
| `SUPERADMIN_PASSWORD` | System user password | - |

### Client

Create `.env` file in `client/` directory:

```bash
VITE_API_URL=http://localhost:5000
VITE_DIRECTUS_URL=https://cms.example.com  # Optional: CMS for UI labels
VITE_DIRECTUS_TOKEN=your-token             # Optional
```

## Running the Stack

### Server

```bash
cd server/Ccd.Server
dotnet run
```

- Runs on `http://localhost:5000`
- Auto-applies pending migrations on startup
- Swagger UI at `http://localhost:5000/swagger/ui`
- Health check at `http://localhost:5000/health`

### Client

```bash
cd client
yarn install  # First time only
yarn dev
```

- Runs on `http://localhost:3000`
- Hot module replacement enabled
- Proxies API requests to server

## Useful Commands

### Server

```bash
# Build for production
npm run build

# Run tests
npm run test

# Check C# formatting
npm run check-formatting

# Create new migration
./Ccd.Server/create-migration.sh AddNewFeature
```

### Client

```bash
# Type check
yarn typecheck

# Lint
yarn lint

# Fix lint issues
yarn lint:fix

# Production build
yarn build
```

## Troubleshooting

### Database connection failed

1. Check PostgreSQL is running: `docker ps` or `pg_isready`
2. Verify connection string in `appsettings.json`
3. Ensure database exists: `psql -l | grep ccd-server`

### Migrations failing

1. Check for pending migrations: Server logs will show "Applying DB migrations"
2. Manual migration: `cd Ccd.Server && dotnet ef database update`

### Port already in use

```bash
# Find process on port 5000
lsof -i :5000

# Kill process
kill -9 <PID>
```

### Client can't reach server

1. Verify server is running at `http://localhost:5000`
2. Check `.env` has correct `VITE_API_URL`
3. Check browser console for CORS errors (shouldn't happen - server allows all origins)

## IDE Setup

### VS Code

Recommended extensions:
- C# Dev Kit (Microsoft)
- ESLint
- Prettier
- Tailwind CSS IntelliSense

### JetBrains Rider

- Open `server/server.sln` for backend
- Open `client/` folder separately for frontend

## Default Accounts

After initial migration, the system has:
- **SYSTEM_USER**: Superadmin account (password from `SUPERADMIN_PASSWORD` env var)

Create additional users via the API or directly in the database.
