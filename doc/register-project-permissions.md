# Walkthrough: Grant project access

> [!IMPORTANT]
> FoundryX is an experimental project. It is currently available only by invitation to selected customers.

Use this walkthrough to register an existing Microsoft Foundry project in FoundryX, assign project roles, choose allowed models and tools, and verify user access.

For permission details and administration concepts, see [Admin Center permissions by page](admin-portal-permissions.md) and [FoundryX administration concepts and reference](enterprise-admin-agent-access.md).

## Before you begin

Make sure you have:

- An active, onboarded FoundryX tenant. If needed, complete [Tenant onboarding requirements](tenant-onboarding-requirements.md) first.
- All 15 [Access management Actions](admin-portal-permissions.md#required-access-management-actions) at subscription scope on the target Azure subscription (for example, **Owner**, **Contributor** + **User Access Administrator**, or a qualifying custom role). If you use Privileged Identity Management (PIM), activate your role first.
- An existing Microsoft Foundry project under an `AIServices` Foundry account in that subscription, with a ready model deployment and any required connections or Toolboxes already configured.
- The list of Microsoft Entra users or groups that need project access (optional during initial registration—you can also add them later).

If you need to create a native Foundry project first, see [Prepare the tenant and resources](enterprise-admin-agent-access.md#prepare-the-tenant-and-resources). Registering a project grants Azure resource roles to your tenant's FoundryX service principal; review [what project registration grants](enterprise-admin-agent-access.md#know-what-project-registration-grants) before you start.

## 1. Sign in to the Admin Center

1. Open the [FoundryX Admin Center (staging)](https://foundryx-portal-staging.redsea-0f4601f0.westus2.azurecontainerapps.io/) or the URL provided by your service operator.
2. Sign in with your work or school account, and complete any multifactor authentication (MFA) prompt.
3. To open a specific tenant directly, use `https://<admin-center-host>/?tenant=<tenant-id>`.
4. If you're already signed in and need to switch tenants or accounts, open **Account**, find **Current directory**, and select **Switch** (or **Switch account**).

![FoundryX Admin Center Overview with the Manage project access action.](images/admin-landing-page.png)

*The staging Admin Center Overview.*

## 2. Select the project

1. On **Overview**, select **Manage project access** (or select **Access** in the left navigation).
2. Select **Grant access**.
3. Select **Azure subscription**. If you have management permissions on only one subscription, the form selects it automatically.
   - Subscriptions where you have read access but lack the 15 management Actions appear disabled. Hover over a disabled subscription or select **View missing permissions** (and **Copy**) to see which Actions you need.
4. Select **Foundry project** and choose an unregistered project.
   - If your project is already registered, open its existing entry in the **Access** list instead.
   - To create a project in Microsoft Foundry first, select **Create new Foundry project**, and then reopen **Grant access**.

## 3. Review employee access

In **Users / Groups**, your signed-in account is preselected as **Owner**. Keep, change, or remove this draft assignment as needed. Initial user assignments are optional—you can remove all assignments to register the project first and add users later.

1. Under **Users / Groups**, search for and select the Microsoft Entra users or groups you want to add, or select **All users in \<tenant name\>** for tenant-wide access.
2. Choose a **Foundry X role** for each entry:
   - **Consumer** (default for newly added entries): Invoke deployed agents and use allowed models.
   - **User**: Build, deploy, evaluate, monitor, and publish agents; reuse approved connections and Toolboxes.
   - **Manager**: Everything in **User**, plus add or remove **User** grants for individuals and groups.
   - **Owner**: Everything in **User**, plus manage all project roles, allowed models and tools, and project connections and Toolboxes.

Tenant-wide grants support **Consumer** or **User** only. For details on how multiple grants combine, see [Choose the correct project role](enterprise-admin-agent-access.md#choose-the-correct-project-role).

## 4. Register the project and review access

1. Select **Grant access** and wait for registration to finish.
2. Select the project name in the **Access** list to open **Access details** and **Users / Groups**.
3. Confirm that the saved Microsoft Entra users, groups, and roles match what you expect.
4. To add or edit users later, use **Add Users / Groups** or select **...** > **Edit access** > **Access**, and then select **Save**.

New registrations start with empty model and tool allowlists (`[]`), which block all models and tools until you complete step 5.

If the project status shows **Import incomplete**, wait for Azure role propagation or resolve the reported error, and then select **...** > **Retry import**. See [Registration lifecycle](enterprise-admin-agent-access.md#registration-lifecycle) and [Troubleshoot](enterprise-admin-agent-access.md#troubleshoot) for details on partial saves and retry behavior.

## 5. Choose allowed models and tools

1. Open the project's **...** menu and select **Edit access**. The dialog opens on the **Models & Tools** tab.
2. In **Allowed models**, select the model deployment names that project members can use. (To deploy a new model in Foundry first, select **Deploy new models in Foundry portal**.)
3. In **Allowed tools**, select the built-in tools (such as **Web search**), project connections, and Toolboxes that project members can use. Allowing a Toolbox covers its configured tools and same-project connections; add a separate connection grant only if agents use that connection directly outside the Toolbox.
4. Select **Save**, reopen the project entry, and confirm your saved **Allowed models** and **Allowed tools**.

In **Edit access**, the FoundryX service principal loads models and tools in one combined request. If either list fails to load, select **Retry model deployments** or **Retry project tools**, or check the service principal's [model read permissions](admin-portal-permissions.md#allowed-models) and [tool permissions](admin-portal-permissions.md#allowed-tools).

## 6. Verify employee access

1. Ask a builder with **User**, **Manager**, or **Owner** access to install the plugin and sign in using the [Builder guide](builder-guide.md#get-started-with-the-plugin).
2. Have the builder verify access in Copilot, or run these command-line interface (CLI) checks (after [manual CLI setup](builder-guide.md#manual-cli-setup-optional)):

   ```text
   foundryx --version
   foundryx auth login --tenant <tenant-id>
   foundryx auth status
   foundryx access show
   foundryx access project list
   foundryx access show --project <project-id>
   foundryx access check --project <project-id> --action agent.deploy --model <deployment-name>
   ```

   Use the FoundryX project universally unique identifier (UUID) from `foundryx access project list`, not the Azure resource ID.
3. If the builder's agent uses a Toolbox, include it in the check:

   ```text
   foundryx access check --project <project-id> --action agent.deploy --model <deployment-name> --tool toolbox:<toolbox-name>
   ```

4. Have the builder deploy a test agent and invoke it to confirm runtime access (deployment and invocation can incur Azure charges):

   ```text
   foundryx agent invoke "Verify the configured tool with a non-sensitive request." --agent-id <agent-id> --project <project-id>
   ```

5. Share the tenant sign-in link, FoundryX project UUID, approved model deployment names, approved tool names, and your team's contact for access requests.

## Next steps

- [Control model access and deployment](enterprise-admin-agent-access.md#control-model-access-and-deployment)
- [Prepare and allow tools](enterprise-admin-agent-access.md#prepare-and-allow-tools)
- [Manage project membership](enterprise-admin-agent-access.md#manage-project-membership)
- [Disable or remove a permission](enterprise-admin-agent-access.md#disable-or-remove-a-permission)
