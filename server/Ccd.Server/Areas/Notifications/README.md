# Notifications Area

## Purpose

Provides notification infrastructure for the platform. Currently a placeholder/stub for future notification capabilities.

## Services

### INotificationService

Interface for notification services:

```csharp
Task SendEmail(string to, string subject, string message, Dictionary<string, string> filesBase64 = null)
```

### NotificationService

Current implementation is a stub (TODO: send email). Used as abstraction layer for email sending.

## Models

### INSNotificationSettings

Configuration model for notification providers:

| Property | Type | Description |
|----------|------|-------------|
| EmailProvider | string | Email service provider |
| SendgridApiKey | string | SendGrid API key |
| SendgridSenderEmail | string | SendGrid sender address |
| MailgunApiKey | string | Mailgun API key |
| MailgunBaseUrl | string | Mailgun API URL |
| MailgunDomain | string | Mailgun domain |
| MailgunSenderEmail | string | Mailgun sender address |
| PushProvider | string | Push notification provider |
| OnesignalAppId | string | OneSignal app ID |
| OnesignalAppKey | string | OneSignal API key |

### INSNotificationRequest

Request model for notifications.

### INSNotificationType

Enum/constants for notification types.

## Notes

- Currently integrated via `EmailManagerService` which uses `INotificationService`
- Supports multiple email providers (SendGrid, Mailgun) in configuration
- Push notification support (OneSignal) configured but not implemented
- Designed for extensibility to add SMS, push, or other notification channels
