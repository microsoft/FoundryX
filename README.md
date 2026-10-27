# FoundryX plugin (preview)

GitHub Copilot plugin for FoundryX-managed Microsoft Foundry projects. It includes
the `foundry-agent` skill and **FoundryX Canvas (Preview)** (`foundryx-canvas`). It does not change
the existing `microsoft-foundry` plugin or provide the native `azd ai` workflow.

## Prerequisites

- Use the installed FoundryX CLI (`foundryx`). Install only if it is missing or an
  encountered issue suggests a version mismatch, not just because the version
  differs from this plugin.
- When installation or an update is needed, select a published matching
  [FoundryX CLI release](https://github.com/microsoft/foundryx-plugin/releases?q=FoundryX&expanded=true),
  including prereleases, for the intended service environment, OS and architecture.
  Use the full release version rather than GitHub's latest-release endpoint.
  Standalone binaries do not require Node.js or npm. Linux sign-in requires
  `libsecret-1` and a running Secret Service/keyring.
- Retain the CLI service profile for the FoundryX environment you intend to use.
  This plugin contains no service profile and does not select an environment.
- Use GitHub Copilot App with canvas extension support for the graphical view.
  The skill can also be used in a compatible Copilot CLI session.

Installing the plugin does not run CLI installation hooks, sign in or grant
permissions. The skill provides CLI installation guidance when needed; it does
not bundle the executable. Complete sign-in when needed:

```text
foundryx --version
foundryx auth status
foundryx auth login
```

## Install

After the plugin is published at the root of this repository's default branch:

```text
copilot plugin marketplace add microsoft/foundryx-plugin
copilot plugin install foundry-agent@foundryx
```

The repository includes a small catalog listing only this root plugin. Direct
installation with `copilot plugin install microsoft/foundryx-plugin` currently
works, but Copilot CLI warns that direct installs are deprecated.

In VS Code, run **Chat: Install Plugin From Source** from the Command Palette and
enter `https://github.com/microsoft/foundryx-plugin`. Alternatively, use **Chat: Add
Plugin Marketplace** with `microsoft/foundryx-plugin`, browse it and install
`foundry-agent`.
Installing the skill does not enable canvas capabilities in a host that lacks them.

For a local checkout, use the repository root:

```text
copilot plugin install <path-to-foundryx-plugin>
```

Start a new Copilot session after installation. Use `copilot plugin list` to
confirm the `foundry-agent` plugin is enabled. A local install is cached; reinstall
it after changing the local package.

If `foundry-agent` is installed from another repository or marketplace, uninstall
that copy before installing from this repository. Existing installations do not
automatically switch sources.

Do not load duplicate copies of the same skill/canvas. Before activating this
plugin, remove or disable a separately installed `foundry-agent` skill and the
standalone `foundry-canvas` extension. Inspect their locations first and remove
only those exact components; do not delete shared Copilot configuration or the
CLI credential cache. The native `microsoft-foundry` plugin can remain installed:
its builder canvas uses a different canvas ID.

## Use

For the access model, roles, resource policies, and administration options, see
[FoundryX administration concepts and reference](doc/enterprise-admin-agent-access.md).
For the step-by-step portal task, follow
[Walkthrough: Register project permissions](doc/register-project-permissions.md).

Invoke `/foundry-agent` for FoundryX workflows. In clients that qualify plugin
components, select the `foundry-agent` skill from this plugin in the skill picker.
It discovers projects and tools, builds and operates Agents, and uses the hosted
FoundryX API through the installed CLI.

For a graphical list of deployed Agents, ask Copilot to open the FoundryX Agent
canvas. The skill opens it directly; no separate open command is needed.
The canvas shares the CLI account and OS credential cache. Sign-out in either also
signs out the other. Opening the canvas does not publish or modify an Agent.

Project Users and Managers discover and reuse configured connections/Toolboxes.
All connection/Toolbox writes require effective Project Owner membership, even
for subscription administrators. Per-user tool consent remains a manual action.
Deployment, invocation, evaluation and publishing can incur costs; ordinary
deployment does not automatically publish an Agent to Microsoft 365 or Teams.

## Package layout

```text
foundryx-plugin/
  marketplace.json
  plugin.json
  skills/foundry-agent/SKILL.md
  skills/foundry-agent/references/
  com.github.copilot/extensions/foundry-canvas/
    extension.mjs
    cli-bridge.mjs
    public/
```

This is an Agent Plugins 1.0 package, matching the format used by
`microsoft-foundry@awesome-copilot`. The existing canvas runtime and UI are
packaged without replacing their transport or authentication.

Plugin updates distribute the skill and canvas together. They do not update the
separate CLI. The manifest version matches the packaged skill/CLI base source
version; CLI builds may append an environment suffix. Follow the skill's
prerequisite checks rather than reinstalling a working CLI merely because its
version differs.

This repository distributes the standalone `foundry-agent` plugin. Its generated
contents come from the FoundryX source repository; update the source and re-export
rather than editing the generated skill or canvas here. Public standalone CLI
binaries are distributed through this repository's releases, not inside the plugin.
Review public changes before committing or pushing. No credentials, tenant
inventory, native connection definitions or CLI installation packages are included.

## Releasing CLI binaries

The **Build and release FoundryX CLI binary** GitHub Actions workflow publishes
Windows x64/ARM64, macOS x64/ARM64 and Linux x64 binaries with checksums and source
provenance. It builds from a trusted private FoundryX source branch; this public
repository contains only the release automation and generated plugin.

1. Configure the repository Actions secret `FOUNDRYX_SOURCE_SSH_KEY` with the
   private key corresponding to a read-only deploy key on
   `SmallBlackHole/foundry-orchestrator-agent`. Set it through GitHub repository
   settings; never put key material in a file committed to this repository.
2. Commit and push the source changes, keeping the CLI package/lockfile, skill and
   canvas manifest base versions aligned. Export and review the matching plugin,
   then commit and push this repository's plugin and release automation.
3. Obtain explicit confirmation before manually running the workflow. Select its
   `main` branch, a trusted `source_branch` (default `main`) and an `environment`
   matching the intended service profile (default `staging`).
4. The workflow resolves the source commit once, builds and tests all five native
   targets with Node.js 24, and publishes a **prerelease**, not a draft, tagged
   `foundryx-v<version>-<environment>`. It does not overwrite an existing release.
   Verify all five binaries, `SHA256SUMS`, `release.json` and `release-notes.md`
   before announcing the release.

Repository setup alone does not publish binaries. Confirm a matching release
exists before directing users to install the CLI.

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
