# Authentication Area

## Purpose

Handles user authentication, account activation, and password management. Generates JWT tokens for authenticated sessions.

## Route

`/api/v1/authentication`

## Controller

### AuthenticationController

| Method | Endpoint | Permission | Description |
|--------|----------|------------|-------------|
| POST | `/login` | Public | Authenticate user with email/password |
| POST | `/activation` | Public | Activate user account with activation code |
| POST | `/forgot-password` | Public | Request password reset email |
| POST | `/reset-password` | Public | Reset password with reset code |

## Services

### AuthenticationService

- `Authenticate(email, password)` - Validates credentials, returns JWT token with user data and organization roles
- `Activate(email, activationCode)` - Activates user account, sends account ready email
- `ForgotPassword(email)` - Generates password reset code, sends reset email via SendGrid
- `ResetPassword(email, code, password)` - Validates reset code and updates password

**Special Cases:**
- Superadmin login uses static password from configuration
- System user (SYSTEM_USER) has special handling

## Request/Response Models

### UserLoginRequest
- `Username` (email)
- `Password`

### UserAuthenticationResponse
- JWT token
- User data
- List of organizations with roles

### ForgotPasswordRequest / ResetPasswordRequest
- Email and reset code handling

## Dependencies

- `UserService` - User lookup and updates
- `EmailManagerService` - Welcome/account ready emails
- `SendGridService` - Password reset emails via SendGrid templates
- `AuthenticationHelper` - Password hashing/verification, JWT token generation

## Notes

- JWT tokens include organization-scoped roles
- Password hashing uses salt from User entity
- Activation codes are one-time use GUIDs
