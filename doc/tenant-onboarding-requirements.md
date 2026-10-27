# FoundryX tenant onboarding requirements

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

1. Download `Check-FoundryXAdminConsentRole.ps1` from the onboarding guide. The repository copy is `doc/Check-FoundryXAdminConsentRole.ps1`.
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

The permissions allow the FoundryX API to request Microsoft Graph and Azure Resource Manager tokens on behalf of the signed-in user. Each Azure operation remains limited by that user's existing Azure RBAC assignments.

## Completion criteria

After consent, FoundryX must:

- Verify that API, Portal, and CLI consent completed for the same tenant.
- Activate the tenant for the FoundryX private preview.

After activation, users can sign in with work or school accounts and access FoundryX projects assigned to them. Azure operations continue to follow each signed-in user's Azure RBAC assignments.
