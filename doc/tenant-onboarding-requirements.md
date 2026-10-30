# FoundryX tenant onboarding requirements

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

To connect a tenant to FoundryX, an eligible Microsoft Entra administrator must
approve the application permissions and complete tenant activation.

For permissions needed **after onboarding**, see
[Admin Center permissions by page](admin-portal-permissions.md). Successful
onboarding does not grant subscription management or native Foundry data access
to the person who signs in to the Admin Center.

## Administrator requirements

An administrator who completes onboarding must have one of these active Microsoft Entra built-in roles:

- Application Administrator
- Cloud Application Administrator
- Privileged Role Administrator
- Global Administrator

The administrator uses this role to approve application permissions for the
tenant. If the role is eligible through Privileged Identity Management (PIM),
activate it before starting.

These are **Microsoft Entra roles**, not Azure subscription roles. Subscription
Owner is not required for tenant onboarding. Employees do not need an Entra
administrator role to sign in after onboarding.

## Preflight role check

Before opening the invitation, run the FoundryX role-check script with the customer tenant ID:

1. Download [`Check-FoundryXAdminConsentRole.ps1`](Check-FoundryXAdminConsentRole.ps1) from this repository.
2. Open Windows PowerShell in the folder that contains the script.
3. Unblock the downloaded file:

   ```powershell
   Unblock-File .\Check-FoundryXAdminConsentRole.ps1
   ```

4. Run the script with the customer tenant ID:

   ```powershell
   .\Check-FoundryXAdminConsentRole.ps1 -t <customer-tenant-id>
   ```

5. Sign in with the account that will approve consent. The script uses Azure CLI and installs it with Windows Package Manager if it is not already available.
6. Continue when the JSON result contains `"eligibleRoleDetected": true`. If the result is `false`, activate an eligible PIM role or ask an administrator with one of the roles above to complete onboarding.

The preflight checks active built-in roles only. It cannot detect inactive PIM eligibility or custom roles. The Microsoft Entra admin-consent page is the final authority on whether the account can grant consent.

## Consent and tenant setup

Open the invitation supplied by your FoundryX contact. The welcome page is
titled **Connect your organization to FoundryX**. Use **Learn about onboarding**
to review these requirements, then select **Start onboarding** with an eligible
Microsoft Entra administrator account. An expired invitation needs a replacement;
changing accounts does not extend it.

The administrator completes these steps in order:

1. **Approve the FoundryX API permissions.** Review the permissions on the Microsoft Entra consent page. Microsoft Entra creates the FoundryX API enterprise application in the customer tenant.
2. **Complete the Portal and CLI consent steps.** Follow the redirects and approve the standard sign-in permissions. The Portal and CLI are preauthorized clients of the API; FoundryX access does not require separate customer-tenant service principals for them.
3. **Wait for activation to be verified.** Continue only when the result page says **Your organization is connected to FoundryX**. A success redirect alone is not proof of activation.

### Application permissions to approve

| Service | Delegated permission | Why FoundryX needs it |
| --- | --- | --- |
| Microsoft Graph | `User.ReadBasic.All` | Find users and read their basic profiles. |
| Microsoft Graph | `GroupMember.Read.All`, together with `User.ReadBasic.All` | Find groups, read group membership, and check group-based access. |
| Azure Resource Manager (ARM) | `user_impersonation` | Check subscription roles and read or manage Azure resources as the signed-in user. |
| Microsoft Foundry | `user_impersonation` | List native Toolboxes as the signed-in user. |
| FoundryX API, through the Portal and CLI | `access_as_user`, plus the sign-in permissions shown during consent | Sign users in and let the clients call the API for them. |

"Delegated" means FoundryX acts on behalf of the signed-in user. The API obtains
the Graph, ARM, and Foundry tokens; users do not supply these tokens themselves.
Application consent does not remove directory or guest restrictions.

## Permission boundary

**Consent is not project access.** Onboarding does not assign Azure resource
roles to employees or to the FoundryX service principal. It also does not assign
FoundryX project roles to employees.

When FoundryX reads Azure or native Foundry resources as the signed-in user,
that user still needs the required resource permissions. For example, Azure
subscription Owner alone does not permit native Toolbox reads.

After onboarding, an authorized subscription administrator registers a project
and grants access. Registration gives the customer tenant's FoundryX service
principal access to the selected Azure resources. The administrator separately
assigns employees Consumer, User, Manager, or Owner access to that project
through FoundryX. These project access grants (ACL entries) do not assign Azure
roles to employees and are not prerequisites for tenant onboarding.

## Completion criteria

After consent, FoundryX must:

- Verify that API, Portal, and CLI consent completed for the same tenant and that the FoundryX API service principal is available.
- Activate the tenant for the FoundryX private preview.

## Who can sign in after onboarding?

**Any user in the active tenant can sign in to the Admin Center**, subject to the
organization's Microsoft Entra sign-in policies. No Entra administrator, Azure
subscription, or FoundryX project role is required just to sign in. Guests must
use their identity in the onboarded tenant.

Signing in does not grant project access. Users need an individual, group, or
tenant-wide FoundryX grant to use a project. Subscription administrators can
also view and manage registered projects in their subscriptions.

Select **Sign in to FoundryX** on the completion page to use the tenant-specific
sign-in link. **Share** shares that link, or copies it when browser sharing is not
available. Share the sign-in link with employees, not the onboarding invitation.
Next, review [who can grant access and what each project role allows](admin-portal-permissions.md),
then follow the [project access walkthrough](register-project-permissions.md).

## If onboarding does not complete

| Result | Action |
| --- | --- |
| **Administrator consent was not granted** | The organization is not activated. Reopen the invitation with an eligible administrator before it expires. Permissions approved in earlier steps can remain in Microsoft Entra. |
| **Tenant onboarding could not be completed** | Try the original invitation again. If the error continues, contact FoundryX support with the displayed request ID. |
| **Confirming tenant onboarding** cannot verify activation | Do not assume the tenant is active. Resolve the reported error with support before granting project access. |
| Invitation expired | Ask your FoundryX contact for a replacement invitation. |
