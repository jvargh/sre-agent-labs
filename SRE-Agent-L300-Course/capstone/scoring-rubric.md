# Capstone Scoring Rubric (D13)

> **Module:** M13 — Production Rollout Playbook + Multi-Agent Incident Drill
> **Duration:** 90 min capstone exercise
> **Pass threshold:** ≥ 80% of total points
> **Tied to:** [MD §6 Success Metrics](../SREA-Level300.md#6-success-metrics)

---

## Overview

The trainer fires **three synthetic incidents** back-to-back using the D11 incident generator with `[TEST]` prefix. Attendees demonstrate that their full M1–M12 stack handles each incident end-to-end with **no human input after the trigger**.

---

## Scoring Summary

| Category | Max Points | Type |
|----------|-----------|------|
| Drill 1 — `[TEST] P3 high latency` | 20 | Machine + Human |
| Drill 2 — `[TEST] P1 db corruption` | 45 | Machine + Human |
| Drill 3 — `[TEST] P2 api 500s` | 35 | Machine + Human |
| **Total** | **100** | |
| **Pass** | **≥ 80** | |

---

## Drill 1 — `[TEST] P3 high latency`

**Expected behavior:** Routed to `low-sev-triager` (M3) in **Review** mode, deep investigation off. Agent proposes one mitigation. Hooks audit the tool call.

### Machine-Checkable Items (14 pts)

| # | Criterion | Points | Check Method |
|---|-----------|--------|--------------|
| 1.1 | Response plan A fired (P3 filter matched) | 4 | Builder → Incident Response Plans → Activity log shows trigger |
| 1.2 | `low-sev-triager` custom agent dispatched | 4 | Agent Canvas → thread shows `low-sev-triager` active |
| 1.3 | Hook audited the tool call (PostToolUse audit event in App Insights) | 3 | KQL: `customEvents \| where Name == "AgentToolExecution" and customDimensions.AgentName == "low_sev_triager"` |
| 1.4 | Agent operated in Review mode (awaited approval) | 3 | Thread shows approval prompt before executing action |

### Human-Judged Items (6 pts)

| # | Criterion | Points | Rubric |
|---|-----------|--------|--------|
| 1.5 | Proposed mitigation is reasonable and actionable | 3 | 3 = specific + actionable; 2 = reasonable but vague; 1 = generic; 0 = wrong |
| 1.6 | Hypothesis quality (if agent states one) | 3 | 3 = correctly identifies latency source; 2 = plausible but incomplete; 1 = vague; 0 = absent |

---

## Drill 2 — `[TEST] P1 db corruption`

**Expected behavior:** Routed via `incident_triager` → `db_expert` → `notifier` (M6). Deep Investigation Mode 2 fires automatically. Stop hook (M9) ensures response includes root cause and recommended action. PostToolUse hook blocks `az group delete`. Notifier emits Teams + email.

### Machine-Checkable Items (31 pts)

| # | Criterion | Points | Check Method |
|---|-----------|--------|--------------|
| 2.1 | Response plan B fired (P1 filter matched) | 4 | Builder → Activity log |
| 2.2 | `incident_triager` dispatched as first agent | 3 | Agent Canvas → thread shows `incident_triager` as entry point |
| 2.3 | Handoff to `db_expert` occurred | 4 | Thread shows handoff event from `incident_triager` → `db_expert` |
| 2.4 | Deep Investigation Mode 2 executed (4-phase tree: research → hypotheses → validation → conclusion) | 5 | Investigation tree visible in thread with all 4 phases |
| 2.5 | Stop hook validated completeness (root cause + recommended action present) | 4 | App Insights: `customEvents \| where Name == "AgentHookExecution" and customDimensions.HookType == "Stop"` shows `ok: true` |
| 2.6 | PostToolUse hook blocked dangerous command (`az group delete` or similar) | 5 | App Insights: `customEvents \| where customDimensions.HookDecision == "block"` — or test by injecting a bad prompt |
| 2.7 | Handoff to `notifier` occurred | 3 | Thread shows handoff from `db_expert` → `notifier` |
| 2.8 | Audit event present in App Insights for the full chain | 3 | KQL: `customEvents \| where customDimensions.ThreadId == "<drill-thread>" \| summarize count() by Name` shows AgentHandoff, AgentToolExecution, ModelGeneration |

### Human-Judged Items (14 pts)

| # | Criterion | Points | Rubric |
|---|-----------|--------|--------|
| 2.9 | Notifier Teams message quality | 5 | 5 = clear summary with root cause + action + severity; 3 = adequate but missing one element; 1 = present but unhelpful; 0 = not sent |
| 2.10 | Notifier email quality | 4 | 4 = matches Teams message quality; 2 = sent but incomplete; 0 = not sent |
| 2.11 | Root cause hypothesis quality | 5 | 5 = correctly identifies db corruption scenario; 3 = plausible; 1 = vague; 0 = wrong |

---

## Drill 3 — `[TEST] P2 api 500s`

**Expected behavior:** Same chain as Drill 2, but branches to `api_expert` instead of `db_expert`. Audit query (M10) shows which custom agent was selected and total token cost.

### Machine-Checkable Items (23 pts)

| # | Criterion | Points | Check Method |
|---|-----------|--------|--------------|
| 3.1 | Response plan B fired (P2 filter matched) | 4 | Builder → Activity log |
| 3.2 | `incident_triager` dispatched | 3 | Thread shows `incident_triager` |
| 3.3 | Handoff to `api_expert` (not `db_expert`) | 5 | Thread shows correct branch: `incident_triager` → `api_expert` |
| 3.4 | Handoff to `notifier` occurred | 3 | Thread shows `api_expert` → `notifier` |
| 3.5 | Audit event present in App Insights | 3 | KQL query returns events for this thread |
| 3.6 | Token cost visible via M10 audit query | 5 | KQL: `customEvents \| where Name == "ModelGeneration" and customDimensions.ThreadId == "<drill-thread>" \| summarize sum(toint(customDimensions.InputTokens) + toint(customDimensions.OutputTokens)) by customDimensions.AgentName` |

### Human-Judged Items (12 pts)

| # | Criterion | Points | Rubric |
|---|-----------|--------|--------|
| 3.7 | Notifier message quality (Teams + email) | 5 | Same rubric as Drill 2 items 2.9/2.10 |
| 3.8 | API 500s hypothesis quality | 4 | 4 = correctly identifies API error pattern; 2 = plausible; 0 = wrong |
| 3.9 | Correct agent branch selected (api vs db justification) | 3 | 3 = triager reasoning clear; 1 = correct but no reasoning; 0 = wrong branch |

---

## Scoring Worksheet

| Drill | Machine Points Earned | Machine Max | Human Points Earned | Human Max | Subtotal |
|-------|----------------------|-------------|--------------------|-----------| ---------|
| Drill 1 — P3 high latency | ___ / 14 | 14 | ___ / 6 | 6 | ___ / 20 |
| Drill 2 — P1 db corruption | ___ / 31 | 31 | ___ / 14 | 14 | ___ / 45 |
| Drill 3 — P2 api 500s | ___ / 23 | 23 | ___ / 12 | 12 | ___ / 35 |
| **Total** | **___ / 68** | **68** | **___ / 32** | **32** | **___ / 100** |

**Pass: ≥ 80 / 100**

---

## Tie to Success Metrics (MD §6)

| MD §6 Metric | Capstone Validation |
|-------------|---------------------|
| Non-default response plan dispatching to YAML-defined custom agent (100%) | Drills 1–3 all verify response plan → custom agent dispatch |
| At least one Stop hook + one PostToolUse hook at agent level (100%) | Drill 2 items 2.5 + 2.6 |
| At least one Kusto tool + one Python tool in a custom agent (≥90%) | Drill 2/3 — `db_expert` and `api_expert` use Kusto tools from M5 |
| All three synthetic incidents handled end-to-end without manual intervention (≥80%) | This rubric's pass threshold: ≥ 80% |
| Audit workbook saved + shared (≥90%) | Drill 3 item 3.6 verifies M10 audit query |
| Cost per attendee per day ≤ USD 50 | Monitored separately by D12 cost-cap watcher |

---

## Notes for Trainers

- Use the D11 synthetic-incident generator to fire all three incidents with `--prefix [TEST]`.
- Machine-checkable items should be verified via App Insights KQL queries during the scoring window.
- Human-judged items are scored by the trainer in real-time as notifications arrive.
- If an attendee scores < 80%, review which module's output was missing and recommend targeted re-work.
