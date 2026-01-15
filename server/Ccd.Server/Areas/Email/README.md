# Email Area

## Purpose

Handles email composition and sending for system notifications. Uses embedded HTML templates with placeholder substitution.

## Services

### EmailManagerService

Composes and sends templated emails using embedded HTML resources:

| Method | Description |
|--------|-------------|
| `SendWelcomeMail(to, firstName, activationLink)` | Welcome email with account activation link |
| `SendAccountReadyMail(to, firstName, profilePageLink, searchPageLink)` | Account activated confirmation |
| `SendForgotPasswordMail(to, firstName, resetPasswordLink)` | Password reset request email |
| `SendResetPasswordMail(to, firstName, searchPageLink)` | Password reset confirmation |

**Template Files** (Embedded Resources):
- `Emails/Welcome.html`
- `Emails/AccountReady.html`
- `Emails/ForgotPassword.html`
- `Emails/ResetPasswordConfirm.html`

### SendGridService

Low-level SendGrid API integration:

| Method | Description |
|--------|-------------|
| `SendEmail(to, templateId, templateData)` | Send email using SendGrid dynamic template |

**Configuration:**
- `SendgridApiKey` - API key from StaticConfiguration
- `SendgridSenderEmail` - Sender email address

### ISendGridService

Interface for SendGridService.

### INotificationService / NotificationService

Generic notification interface (currently a stub/placeholder for future email provider abstraction).

## Template Placeholders

Templates use `{{ VariableName }}` syntax:
- `{{ FirstName }}`
- `{{ ActivationLink }}`
- `{{ ProfilePageLink }}`
- `{{ SearchPageLink }}`
- `{{ ResetPasswordLink }}`

## Notes

- HTML templates are embedded resources compiled into the assembly
- SendGrid dynamic templates are used for password reset (configured via `SendgridPasswordResetEmailTemplateId`)
- EmailManagerService wraps template loading and placeholder substitution
- SendGridService handles actual email delivery via SendGrid API
