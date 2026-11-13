# FoundryX Terraform provider reference

This reference describes version `0.0.5` of the
[`smallblackhole/foundryx` provider](https://github.com/SmallBlackHole/terraform-provider-foundryx).
For setup and an end-to-end example, see
[Manage FoundryX project access with Terraform](terraform.md).

## Provider configuration

The provider requires Terraform 1.7 or later and connects to staging by default.
Set the following in the `foundryx` provider block:

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `tenant_id` | String | Yes | Microsoft Entra tenant UUID for the delegated session. |

The provider sends requests directly to the FoundryX API. By default, it uses
the signed-in FoundryX command-line interface (CLI) session to acquire and
refresh credentials. The CLI profile and tenant must match the provider.
Terraform doesn't start an interactive sign-in.

| Environment variable | Purpose |
| --- | --- |
| `FOUNDRYX_CLI_PATH` | Path to the matching native CLI executable or `bin\foundryx.js` when it isn't on `PATH`. JavaScript requires Node.js; shell wrappers aren't supported. |
| `FOUNDRYX_ACCESS_TOKEN` | Overrides CLI authentication with a delegated FoundryX API token. The token isn't refreshed. |
| `FOUNDRYX_CA_CERT_FILE` | Adds PEM trust roots without disabling TLS verification. |

Don't put tokens in Terraform configuration or save token output to a file.
Workload identity isn't supported. The provider caches tokens in memory;
signing out of the CLI doesn't immediately invalidate a cached token. A
session change is detected when credentials are next acquired. Review the
account and rerun Terraform after signing out or switching accounts.

## Project registration

`foundryx_project_registration` registers an existing native project. It starts
with empty model and tool allowlists; it doesn't create a native project.
Registration can provision Azure access for the FoundryX service principal.

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `project_arm_id` | String | Yes | Azure Resource Manager (ARM) ID of the existing Foundry project. |

| Read-only attribute | Type | Description |
| --- | --- | --- |
| `id` | String | Tenant-bound import identifier. |
| `project_id` | String | FoundryX project UUID, used by policy and member resources. |
| `name` | String | Name used for **Remove access** confirmation. |
| `enabled` | Boolean | Whether the registration is enabled. |
| `importing` | Boolean | Whether import recovery is pending. |
| `deleting` | Boolean | Whether access cleanup is pending. |

Import ID: `<tenant-id>/<project-id>`. Changing the ARM identity replaces the
registration; case-only changes don't. An incomplete setup or monitoring
error requires recovery through FoundryX or removal before retrying.
Removing a registration removes all FoundryX grants for the project, including
those outside Terraform, but retains native Azure resources. Refused or
incomplete removal retains Terraform state.

## Project policy

`foundryx_project_policy` manages both complete allowlists for one registration.
It doesn't manage native models or tools, or the policy description.

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `project_id` | String | Yes | FoundryX project UUID. |
| `allowed_models` | Set of strings | Yes | Complete set of allowed deployment names. |
| `allowed_tools` | Set of strings | Yes | Complete set of `builtin:`, `connection:`, and `toolbox:` keys. |

The read-only `id` is the tenant-bound import identifier. Import ID:
`<tenant-id>/<project-id>`. Names and keys are case-sensitive; set order
doesn't matter. An empty set allows none. A missing policy and an explicitly
empty policy read the same way.

Policy deletion isn't supported. Before removing a managed registration, use
the [state-only policy handoff](terraform.md#remove-access). Setting both
lists to empty denies access but doesn't delete the policy.

## Project member

`foundryx_project_member` manages one direct user, group, or tenant-wide grant.
It doesn't manage access inherited through another grant.

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `project_id` | String | Yes | FoundryX project UUID. |
| `principal_type` | String | Yes | `user`, `group`, or `tenant`. |
| `principal_id` | String | Yes | Microsoft Entra object UUID, or the provider's tenant UUID for a tenant-wide grant. |
| `role` | String | Yes | `consumer`, `user`, `manager`, or `owner`. Tenant-wide grants support only `consumer` and `user`. |

The read-only `id` is the tenant-bound import identifier. Import ID:
`<tenant-id>/<project-id>/<principal-type>/<principal-id>`. Tenant, project,
user, and group IDs must be canonical UUIDs. A tenant-wide grant gives access
to all users in the tenant. Changing the grant identity requires replacement;
changing its role updates the grant. Deleting it revokes only that direct
grant, and access through other grants can remain.

## Import and update behavior

Import existing registrations, policies, and direct grants before managing
them. Import reads existing state without changing access. Create operations
don't adopt existing registrations or grants, even if a grant has the same
role. If a create response is lost before state is saved, inspect FoundryX and
import the created record before applying again; the provider doesn't replay
ambiguous mutations automatically.

Updates can overwrite changes made after planning. Review a fresh plan before
applying. For import commands and the removal sequence, see
[Manage existing access](terraform.md#manage-existing-access) and
[Remove access](terraform.md#remove-access).
