# could-infrastructure-

A cloud infrastructure project with automated completion notifications.

## Notification Workflow

When the project design and implementation is complete, a GitHub Actions workflow
automatically notifies the repository owner by:

1. **Creating a GitHub issue** that mentions the owner, listing project status,
   pull request links, and testing instructions.
2. **Sending an email** (when SMTP secrets are configured) with the same
   information in a formatted HTML message.

### Triggers

The notification fires on any of the following events:

| Event | Condition |
|-------|-----------|
| Push to `main` or `master` | Any push |
| Pull request closed | Only when the PR is **merged** |
| Manual (`workflow_dispatch`) | Run the workflow from the Actions tab |

### Required Secrets (email only)

Configure the following repository secrets to enable email notifications
(**Settings → Secrets and variables → Actions → New repository secret**):

| Secret | Description |
|--------|-------------|
| `NOTIFY_EMAIL` | Recipient email address |
| `MAIL_SERVER`  | SMTP server hostname (e.g. `smtp.gmail.com`) |
| `MAIL_PORT`    | SMTP port (default: `587`) |
| `MAIL_USERNAME`| SMTP account username / sender address |
| `MAIL_PASSWORD`| SMTP account password or app password |

> If the email secrets are not set, the workflow skips the email step and only
> creates the GitHub issue notification.

### Manual Trigger

You can fire the notification at any time from the **Actions** tab:

1. Go to **Actions → Notify User on Project Completion**.
2. Click **Run workflow**.
3. Optionally add a custom message to include in the notification.
4. Click **Run workflow**.
