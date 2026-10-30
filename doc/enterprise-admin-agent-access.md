# FoundryX administration concepts and reference

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

Use FoundryX to give employees access to customer-owned Microsoft Foundry projects without assigning Azure roles to each employee. Administrators register projects, select the models and tools that members can use, and assign access through Microsoft Entra users, groups, or the tenant.

This page explains the access model, resource policies, and administration options in the FoundryX private preview. For the step-by-step portal task, follow [Walkthrough: Grant project access](register-project-permissions.md).

Customer administration does not include deployment of the FoundryX service or provider-side tenant administration. Your organization retains ownership of its subscriptions, resources, quota, costs, and security policy.

**Staging portal:** [FoundryX Admin Center](https://foundryx-portal-staging.redsea-0f4601f0.westus2.azurecontainerapps.io/)

Use your organization's sign-in process. This guide contains no shared test accounts, passwords, or credentials.

## In this reference

- [Understand the access model](#understand-the-access-model)
- [Prepare the tenant and resources](#prepare-the-tenant-and-resources)
- [Control model access and deployment](#control-model-access-and-deployment)
- [Prepare and allow tools](#prepare-and-allow-tools)
- [Manage project membership](#manage-project-membership)
- [Disable or remove a permission](#disable-or-remove-a-permission)
- [Troubleshoot](#troubleshoot)

## Understand the access model

A **Permission** registers one native Foundry project in FoundryX. It contains project membership and a shared model and tool policy. It does not create a separate copy of the native project. The Admin Center presents these records under **Access**, using **Grant access**, **Edit access**, and **Remove access**. CLI commands and error codes can still refer to permissions.

There are three separate authorization boundaries:

| Boundary | Purpose | Who controls it |
| --- | --- | --- |
| Tenant onboarding | Admits the tenant and obtains consent for FoundryX sign-in and delegated directory and Azure management access. | A tenant administrator and the FoundryX service operator. |
| Azure subscription management | Creates or imports projects, provisions service-principal access, and controls project lifecycle and model-management delegation. | Subscription Owner, or a person with both Contributor and User Access Administrator at subscription scope. |
| FoundryX project membership | Controls agent development, invocation, membership, and connection or Toolbox administration within a registered project. | The project's assigned roles, subject to its resource policy. |

An Entra administrator role does not replace the required Azure subscription roles. A subscription management role does not automatically make its holder a FoundryX Project Owner.

### Choose the correct project role

| Project role | Capabilities |
| --- | --- |
| Consumer | Use allowed models and invoke deployed agents. Does not grant agent development or deployment. |
| User | Consumer capabilities plus agent development, deployment, evaluation, and publishing workflows; discover and reuse existing connections and Toolboxes. |
| Manager | User capabilities plus assignment or removal of **User** grants for individuals and groups. Cannot change Consumer, Manager, Owner, or tenant-wide grants. |
| Owner | User capabilities plus management of all project roles, the resource policy, connections, and Toolboxes, including connection and Toolbox deletion. |

Give employees **User** access if they must build agents. Reserve **Owner** for people who administer project resources. Publishing still requires its separate sign-in, native setup, and tenant approval; the project role alone does not complete publication.

FoundryX uses the highest role from all matching direct, group, and tenant grants. There is no lower-priority grant that overrides a higher role. For example, a direct Consumer grant does not reduce a User role received through a group.

Subscription managers can administer permissions and models without project membership. They still need a project role for agent work, and **Project Owner membership is required for every connection or Toolbox write**.

### Know what project registration grants

Saving a new permission is not a read-only operation. FoundryX uses the administrator's delegated Azure authority to provision access for the FoundryX API enterprise application in the customer tenant.

Project registration provisions access at these scopes:

| Scope | Service access |
| --- | --- |
| Selected project | Foundry User and user-identity delegation for hosted agent invocation. |
| Parent Foundry account | Foundry Project Manager and a custom runtime role for account, project, and model operations. |
| Resource group | Custom roles for Bot publishing operations, monitoring resource reads, and telemetry queries. |
| Existing imported monitoring resources, when configured | Read and query access to the relevant Application Insights and Log Analytics resources. |

Review these scopes against your organization's Azure policy before registration. Monitoring query access can include captured messages and tool payloads in accessible workspace tables. This is separate from the model and tool selections in the permission form.

Project users receive no backend credential or individual Azure role through this process. FoundryX checks their access before using the customer-tenant service identity.

### Registration lifecycle

FoundryX verifies the subscription and tenant, saves the policy in a disabled import record, provisions service access, and discovers existing model deployments and agents. It enables the permission after successful resource registration.

Import records resource identities and agent/version metadata. It does not copy agent prompts, source code, connection credentials, or conversation content into its project-registration metadata.

The portal applies the import or policy change **before** it saves membership changes, and saves each membership change separately. The whole form is not one atomic transaction. If a later step fails, earlier changes can remain.

An incomplete import remains visible as **Import incomplete** and stays disabled. Retrying preserves the saved policy. Reimporting a completed permission does not reset membership or its existing policy. See [Troubleshoot](#troubleshoot) for recovery actions.

### Authorization and runtime verification

`access check` makes no resource changes. `allowed: true` confirms authorization only, not runtime health. `allowed: false` reports a blocking rule; `allowed: null` means authority could not be verified. Denied and unverified checks exit nonzero. The real operation checks access again.

A successful form save does not prove that an employee can build and run an agent. The [registration walkthrough](register-project-permissions.md#6-verify-employee-access) includes employee access and runtime verification.

## Prepare the tenant and resources

Before creating a permission, confirm the following:

| Requirement | What to check |
| --- | --- |
| Active FoundryX tenant | Complete the invitation and consent process with the service operator. An invited or suspended tenant cannot use the normal project workflow. |
| Tenant-consent authority | For onboarding, activate an eligible Entra administrator role. See [tenant onboarding requirements](tenant-onboarding-requirements.md) and its role-check script. |
| Subscription authority | Use Subscription Owner, or both Contributor and User Access Administrator at subscription scope. Activate eligible roles before continuing. |
| Supported native project | Use a project under a Microsoft Foundry account with resource kind `AIServices`. Select a subscription in the signed-in tenant. |
| Models | Have at least one ready model deployment for employees who must build or invoke agents. Verify quota and regional capacity before deploying additional models. |
| Tools | Create the required native project connections and Toolboxes, and complete their external authentication or identity setup. |
| Access plan | Identify the users or groups, their roles, and the models and tools they need. Choose tenant-wide access only when intended. |

Tenant consent alone does not assign Azure resource roles to the FoundryX service identity. Project registration performs that separate access-provisioning step.

The Admin Center's **Grant access** workflow imports an existing project. To create a native project first, use [Microsoft Foundry](https://ai.azure.com/) or the FoundryX CLI:

```text
foundryx access project options
foundryx access project create <resource-name> --subscription <subscription-id> --region <region>
```

The CLI creation path provisions native resources, including monitoring. It requires subscription management authority and can incur Azure costs. Review the returned project and any setup errors before granting employee access.

For portal sign-in and registration, follow the [registration walkthrough](register-project-permissions.md). Only a subscription manager can create a new permission; Project Owner membership alone is not sufficient.

CLI examples in this reference assume the intended environment and tenant are selected. For direct terminal use, follow [Manual CLI setup](builder-guide.md#manual-cli-setup-optional) and the [sign-in and access checks](register-project-permissions.md#6-verify-employee-access).

Commands use the **FoundryX project UUID**, returned by `foundryx access project list`. It is not the native Azure resource ID. Native resource IDs are used for discovery and import.

## Control model access and deployment

Model deployments belong to the parent Foundry account. Each registered project has its own allowlist, even when projects share that account.

To change model access, open the project's **...** menu, select **Edit access**, change **Allowed models (optional)**, and select **Save**. The edit form reads the current native deployment list, including deployments created outside FoundryX. **Deploy new models in Foundry portal** opens Foundry for separate deployment; it does not deploy a model from the access form.

The policy applies to every member, including Owners. It is not a separate list for each user.

| Stored policy value | Meaning |
| --- | --- |
| An explicit array | Allow only the listed deployment names or tool resource keys. |
| `[]` | Allow none of that resource kind. |
| `null` | Unrestricted for that resource kind, including later resources. |

An empty model selection does **not** mean all models. It blocks model use and agents that require a model. The same array rules apply independently to tools.

### Set an explicit policy through the CLI

An Owner or subscription manager can inspect the resource choices and saved policy:

```text
foundryx access project resources --project <project-id>
foundryx access project policy show --project <project-id>
```

For example, save this as `policy.json` to allow one model deployment and no tools. Replace `approved-model-deployment` with an existing deployment name from the resource results:

```json
{
  "allowed_models": ["approved-model-deployment"],
  "allowed_tools": []
}
```

Apply the intended policy, then read it back:

```text
foundryx access project policy set --project <project-id> --file policy.json
foundryx access project policy show --project <project-id>
```

Policy updates preserve omitted fields. Use an explicit `[]` to deny all or `null` to allow all; do not omit a field expecting it to reset. First-time CLI import requires both fields in its policy file.

### Deploy or change a model

The permission form selects existing deployments; it does not deploy models. Use Foundry or the CLI to provision a deployment:

```text
foundryx model catalog --project <project-id>
foundryx model quota --project <project-id> --deployable
foundryx model deploy --project <project-id> --name <deployment-name> --model-name <model-name> --model-version <version> --model-format <format> --sku <sku> --capacity <capacity>
foundryx model list --project <project-id>
```

Catalog access requires project User membership or higher; model listing requires project membership. Quota inspection requires subscription management authority. If you also perform developer work, obtain the appropriate project role rather than assuming that subscription authority supplies it.

Choose values from the current catalog and quota results. Capacity is measured in thousands of tokens per minute for the token-rate deployment options. Quota does not guarantee regional availability.

A successful deployment through FoundryX joins that project's explicit model allowlist automatically. A deployment created outside FoundryX must be selected in the permission, unless the model policy is unrestricted.

Subscription managers can deploy models and scale or delete allowed deployments. Project model management is **disabled by default**. A subscription manager can enable it through the CLI:

```text
foundryx access project model-management enable <project-id>
foundryx access project model-management disable <project-id>
```

When enabled, effective Users, Managers, and Owners can deploy models and scale or delete allowed deployments. Consumers cannot. Disabling the setting removes that delegated authority; it does not delete deployments.

Model changes can affect other projects that share the same account. Review dependencies and costs before scaling or deleting a deployment.

## Prepare and allow tools

The Admin Center controls which tools project members can use. Resource creation, credentials, external consent, and network configuration are separate tasks.

| Tool choice | Policy key | Preparation |
| --- | --- | --- |
| Built-in tool | `builtin:<type>` | Confirm native/runtime support. Built-in choices include web search, Code Interpreter, Azure AI Search, and public MCP. Some tools also need a connection or other configuration. |
| Project connection | `connection:<name>` | Create it in the selected native project and configure its authentication. |
| Toolbox | `toolbox:<name>` | Create the Toolbox, review its tool sources and connections, and select its published default or a pinned version. |

Allowing a Toolbox permits its configured tools and same-project connections
through that Toolbox, including changes to its owner-published default version.
Separate connection grants control direct use outside the Toolbox. Removing a
connection grant does not block its use through an allowed Toolbox. To revoke
that path, remove the Toolbox grant or change its contents. Native authentication,
resource validation, and project boundaries still apply.

A public MCP server used directly is distinct from a project connection or Toolbox.

The permission form automatically includes **Web search** when available and does not let you clear it in the picker. A later portal policy save can add it again. If your policy must exclude web search or deny all tools, use an explicit CLI policy and verify it after any portal edits.

### Create or maintain shared resources

Connection and Toolbox writes through FoundryX require effective **Project Owner** membership, even for subscription managers. Users and Managers can discover and reuse existing resources but cannot change them.

Use these detailed administration references:

- [RemoteTool MCP connections](../skills/foundry-agent/references/connection-create.md): create or update connections, replace credentials, and delete connections.
- [Toolboxes](../skills/foundry-agent/references/toolbox.md): create Toolboxes, create versions, change the published default, and remove unused versions.
- [Hosted Agent Toolbox integration](../skills/foundry-agent/references/hosted-agent-toolbox.md): select an endpoint, declare resources, and handle per-user consent.

For a new MCP-backed Toolbox, create the connection before the Toolbox. Keep credentials in the native connection, not in agent source, Toolbox definitions, this guide, or command-line arguments. For credential replacement, use `--credentials-stdin` with a protected secret source.

OAuth configuration and external identity grants may require Foundry, Azure, Microsoft Entra, or the tool provider. They are not created by selecting a resource in the permission form.

A new Toolbox version does not automatically become the published default. An unversioned endpoint follows default-version changes; a pinned endpoint keeps its selected version. Review existing consumers before publishing a different default.

### Verify configuration and runtime separately

```text
foundryx connection list --project <project-id>
foundryx connection show <connection-name> --project <project-id>
foundryx toolbox list --project <project-id>
foundryx toolbox show <toolbox-name> --project <project-id>
```

These commands return safe configuration summaries. Lists can contain resources with `allowed: false`; existence does not establish access. Discovery reports `runtime_verified: false` because it does not test credentials, consent, network access, or tool execution.

Use a deployed agent invocation to verify runtime behavior. OAuth tools can require each invoking user to complete consent. Follow the returned consent URL manually, then continue with the same account and reported conversation ID. Administrator consent or a shared connection does not automatically supply each employee's external tool access.

### Existing hosted agents

Imported native hosted agents have no verified source tool declarations. A restricted tool policy, including `[]`, blocks their invocation and activation with `hosted_tool_declarations_unknown`.

Use reviewed source to create a new FoundryX hosted agent with explicit `tool_resources`. Do not remove tool restrictions merely to make an imported agent run. Resource declarations support FoundryX policy checks; they do not isolate arbitrary hosted source code at runtime.

## Manage project membership

Open **Access** and select the project name to view **Access details** and its **Users / Groups** assignments.

| Task | Portal steps |
| --- | --- |
| Add access | In **Users / Groups**, select **Add Users / Groups**, search for a user or group, select its role, and confirm with **Add**. |
| Change a role | Open the assignment's **...** menu and select **Edit role**. Review and save the new role. |
| Remove a grant | Open the assignment's **...** menu and select **Remove**. Review the affected identity and confirm removal. |
| Inspect a group | Select the group's name to view its users. This does not edit Entra group membership. |
| Edit several assignments | Open the project's **...** menu, select **Edit access**, and review the selected identities and roles before **Save**. |

The **Foundry X role** information tip explains the project roles. It does not
grant Azure subscription authority or change which assignments you can manage.

Directory searches use the signed-in person's delegated Microsoft Graph access. Creating a group, inviting an external user, or changing group membership takes place in Microsoft Entra, not in the project permission form.

Only an Owner or subscription manager can add or change a tenant-wide grant. Tenant-wide access supports **Consumer** or **User**, not Manager or Owner, and applies to all users in the tenant.

A Manager can add User grants or remove existing User grants for individuals and groups. An Owner or subscription manager must handle Consumer grants and changes involving higher roles. These limits apply even if a role description in a preview screen suggests broader access.

Removing one assignment does not necessarily remove effective access. Check remaining direct, group, and tenant-wide grants. A direct role downgrade cannot reduce access received from another grant.

CLI equivalents and access diagnostics are in [Project permissions and access diagnostics](../skills/foundry-agent/references/permissions.md).

## Disable or remove a permission

Choose the operation that matches your intent:

| Intent | Operation | Effect |
| --- | --- | --- |
| Remove one access path | Remove its direct, group, or tenant grant. | Other matching grants can still authorize the user. |
| Temporarily block project use | A subscription manager runs `foundryx access project disable <project-id>`. | Blocks project use through FoundryX; keeps the registration, policy, memberships, and native resources. |
| Restore a disabled project | A subscription manager runs `foundryx access project enable <project-id>`. | Restores access under the saved policy and grants. Does not complete a pending import or deletion. |
| Remove the FoundryX registration | A subscription manager selects **Remove access** from the project's **...** menu and confirms **Remove project access?** with **Remove access**. | Removes the permission and its FoundryX access records after service-access cleanup. |

For CLI deletion, provide the exact permission name:

```text
foundryx access project delete <project-id> --name <exact-permission-name>
```

The portal supplies that name when you confirm its removal dialog; it does not require you to type it. The button shows **Removing…** while the request runs, and the dialog cannot be closed during that operation.

Permission deletion does **not** delete native projects, models, agents, tools, Bots, monitoring resources, or conversations. It does remove FoundryX membership, policy, and associated tracking metadata. Native resources can continue to incur costs, and direct Azure or external access remains separate.

Cleanup revokes only verified FoundryX-managed role assignments. It preserves shared assignments needed by other registrations and customer-managed or inherited Azure access. Do not interpret permission deletion as removal of every Azure grant to the enterprise application.

If deletion fails after cleanup starts, the permission remains disabled. The list
shows **Deletion incomplete. Retry delete.** Resolve the reported error and retry
**Remove access**. Do not enable it or manually remove its registration to bypass
cleanup. Wait for active model or agent operations to finish before deleting a
permission.

## Troubleshoot

| Symptom or code | Check and action |
| --- | --- |
| Organization is not active | Verify the tenant in the sign-in link. Ask the service operator to complete onboarding or review suspension. Switching accounts does not activate a tenant. |
| **Grant access** or an access action is disabled, or `azure_role_required` | Read the warning or action tooltip. Verify Subscription Owner, or both Contributor and User Access Administrator at subscription scope, in the selected tenant. A project role is not sufficient for registration. |
| No subscriptions or projects appear | Confirm the tenant and delegated Azure read access. Only supported Foundry accounts and unregistered projects appear in the new-permission picker. A discovery error is not an empty inventory. |
| Directory users or groups fail to load | Check delegated Graph consent and directory access. Resolve the error and retry; do not replace failed results with an assumed empty list. |
| Additional sign-in verification is requested | Complete the Microsoft sign-in flow. Sign-in checks delegated management access and existing Azure MFA write/delete requirements for subscription managers. It does not add roles or change tenant policy. Later verification can still occur. The portal can retry reads after verification, but it does not automatically replay mutations. Inspect current state before retrying a save. |
| **Save access** is disabled | Select an unregistered project and at least one identity. Wait for successful model discovery and either successful tool discovery or the new-registration recovery path that saves no allowed tools. |
| Save failed after some changes | Reload the permission and inspect its policy and assignments. Import, policy, and membership changes can have succeeded independently. |
| **Import incomplete**, `project_import_access_pending`, or `project_import_incomplete` | Review the error. If Azure role propagation is pending, wait and use **Retry import**. The permission remains disabled until registration completes. |
| Employee can invoke but cannot build | Check their effective role. Consumer does not grant development; assign User or higher as appropriate. |
| `model_not_allowed`, `tool_not_allowed`, or no models allowed | Inspect the shared policy. `[]` denies all. Select the exact deployment or directly used resource key. A Toolbox grant covers its internal connections; direct connection use needs its own grant. |
| `model_not_ready` | Check the native model deployment state. Select a deployment whose provisioning state is `Succeeded`. |
| `project_owner_required` for connection or Toolbox changes | Obtain Project Owner membership. Subscription authority and Manager membership do not substitute for it. |
| `hosted_tool_declarations_unknown` | Deploy a new hosted agent from reviewed source with explicit resource declarations. An imported hosted agent cannot prove its tools satisfy a restricted policy. |
| `oauth_consent_required` | Have the invoking employee complete the returned tool-consent flow, then resume with the same identity and conversation. Do not substitute administrator credentials. |
| `subscription_access_unverified` | Reauthenticate or ask an Azure administrator to inspect delegated management access. An unverified check is not proof that the role is absent. |
| **Deletion incomplete. Retry delete.**, `permission_revocation_pending`, or `permission_assignment_changed` | Inspect the named access-cleanup error. An Azure administrator must review changed assignments; retry **Remove access** after resolution. |
| Monitoring is absent or access is denied | A subscription manager can inspect monitoring with `foundryx access project monitoring show --project <project-id>`. Review changes before using `monitoring setup`, which can create or repair resources, connections, and monitoring grants. |

Import can succeed even when monitoring setup needs attention. Inspect any returned monitoring error separately. The monitoring recovery commands are available through the CLI, not the permission form.

For support, record the operation, error code, request ID, environment, and time. Share project or tenant identifiers only through your organization's approved support channel. Never include passwords, tokens, connection keys, or sensitive tool output.
