# Foundry X

**From an idea to an agent, with your organization's approved models and tools.**

> [!IMPORTANT]
> Foundry X is an experimental project in preview. It is currently available only by invitation to selected customers.

## 🚀 What is Foundry X?

Foundry X helps employees build and operate agents in Microsoft Foundry through
GitHub Copilot. Your organization prepares the Azure resources, approves models
and tools, and grants project access. Builders can then develop agents without
needing their own Azure subscription or individual Azure roles for normal agent work.

Describe what you want to build, review the source and configuration, and let
Copilot help you deploy, evaluate, and operate the agent. Your organization keeps
control of its resources, access, and costs.

**The components**

| Component | What it is used for |
| --- | --- |
| **Copilot plugin** (`foundry-agent`) | Adds the `/foundry-agent` skill and Foundry X Canvas. The skill guides setup, discovers approved resources, and uses the CLI to build and operate agents. |
| **Foundry X CLI** (`foundryx`) | Handles sign-in, project and resource discovery, access checks, agent deployment and invocation, evaluation, monitoring, and publishing workflows. Copilot uses it for you; direct terminal use is also available. |
| **Foundry X Canvas (Preview)** (`foundryx-canvas`) | Gives you a graphical view of deployed agents, details, lifecycle actions, monitoring, and publishing in a supported Copilot host. It is not a source editor or an interactive agent chat. |
| **Admin Center and API** | Let administrators connect the tenant, register projects, choose allowed models and tools, and grant access. The API checks project permissions before using your organization's Foundry resources. |

This repository distributes the plugin and standalone CLI binaries. Foundry X
does not replace Microsoft Foundry or the native `microsoft-foundry` plugin and
its `azd ai` workflow. See the [overview](doc/overview.md) for architecture and governance.

## 🏢 Tenant onboarding

An eligible Microsoft Entra administrator connects your organization to Foundry X
and approves the required application permissions.
Follow [Tenant onboarding requirements](doc/tenant-onboarding-requirements.md)
for administrator roles, consent steps, and tenant activation.

Onboarding lets users sign in, subject to your organization's Entra policies.
It does not grant access to projects or assign Azure resource roles.

## 🔑 Project access configuration

Follow the [tenant administrator walkthrough: Grant project access](doc/register-project-permissions.md)
to register an existing Foundry project, select allowed models and tools, and
assign project access to users or groups.

[Admin Center permissions by page](doc/admin-portal-permissions.md) explains who
can grant access, why model or tool lists may not load, and what Consumer, User,
Manager, and Owner access grants let recipients do in a project.

**Signing in does not grant project access. Foundry X project roles are not
Azure role assignments to each employee.** For the full access model and
resource policies, see the [administration reference](doc/enterprise-admin-agent-access.md).

## 🛠️ Build your first agent

Your tenant must be onboarded, and your administrator must give you **User**
or higher access to a prepared project before you build an agent.

**First, install the plugin.** Choose your Copilot client:


| Where you work | Installation guide |
| --- | --- |
| **VS Code or VS Code Insiders** | [Install the plugin in VS Code](doc/builder-guide.md#vs-code-or-vs-code-insiders) |
| **GitHub Copilot app** | [Install the plugin in the Copilot app](doc/builder-guide.md#github-copilot-app) |
| **GitHub Copilot CLI** | [Install the plugin in Copilot CLI](doc/builder-guide.md#github-copilot-cli) |
| **Direct terminal use** | [Optional manual Foundry X CLI setup](doc/builder-guide.md#manual-cli-setup-optional) |

You do not need to install the Foundry X CLI manually for the plugin workflow.
The skill checks it and installs it if missing, or updates it when needed for
compatibility. The plugin installer itself does not bundle the CLI or sign you in.

Use a workspace where Copilot can run commands and install user-owned tools when
needed. Canvas requires a host with canvas extension support; other compatible
hosts can use the CLI workflow without it. Installing the plugin does not
onboard your tenant or grant project access.

**Then, follow the [Builder walkthrough: Build and operate your first agent](doc/build-first-agent.md).**
It takes you through sign-in, development, deployment, invocation, and inspection.

Invoke `/foundry-agent` and describe the agent you want to build. If your client
qualifies plugin skill names, select this plugin's `foundry-agent` skill in the
skill picker.

Let Copilot handle CLI setup, commands, and resource discovery. Complete
Microsoft sign-in yourself when prompted and review requested operations.

For a graphical view, ask Copilot to open the Foundry X Agent canvas.
It shares the CLI account and OS credential cache; signing out of either signs
out the other. Opening Canvas does not publish or modify an agent.

Project Users and Managers discover and reuse configured connections/Toolboxes.
All connection/Toolbox writes require effective Project Owner membership, even
for subscription administrators. Per-user tool consent remains a manual action.
Deployment, invocation, evaluation and publishing can incur costs; ordinary
deployment does not automatically publish an Agent to Microsoft 365 or Teams.

## 🤝 Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## ⚖️ Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

## 📚 Resources

- [Documentation contents](doc/overview.md#table-of-contents) and [architecture overview](doc/overview.md).
- [Builder concepts and reference](doc/builder-guide.md).
- [Administration concepts and reference](doc/enterprise-admin-agent-access.md).
- [CLI releases and installation notes](https://github.com/microsoft/FoundryX/releases).
- [Issues and feedback](https://github.com/microsoft/FoundryX/issues).

CLI releases include Windows x64/ARM64, macOS x64/ARM64, and Linux x64 binaries,
`SHA256SUMS`, `release.json`, and installation notes. Choose the version and service
environment that match your intended use, and verify the published checksums.
