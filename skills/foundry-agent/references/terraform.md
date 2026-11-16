# Author FoundryX Terraform configurations

Use the installed provider's schema for HCL structure, not a second hand-maintained
resource specification in this skill. This workflow authors configuration; it does
not authorize live access changes or native Azure provisioning.

## Resolve the provider and its reference material

Read the user's existing `.tf` files and `.terraform.lock.hcl` first. Preserve the
provider source, version constraints, backend, and unrelated configuration. Do not
upgrade providers or change the backend just to obtain a schema.

The provider is published on the
[Terraform Registry](https://registry.terraform.io/providers/smallblackhole/foundryx/latest/docs)
as `smallblackhole/foundryx` (full source address:
`registry.terraform.io/smallblackhole/foundryx`). Use `source = "smallblackhole/foundryx"`
for new configurations and select a published version compatible with the user's
constraints. Do not invent a publisher, download URL, or CLI scaffolding command.
If installation fails, report the blocker and use matching provider documentation
when available; label unvalidated HCL accordingly.

Use the matching version's Registry documentation for authentication, import,
recovery, and removal guidance. Complete registration/policy/membership examples
are distributed in the
[public provider repository](https://github.com/SmallBlackHole/terraform-provider-foundryx).
For version `0.0.2`, see the published
[examples](https://github.com/SmallBlackHole/terraform-provider-foundryx/tree/v0.0.2/examples)
and [resource documentation](https://github.com/SmallBlackHole/terraform-provider-foundryx/tree/v0.0.2/docs/resources).
For other versions, resolve files from the matching release tag rather than
assuming example paths are unchanged. Do not require a source checkout, private
repository access, local build, or development installation overrides.

## Inspect the actual schema

After provider installation in the Terraform working directory:

```text
terraform providers schema -json
```

If initialization is needed only for authoring, use `terraform init -backend=false`
to install the declared provider from the Registry without initializing the backend.
Preserve any existing approved installation overrides. Do not configure or migrate
remote state, bypass installation errors, or substitute another provider.

Parse the JSON locally and select
`provider_schemas["registry.terraform.io/smallblackhole/foundryx"]`.
Inspect only the relevant entries:

- `provider.block.attributes` for endpoint and tenant configuration.
- `resource_schemas` for supported resource types.
- Each resource's `block.attributes` and `block.block_types` for types,
  descriptions, and required/optional/computed fields.

Schema retrieval does not require FoundryX credentials or configure the provider's
API client. It describes the installed version, not live project inventory. It
does not encode every validator, import format, or deletion behavior; use the
matching resource docs and sample for those constraints. Do not infer support for
Agents, model deployment, or arbitrary CLI commands from the provider name.

## Author only the requested FoundryX access

- Register an existing native Foundry project; registration does not create Azure
  infrastructure. Keep any separately requested Azure provisioning distinct.
- Configure complete model and tool allowlists, not incremental additions.
  Explicit empty sets deny all. Use real deployment names and discovered tool keys.
- Reference the registration's computed project UUID in dependent resources.
  Memberships must explicitly depend on the policy when that policy is managed in
  the same configuration, so access is not granted before restrictions are set.
- Manage direct user, group, or tenant grants, not inferred effective access.
  Tenant-wide grants affect all users in the tenant and support only Consumer/User.
  Never invent principal UUIDs or silently broaden roles.
- Import existing registrations and direct grants instead of trying to recreate
  or silently adopt them. Use import formats from the matching resource docs.
- Warn before destructive changes: registration removal revokes all FoundryX
  project access, including grants outside this configuration, but retains native
  Azure resources. Independent policy deletion is unsupported; follow the
  documented state-only policy handoff before registration removal.

Prefix user-chosen labels and placeholders with `your-`; preserve provider-defined
resource types, argument names, enums, and tool-key syntax. Use typed variables for
missing environment values. Ask only for unresolved values needed for the requested
work; never request tokens or put credentials in HCL, variable files, or state.

## Validate and hand off

```text
terraform fmt
terraform validate
```

Format only the files in scope. Validation checks configuration, not permissions or
successful deployment. Report missing providers or failed checks as unverified.

Run `terraform plan` only when the user requests or authorizes live planning;
planning can authenticate and read remote state. Use the installed FoundryX CLI for
any needed identity/project/principal discovery, following
[Permissions & access](permissions.md). Terraform itself never installs the CLI or
opens login. On credential failure, surface its download link and tenant-specific
login instruction; the user signs in separately and reruns the command. Do not use
`az login`, direct HTTP scripts, or a token-copying workaround.

Do not run `apply`, `destroy`, imperative imports, state removal, or a state-only
handoff without explicit approval for that action. After an ambiguous mutation,
inspect and recover/import as documented rather than blindly retrying. Hand off
the files changed, provider version/schema used, checks performed, and any blocked
values or operations without claiming unapplied access exists.
