# Foundry X

**Go from an idea to a working agent with your organization's approved models and tools.**

> [!IMPORTANT]
> Foundry X is an experimental project in preview. It is currently available only by invitation to selected customers.

## 🚀 What is Foundry X?

Foundry X helps you build and run agents in Microsoft Foundry through GitHub Copilot. Your administrators prepare the Azure resources, approve models and tools, and grant project access. You can then build agents without needing your own Azure subscription or individual Azure roles.

Describe what you want to build, review the generated code and settings, and let Copilot help you deploy, evaluate, and monitor your agent. Your organization keeps full control of its Azure resources, access policies, and costs.

| Component | What you use it for |
| --- | --- |
| **Copilot plugin** (`foundry-agent`) | Adds the `/foundry-agent` skill and Foundry X Canvas to GitHub Copilot. The skill guides setup, finds approved resources, and runs the command-line interface (CLI) for you. |
| **Foundry X CLI** (`foundryx`) | Signs you in, checks access, discovers models and tools, and deploys, runs, evaluates, monitors, and publishes agents. You can also run it directly in your terminal. |
| **Foundry X Canvas (Preview)** (`foundryx-canvas`) | Shows your deployed agents, status, endpoints, monitoring metrics, and publishing options in supported Copilot clients. |
| **Admin Center and application programming interface (API)** | Let administrators connect the tenant, register projects, choose allowed models and tools, and grant project access. |

This repository provides the Copilot plugin and standalone CLI binaries. Foundry X works alongside Microsoft Foundry and is separate from the native `microsoft-foundry` plugin (`azd ai`). For architecture and governance details, see the [Foundry X overview](doc/overview.md).

## 🏢 Tenant onboarding

A Microsoft Entra administrator connects your organization to Foundry X and approves the required application permissions. Follow [Tenant onboarding requirements](doc/tenant-onboarding-requirements.md) to check your role, approve consent, and activate your tenant.

Onboarding lets users in your tenant sign in. Next, an Azure subscription administrator registers a project and grants user access.

## 🔑 Project access configuration

After onboarding, register a Microsoft Foundry project, choose allowed models and tools, and assign project roles to users or groups:

- Follow the [Walkthrough: Grant project access](doc/register-project-permissions.md) for step-by-step setup.
- Read [Admin Center permissions by page](doc/admin-portal-permissions.md) to see who can grant access, how model and tool lists load, and what the **Consumer**, **User**, **Manager**, and **Owner** roles allow.
- See the [Administration concepts and reference](doc/enterprise-admin-agent-access.md) for resource policies and troubleshooting.

## 🛠️ Build your first agent

Before you build an agent, make sure your tenant is onboarded and your administrator has granted you **User**, **Manager**, or **Owner** access to a registered project.

1. **Install the Copilot plugin** for your client (Copilot installs or updates the Foundry X CLI automatically when you use the skill):

   | Client | Installation steps |
   | --- | --- |
   | **VS Code or VS Code Insiders** | [Install the plugin in VS Code](doc/builder-guide.md#vs-code-or-vs-code-insiders) |
   | **GitHub Copilot app** | [Install the plugin in the GitHub Copilot app](doc/builder-guide.md#github-copilot-app) |
   | **GitHub Copilot CLI** | [Install the plugin in GitHub Copilot CLI](doc/builder-guide.md#github-copilot-cli) |
   | **Terminal (optional)** | [Set up the Foundry X CLI manually](doc/builder-guide.md#manual-cli-setup-optional) |

2. **Follow the [Walkthrough: Build and operate your first agent](doc/build-first-agent.md).** Run `/foundry-agent`, describe the agent you want to build, and complete Microsoft sign-in when prompted. You can also ask Copilot to open Foundry X Canvas to view, monitor, or publish your deployed agents.

## 🤝 Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot checks whether you need to provide a CLA and comments on the pull request with instructions. You only need to complete the CLA once across all Microsoft repositories.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com).

## ⚖️ Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos must follow [Microsoft's Trademark and Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos is subject to those third parties' policies.

## 📚 Resources

- [Documentation table of contents](doc/overview.md#table-of-contents) and [Foundry X overview](doc/overview.md)
- [Builder concepts and reference](doc/builder-guide.md)
- [Administration concepts and reference](doc/enterprise-admin-agent-access.md)
- [Foundry X CLI releases and checksums](https://github.com/microsoft/FoundryX/releases)
- [GitHub issues and feedback](https://github.com/microsoft/FoundryX/issues)
