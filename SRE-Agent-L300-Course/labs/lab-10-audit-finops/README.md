---
lab: 10
level: 400
duration_minutes: 75
track: all
dependencies: [Lab 1, Lab 2, Lab 3, Lab 4, Lab 5, Lab 6, Lab 7, Lab 8, Lab 9]
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# Lab 10 — Audit, FinOps & Observability: KQL on customEvents, Token-Cost Analytics, Model-Tier Strategy

## Learning Outcome

A KQL workbook saved in the agent's App Insights with 5 queries the team will live in. Plus a FinOps overlay mapping model tier choices to spend, and trace correlation mastery.

> **Pre-read:** [Audit Agent Actions](https://sre.azure.com/docs/capabilities/audit-agent-actions) · [Monitor Agent Usage](https://sre.azure.com/docs/capabilities/monitor-agent-usage) · [Track Incident Value](https://sre.azure.com/docs/capabilities/track-incident-value)

---

## Checkpoint Schedule

| Time | Checkpoint |
|------|-----------|
| 0:00 | Lab start — verify Lab 9 hooks active |
| 0:15 | ✅ CP1 — Event types recognized, App Insights open |
| 0:30 | ✅ CP2 — Queries 1–3 authored and saved |
| 0:45 | ✅ CP3 — Queries 4–5 authored and saved |
| 0:60 | ✅ CP4 — FinOps overlay discussion complete |
| 0:75 | ✅ CP5 — Trace correlation + Activity Log walkthrough done |

---

## Navigating to App Insights (5 min)

### 0.1 Open the Logs Pane

- **Action:** Agent portal → **Monitor** → **Logs** → this opens the agent's App Insights in Azure Portal → query `customEvents`.
- **Expected state:** The KQL query editor opens targeting the `customEvents` table.
- **Troubleshooting:** If Monitor → Logs is grayed out, the agent may not have App Insights configured. Verify in the agent's resource settings.

---

## Event Types to Recognize (10 min)

Review the nine event types that appear in `customEvents.name`:

| Event Type | Description |
|-----------|-------------|
| `AgentResponse` | Final response delivered to user or incident thread |
| `ModelGeneration` | LLM call (start/end with token counts) |
| `AgentToolExecution` | Tool call (start/end with tool name and duration) |
| `AgentExecution` | Top-level agent execution lifecycle |
| `MetaAgent` | Meta-agent orchestration events |
| `AgentHandoff` | Custom agent handoff events |
| `IncidentActivitySnapshot` | Incident processing summary with outcomes |
| `AgentAzCliExecution` | Azure CLI command execution details |
| `ApprovalDecision` | Human approval/rejection events |

- **Action:** Run `customEvents | distinct name | sort by name asc` to verify these event types are present.
- **Expected state:** At least 5–7 of the nine types appear (depends on lab activity so far).
- **Troubleshooting:** If few events appear, re-fire a test incident from Lab 3 and wait 2–3 minutes for telemetry to flush.

> **🔖 Checkpoint CP1** — Event types recognized. App Insights KQL editor is open.

---

## Query 1 — Per-Thread Replay (10 min)

### 1.1 Author the Query

- **Action:** In the KQL editor, author:

  ```kql
  customEvents
  | where customDimensions.ThreadId == "<paste-a-thread-id-from-Lab 3>"
  | project timestamp, name, customDimensions.AgentName, customDimensions.ToolName,
            customDimensions.ModelId, tolong(customDimensions.InputTokens),
            tolong(customDimensions.OutputTokens)
  | order by timestamp asc
  ```

- **Expected state:** Full event stream for a single thread — shows the progression from `MetaAgent` → `AgentHandoff` → `AgentToolExecution` → `ModelGeneration` → `AgentResponse`.
- **Troubleshooting:** If no results, verify the `ThreadId` value. Copy it from a conversation URL or the Lab 3 incident thread.

### 1.2 Save the Query

- **Action:** Click **Save** → name it `per-thread-replay` → save to the workbook.
- **Expected state:** Query saved and accessible from the Saved queries pane.
- **Troubleshooting:** If the Save button is disabled, ensure you have Contributor access to the App Insights resource.

---

## Query 2 — Top Tools Last 30 Days (5 min)

### 2.1 Author and Save

- **Action:**

  ```kql
  customEvents
  | where name == "AgentToolExecution"
  | where customDimensions.EventType == "ToolStart"
  | where timestamp > ago(30d)
  | summarize call_count = count() by tostring(customDimensions.ToolName)
  | order by call_count desc
  | take 20
  ```

- **Expected state:** Table showing tool names ranked by call frequency.
- **Troubleshooting:** If `EventType` field is missing, try filtering on `customDimensions` keys using `| getschema`.

> **Save as:** `top-tools-30d`

---

## Query 3 — Token Cost by Custom Agent (10 min)

### 3.1 Author and Save

- **Action:**

  ```kql
  customEvents
  | where name == "ModelGeneration"
  | where customDimensions.EventType == "ModelGenerationEnd"
  | where timestamp > ago(30d)
  | extend InputTokens = tolong(customDimensions.InputTokens),
           OutputTokens = tolong(customDimensions.OutputTokens),
           AgentName = tostring(customDimensions.AgentName),
           ModelId = tostring(customDimensions.ModelId)
  | summarize TotalInput = sum(InputTokens), TotalOutput = sum(OutputTokens),
              Calls = count() by AgentName, ModelId
  | extend TotalTokens = TotalInput + TotalOutput
  | order by TotalTokens desc
  ```

- **Expected state:** Breakdown of token consumption by custom agent and model.
- **Troubleshooting:** If token counts are null, the agent may not be emitting token telemetry for all calls. Focus on calls where `ModelGenerationEnd` events are present.

> **Save as:** `token-cost-by-agent`

> **🔖 Checkpoint CP2** — Queries 1–3 saved in the workbook.

---

## Query 4 — Incident Outcomes 30 Days (10 min)

### 4.1 Author and Save

- **Action:**

  ```kql
  customEvents
  | where name == "IncidentActivitySnapshot"
  | where timestamp > ago(30d)
  | project timestamp,
            MitigatedByAgent = tostring(customDimensions.MitigatedByAgent),
            AssistedByAgent = tostring(customDimensions.AssistedByAgent),
            Autonomy = tostring(customDimensions.Autonomy),
            ResponsePlanId = tostring(customDimensions.ResponsePlanId)
  | summarize
      Mitigated = countif(MitigatedByAgent == "true"),
      Assisted = countif(AssistedByAgent == "true"),
      Total = count()
      by ResponsePlanId, Autonomy
  | order by Total desc
  ```

- **Expected state:** Summary of incident outcomes grouped by response plan and autonomy level.
- **Troubleshooting:** If `IncidentActivitySnapshot` events are missing, ensure the Lab 3 response plans have processed at least one incident.

> **Save as:** `incident-outcomes-30d`

---

## Query 5 — Approval Rate (5 min)

### 5.1 Author and Save

- **Action:**

  ```kql
  customEvents
  | where name == "ApprovalDecision"
  | where timestamp > ago(30d)
  | extend Decision = tostring(customDimensions.Decision),
           Approver = tostring(customDimensions.Approver)
  | summarize
      Approved = countif(Decision == "Approve"),
      Rejected = countif(Decision == "Reject"),
      Total = count()
      by Approver
  | extend ApprovalRate = round(100.0 * Approved / Total, 1)
  | order by Total desc
  ```

- **Expected state:** Per-approver approval rate percentage.
- **Troubleshooting:** If no `ApprovalDecision` events exist, this is expected if all plans are in Autonomous mode. Note this in the workbook as "N/A — no Review-mode plans active."

> **Save as:** `approval-rate`

> **🔖 Checkpoint CP3** — All 5 queries saved in the workbook.

---

## FinOps Overlay (15 min)

### 6.1 Model Tier → Spend Mapping

Discuss with the group:

| Context | Recommended Tier | Cost Impact |
|---------|-----------------|-------------|
| Hooks (default) | Fast Reasoning | Low — runs on every tool call |
| Hooks (high-stakes policy) | Reasoning | Higher — use only for critical safety checks |
| Scheduled tasks (polling) | Fast | Minimal |
| Scheduled tasks (deep RCA) | Reasoning | Higher — justified by outcome |
| Custom agents | Per response-plan severity | Match cost to business criticality |

### 6.2 Actionable Review Cadence

- Weekly: review `IncidentActivitySnapshot` for mitigation trends.
- Monthly: review `token-cost-by-agent` for spend outliers.
- Reference: [Monitor Agent Usage](https://sre.azure.com/docs/capabilities/monitor-agent-usage)

> **🔖 Checkpoint CP4** — FinOps overlay discussion complete.

---

## Trace Correlation (10 min)

### 7.1 TraceId Walkthrough

- **Action:** Pick a `TraceId` from a Lab 3 incident thread. Run:

  ```kql
  customEvents
  | where customDimensions.TraceId == "<trace-id>"
  | project timestamp, name, customDimensions.AgentName, customDimensions.ToolName
  | order by timestamp asc
  ```

- **Expected state:** The full request lifecycle: `MetaAgent` → `AgentHandoff` → `AgentToolExecution` → `ModelGeneration` → `AgentResponse`.
- **Troubleshooting:** If TraceId is not populated, it may not be available for all event types. Focus on `AgentToolExecution` and `ModelGeneration` events.

### 7.2 Azure Activity Log for Drift Detection

- **Action:** Open the Azure Activity Log for the agent resource. Filter to `Write` operations in the last 7 days.
- **Expected state:** Shows any out-of-band changes made to the agent via the portal (config drift detection — pairs with Lab 12).
- **Troubleshooting:** If no entries appear, no manual changes have been made. This is the desired state for IaC-managed agents.

> **🔖 Checkpoint CP5** — Trace correlation demonstrated. Activity Log reviewed.

---

## Next Lab

Proceed to [Lab 11 — Enterprise Topology](../lab-11-enterprise-topology/README.md).
