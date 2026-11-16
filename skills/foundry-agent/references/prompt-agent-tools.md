# Prompt Agent tools

Configure `agent.tools` in `foundryx.yaml` for a Prompt Agent (`kind: prompt`), then run `foundryx agent deploy` (`tools: []` disables tools on a plain non-harness Prompt Agent; on a `microsoft_copilot_preview` Agent, keep `microsoft_copilot_toolset_preview` with all 5 harness tools resolved to `enabled: false`—such as `default_config.enabled: false` with no enabled `configs`—to disable built-in harness tools; omitting `tools` on update preserves deployed settings).

For existing project resources, first use `connection list` and `connection show`
per [Discover and reuse tools](tool-discovery.md). Use only the reported supported
Prompt mapping; resource discovery does not validate live authentication. Do not
create connections, fetch credentials or change an existing Toolbox as part of
ordinary Agent building.

## 1. Microsoft Copilot toolset (`microsoft_copilot_toolset_preview`)

```yaml
harness:
  type: microsoft_copilot_preview
tools:
  - type: microsoft_copilot_toolset_preview
    default_config:
      enabled: true # false keeps unset built-in harness tools disabled
    # Optional per-tool overrides when requested:
    configs:
      - name: filesystem_read
        enabled: true
      - name: filesystem_write
        enabled: true
      - name: shell
        enabled: true
      - name: web
        enabled: false
      - name: subagents
        enabled: true
```

- **Harness & YAML contract**: Requires `harness.type: microsoft_copilot_preview` on a Prompt Agent (`kind: prompt`), using `snake_case` fields (`default_config.enabled` and optional unique `configs` entries for `filesystem_read`, `filesystem_write`, `shell`, `web`, and `subagents`). `foundryx agent init` (`harness-agent` sample) starts with `default_config.enabled: false`; set `default_config.enabled: true` automatically when `builtin:microsoft_copilot_toolset_preview` is in `allowed_tools` from `foundryx access show --project <project-id>`, keep it `false` when not allowed, and add per-tool `configs` only when requested. Existing Agents cannot switch `harness` across versions (`409 agent_harness_immutable`).
- **Policy check**: `builtin:microsoft_copilot_toolset_preview` is required whenever at least one of the 5 harness tools (`filesystem_read`, `filesystem_write`, `shell`, `web`, `subagents`) remains enabled after applying `default_config.enabled` (default `true` when omitted or when `microsoft_copilot_toolset_preview` is omitted on a `microsoft_copilot_preview` Agent) and per-tool `configs` overrides; no grant is required when all 5 tools resolve to `enabled: false`:
  ```text
  foundryx access check --project <project-id> --action agent.deploy --model <deployment> --tool builtin:microsoft_copilot_toolset_preview
  ```
- **Search tool selection (`web` vs `web_search`)**: Prefer one search tool—when the harness `web` tool is enabled, do not also configure `type: web_search` unless the user explicitly asks for `web_search` (or set `web` to `enabled: false` in `configs` when using `web_search`).
- **Region & verification**: Surface unsupported-region, unsupported-model, or policy errors directly without masking the failure; fall back to a plain Prompt Agent without `harness` only when the project region does not support the Microsoft Copilot harness or when explicitly requested. Normalized `tool_calls` from `foundryx agent invoke "<prompt>" --json` does not include `microsoft_copilot_toolset_preview` harness tool calls (`filesystem_read`, `filesystem_write`, `shell`, `web`, `subagents`) and raw output items are not retained, so a completed harness tool call can leave `tool_calls` absent or empty; report harness tool execution as unverified unless independent evidence is available.

## 2. Built-in Web Search and Code Interpreter

```yaml
tools:
  - type: web_search
  - type: code_interpreter
```

- **Runtime limits**: Code Interpreter supports text results only (no file upload/download or retained Python state across turns). Web Search uses Bing under separate data-handling terms; both tools may incur extra charges. Keep pilot inputs synthetic or public.
- **Verification**: Read sources/warnings in default output, and use remote `foundryx agent invoke "<prompt>" --json` to verify actual `tool_calls` (`type` and `status`)—enabled does not mean executed, and answer prose is not proof of tool use. Surface unsupported model, region, or policy errors directly without falling back to a tool-free answer.

## 3. Existing Azure AI Search index

```yaml
tools:
  - type: azure_ai_search
    azure_ai_search:
      indexes:
        - project_connection_id: <search-connection-name>
          index_name: <index-name>
          query_type: simple # simple | vector | semantic | vector_simple_hybrid | vector_semantic_hybrid
          top_k: 5
          # filter: "<optional OData filter <= 8192 chars>"
```

- Configure at most one `azure_ai_search` entry with one index from an existing knowledge source (`indexes` length 1); do not provision or alter Search resources during Agent authoring.
- Require grounded answers with citations and report tool failures rather than guessing.

## 4. Direct public MCP servers

```yaml
tools:
  - type: mcp
    server_label: docs
    server_url: https://learn.microsoft.com/api/mcp
    require_approval: never
  - type: mcp
    server_label: issues
    project_connection_id: shared-issues-reader
    require_approval: never
    allowed_tools:
      - list_issues
```

- **Auth & URL**: Use `server_url` alone for unauthenticated endpoints, or `project_connection_id` for an existing same-project `RemoteTool` connection (`none` or `custom-keys`; Project `user`/`manager`/`owner` may attach existing connections, but creating/updating them requires administrator authority per [RemoteTool MCP connections](connection-create.md); native connection names are not FoundryX UUIDs). If both are supplied, `server_url` must match the connection target. `server_url` requires a public HTTPS DNS name on port 443 without query parameters, fragments, or embedded credentials. Never put headers or keys in YAML.
- **Approval & least privilege**: Require distinct `server_label` values (`^[A-Za-z0-9_-]{1,64}$`) and explicit `require_approval: never` (approval/resume is unsupported; an unexpected approval is an error, not permission to approve). Because all consumers share the connection's key without per-call confirmation, prefer read-only keys and a narrow `allowed_tools` list (omitting it exposes all tools).
- **Hosted-only MCP cases**: Do not add OAuth/OBO, Entra identity connections (`project-managed-identity`, `agentic-identity`), private MCP endpoints, or Toolboxes through Prompt `agent.tools`; use a Hosted Agent ([Hosted Agent Toolbox](hosted-agent-toolbox.md)).
- **Verification**: Inspect `MCP calls:` (`<server_label>/<tool>: completed|failed`) in output or `tool_calls` in `--json`, not just tool discovery or answer prose. Key rotation is live; changed target URLs require reviewed redeployment. Do not retry ambiguous execution automatically.
