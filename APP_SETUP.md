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

### Disable CSP for Development

Edit `client/index.html` and comment out the Content-Security-Policy meta tag:

```html
<!-- CSP disabled for development - re-enable for production -->
<!-- <meta http-equiv="Content-Security-Policy" content="script-src 'self';" /> -->
```

### Install Dependencies and Run

```bash
cd client
yarn install
yarn dev
```

The client will be available at http://localhost:3000

## Step 4: Initial Deployment Settings

1. Open http://localhost:3000
2. Login with superadmin credentials:
   - **Username**: `superadmin`
   - **Password**: `superadmin_password`

3. Configure deployment settings:

| Field | Value |
|-------|-------|
| Deployment Name | `Local Dev` |
| Deployment Country | `Ireland` |
| Admin Level 1 Name | `Province` |
| Admin Level 2 Name | `County` |
| Admin Level 3 Name | `Municipal District` |
| Admin Level 4 Name | `Electoral Division` |
| Metabase Iframe URL | (leave default) |

4. Add funding sources:
   - Keep existing: `BHA`, `Other`
   - Add: `FCDO`, `ECHO`

5. Click **Save settings**

## Step 5: Create Organization and User

The superadmin account is only for deployment settings. You need to create an organization and a regular user to use the full application.

### Get Authentication Token

```bash
TOKEN=$(curl -s -X POST http://localhost:5000/api/v1/authentication/login \
  -H "Content-Type: application/json" \
  -d '{"username":"superadmin","password":"superadmin_password"}' | jq -r '.token')

echo $TOKEN
```

### Create Organization

```bash
curl -s -X POST http://localhost:5000/api/v1/organizations \
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
  }'
```

Save the returned organization `id` for the next step.

### Create User

Due to email service configuration, creating users via API may fail. Use this database approach instead:

```bash
# Replace ORG_ID with your organization ID from the previous step
ORG_ID="your-organization-id-here"

# Create user
docker exec ccd-postgres psql -U ccd-server -d ccd-server -c "
INSERT INTO \"user\" (id, email, password, first_name, last_name, language, activated_at, created_at, updated_at, is_deleted)
VALUES (
  'a1111111-1111-1111-1111-111111111111',
  'test@test.com',
  'placeholder',
  'Test',
  'User',
  'en',
  NOW(),
  NOW(),
  NOW(),
  false
);"

# Link user to organization
docker exec ccd-postgres psql -U ccd-server -d ccd-server -c "
INSERT INTO user_organization (organization_id, user_id, role, permissions)
VALUES (
  '$ORG_ID',
  'a1111111-1111-1111-1111-111111111111',
  'admin',
  '[\"Deduplication\", \"Referrals\", \"Booking\"]'
);"
```

### Set User Password

```bash
curl -s -X PATCH http://localhost:5000/api/v1/users/a1111111-1111-1111-1111-111111111111 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "organization-id: $ORG_ID" \
  -d '{"password": "password123"}'
```

## Step 6: Login and Use the Application

1. Go to http://localhost:3000
2. Login with your new user:
   - **Email**: `test@test.com`
   - **Password**: `password123`

You should now see the full application with sidebar navigation.

## Quick Reference

### Default Credentials

| Account | Username/Email | Password |
|---------|----------------|----------|
| Superadmin | `superadmin` | `superadmin_password` |
| Test User | `test@test.com` | `password123` |

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
- Ensure CSP meta tag is commented out in `index.html`
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
