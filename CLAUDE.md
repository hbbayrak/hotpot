# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CCD Data Stewardship Platform - a humanitarian data sharing platform enabling aid organizations to manage beneficiary data collectively. Features deduplication, referrals between organizations, and beneficiary data access.

## Commands

### Server (.NET 8)

```bash
# From server/ directory
cd server

# Build for production (Linux x64)
npm run build

# Run tests
npm run test
# Or directly: cd Ccd.Tests && dotnet test

# Run single test
cd Ccd.Tests && dotnet test --filter "FullyQualifiedName~TestClassName.TestMethodName"

# Check C# formatting
npm run check-formatting

# Run locally
cd Ccd.Server && dotnet run
```

### Client (React + Vite)

```bash
# From client/ directory
cd client

# Dev server
yarn dev

# Production build
yarn build

# Lint (ESLint + Stylelint)
yarn lint

# Fix lint issues
yarn lint:fix

# Type check only
yarn typecheck
```

## Architecture

### Backend (server/Ccd.Server/)

**Pattern**: Controller-Service-Repository with feature-based Areas

```
Areas/                    # Feature modules
├── Authentication/       # JWT auth
├── Beneficiaries/        # Beneficiary CRUD
├── Deduplication/        # Duplicate detection with FuzzySharp
├── Referrals/           # Inter-org referral workflow
├── Organizations/        # Multi-tenancy
└── ...                   # 15 total areas

Data/
├── CcdContext.cs         # EF Core DbContext
└── SoftDelete.cs         # Soft delete pattern

Helpers/                  # Utilities, extensions, attributes
Migrations/               # EF Core migrations (100+)
```

**Key patterns**:
- Multi-tenancy: Organization ID in request header filters all queries
- Soft deletes via `IIsDeleted` interface
- Snake_case column naming (PostgreSQL)
- AutoMapper for DTO mapping
- JWT Bearer + API key authentication

### Frontend (client/src/)

**Stack**: React 18 + TypeScript + TanStack Query + Radix UI + Tailwind

```
modules/                  # Feature pages (17 modules)
├── BeneficiaryList/
├── DeduplicationPage/
├── Referrals/
└── ...

components/
├── ui/                   # Radix UI wrappers (~35 components)
└── DataTable/            # Sortable/searchable tables

services/                 # API layer (axios + interceptors)
providers/                # Context (auth, theme, language)
layouts/                  # Route wrappers
```

**Key patterns**:
- `services/api.ts`: Axios instance with auth header injection
- React Query for server state
- React Hook Form + Zod for forms
- Protected routes with permission checks

## Database

- PostgreSQL with EF Core
- Migrations auto-run on startup
- Dapper used alongside EF Core for complex queries

## Key Domain Concepts

- **Beneficiary**: Individual receiving aid
- **Booking**: Assignment of beneficiary to assistance
- **Deduplication**: Fuzzy matching to find duplicate records
- **Referral**: Beneficiary transfer between organizations
- **List**: Uploaded dataset of beneficiaries

## API

Base: `/api/v1`

Controllers map to Areas (e.g., `BeneficiaryController`, `ReferralController`, `DeduplicationController`)

Paginated responses with standard metadata.