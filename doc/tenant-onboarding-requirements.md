# FoundryX tenant onboarding requirements

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

To connect your organization to FoundryX, you need an eligible Microsoft Entra administrator role to approve the application permissions and complete tenant activation.

Onboarding connects your Microsoft Entra tenant to FoundryX so users can sign in. To register projects and grant access after onboarding, see [Admin Center permissions by page](admin-portal-permissions.md).

## Administrator requirements

You need one of these active Microsoft Entra built-in roles (or a custom role with permissions to grant tenant-wide admin consent for the delegated permissions below):

- Application Administrator
- Cloud Application Administrator
- AI Administrator
- Privileged Role Administrator
- Global Administrator

If your role is assigned through Privileged Identity Management (PIM), activate it before you begin.

These are **Microsoft Entra roles**, not Azure subscription roles. You don't need Azure subscription Owner to onboard a tenant, and Application Developer cannot grant tenant-wide consent. For background on consent roles, see [Grant tenant-wide admin consent to an application](https://learn.microsoft.com/entra/identity/enterprise-apps/grant-admin-consent#prerequisites).

## Preflight role check

Before you open your onboarding invitation, you can run the preflight PowerShell script to check whether your signed-in account has one of the built-in roles above:

1. Download [`Check-FoundryXAdminConsentRole.ps1`](https://github.com/microsoft/FoundryX/releases/download/Check-FoundryXAdminConsentRole-v1/Check-FoundryXAdminConsentRole.ps1).
2. Open Windows PowerShell in the download folder and unblock the file:

   ```powershell
   Unblock-File .\Check-FoundryXAdminConsentRole.ps1
   ```

3. Run the script with your tenant ID:

   ```powershell
   .\Check-FoundryXAdminConsentRole.ps1 -t <customer-tenant-id>
   ```

4. Sign in with the administrator account you plan to use for onboarding. If Azure command-line interface (CLI) isn't installed, the script installs it with Windows Package Manager.
5. Check the output:
   - `"eligible": true` means the script found an active built-in role from the list above.
   - `"eligible": false` means none of those active built-in roles appeared in your token. If you use PIM, activate your role and sign in again. If you use a qualifying custom role, you can still continue to the Microsoft Entra consent page.

## Complete consent and tenant setup

Open the onboarding invitation link from your FoundryX contact. On **Connect your organization to FoundryX**, select **Start onboarding** and complete these steps:

1. **Approve the FoundryX application programming interface (API) permissions** on the Microsoft Entra consent page. This step creates the FoundryX API enterprise application in your tenant.
2. **Approve the Admin Center and CLI sign-in permissions** when redirected. Both clients are preauthorized to call the FoundryX API.
3. **Confirm activation.** Wait until the page displays **Your organization is connected to FoundryX**.

### Application permissions to approve

All approved permissions are **delegated** permissions, which means FoundryX acts on behalf of the signed-in user:

| Service | Delegated permission | Purpose |
| --- | --- | --- |
| Microsoft Graph | `User.ReadBasic.All` | Search for users and read basic profile details. |
| Microsoft Graph | `GroupMember.Read.All` (with `User.ReadBasic.All`) | Search for groups and check group membership for project access. |
| Azure Resource Manager (ARM) | `user_impersonation` | Check subscription permissions and manage Azure resources as the signed-in administrator. |
| Microsoft Foundry | `user_impersonation` | Read native project tools and Toolboxes as the signed-in user when delegated discovery is used. |
| FoundryX API | `access_as_user` (plus standard sign-in scopes) | Sign users in and allow the Admin Center and CLI to call the FoundryX API. |

## What onboarding does and does not grant

Onboarding activates your tenant and approves delegated app permissions. It does **not**:

- Give the FoundryX service principal access to your Azure subscriptions or Foundry projects.
- Give employees access to any Foundry project.

After onboarding, an Azure subscription administrator registers each project and assigns users **Consumer**, **User**, **Manager**, or **Owner** access in the Admin Center.

## Who can sign in after onboarding?

**Any user in your active tenant can sign in to the Admin Center**, as long as your organization's Microsoft Entra sign-in policies allow it. Users don't need an Entra administrator role, an Azure role, or a FoundryX role just to sign in. Guests must sign in using your tenant's sign-in link.

On the completion page, select **Sign in to FoundryX**, or select **Share** to copy the tenant-specific sign-in link for your team (share the sign-in link, not your onboarding invitation).

Next:

1. Review [Admin Center permissions by page](admin-portal-permissions.md).
2. Follow the [Walkthrough: Grant project access](register-project-permissions.md) to register your first project.

## Troubleshoot onboarding

| Issue | What to do |
| --- | --- |
| **Administrator consent was not granted** | Activate an eligible role in PIM or sign in with an eligible administrator account, then reopen the invitation before it expires. |
| **Tenant onboarding could not be completed** or activation cannot be verified | Try the invitation link again. If the error continues, contact FoundryX support with the displayed request ID before registering projects. |
| **Invitation expired** | Request a new invitation link from your FoundryX contact. |
