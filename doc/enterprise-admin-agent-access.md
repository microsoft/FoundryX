# FoundryX administration concepts and reference

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

FoundryX lets you give employees controlled access to Microsoft Foundry projects without assigning individual Azure role-based access control (RBAC) roles to each user. You register a project, choose the allowed models and tools, and assign project roles to Microsoft Entra users, groups, or all tenant users.

- For step-by-step setup in the portal, follow [Walkthrough: Grant project access](register-project-permissions.md).
- For the permissions required at each layer, see [Admin Center permissions by page](admin-portal-permissions.md).

**Staging portal:** [FoundryX Admin Center](https://foundryx-portal-staging.redsea-0f4601f0.westus2.azurecontainerapps.io/)

## In this reference

- [Understand the access model](#understand-the-access-model)
- [Prepare the tenant and resources](#prepare-the-tenant-and-resources)
- [Control model access and deployment](#control-model-access-and-deployment)
- [Prepare and allow tools](#prepare-and-allow-tools)
- [Manage project membership](#manage-project-membership)
- [Disable or remove a permission](#disable-or-remove-a-permission)
- [Troubleshoot](#troubleshoot)

## Understand the access model

Each access entry (called a **Permission** in the command-line interface (CLI) and **Access** in the Admin Center) links one native Microsoft Foundry project to FoundryX. It stores the project's user assignments and its shared model and tool allowlists.

For the four permission layers (Org, Azure, Foundry, and FoundryX) and the 15 subscription Actions required to register a project, see [Admin Center permissions by page](admin-portal-permissions.md#how-the-permission-layers-fit-together).

### Choose the correct project role

Assign the lowest role that fits each user's work (see the [full role comparison table](admin-portal-permissions.md#4-what-project-access-do-users-receive)):

- **Consumer:** Invoke deployed agents and use allowed models.
- **User:** Build, deploy, evaluate, monitor, and publish agents; reuse approved connections and Toolboxes.
- **Manager:** Everything in **User**, plus add or remove **User** grants for individual users and groups.
- **Owner:** Everything in **User**, plus manage all project roles, allowed models and tools, and project connections and Toolboxes.

If a user matches multiple direct, group, or tenant-wide grants, the highest role applies (**Owner > Manager > User > Consumer**). Azure subscription administrators can manage project registration and model deployments, but still need FoundryX **Owner** on the project to create, update, or delete connections and Toolboxes.

### Know what project registration grants

When you register a project, FoundryX uses your delegated Azure permissions to grant access to the FoundryX application programming interface (API) service principal in your tenant:

| Azure scope | Service principal access |
| --- | --- |
| **Selected project** | **Foundry User** and user-identity delegation for hosted agent invocation. |
| **Parent Foundry account** | **Foundry Project Manager** and a custom runtime role for account, project, and model operations. |
| **Resource group** | Custom roles for Bot publishing operations, monitoring reads, and telemetry queries. |
| **Monitoring resources** (when configured) | Read and query access to the connected Application Insights and Log Analytics resources. |

Review these scopes against your organization's Azure policies before registering a project.

### Registration lifecycle

When you submit **Grant access**:

1. FoundryX verifies your subscription and tenant, creates a disabled import record with empty model and tool allowlists (`[]`), assigns the service principal roles above, reads native model deployments, and enables the project.
2. FoundryX then submits any selected user or group assignments in one atomic batch of up to 500 changes.
   - If the membership batch fails, the project registration (or an earlier policy update) remains saved while the rejected membership batch is not applied.
3. After registration completes, open **Edit access** > **Models & Tools** to select allowed models and tools (loaded using the FoundryX service principal). Use the **Access** tab to update membership.

Registration does not import pre-existing native agents into FoundryX lists or Canvas, and it does not delete them.

If registration fails during setup, the project appears as **Import incomplete** and stays disabled. Resolve the underlying Azure error and select **...** > **Retry import**. Unlike **Edit access**, the **Retry import** pickers use your signed-in administrator account's Azure and native Foundry Toolbox permissions, and saving replaces the incomplete policy with your current selections.

### Authorization and runtime verification

Running `foundryx access check` tests FoundryX policy only:

- `allowed: true` means FoundryX policy allows the request (it does not test runtime health or external credentials).
- `allowed: false` means a policy rule blocks the request (exits nonzero).
- `allowed: null` means access could not be verified (exits nonzero).

To verify end-to-end access, follow [Verify employee access](register-project-permissions.md#6-verify-employee-access).

## Prepare the tenant and resources

Before you register a project, confirm these items:

| Item | What to check |
| --- | --- |
| **Active tenant** | Complete [tenant onboarding](tenant-onboarding-requirements.md) with an eligible Microsoft Entra administrator role. |
| **Subscription permissions** | Confirm you have all 15 [Access management Actions](admin-portal-permissions.md#required-access-management-actions) on the subscription and activate any Privileged Identity Management (PIM) role. |
| **Foundry project** | Use a project under a Microsoft Foundry account of kind `AIServices` in your tenant's subscription. |
| **Models and tools** | Deploy at least one model and configure any needed project connections and Toolboxes in Microsoft Foundry. |

In the Admin Center, **Grant access** imports an existing project. If you want to create a new native project from the CLI instead, run:

```text
foundryx access project options
foundryx access project create <resource-name> --subscription <subscription-id> --region <region>
```

CLI project creation provisions native Foundry and monitoring resources, can incur Azure charges, and checks 27 subscription Actions (the 15 management Actions plus 12 creation and quota Actions).

All CLI project commands after import use the **FoundryX project universally unique identifier (UUID)** returned by `foundryx access project list`, not the Azure resource ID.

## Control model access and deployment

Model deployments live on the parent Foundry account, while each registered project has its own model allowlist.

To update allowed models in the Admin Center, open the project's **...** menu, select **Edit access**, select the deployments under **Allowed models** on the **Models & Tools** tab, and select **Save**.

The allowlist applies to every project member, including **Owner**:

| Policy value | Meaning |
| --- | --- |
| `["deployment-a", ...]` | Allow only the listed model deployments or tool keys. |
| `[]` | Allow none of that resource type. |
| `null`, missing, or invalid | Allow none of that resource type. |

### Set an explicit policy through the CLI

As a FoundryX **Owner** or subscription administrator, you can view and update the resource policy from the CLI:

```text
foundryx access project resources --project <project-id>
foundryx access project policy show --project <project-id>
```

Create a `policy.json` file (for example, allowing one model and no tools):

```json
{
  "allowed_models": ["approved-model-deployment"],
  "allowed_tools": []
}
```

Apply and verify the policy:

```text
foundryx access project policy set --project <project-id> --file policy.json
foundryx access project policy show --project <project-id>
```

Omitted fields keep their current values during `policy set`; pass `[]` explicitly to clear a list. CLI project import and retry require both fields in `policy.json`.

### Deploy or change a model

Selecting a model in **Edit access** only updates the allowlist. To deploy a new model, use Microsoft Foundry or run:

```text
foundryx model catalog --project <project-id>
foundryx model quota --project <project-id> --deployable
foundryx model deploy --project <project-id> --name <deployment-name> --model-name <model-name> --model-version <version> --model-format <format> --sku <sku> --capacity <capacity>
foundryx model list --project <project-id>
```

- `model quota` requires subscription management permissions plus `Microsoft.CognitiveServices/locations/usages/read` at subscription scope on your signed-in account.
- Deployments created through `foundryx model deploy` are added to the project's model allowlist automatically. Deployments created in the Foundry portal must be enabled in **Edit access**.
- By default, only subscription administrators can deploy, scale, or delete models. A subscription administrator can delegate model management to project **User**, **Manager**, and **Owner** roles:

  ```text
  foundryx access project model-management enable <project-id>
  foundryx access project model-management disable <project-id>
  ```

## Prepare and allow tools

In **Edit access** > **Models & Tools**, you choose which tools project members can use:

| Tool type | Policy key | Setup notes |
| --- | --- | --- |
| **Built-in tool** | `builtin:<type>` | The picker offers **Web search**, **Code interpreter**, and **Azure AI Search**. **Web search** is optional and can be selected or cleared. |
| **Project connection** | `connection:<name>` | Create the connection and configure its authentication in the native Foundry project. Infrastructure connections (Application Insights, app configuration, container registries, Python feeds, Git) are hidden from the picker. |
| **Toolbox** | `toolbox:<name>` | Allows the Toolbox's configured tools and same-project connections through that Toolbox. Separate `connection:<name>` grants are needed only when an agent uses a connection directly outside the Toolbox. |
| **Direct public Model Context Protocol (MCP) server** | `builtin:mcp` | Not shown in the portal picker; add `builtin:mcp` via [CLI policy](#set-an-explicit-policy-through-the-cli) if needed and recheck after portal edits. |

### Create or maintain shared resources

You need FoundryX **Owner** on the project to create, update, or delete connections and Toolboxes through FoundryX (even if you are an Azure subscription administrator). See:

- [RemoteTool MCP connections](../skills/foundry-agent/references/connection-create.md)
- [Toolboxes](../skills/foundry-agent/references/toolbox.md)
- [Hosted Agent Toolbox integration](../skills/foundry-agent/references/hosted-agent-toolbox.md)

Create the connection before creating an MCP-backed Toolbox, and pass secrets only with `--credentials-stdin`.

### Verify configuration and runtime separately

Inspect configured connections and Toolboxes with:

```text
foundryx connection list --project <project-id>
foundryx connection show <connection-name> --project <project-id>
foundryx toolbox list --project <project-id>
foundryx toolbox show <toolbox-name> --project <project-id>
```

These commands check configuration metadata (`runtime_verified: false`). Test actual tool execution by invoking a deployed agent. For per-user OAuth tools, each invoking user completes their own consent link and resumes the conversation.

### Existing hosted agents

Hosted agents registered without verified source `tool_resources` declarations cannot be invoked or enabled through FoundryX (`hosted_tool_declarations_unknown`). Deploy a new hosted agent from reviewed source code with explicit `tool_resources`.

## Manage project membership

In **Access**, select a project name to view **Access details** and **Users / Groups**:

| Task | Steps in the Admin Center |
| --- | --- |
| **Add users or groups** | In **Users / Groups**, select **Add Users / Groups**, search for the user or group, choose a role, and select **Add**. |
| **Change one role** | Open the entry's **...** menu, select **Edit role**, choose the new role, and save. |
| **Remove one grant** | Open the entry's **...** menu, select **Remove**, and confirm. (If the user also belongs to another granted group or tenant-wide grant, that access remains.) |
| **View group members** | Select a group's name to view its members in Microsoft Entra. |
| **Edit multiple grants** | Open the project's **...** menu, select **Edit access** > **Access**, update the list (up to 500 changes per save), and select **Save**. |

For CLI membership commands, see [Project permissions and access diagnostics](../skills/foundry-agent/references/permissions.md).

## Disable or remove a permission

| Goal | What to do | Result |
| --- | --- | --- |
| **Remove one user or group** | Remove that grant in **Users / Groups**. | Removes only that grant; other matching group or tenant grants still apply. |
| **Temporarily pause project access** | Run `foundryx access project disable <project-id>`. | Blocks FoundryX access while keeping registration, policy, memberships, and Azure resources intact. Run `foundryx access project enable <project-id>` to restore access. |
| **Remove the project from FoundryX** | In the Admin Center, open the project's **...** menu and select **Remove access** (or run `foundryx access project delete <project-id> --name <exact-permission-name>`). | Revokes FoundryX-managed service principal role assignments and deletes the FoundryX registration. Does **not** delete your native Azure resources, models, agents, or monitoring data. |

If role cleanup fails during removal, the entry stays disabled and displays **Deletion incomplete. Retry delete.** Resolve the reported Azure role error and select **Remove access** again.

## Troubleshoot

| Symptom or error code | What to check and do |
| --- | --- |
| **Organization is not active** | Check the `?tenant=<tenant-id>` value in your sign-in link, or complete [tenant onboarding](tenant-onboarding-requirements.md). |
| **Grant access** is disabled, subscription is disabled, or `azure_role_required` | Hover over the disabled subscription or select **View missing permissions** (and **Copy**). Make sure your account has all 15 [Access management Actions](admin-portal-permissions.md#required-access-management-actions) at subscription scope. |
| **No subscriptions or projects appear** | Confirm you signed in to the right tenant and that your unregistered project is under an `AIServices` Foundry account. |
| **Models or tools fail to load in Edit access** | Check the FoundryX service principal's [model read permissions](admin-portal-permissions.md#allowed-models) on the parent account and [tool permissions](admin-portal-permissions.md#allowed-tools) (such as **Foundry User**) on the project. |
| **Models or tools fail to load in Retry import** | **Retry import** uses your signed-in administrator account. Confirm your account has subscription read access and native Foundry data access (such as **Foundry User**) on the project. |
| **Directory users or groups fail to load** | Verify that the Microsoft Graph permissions from [onboarding](tenant-onboarding-requirements.md#application-permissions-to-approve) were granted. |
| **Save failed after partial changes** | Reopen the project entry. Registration or policy changes are saved before the membership batch (up to 500 changes), so check what succeeded before retrying. |
| **Import incomplete**, `project_import_access_pending`, or `project_import_incomplete` | Wait if Azure role assignments are still propagating, then select **...** > **Retry import**, choose your intended models and tools, and save. |
| **Builder can invoke agents but cannot build** | Change the builder's effective role from **Consumer** to **User** or higher. |
| `model_not_allowed` or `tool_not_allowed` | Open **Edit access** > **Models & Tools** and allow the model deployment or tool resource key (`[]` blocks all). |
| `model_not_ready` | Choose a model deployment whose provisioning state in Microsoft Foundry is `Succeeded`. |
| `project_owner_required` | Assign FoundryX **Owner** on the project to the person creating or updating connections or Toolboxes. |
| `hosted_tool_declarations_unknown` | Deploy a new hosted agent from reviewed source code with explicit `tool_resources`. |
| `oauth_consent_required` | Have the invoking user open the returned consent URL, sign in with the same account, and resume the conversation. |
| `subscription_access_unverified` | Sign in again or ask your Azure administrator to check delegated ARM access. |
| `model_quota_permission_required` | Grant `Microsoft.CognitiveServices/locations/usages/read` at subscription scope to the signed-in user running `foundryx model quota`. |
| **Deletion incomplete. Retry delete.**, `permission_revocation_pending`, or `permission_assignment_changed` | Ask an Azure administrator to inspect the role assignment error, then select **Remove access** again. |
| **Monitoring is missing or denied** | Run `foundryx access project monitoring show --project <project-id>` as a subscription administrator, and use `monitoring setup` if you need to repair monitoring resources. |

When contacting support, include the operation, error code, request ID, environment, and timestamp. Never share passwords, tokens, or connection keys.
