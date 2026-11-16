# Native Foundry skills

This is the explicit Project Owner administration path. These resources are not
the coding assistant's installed skills. Every `foundryx skill` command, including
list, show and download, requires effective Project Owner membership.
Subscription-management authority alone is insufficient.

Check `foundryx skill --help` before using this capability. If the installed CLI
does not expose it, report the version/capability mismatch and use the matching
CLI release; never substitute `az`, `azd`, direct HTTP or a second skill system.

## Create, stage and publish

Author a skill directory with `SKILL.md` at its root, optionally with supporting
files. Front matter requires an unquoted matching `name` and a nonempty unquoted
`description`; the body contains the instructions. Do not include credentials,
repository state or dependency caches.

```text
foundryx skill list --project <project-id>
foundryx skill create <name> --from-file <SKILL.md-or-directory-or-zip> --project <project-id>
foundryx skill show <name> --project <project-id>
foundryx skill version create <name> --from-file <path> --project <project-id>
foundryx skill version list <name> --project <project-id>
foundryx skill show <name> --version <version> --project <project-id>
foundryx skill publish <name> <version> --project <project-id>
```

Creation initializes the first version as default and refuses an existing native
name. Later uploads create immutable staged versions and leave the default
unchanged. Publish explicitly selects a version, including for rollback.
Existing same-project native skills need no import or adoption.

Mutations default to human-readable output; use `--output json` for structured
results. An unresolved mutation or readback failure is not success: inspect
native metadata before retrying, and never blindly repeat a version upload.
Obtain approval before impactful administration; never create/delete/recreate
shared resources as an automatic Agent-building fallback.

## Inspect content and delete

```text
foundryx skill download <name> --version <version> --output-file <new-file.zip> --project <project-id>
foundryx skill version delete <name> <version> --project <project-id>
foundryx skill delete <name> --project <project-id>
```

Download saves a raw ZIP to an explicit new file; it never overwrites, extracts,
executes scripts, or installs a coding-assistant skill. Omit `--version` to
resolve the default once and download that concrete version.

Default versions and known native references block deletion. Incomplete
dependency inspection fails closed. Deletion never cascades or force-removes
references; Hosted source and external consumers cannot be exhaustively scanned.

## Expose through a Toolbox

Only a Project Owner can create/version/publish a Toolbox with skill references.
Use the existing [Toolbox workflow](toolbox.md) with a complete snapshot:

```yaml
description: Support guidance
tools: []
skills:
  - name: support-style
    version: "2"
```

Pin a version for stable behavior. Omitting `version` follows the skill default
and later skill publication can change runtime behavior without republishing the
Toolbox. If any retained Toolbox version contains skills, including staged
versions and history after rollback, new versions require an explicit `skills`
list; `skills: []` intentionally omits attachments from the new snapshot.

Normal User/Manager workflows use an allowed `toolbox show [--version]`, which
returns skill names and pinned-version/default-following references only.
Do not call standalone skill APIs or fetch skill bodies for normal discovery.
The Toolbox grant covers its attached skills; no separate skill grant exists.
Toolbox lists do not reveal attached skills.

At runtime the Hosted `toolbox` sample uses a compatible SDK skills provider
alongside its ordinary tools. Skills are MCP resources, not ordinary tools.
Verify skill loading through the deployed Agent; stored references, a build,
or a model claiming to have a skill are not execution proof. Local `agent run`
still does not proxy Toolbox MCP.
