# Manage FoundryX project access with Terraform

Use the [FoundryX Terraform provider](https://github.com/SmallBlackHole/terraform-provider-foundryx)
to manage access to an existing Microsoft Foundry project. The provider is
published under the `smallblackhole/foundryx` namespace.

> [!IMPORTANT]
> FoundryX is an experimental project available by invitation to selected
> customers. The provider connects to the staging environment by default.

## What the provider manages

| Resource | Purpose |
| --- | --- |
| `foundryx_project_registration` | Register an existing Foundry project with FoundryX. |
| `foundryx_project_policy` | Manage the project's complete model and tool allowlists. |
| `foundryx_project_member` | Manage one direct user, group, or tenant-wide grant. |

The provider does not create native Foundry projects, model deployments, or
tools. Registration can create Azure role definitions and assignments for the
FoundryX service principal. It does not assign Azure roles to project members.
For the access model and registration scopes, see
[Administration concepts and reference](enterprise-admin-agent-access.md#know-what-project-registration-grants).

A new registration starts with empty allowlists, which deny access to models
and tools. The policy resource replaces both complete lists; it does not add
entries to the existing lists. Names and tool keys are case-sensitive. An
empty list allows none.

## Prerequisites

- Terraform 1.7 or later.
- An onboarded FoundryX tenant and an existing Foundry project in that tenant.
- An administrator with the required
  [subscription access management permissions](admin-portal-permissions.md#register-a-project-through-grant-access).
  An Entra administrator role alone is not enough.
- The standalone FoundryX command-line interface (CLI) for the same service
  environment, with generic `auth get-access-token` support. Download it from
  [FoundryX releases](https://github.com/microsoft/FoundryX/releases).
  Terraform does not install the CLI.
- Existing model deployments and tools, if you want to allow them.

Sign in before running Terraform:

```shell
foundryx auth login --tenant <tenant-id>
```

The provider uses the signed-in CLI session to acquire and refresh delegated
credentials. The CLI profile and tenant must match the provider. If the CLI
isn't on your path, set `FOUNDRYX_CLI_PATH` to the native executable or its
`bin\foundryx.js` entry point. The JavaScript entry point requires Node.js;
shell wrappers aren't supported.

The provider also accepts a delegated FoundryX API token through
`FOUNDRYX_ACCESS_TOKEN`, but it doesn't refresh that token. Don't put tokens
in Terraform configuration. Workload identity isn't supported. For details,
see the [provider configuration reference](terraform-provider-reference.md#provider-configuration).

## Register a project and grant access

This example registers an existing project, sets its policy, and grants one
user the Consumer role. Use it for a new FoundryX registration. If any of
these records already exist, [import them first](#manage-existing-access).

Save the following as `main.tf`:

```hcl
terraform {
  required_version = ">= 1.7"
  required_providers {
    foundryx = {
      source  = "smallblackhole/foundryx"
      version = "0.0.5"
    }
  }
}

variable "tenant_id" {
  type = string
}

variable "project_arm_id" {
  type = string
}

variable "allowed_models" {
  type = set(string)
}

variable "allowed_tools" {
  type = set(string)
}

variable "user_object_id" {
  type = string
}

provider "foundryx" {
  tenant_id = var.tenant_id
}

resource "foundryx_project_registration" "project" {
  project_arm_id = var.project_arm_id
}

resource "foundryx_project_policy" "policy" {
  project_id     = foundryx_project_registration.project.project_id
  allowed_models = var.allowed_models
  allowed_tools  = var.allowed_tools
}

resource "foundryx_project_member" "consumer" {
  project_id     = foundryx_project_registration.project.project_id
  principal_type = "user"
  principal_id   = var.user_object_id
  role           = "consumer"

  depends_on = [foundryx_project_policy.policy]
}
```

Set the variables through your usual Terraform workflow:

| Variable | Value |
| --- | --- |
| `tenant_id` | Microsoft Entra tenant UUID matching the CLI session. |
| `project_arm_id` | Azure Resource Manager (ARM) ID of the existing Foundry project. |
| `allowed_models` | Complete set of existing model deployment names to allow. |
| `allowed_tools` | Complete set of tool keys to allow, such as `builtin:web_search`, `connection:<name>`, or `toolbox:<name>`. |
| `user_object_id` | Microsoft Entra object UUID of the user receiving access. |

The explicit dependency applies the policy before the member grant. Terraform
also uses the registration's FoundryX project UUID for the policy and member;
this UUID is different from the Azure project resource ID.

Run the following commands and review the plan before you apply it:

```shell
terraform init
terraform plan
terraform apply
```

The provider supports `consumer`, `user`, `manager`, and `owner` roles for
users and groups. For tenant-wide access, use `principal_type = "tenant"`
and set `principal_id` to the provider's tenant UUID. Tenant-wide grants
support only `consumer` and `user`. They grant access to all users in the
tenant. The server checks which roles the signed-in administrator can assign.
See the [project role comparison](admin-portal-permissions.md#4-what-project-access-do-users-receive).

## Manage existing access

Import each existing registration, policy, and direct grant that you want
Terraform to manage. The provider doesn't automatically adopt existing
records, even when a grant has the requested role. Use the tenant UUID and
FoundryX project UUID, not the Azure resource ID:

```shell
terraform import foundryx_project_registration.project "<tenant-id>/<project-id>"
terraform import foundryx_project_policy.policy "<tenant-id>/<project-id>"
terraform import foundryx_project_member.consumer "<tenant-id>/<project-id>/user/<user-object-id>"
```

Only import records that exist. Review the next plan: differences in the
policy replace the complete allowlists. A direct user grant is separate from
access inherited through a group or tenant-wide grant.

If a create operation succeeds but its response is lost before Terraform saves
state, inspect FoundryX and import the created record before applying again.
For incomplete registration, finish recovery in FoundryX or remove the
incomplete access before retrying. Updates can overwrite changes made after
planning, so review a fresh plan before applying.

## Remove access

To revoke only a direct grant, remove its `foundryx_project_member` block and
apply the reviewed plan. Other direct or inherited grants can still give the
user access.

The policy resource can't be deleted separately. Before removing a
Terraform-managed registration, replace its policy block with a state-only
handoff and remove any member `depends_on` references to that policy:

```hcl
removed {
  from = foundryx_project_policy.policy
  lifecycle {
    destroy = false
  }
}
```

Apply this change while keeping the registration and members configured. Then
remove the member and registration blocks and review the plan before applying.
Do not use a one-step destroy. Removing the registration removes **all**
FoundryX access to that project, including grants managed outside Terraform.
It leaves the native Azure project, deployments, and tools intact.

## References

- [Provider configuration and resource reference](terraform-provider-reference.md)
- [Existing project access example](https://github.com/SmallBlackHole/terraform-provider-foundryx/tree/v0.0.5/examples/existing-project-access)
- [Terraform Registry](https://registry.terraform.io/providers/SmallBlackHole/foundryx/latest)
