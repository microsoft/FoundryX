# Admin Center permissions by page

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

The permissions you need to **register a project and grant access** are separate from the project permissions that **users receive**.

| Stage | Who it applies to | Required permission or result |
| --- | --- | --- |
| **Tenant onboarding** | Microsoft Entra administrator | Requires an eligible [Microsoft Entra administrator role](tenant-onboarding-requirements.md#administrator-requirements) to approve app permissions and activate the tenant. |
| **Admin Center sign-in** | Any user in the active tenant | Requires sign-in allowed by your tenant's Microsoft Entra policies. Sign-in alone does not grant project access. |
| **Grant project access** | Azure subscription administrator | Requires all 15 [Access management Actions](#required-access-management-actions) at subscription scope (for example, **Owner**, **Contributor** + **User Access Administrator**, or a custom role). |
| **Use or manage a registered project (FoundryX ACLs)** | Selected users, groups, or all tenant users | Grants **Consumer**, **User**, **Manager**, or **Owner** access in FoundryX. These access control list (ACL) entries are not Azure role-based access control (RBAC) assignments to users. |

## How the permission layers fit together

![Four layers: Org (Tenant) consent; Azure high-privilege and read permissions; Foundry project data permissions; FoundryX project roles.](images/admin-permission-layers.svg)

Each layer is checked separately:

- **Org (Tenant):** Microsoft Entra roles that can grant consent and the delegated permissions they approve.
- **Azure:** Subscription permissions needed to register or remove a project (3 high-privilege role-management Actions and 12 read Actions).
- **Foundry:** Project data permissions needed to list tools and Toolboxes. After registration, the FoundryX service principal uses this access to load tools in **Edit access**.
- **FoundryX:** Project roles (ACL entries) that control who can invoke or build agents and manage access for that project through FoundryX.

## 1. What does tenant onboarding require?

A Microsoft Entra administrator approves the application permissions and completes tenant activation. For the eligible roles, preflight script, and consent steps, see [Tenant onboarding requirements](tenant-onboarding-requirements.md).

Onboarding connects your organization to FoundryX. Next, a subscription administrator registers projects and grants user access.

## 2. Who can sign in to the Admin Center?

**Any user in an active, onboarded tenant can sign in** if your Microsoft Entra policies allow it. You don't need an Entra administrator role, an Azure role, or a FoundryX role just to sign in. Guests must sign in through the onboarded tenant's sign-in link.

After you sign in:

- You see enabled projects where you have a direct, group, or tenant-wide FoundryX role.
- If you manage an Azure subscription, you also see registered projects in that subscription.

## 3. Who can grant access?

### Register a project through Grant access

> [!NOTE]
> Permission-based checks apply after the authorization update is deployed to your environment. Older environments require built-in subscription **Owner**, or **Contributor** plus **User Access Administrator**, and do not support custom roles.

To register a project, you need all 15 [Access management Actions](#required-access-management-actions) at **subscription scope** on the target Azure subscription. You can get these permissions from:

- Built-in **Owner**
- **Contributor** combined with **User Access Administrator**
- Custom roles or multiple role/group assignments that together include all 15 Actions

If you use Privileged Identity Management (PIM), activate your role before you start. Resource-group or project-level Owner, Microsoft Entra administrator roles, and FoundryX **Owner** do not satisfy this subscription check.

When you register a project, FoundryX uses your Azure permissions to grant the customer-tenant FoundryX service principal access to the project's Azure resources.

### Required Access management Actions

All 15 Actions are required at subscription scope to register or import a project, retry an incomplete import, or remove project access:

| Purpose | Required Azure Action |
| --- | --- |
| Read the subscription | `Microsoft.Resources/subscriptions/read` |
| Check your permissions | `Microsoft.Authorization/permissions/read` |
| Read role definitions | `Microsoft.Authorization/roleDefinitions/read` |
| Create or update service role definitions (high privilege) | `Microsoft.Authorization/roleDefinitions/write` |
| Read role assignments | `Microsoft.Authorization/roleAssignments/read` |
| Assign service access (high privilege) | `Microsoft.Authorization/roleAssignments/write` |
| Remove service access (high privilege) | `Microsoft.Authorization/roleAssignments/delete` |
| Read Foundry accounts | `Microsoft.CognitiveServices/accounts/read` |
| Read native projects | `Microsoft.CognitiveServices/accounts/projects/read` |
| Read model deployments | `Microsoft.CognitiveServices/accounts/deployments/read` |
| Read project connections | `Microsoft.CognitiveServices/accounts/projects/connections/read` |
| Read Application Insights resources | `Microsoft.Insights/components/read` |
| Read Log Analytics workspaces | `Microsoft.OperationalInsights/workspaces/read` |
| Read policy assignments | `Microsoft.Authorization/policyAssignments/read` |
| Read policy exemptions | `Microsoft.Authorization/policyExemptions/read` |

FoundryX checks these Actions through the Azure Resource Manager (ARM) Permissions application programming interface (API) using your delegated token. Wildcards (such as `*`) are supported, and `NotActions` in one permission block do not block an Action granted by another role assignment.

> [!TIP]
> **Creating a new native project in the command-line interface (CLI) uses a separate 27-Action check** (these 15 Actions plus 12 resource-creation and quota Actions). In the Admin Center, **Grant access** registers an existing project.

### Permissions in the Grant access dialog

The **Grant access** dialog reads Azure and directory resources using your signed-in account:

| Field | What your account needs |
| --- | --- |
| **Azure subscription** | Permission to read the subscription and check permissions (`Microsoft.Authorization/permissions/read`). Disabled subscriptions are read-only; hover over one or select **View missing permissions** (and **Copy**) to see which Actions are missing. |
| **Foundry project** | Read access to the parent Foundry account (kind `AIServices`) and its unregistered projects. |
| **Users / Groups** | The delegated Microsoft Graph permissions approved during [onboarding](tenant-onboarding-requirements.md#application-permissions-to-approve), subject to your directory and guest rules. |

Complete any multifactor authentication (MFA) prompt if your organization requires it for Azure role changes.

The **Grant access** dialog does not include model or tool pickers. You register the project first, and then choose allowed models and tools in **Edit access** > **Models & Tools**.

### Allowed models

After registration completes, **Edit access** > **Models & Tools** loads model deployments from the **parent Foundry account** using the **FoundryX service principal** (established during registration), not your personal Azure roles:

- `Microsoft.CognitiveServices/accounts/read`
- `Microsoft.CognitiveServices/accounts/deployments/read`

These permissions apply on the parent Foundry account. A native Foundry data role isn't needed to list models.

### Allowed tools

For completed registrations, **Edit access** > **Models & Tools** also uses the **FoundryX service principal** to load tools:

| Required service-principal access | Scope |
| --- | --- |
| `Microsoft.CognitiveServices/accounts/projects/connections/read` | Selected native Foundry project |
| Native Foundry data permission to list Tools and Toolboxes (for example, **[Foundry User](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#foundry-user)**) | Selected native Foundry project |

In **Edit access**, models, connections, and Toolboxes load in a single combined request. If any part fails, both the model and tool lists show an error. Check the FoundryX service principal's roles on the account and project.

**When your personal Azure and Foundry data permissions are used instead:**
If you run CLI discovery on an unregistered project or use **Retry import** on an incomplete registration, FoundryX loads models and tools using your signed-in account (requiring `Microsoft.Resources/subscriptions/read`, the ARM reads above, and native Foundry Toolbox permissions on your account, since Azure subscription Owner alone does not include Foundry data actions).

For supported tool types and excluded infrastructure connections, see [Prepare and allow tools](enterprise-admin-agent-access.md#prepare-and-allow-tools).

### Register access and select resources

1. In **Grant access**, select the subscription and unregistered project, then review **Users / Groups**. Your account is preselected as **Owner**—keep, change, or remove it as needed. Initial user assignments are optional.
2. Select **Grant access** to register the project:
   - **Service access:** Assigns the required Azure roles to your tenant's FoundryX service principal.
   - **User access (optional):** Saves your selected users, groups, or tenant-wide audience in the project's ACL (submitted as one atomic batch of up to 500 changes after registration).
3. New registrations start with empty model and tool allowlists (`[]`), which block all models and tools. Open **...** > **Edit access** > **Models & Tools**, select the approved models and tools, and select **Save**.

Follow the [Walkthrough: Grant project access](register-project-permissions.md) for the complete flow.

## 4. What project access do users receive?

**FoundryX roles control who can invoke or build agents and manage access for a specific Foundry project through FoundryX.** You assign these roles in **Users / Groups** during **Grant access** or later in **Edit access**.

FoundryX roles apply only inside FoundryX. They do not grant direct access in the Azure portal or native Foundry portal.

| FoundryX role | What you can do | Limits |
| --- | --- | --- |
| **Consumer** | Use allowed models and invoke deployed agents. | Cannot build or deploy agents, manage access, or change project settings. |
| **User** | Everything in **Consumer**, plus build, deploy, evaluate, monitor, and publish agents; reuse approved connections and Toolboxes. | Cannot manage project access or change allowed models and tools. |
| **Manager** | Everything in **User**, plus add or remove **User** grants for individual users and groups. | Cannot manage **Consumer**, **Manager**, **Owner**, or tenant-wide grants, or change allowed models and tools. |
| **Owner** | Everything in **User**, plus manage all project roles, change allowed models and tools, and create, update, or delete project connections and Toolboxes. | Cannot register a new project or run **Remove access** without Azure subscription permissions. |

Key rules for project roles:

- **Highest role wins:** If you match multiple direct, group, or tenant-wide grants, your highest role applies (**Owner > Manager > User > Consumer**).
- **Tenant-wide grants:** Support **Consumer** or **User** only.
- **Shared resource policy:** The project's allowed models and tools apply to **every role, including Owner**. An empty list (`[]`) blocks all resources of that type.

## Manage access after registration

| Admin Center action | Who can do it |
| --- | --- |
| View access details | Any project member or an administrator of the project's Azure subscription. |
| Add, edit, or remove user and group roles | FoundryX **Owner** or subscription administrator (**Manager** can add or remove **User** grants for individuals and groups). |
| Change tenant-wide access or allowed models and tools | FoundryX **Owner** or subscription administrator. |
| **Remove access** or **Retry import** | Subscription administrator with all 15 [Access management Actions](#required-access-management-actions). |

Keep in mind:

- Azure subscription permissions do not automatically make you a FoundryX **Owner**. You still need a FoundryX role to build agents, and you need FoundryX **Owner** to create, edit, or delete connections and Toolboxes.
- Editing only **Users / Groups** (through **Add Users / Groups** or the **Access** tab in **Edit access**) does not reload or change your saved models and tools.

For policy details and troubleshooting, see [Administration concepts and reference](enterprise-admin-agent-access.md).
