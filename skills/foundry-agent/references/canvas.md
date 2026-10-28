# FoundryX Canvas

Open the `foundryx-canvas` canvas when the user explicitly asks to list or view
deployed Agents, or by default after a successful `foundryx agent deploy`. It
lists only Agents created by the signed-in user in projects where they have
developer access, and provides publishing actions. For a text listing of all
project Agents, use `foundryx agent list --project <project-id>` for each applicable
project from `foundryx access project list`. Do not present that project-wide count
as the personal canvas count.
Reuse an existing matching canvas when available. Opening the canvas is a display
step; continue any remaining requested work.

The canvas shares the CLI account and credential cache.

The canvas refreshes PATH before starting the CLI. If it cannot find a newly
installed CLI, wait for installation to finish and reopen the canvas to retry.
