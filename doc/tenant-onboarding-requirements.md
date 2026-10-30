# FoundryX tenant onboarding requirements

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

This document records the requirements in the FoundryX tenant onboarding guide. The guide describes onboarding for the FoundryX private preview.

## Administrator requirements

An administrator who completes onboarding must have one of these active Microsoft Entra built-in roles:

- Application Administrator
- Cloud Application Administrator
- Privileged Role Administrator
- Global Administrator

The role must allow the administrator to grant tenant-wide admin consent for the delegated permissions shown during onboarding. If the required role is eligible through Privileged Identity Management (PIM), activate it before starting.

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

The permissions support these operations:

- Microsoft Graph delegated access lets FoundryX find users and evaluate group-based project access.
- Azure Resource Manager delegated access lets FoundryX act within the signed-in user's existing Azure role-based access control (RBAC) assignments.
- Portal and CLI sign-in permissions identify the user and keep the user's session active.

## Permission boundary

Onboarding does not grant the FoundryX enterprise applications access to a specific Azure resource. It does not assign a service principal an Azure subscription, resource group, or Foundry resource role.

The delegated permissions allow the FoundryX API to request Microsoft Graph and Azure Resource Manager tokens on behalf of the signed-in user. Delegated Azure management operations remain limited by that user's existing Azure RBAC assignments.

Project registration is a separate step. An authorized subscription administrator grants the customer-tenant FoundryX service identity access to the selected resources. FoundryX can then authorize employees through project membership and resource policies without assigning Azure roles to each employee. See [administration concepts and reference](enterprise-admin-agent-access.md) for the access model, or follow the [registration walkthrough](register-project-permissions.md) to set up a project permission.

## Completion criteria

After consent, FoundryX must:

- Verify that API, Portal, and CLI consent completed for the same tenant and that the FoundryX API service principal is available.
- Activate the tenant for the FoundryX private preview.

After activation, users can sign in with work or school accounts. Access to registered FoundryX projects requires a matching project grant and remains subject to the project's model and tool policy. Subscription management operations still require the administrator's Azure authority.

Select **Sign in to FoundryX** on the completion page to use the tenant-specific
sign-in link. **Share** shares that link, or copies it when browser sharing is not
available. Share the sign-in link with employees, not the onboarding invitation.
Next, an authorized subscription administrator must create or connect a project
and grant access through the [project access walkthrough](register-project-permissions.md).

## If onboarding does not complete

| Result | Action |
| --- | --- |
| **Administrator consent was not granted** | The organization is not activated. Reopen the invitation with an eligible administrator before it expires. Permissions approved in earlier steps can remain in Microsoft Entra. |
| **Tenant onboarding could not be completed** | Try the original invitation again. If the error continues, contact FoundryX support with the displayed request ID. |
| **Confirming tenant onboarding** cannot verify activation | Do not assume the tenant is active. Resolve the reported error with support before granting project access. |
| Invitation expired | Ask your FoundryX contact for a replacement invitation. |
