# Lab 7 — MCP Integrations II: Partner Connectors, Wildcards, 80-Tool Budget, Plugin Marketplace

## Learning Outcome

Multiple MCP connectors configured with capacity management mastery. Attendees will manage Streamable-HTTP partner connectors, an stdio MCP server, capacity bar tuning, YAML wildcards, and Plugin Marketplace awareness.

> **Pre-read:** [MCP Connectors & Tools](https://sre.azure.com/docs/capabilities/mcp-connectors) · [Setup MCP Connector](https://sre.azure.com/docs/tutorials/connectors/setup-mcp-connector) · [Plugin Marketplace](https://sre.azure.com/docs/capabilities/plugin-marketplace)

---

## Checkpoint Schedule

| Time | Checkpoint |
|------|-----------|
| 0:00 | Lab start — verify sandbox + Lab 6 chain functional |
| 0:15 | ✅ CP1 — Two Streamable-HTTP connectors added |
| 0:30 | ✅ CP2 — stdio MCP server running in agent container |
| 0:45 | ✅ CP3 — Capacity bar exercise complete |
| 0:60 | ✅ CP4 — YAML wildcards wired to custom agent |
| 0:75 | ✅ CP5 — Plugin Marketplace click-through + health drill done |

---

## Step 1 — Add Two Streamable-HTTP Partner Connectors (15 min)

### 1.1 Add Datadog Connector

- **Action:** Navigate to **Builder → Connectors → MCP → Add connector → Streamable HTTP**.
- **Expected state:** The "Add MCP Connector" dialog appears with fields for Name, URL, and Auth method.
- **Troubleshooting:** If the dialog does not load, hard-refresh the portal (`Ctrl+Shift+R`).

### 1.2 Configure Datadog Endpoint

- **Action:** Enter connector name `datadog-mcp`, paste the Datadog MCP endpoint URL provided by the trainer, select **Bearer token** auth, paste the API key from Key Vault.
- **Expected state:** The connector card shows `Testing connection…` then transitions to `Connected`.
- **Troubleshooting:** If `Connection failed`, verify the endpoint URL has no trailing slash and the API key is valid. Check network egress from the agent's VNET.

### 1.3 Add Second Partner Connector (Splunk or GitHub)

- **Action:** Repeat the flow for a second Streamable-HTTP connector (e.g., `splunk-mcp` or `github-mcp`). Use trainer-provided credentials.
- **Expected state:** Two connector cards visible in the Connectors list, both showing `Connected` with green heartbeat.
- **Troubleshooting:** If one connector shows `Disconnected`, wait 60 s for the heartbeat cycle. If persistent, check the connector's health endpoint separately with `curl`.

> **🔖 Checkpoint CP1** — Two Streamable-HTTP connectors show `Connected` status in Builder → Connectors.

---

## Step 2 — Add One stdio MCP Server (15 min)

### 2.1 Configure the npx-Based stdio Server

- **Action:** Navigate to **Builder → Connectors → MCP → Add connector → stdio**. Enter:
  - **Name:** `custom-stdio-server`
  - **Command:** `npx`
  - **Args:** `["@workshop/sre-mcp-server"]`
- **Expected state:** The stdio configuration form accepts the command without errors.
- **Troubleshooting:** If `npx` is not recognized, verify the agent runtime includes Node 20. stdio servers run inside the agent container — no Docker is available.

### 2.2 Verify Runtime Constraints

- **Action:** Review the runtime constraints panel that appears after saving:
  - Node 20, Python 3.12, .NET 9 — these are the only supported runtimes
  - No Docker, no custom containers
  - Server runs inside the agent container (same blast radius as the agent itself)
- **Expected state:** The connector card shows `Connected` after the npx process boots (may take 10–20 s on first run).
- **Troubleshooting:** If the process crashes on startup, check the server logs in the connector's detail pane. Common issue: missing `package.json` `bin` entry.

> **🔖 Checkpoint CP2** — Three connector cards total (two Streamable-HTTP + one stdio), all `Connected`.

---

## Step 3 — Capacity Bar Exercise (15 min)

### 3.1 Observe the Capacity Bar

- **Action:** Open any connector → **Select tools** step. Note the **capacity bar** at the top:
  - 🔵 Blue: ≤ 70% of the 80-tool budget consumed
  - 🟡 Yellow: 71–90%
  - 🔴 Red: > 90%
- **Expected state:** The bar is blue with only a few tools selected.
- **Troubleshooting:** If the capacity bar is not visible, ensure you are in the tool-selection pane (not the connector overview).

### 3.2 Force a Saturation Event

- **Action:** On the Datadog connector, click **Select all** to select every available tool.
- **Expected state:** The capacity bar jumps to 🟡 yellow or 🔴 red depending on total tools across all connectors.
- **Troubleshooting:** If the bar stays blue, the Datadog connector may have fewer tools than expected. Add tools from the second connector to push the total.

### 3.3 Practice "Remove Unused Tools First"

- **Action:** Deselect tools you will not use in this workshop. Keep only the 3–5 tools relevant to your incident-response chain. Watch the bar drop back to 🔵 blue.
- **Expected state:** Capacity bar is blue (≤ 70%). Tool count shown numerically (e.g., `12 / 80`).
- **Troubleshooting:** If you accidentally deselect a needed tool, use the search box in the tool-selection pane to find it again.

> **Governance note for SRE leads:** The 80-tool limit applies independently per agent *and* per custom agent. stdio servers run inside the agent container — same blast radius as the agent itself. Partner connectors lock the auth method; custom MCPs allow Bearer / custom headers / managed-identity.

> **🔖 Checkpoint CP3** — Capacity bar is blue. You can articulate the 80-tool budget rule.

---

## Step 4 — YAML Wildcards for Tool Assignment (15 min)

### 4.1 Assign Tools via Portal Picker

- **Action:** Open a custom agent (e.g., `db-expert` from Lab 6) → **Tools** tab → use the portal tool picker to add individual MCP tools.
- **Expected state:** Selected tools appear in the agent's tool list.
- **Troubleshooting:** If tools from a connector do not appear, ensure the connector is `Connected` and the tools are selected at the connector level.

### 4.2 Assign Tools via YAML Wildcards

- **Action:** Switch to the YAML view of the custom agent. Add:
  ```yaml
  mcp_tools:
    - datadog-mcp/*
    - github_search_code
  ```
  Note: the `/` separator between connector name and tool name is **required**.
- **Expected state:** The portal tool list updates to show all Datadog tools plus the single GitHub tool.
- **Troubleshooting:** If wildcard expansion fails, verify the connector name matches exactly (case-sensitive). Check for typos in the `/` separator.

> **🔖 Checkpoint CP4** — Custom agent shows MCP tools assigned via YAML wildcards.

---

## Step 5 — Plugin Marketplace Click-Through (10 min)

### 5.1 Browse the Plugin Marketplace

- **Action:** Navigate to **Builder → Plugin Marketplace**.
- **Expected state:** The marketplace page loads, showing community plugins. Each plugin can ship both an MCP server config and a skill bundle.
- **Troubleshooting:** If the Marketplace page shows "Coming soon," this is expected for some tenants at v1.

> ⚠️ **v1 limitation:** The Plugin Marketplace is **click-through only** — no install in this lab. This is a supply-chain awareness exercise. If a public install button becomes available before workshop go-live, file a doc-update issue.

### 5.2 Supply-Chain Discussion (5 min)

- Review: How does a community plugin differ from a partner connector?
- What vetting process exists before a plugin appears in the Marketplace?
- Reference: [Plugin Marketplace](https://sre.azure.com/docs/capabilities/plugin-marketplace)

---

## Step 6 — Health Monitoring Drill (5 min)

### 6.1 Kill the stdio Server Process

- **Action:** In the stdio connector detail pane, note the process state. Ask the trainer to kill the stdio server's process (or use the provided kill script).
- **Expected state:** Within 60 s, the heartbeat indicator changes from `Connected` (green) to `Disconnected` (red).
- **Troubleshooting:** If the status does not update, wait a full 60 s heartbeat cycle.

### 6.2 Observe Auto-Recovery

- **Action:** Wait for the agent to auto-restart the stdio server.
- **Expected state:** The connector returns to `Connected` (green) within 1–2 heartbeat cycles.
- **Troubleshooting:** If auto-recovery fails, manually restart by toggling the connector off and on.

> **🔖 Checkpoint CP5** — You have observed a disconnect → auto-recovery cycle on the stdio server.

---

## Governance Summary for SRE Leads

| Concern | Guidance |
|---------|----------|
| Tool budget | 80 tools per agent, 80 per custom agent — independent budgets |
| stdio blast radius | Runs inside the agent container — treat as same trust boundary |
| Auth methods | Partner connectors: locked auth method. Custom MCPs: Bearer / custom headers / managed-identity |
| Capacity management | Monitor capacity bar; remove unused tools before adding new connectors |
| Plugin Marketplace | Click-through only at v1; supply-chain review pending |

---

## Next Lab

Proceed to [Lab 8 — Python Tools](../lab-08-python-tools/README.md).
