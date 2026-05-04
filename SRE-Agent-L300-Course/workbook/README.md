# SRE Agent Audit Workbook — SRE Agent L300 Workshop (D10)

> **Reference:** Audit, FinOps, and Observability

## Overview

A JSON workbook importable into Application Insights with 5 KQL queries for auditing SRE Agent activity. All queries are pinned to `customEvents` and parameterized by `ThreadId`, `lookbackDays`, and `agentName`.

## Import Instructions

### Azure Portal

1. Open your Application Insights resource in the Azure Portal.
2. Navigate to **Workbooks** in the left menu.
3. Click **+ New**.
4. Click the **Advanced Editor** icon (`</>`) in the toolbar.
5. Replace the default JSON with the contents of `sre-agent-audit.workbook`.
6. Click **Apply** → **Done Editing** → **Save**.
7. Name: `SRE Agent Audit — L300 Workshop`.

### Azure CLI

```bash
# Import workbook via CLI
ATTENDEE="<attendee-handle>"
RG="rg-srea-l300-${ATTENDEE}"
AI_NAME="ai-srea-${ATTENDEE}"
AI_ID=$(az monitor app-insights component show -a "$AI_NAME" -g "$RG" --query id -o tsv)

az portal dashboard import \
  --resource-group "$RG" \
  --input-path ./sre-agent-audit.workbook
```

## Query-to-Outcome Mapping

Each query maps to a specific Lab 10 learning outcome:

| # | Query | Lab 10 Outcome | What It Shows |
|---|-------|-------------|---------------|
| 1 | **Per-thread replay** | Trace correlation | Full event stream for a ThreadId: `MetaAgent → AgentHandoff → AgentToolExecution → ModelGeneration → AgentResponse`. Shows the complete lifecycle of an agent investigation. |
| 2 | **Top tools last N days** | Tool usage analytics | `AgentToolExecution` ToolStart events summarized by ToolName. Identifies most-used tools for capacity planning against the 80-tool budget. |
| 3 | **Token cost by custom agent** | FinOps overlay | `ModelGeneration` ModelGenerationEnd tokens by AgentName and ModelId. Maps model tier choices to estimated cost. Supports the "Fast for polling, Reasoning for deep RCA" strategy. |
| 4 | **Incident outcomes N days** | Agent effectiveness | `IncidentActivitySnapshot` projected by mitigation status, autonomy level, and response plan. Measures the §6 success metric: "≥80% capstone incidents handled end-to-end." |
| 5 | **Approval rate per approver** | Approval bottlenecks | `ApprovalDecision` approve vs reject percentage per approver. Identifies approvers who are bottlenecks or rubber-stamping. Supports the Lab 1 recommendation of ≥2 approvers on rotation. |

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ThreadId` | string | (empty) | Filter to a specific conversation thread. Leave empty for all threads. |
| `lookbackDays` | int | 30 | Number of days to query. |
| `agentName` | string | (empty) | Filter to a specific custom agent. Leave empty for all agents. |

## Event Types Referenced

The workbook queries against these `customEvents` event types (per Lab 10):

- `AgentResponse` — Agent's final response to user
- `ModelGeneration` — LLM call (start/end with token counts)
- `AgentToolExecution` — Tool invocation (start/end with duration)
- `AgentExecution` — Agent execution lifecycle
- `MetaAgent` — Top-level orchestrator events
- `AgentHandoff` — Handoff between custom agents
- `IncidentActivitySnapshot` — Incident resolution outcome
- `AgentAzCliExecution` — Azure CLI commands run by agent
- `ApprovalDecision` — Human approval/rejection events

## Testing Against Seed Data

After running the D11 synthetic incident generator and the D9 ADX seed loader, the workbook queries should return non-empty results. Verify with:

1. Set `lookbackDays` = 1
2. Check Query 1 returns events for any recent thread
3. Check Query 2 shows tool usage
4. Check Query 4 shows incident snapshots
