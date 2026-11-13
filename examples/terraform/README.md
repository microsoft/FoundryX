# FoundryX Terraform examples

These examples manage FoundryX access to an existing Microsoft Foundry
project. They don't create the native project, models, or tools.

| Example | What it grants |
| --- | --- |
| [Existing project access](existing-project-access/main.tf) | Consumer access to one user. |
| [All-in-one access](all-in-one/main.tf) | Owner access to one user, User access to one group, and Consumer access to the entire tenant. |

> [!WARNING]
> The all-in-one example grants access to **all users in the tenant**. Remove
> the `foundryx_project_member.tenant` block if you don't want that grant.
> Registration can create Azure roles and assignments for the FoundryX service
> principal. Review the [registration scopes](../../doc/enterprise-admin-agent-access.md#know-what-project-registration-grants)
> and the plan before applying.

## Run an example

1. Complete the [Terraform prerequisites](../../doc/terraform.md#prerequisites),
   including tenant onboarding, subscription permissions, and CLI sign-in.
   The provider connects to staging by default.
2. Choose one example directory. Create `terraform.tfvars` there using its
   `terraform.tfvars.example` as a template. Replace every placeholder with
   the tenant and project IDs and the user or group object IDs you intend to
   grant access to. Don't commit your local variables file.
3. Set `allowed_models` and `allowed_tools` to the **complete** sets you want
   to allow. Names and keys are case-sensitive; an empty set allows none.
   See [project policy](../../doc/terraform-provider-reference.md#project-policy).
4. In the example directory, run `terraform init`.
5. If the registration, policy, or direct grants already exist, import each
   existing record before applying. See [Import existing records](#import-existing-records).
6. Run `terraform plan`. Review the plan, then run `terraform apply` if the
   changes are intended.

The examples use local Terraform state by default. Protect state and plan files,
which can contain sensitive data. Use a secured remote backend for shared work.

## Import existing records

For either example, use the FoundryX project UUID, not the Azure resource ID.
Import only the records that already exist:

```shell
terraform import foundryx_project_registration.project "<tenant-id>/<project-id>"
terraform import foundryx_project_policy.policy "<tenant-id>/<project-id>"
```

For existing project access:

```shell
terraform import foundryx_project_member.consumer "<tenant-id>/<project-id>/user/<user-object-id>"
```

For all-in-one access:

```shell
terraform import foundryx_project_member.owner "<tenant-id>/<project-id>/user/<owner-object-id>"
terraform import foundryx_project_member.group "<tenant-id>/<project-id>/group/<group-object-id>"
terraform import foundryx_project_member.tenant "<tenant-id>/<project-id>/tenant/<tenant-id>"
```

The provider doesn't automatically adopt existing registrations or direct
grants. An imported policy can change if its complete allowlists differ from
your configuration. Review the next plan.

## Remove access

Removing a member block revokes only that direct grant. To remove an entire
registration, first hand off its policy from Terraform state and remove the
members' dependencies on that policy. Follow the
[safe removal steps](../../doc/terraform.md#remove-access); don't use a
one-step destroy. Removing a registration revokes **all** FoundryX access to
the project, including grants managed outside Terraform, but retains native
Azure resources.
