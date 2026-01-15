# Local Development Setup Guide

This guide walks you through setting up the CCD Data Stewardship Platform for local development.

## Prerequisites

- **Docker** - For running PostgreSQL
- **Node.js 18+** and **Yarn** - For the client
- **.NET 8 SDK** - For the server

### Installing .NET 8 on macOS

```bash
brew install dotnet@8

# Add to your shell (add to ~/.zshrc for persistence)
export DOTNET_ROOT="/opt/homebrew/opt/dotnet@8/libexec"
export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
```

## Step 1: Start PostgreSQL Database

Start a PostgreSQL container with the default credentials:

```bash
docker run -d \
  --name ccd-postgres \
  -e POSTGRES_USER=ccd-server \
  -e POSTGRES_PASSWORD=test123 \
  -e POSTGRES_DB=ccd-server \
  -p 5432:5432 \
  postgres:16
```

Wait for PostgreSQL to be ready:

```bash
docker exec ccd-postgres pg_isready -U ccd-server -d ccd-server
```

### Useful Database Commands

```bash
# Connect to database
docker exec -it ccd-postgres psql -U ccd-server -d ccd-server

# Stop container
docker stop ccd-postgres

# Start container again
docker start ccd-postgres

# Remove container (to start fresh)
docker rm ccd-postgres
```

## Step 2: Configure and Run the Server

The server configuration is in `server/Ccd.Server/appsettings.json`. The default settings should work with the Docker PostgreSQL setup above.

### macOS Port 5000 Conflict

On macOS, port 5000 is used by AirPlay Receiver. Either:

1. **Disable AirPlay Receiver**: System Settings → General → AirDrop & Handoff → AirPlay Receiver → Off
2. **Or change the port** in `server/Ccd.Server/Program.cs` line 21

### Run the Server

```bash
cd server/Ccd.Server
dotnet run
```

The server will automatically run database migrations on startup. You should see:

```
CCD Server initializing...
Applying DB migrations
Now listening on: http://0.0.0.0:5000
```

## Step 3: Configure and Run the Client

### Create Environment File

Create `client/.env` with:

```env
VITE_API_URL=http://localhost:5000
VITE_DIRECTUS_URL=http://localhost:8055
VITE_DIRECTUS_TOKEN=placeholder
```

### Install Dependencies and Run

```bash
cd client
yarn install
yarn dev
```

The client will be available at http://localhost:3000

> **Note**: The CSP (Content Security Policy) is automatically disabled in development mode via a Vite plugin. No manual editing of `index.html` is required.

## Step 4: Initial Setup (UI-based)

1. Open http://localhost:3000
2. Login with superadmin credentials:
   - **Username**: `superadmin`
   - **Password**: `superadmin_password`

3. You'll see the **Deployment Settings** page with an **Initial Setup Required** section at the top.

### Configure Deployment Settings

| Field | Example Value |
|-------|---------------|
| Deployment Name | `Local Dev` |
| Deployment Country | `Ireland` |
| Admin Level 1 Name | `Province` |
| Admin Level 2 Name | `County` |
| Admin Level 3 Name | `Municipal District` |
| Admin Level 4 Name | `Electoral Division` |
| Metabase Iframe URL | (leave default) |

Add funding sources:
- Keep existing: `BHA`, `Other`
- Add: `FCDO`, `ECHO`

Click **Save settings**.

### Create First Organization and Admin User

In the **Initial Setup Required** section:

1. **Organization Details**:
   - Enter organization name (e.g., "Test Organization")
   - Toggle the services your organization provides (MPCA, WASH, Shelter, etc.)

2. **Admin User Details**:
   - First Name: `Test`
   - Last Name: `User`
   - Email: `test@test.com`
   - Password: (min 8 characters, e.g., `password123`)
   - Select permissions (Deduplication, Referrals, Booking)

3. Click **Complete Initial Setup**

## Step 5: Login as Admin User

1. Click "Back to Sign In" at the bottom of the Settings page
2. Login with your new admin credentials:
   - **Email**: `test@test.com`
   - **Password**: `password123`

You should now see the full application with sidebar navigation.

## Quick Reference

### Default Credentials

| Account | Username/Email | Password |
|---------|----------------|----------|
| Superadmin | `superadmin` | `superadmin_password` |
| Admin User (after setup) | `test@test.com` | `password123` |

### URLs

| Service | URL |
|---------|-----|
| Client | http://localhost:3000 |
| Server API | http://localhost:5000 |
| API Docs | http://localhost:5000/swagger (if enabled) |

### Database Connection

```
Host: localhost
Port: 5432
Database: ccd-server
Username: ccd-server
Password: test123
```

## Troubleshooting

### White/blank page on client

- Check browser console (F12) for errors
- Ensure `.env` file exists with correct `VITE_API_URL`
- Restart the client after changing `.env`

### Port 5000 already in use

On macOS, disable AirPlay Receiver or change the port in `Program.cs`

### Database connection errors

Ensure PostgreSQL container is running:
```bash
docker ps | grep ccd-postgres
```

### .NET version issues

Ensure you're using .NET 8:
```bash
dotnet --version  # Should be 8.x.x
```

### Email sending warnings

When creating users locally, you may see a warning in the server console about failed email sending. This is expected in local development without SendGrid configured - the user will still be created successfully.

### Stale session / infinite redirect loop

If you reset the database while the browser has old session data, the app will automatically detect the stale token (401/403 responses) and clear localStorage, then reload. This is handled automatically.

If you still experience issues, manually clear localStorage:
```javascript
// Run in browser console
localStorage.clear(); location.reload();
```

---

## Advanced: Manual Setup (Alternative)

If you prefer to create the organization and user via API/database instead of the UI:

### Get Authentication Token

```bash
TOKEN=$(curl -s -X POST http://localhost:5000/api/v1/authentication/login \
  -H "Content-Type: application/json" \
  -d '{"username":"superadmin","password":"superadmin_password"}' | jq -r '.token')
```

### Create Organization

```bash
ORG_RESPONSE=$(curl -s -X POST http://localhost:5000/api/v1/organizations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Test Organization",
    "isMpcaActive": true,
    "isWashActive": true,
    "isShelterActive": true,
    "isFoodAssistanceActive": true,
    "isLivelihoodsActive": true,
    "isProtectionActive": true,
    "activities": []
  }')

ORG_ID=$(echo $ORG_RESPONSE | jq -r '.id')
echo "Organization ID: $ORG_ID"
```

### Create User via API

```bash
curl -s -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "organization-id: $ORG_ID" \
  -d '{
    "email": "test@test.com",
    "firstName": "Test",
    "lastName": "User",
    "password": "password123",
    "organizationId": "'$ORG_ID'",
    "role": "admin",
    "permissions": ["deduplication", "referral", "booking"]
  }'
```
