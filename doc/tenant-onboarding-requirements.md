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

1. Download [`Check-FoundryXAdminConsentRole.ps1`](https://github.com/8cd88b23-f986-4c2d-9acc-2d18d2217672).
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

The administrator completes these steps in order:

1. **Create the FoundryX enterprise applications.** Microsoft Entra creates service principals for the FoundryX API, Portal, and CLI in the customer tenant.
2. **Approve delegated permissions.** Approve the API permissions first, then approve the standard sign-in permissions for the Portal and CLI. The invitation page displays the current API scope names before onboarding begins.

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

- Verify that API, Portal, and CLI consent completed for the same tenant.
- Activate the tenant for the FoundryX private preview.

After activation, users can sign in with work or school accounts. Access to registered FoundryX projects requires a matching project grant and remains subject to the project's model and tool policy. Subscription management operations still require the administrator's Azure authority.
