# Email Templates

HTML email templates for transactional emails.

## Overview

The application sends transactional emails via SendGrid for:
- User account activation
- Password reset
- Account confirmation

## Architecture

```
EmailManagerService          # Loads templates, replaces variables
        ↓
INotificationService         # Email abstraction
        ↓
SendGridService             # SendGrid API integration
```

## Templates

### Welcome.html

**Trigger:** New user account created (invitation sent)

**Subject:** "Welcome to Ccd"

**Variables:**
| Variable | Description |
|----------|-------------|
| `{{ FirstName }}` | User's first name |
| `{{ ActivationLink }}` | Account activation URL |

**Content:** Welcome message with activation button

---

### AccountReady.html

**Trigger:** Account activated and ready for use

**Subject:** "Welcome to Ccd!"

**Variables:**
| Variable | Description |
|----------|-------------|
| `{{ FirstName }}` | User's first name |
| `{{ ProfilePageLink }}` | Link to user profile |
| `{{ SearchPageLink }}` | Link to search/main page |

**Content:** Confirmation message with navigation links

---

### ForgotPassword.html

**Trigger:** User requests password reset

**Subject:** "Reset Password Request for Ccd Account"

**Variables:**
| Variable | Description |
|----------|-------------|
| `{{ FirstName }}` | User's first name |
| `{{ ResetPasswordLink }}` | Password reset URL |

**Content:** Reset link with security warning

---

### ResetPasswordConfirm.html

**Trigger:** Password successfully reset

**Subject:** "Reset Password Confirmation"

**Variables:**
| Variable | Description |
|----------|-------------|
| `{{ FirstName }}` | User's first name |
| `{{ SearchPageLink }}` | Link to search/main page |

**Content:** Confirmation message with link back to app

## Template Design

All templates feature:
- Responsive HTML (MJML-style tables)
- Microsoft Outlook compatibility
- Branded header with logo
- Footer with disclaimers
- Variable replacement using `{{ VariableName }}` syntax

## Configuration

Environment variables for SendGrid:

| Variable | Description |
|----------|-------------|
| `SENDGRID_API_KEY` | SendGrid API authentication key |
| `SENDGRID_SENDER_EMAIL` | From email address |
| `SENDGRID_INVITATION_EMAIL_TEMPLATE_ID` | Optional: SendGrid template ID |
| `SENDGRID_PASSWORD_RESET_EMAIL_TEMPLATE_ID` | Optional: SendGrid template ID |

## Usage

Templates are embedded resources, loaded via `EmailManagerService`:

```csharp
// In your service
public class MyService
{
    private readonly EmailManagerService _emailManager;

    public async Task InviteUser(User user, string activationLink)
    {
        await _emailManager.SendWelcomeMail(
            user.Email,
            user.FirstName,
            activationLink
        );
    }
}
```

## Adding a New Template

1. **Create HTML file** in `Emails/` folder:
   ```
   Emails/
   └── MyNewTemplate.html
   ```

2. **Mark as embedded resource** in `.csproj`:
   ```xml
   <ItemGroup>
     <EmbeddedResource Include="Emails\MyNewTemplate.html" />
   </ItemGroup>
   ```

3. **Add method to EmailManagerService**:
   ```csharp
   public async Task SendMyNewMail(string to, string firstName, string customVar)
   {
       var resourceStream = typeof(EmailManagerService).Assembly.GetManifestResourceStream(
           "Ccd.Server.Emails.MyNewTemplate.html"
       );
       using var reader = new StreamReader(resourceStream, Encoding.UTF8);

       var html = reader.ReadToEnd();

       html = html.Replace("{{ FirstName }}", firstName);
       html = html.Replace("{{ CustomVar }}", customVar);

       await _notificationService.SendEmail(to, "My Subject", html);
   }
   ```

4. **Call from your service**:
   ```csharp
   await _emailManager.SendMyNewMail(email, firstName, customValue);
   ```

## Template Structure

```html
<!doctype html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    /* Inline styles for email client compatibility */
  </style>
</head>
<body>
  <!-- Header with logo -->
  <table>
    <tr>
      <td>
        <img src="https://new.ccdcapital.com/logo.png" alt="CCD Logo">
      </td>
    </tr>
  </table>

  <!-- Content -->
  <table>
    <tr>
      <td>
        <h1>Hello {{ FirstName }},</h1>
        <p>Your message here...</p>
        <a href="{{ ActionLink }}">Button Text</a>
      </td>
    </tr>
  </table>

  <!-- Footer -->
  <table>
    <tr>
      <td>
        <p>Footer disclaimers and links</p>
      </td>
    </tr>
  </table>
</body>
</html>
```

## Notes

- Templates use table-based layout for email client compatibility
- Inline CSS is preferred over external stylesheets
- Test templates with [Litmus](https://litmus.com/) or similar tools
- Logo URL is hardcoded - update if domain changes
