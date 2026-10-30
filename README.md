# FoundryX plugin (preview)

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

GitHub Copilot plugin for FoundryX-managed Microsoft Foundry projects. It includes
the `foundry-agent` skill and **FoundryX Canvas (Preview)** (`foundryx-canvas`). It does not change
the existing `microsoft-foundry` plugin or provide the native `azd ai` workflow.

For capabilities, architecture, and governance, see the
[FoundryX overview](doc/overview.md). Browse the
[documentation contents](doc/overview.md#table-of-contents) for administration and Builder guides.

## Prerequisites

- Install and enable the `foundry-agent` plugin using the [steps below](#install).
- FoundryX access from your organization. Installing the plugin does not onboard
  your tenant or grant project permissions.
- A compatible coding-agent client and workspace where the agent can execute
  commands and, when needed, install user-owned tools.
- A host with canvas extension support if you want the graphical view. Other
  compatible hosts can use the CLI workflow without Canvas.

You do not need to install or run the FoundryX CLI manually before starting.
The skill checks the installed CLI and handles installation when it is missing,
or an update when a compatibility issue requires one. The plugin installer itself
does not bundle the CLI, run installation hooks, or sign you in.

For direct terminal use or troubleshooting, see
[Manual CLI setup (optional)](doc/builder-guide.md#manual-cli-setup-optional).

## Install

Follow the [Builder guide installation steps](doc/builder-guide.md#get-started-with-the-plugin)
for VS Code / Insiders, the GitHub Copilot app, or GitHub Copilot CLI.
The guide includes screenshots, installation checks, and local-checkout instructions.
If the plugin is already installed, follow [Upgrade](#upgrade).

## Upgrade

Update `foundry-agent` through the same client/interface used to install it.

**GitHub Copilot CLI:**

```text
copilot plugin update foundry-agent@foundryx
```

**VS Code / Insiders:** Open the Command Palette and run **Chat: Open Customizations** to manage / upgrade plugin or even the marketplace.

For a local installation, reinstall from the updated checkout. Start a new
Copilot session and reopen Canvas after updating. The skill checks the CLI
separately and updates it only when needed; keep a working installation and
preserve your service environment, configuration and sign-in.

## Use

For the access model, roles, resource policies, and administration options, see
[FoundryX administration concepts and reference](doc/enterprise-admin-agent-access.md).
For the step-by-step portal task, follow
[Walkthrough: Grant project access](doc/register-project-permissions.md).

Invoke `/foundry-agent` for FoundryX workflows. In clients that qualify plugin
components, select the `foundry-agent` skill from this plugin in the skill picker.
It discovers projects and tools, builds and operates Agents, and uses the hosted
FoundryX API through the installed CLI.

Let the coding agent handle CLI setup, commands and resource discovery. Complete
Microsoft sign-in yourself when prompted and review requested operations.

For a graphical list of deployed Agents, ask Copilot to open the FoundryX Agent
canvas. The skill opens it directly; no separate open command is needed.
The canvas shares the CLI account and OS credential cache. Sign-out in either also
signs out the other. Opening the canvas does not publish or modify an Agent.

Project Users and Managers discover and reuse configured connections/Toolboxes.
All connection/Toolbox writes require effective Project Owner membership, even
for subscription administrators. Per-user tool consent remains a manual action.
Deployment, invocation, evaluation and publishing can incur costs; ordinary
deployment does not automatically publish an Agent to Microsoft 365 or Teams.

## Builder documentation

- [Builder concepts and reference](doc/builder-guide.md) explains access, CLI and
  Canvas capabilities, tools, evaluation, monitoring, publishing, and troubleshooting.
- [Walkthrough: Build and operate your first agent](doc/build-first-agent.md)
  covers sign-in, development, deployment, remote invocation, and Canvas inspection,
  with optional tool, evaluation, monitoring, and publishing steps.

## Package layout

```text
FoundryX/
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

This repository distributes the standalone plugin and public CLI binaries. The
CLI executable is a separate release asset, not a component inside the plugin.
The plugin contains no credentials, tenant inventory or native connection definitions.

## CLI release files

Each CLI release provides Windows x64/ARM64, macOS x64/ARM64 and Linux x64 binaries,
`SHA256SUMS`, `release.json` and installation notes. Select the version and service
environment that match your intended use. The release metadata records platform,
runtime, executable size and SHA-256 checksums.

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
