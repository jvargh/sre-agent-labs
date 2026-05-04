---
module: M8
level: 400
duration_minutes: 90
track: all
dependencies: [M1, M2, M3, M4, M5, M6, M7]
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# M8 — Custom Tools II: Python Tools (AI-Generated, BYO, HTTP-Wrap) + Managed-Identity Scopes

## Learning Outcome

Three Python tools created via the three supported authoring paths: AI-generated, BYO existing function, and HTTP wrapper. Attendees master managed-identity scoping and execution-environment constraints.

> **Pre-read:** [Python Code Execution](https://sre.azure.com/docs/capabilities/python-code-execution) · [Create Python Tool](https://sre.azure.com/docs/tutorials/tools/create-python-tool)

---

## Checkpoint Schedule

| Time | Checkpoint |
|------|-----------|
| 0:00 | Lab start — verify M7 connectors functional |
| 0:15 | ✅ CP1 — Tool 1 (AI-generated) created and tested |
| 0:30 | ✅ CP2 — Tool 2 (BYO) created and tested |
| 0:50 | ✅ CP3 — Tool 3 (HTTP wrapper) created and tested |
| 0:65 | ✅ CP4 — Managed-identity scope configured on Tool 3 |
| 0:75 | ✅ CP5 — Tool 3 wired to db-expert from M6 |
| 0:90 | ✅ CP6 — Compare/contrast wrap-up complete |

---

## Tool 1 — AI-Generated: SLA Compliance Calculator (15 min)

### 1.1 Open the Python Tool Creator

- **Action:** Navigate to **Builder → Agent Canvas → Create → Tool → Python tool → AI-generated**.
- **Expected state:** The AI generation dialog opens with a description field.
- **Troubleshooting:** If the Python tool option is grayed out, check that the agent's runtime supports Python 3.12.

### 1.2 Describe the Tool

- **Action:** Enter the description:
  > "Calculate SLA compliance from uptime and downtime minutes; return whether it meets 99.9%."
- **Expected state:** The AI generates a Python function with `main(uptime_minutes: float, downtime_minutes: float) -> dict` signature.
- **Troubleshooting:** If the generated code is incorrect, edit it manually. The function must return a JSON-serializable `dict`.

### 1.3 Test in Playground

- **Action:** Click **Test** and provide sample inputs: `uptime_minutes=43190, downtime_minutes=10`.
- **Expected state:** Output shows `{"sla_percentage": 99.977, "meets_target": true, "target": 99.9}` (or similar).
- **Troubleshooting:** If the test fails with a timeout, the default is 120 s. Increase if needed (max 900 s).

### 1.4 Create the Tool

- **Action:** Click **Create**. Name it `sla-compliance-calculator`.
- **Expected state:** Tool appears in the Tools list with status `Active`.
- **Troubleshooting:** If creation fails, check that the tool name is unique and uses only lowercase alphanumeric + hyphens.

> **🔖 Checkpoint CP1** — `sla-compliance-calculator` tool created and tested in playground.

---

## Tool 2 — BYO Existing Function (15 min)

### 2.1 Paste Your Function

- **Action:** Navigate to **Builder → Agent Canvas → Create → Tool → Python tool → Paste code**. Paste an existing internal function that returns `dict` from `main(...)`. Example:

  ```python
  def main(service_name: str, lookback_hours: int = 24) -> dict:
      """Check recent deployment status for a service."""
      # Your real internal logic here
      return {
          "service": service_name,
          "last_deploy": "2026-05-02T14:30:00Z",
          "status": "healthy",
          "lookback_hours": lookback_hours
      }
  ```
- **Expected state:** The editor accepts the code with syntax highlighting.
- **Troubleshooting:** The function **must** be named `main` and return a JSON-serializable `dict`. No class-based entry points.

### 2.2 Test and Create

- **Action:** Test with sample inputs, then create as `deployment-status-checker`.
- **Expected state:** Tool is active in the Tools list.
- **Troubleshooting:** If the function imports unavailable packages, check the 700+ preinstalled list. Common packages available: `pandas`, `requests`, `azure-identity`, `reportlab`.

> **🔖 Checkpoint CP2** — `deployment-status-checker` tool created via BYO path.

---

## Tool 3 — HTTP Wrapper Around Internal API / Azure Function (20 min)

### 3.1 Create the HTTP Wrapper Tool

- **Action:** Navigate to **Builder → Agent Canvas → Create → Tool → Python tool → Paste code**. Author a wrapper:

  ```python
  import requests
  import os

  def main(query: str, resource_group: str) -> dict:
      """Query internal CMDB API for resource metadata."""
      endpoint = os.environ.get("CMDB_ENDPOINT", "https://<your-function>.azurewebsites.net/api/cmdb")
      resp = requests.get(
          endpoint,
          params={"q": query, "rg": resource_group},
          headers={"x-functions-key": os.environ.get("CMDB_KEY", "")},
          timeout=30
      )
      resp.raise_for_status()
      return resp.json()
  ```
- **Expected state:** Code accepted. The tool will call the external API at runtime.
- **Troubleshooting:** Outbound network is enabled in the execution environment. If the API is behind a VNET, ensure the agent's egress rules allow it.

### 3.2 Test with a Live Endpoint

- **Action:** Test with the trainer's provided Azure Function URL and key.
- **Expected state:** Returns JSON data from the CMDB endpoint.
- **Troubleshooting:** If `ConnectionError`, verify the endpoint URL. If `401`, check the function key.

> **🔖 Checkpoint CP3** — `cmdb-lookup` tool created as HTTP wrapper.

---

## Managed-Identity Scope (15 min)

### 4.1 Configure the Identity Tab

- **Action:** On Tool 3 (`cmdb-lookup`), open the **Identity** tab. Enable **managed-identity scope** = ARM (or Key Vault, or Storage as appropriate).
- **Expected state:** The identity toggle shows `Enabled` with scope = `ARM`.
- **Troubleshooting:** If the Identity tab is not available, verify the agent has a UAMI assigned.

### 4.2 Demonstrate Secretless Access

- **Action:** Modify Tool 3 to call an ARM endpoint using `azure.identity.ManagedIdentityCredential` instead of a function key:

  ```python
  from azure.identity import ManagedIdentityCredential
  import requests

  def main(resource_group: str) -> dict:
      """List resources in a resource group using managed identity."""
      credential = ManagedIdentityCredential()
      token = credential.get_token("https://management.azure.com/.default")
      resp = requests.get(
          f"https://management.azure.com/subscriptions/<sub-id>/resourceGroups/{resource_group}/resources?api-version=2021-04-01",
          headers={"Authorization": f"Bearer {token.token}"},
          timeout=30
      )
      resp.raise_for_status()
      return resp.json()
  ```
- **Expected state:** The tool returns resources without any hardcoded secrets.
- **Troubleshooting:** If `CredentialUnavailableError`, the managed-identity scope may not be enabled on the tool's Identity tab.

> **🔖 Checkpoint CP4** — Tool 3 uses managed identity. No secrets in code.

---

## Execution-Environment Facts

Attendees must memorize these constraints:

| Property | Value |
|----------|-------|
| Timeout | 5–900 s (default 120 s) |
| Container | Fresh container per call — no persistent state |
| Temp storage | `/mnt/data` for temporary files |
| Outbound network | Enabled |
| GPU | Not available |
| Preinstalled packages | 700+ including `pandas`, `requests`, `azure-identity`, `reportlab` |
| Return type | Must be JSON-serializable |

---

## Wire Tool 3 to db-expert (10 min)

### 5.1 Attach to Custom Agent

- **Action:** Open `db-expert` from M6 → **Tools** tab → add `cmdb-lookup`.
- **Expected state:** The tool appears in db-expert's tool list alongside the Kusto tool from M5.
- **Troubleshooting:** If the tool does not appear in the picker, verify it is in `Active` state.

### 5.2 Test the Integration

- **Action:** In a chat with `db-expert`, prompt: "Look up the CMDB entry for resource group `<workshop-rg>`."
- **Expected state:** The agent calls `cmdb-lookup` and returns metadata from the CMDB API.
- **Troubleshooting:** If the agent does not select the tool, check the tool's `description` field — this is the discovery surface.

> **🔖 Checkpoint CP5** — Tool 3 is wired to `db-expert` and callable from chat.

---

## Compare/Contrast Wrap-Up (5 min)

| Decision Factor | Python Tool | MCP Connector |
|----------------|-------------|---------------|
| Authoring | Portal-native, three paths | External server, protocol-based |
| Runtime | Agent container, fresh per call | Separate process or remote endpoint |
| Identity | Managed-identity scope toggle | Bearer / custom headers / MI |
| Use case | Custom logic, API wrapping | Partner integrations, existing MCP servers |

Reference: [Python Tools](https://sre.azure.com/docs/capabilities/python-code-execution) vs [MCP Connectors](https://sre.azure.com/docs/capabilities/mcp-connectors)

> **🔖 Checkpoint CP6** — Lab complete.

---

## Next Module

Proceed to [M9 — Agent Hooks](../module-M9-agent-hooks/README.md).
