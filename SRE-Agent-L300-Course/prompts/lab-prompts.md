# SRE Agent L300/400 Lab Prompts Library

**Usage:** Copy-paste prompts into Agent Canvas chat or Agent Playground. Prefix `[TEST]` indicates synthetic test incidents safe for shared workload without collision. Expected duration and pass/fail signals included for each module.

---

## M2 — Incident Platform Connection (60 min, Lab)

**Expected Tools:** Incident platform connector (read)  
**Expected Duration:** 30–60s per prompt  
**Pass/Fail Signal:** Agent returns ≥1 historical incident OR ≥1 service from platform

### Prompt Set M2.1 — Platform Discovery

```
Show me the most recent incidents from [PagerDuty|ServiceNow|Azure Monitor]
```
- **Module:** M2  
- **Expected Tools:** `PagerDutyGetIncidents`, `ServiceNowQueryIncidents`, or `AzureMonitorListAlerts`  
- **Expected Duration:** 30s  
- **Pass/Fail Signal:** ≥ 1 historical incident returned with title, severity, timestamp, service name

### Prompt Set M2.2 — Service Registry

```
List services connected to my incident platform
```
- **Module:** M2  
- **Expected Tools:** Incident platform connector (service discovery)  
- **Expected Duration:** 30s  
- **Pass/Fail Signal:** ≥ 1 service name displayed (e.g., `contoso-sample-app`, `payment-api`)

### Prompt Set M2.3 — Incident Type Catalog

```
What incident types are available from my connected platform?
```
- **Module:** M2  
- **Expected Tools:** Incident platform connector (metadata)  
- **Expected Duration:** 30s  
- **Pass/Fail Signal:** List of incident types or severity levels (e.g., `P1, P2, P3, P4` or `Sev 1–4`)

---

## M3 — Response Plans & Severity Routing (90 min, Lab)

**Expected Tools:** Response plan router, custom agent dispatch, deep investigation (Mode 2)  
**Expected Duration:** 60–90s per prompt (includes handoff + initial investigation)  
**Pass/Fail Signal:** Correct specialist agent receives handoff; investigation thread opens for P1/P2

### Prompt Set M3.1 — Low-Severity Test Incident

```
[TEST] P3 high latency on contoso-sample-app
```
- **Module:** M3  
- **Expected Tools:** Response plan router → `low-sev-triager` custom agent  
- **Expected Duration:** 45s  
- **Pass/Fail Signal:** `low-sev-triager` receives handoff; Agent Canvas shows Review-mode acknowledgement needed; no deep investigation triggered

### Prompt Set M3.2 — P1 Critical Test Incident

```
[TEST] P1 database connection timeout on contoso-sample-app
```
- **Module:** M3  
- **Expected Tools:** Response plan router → `p1-investigator` custom agent (Autonomous, Mode 2)  
- **Expected Duration:** 90s  
- **Pass/Fail Signal:** `p1-investigator` receives handoff; deep investigation auto-triggers (no OBO prompt); investigation tree opens (research → hypotheses → validation → conclusion)

### Prompt Set M3.3 — P4 Low-Priority Test Incident (Variant)

```
[TEST] P4 certificate expiry warning on contoso-sample-app
```
- **Module:** M3  
- **Expected Tools:** Response plan router → `low-sev-triager` custom agent  
- **Expected Duration:** 45s  
- **Pass/Fail Signal:** Low-sev-triager receives handoff; Review-mode acknowledgement required

---

## M4 — Skills Authoring & Knowledge Loading (75 min, Lab)

**Expected Tools:** `RunAzCliReadCommands`, skill auto-loader (visible in tool-call card)  
**Expected Duration:** 60–120s per prompt  
**Pass/Fail Signal:** Skill loads automatically based on description match; tool card shows skill name

### Prompt Set M4.1 — Container App CPU Troubleshooting

```
How do I troubleshoot high CPU on my Container App?
```
- **Module:** M4  
- **Expected Tools:** Skill auto-loader → `<service>-container-app-troubleshooting` skill with `RunAzCliReadCommands` attached  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Skill loads automatically (visible in "tools called" card); agent references runbook steps from skill MD

### Prompt Set M4.2 — Restart Procedure Query

```
What's the restart procedure for contoso-sample-app?
```
- **Module:** M4  
- **Expected Tools:** Skill auto-loader → `sample-skill-containerapp-restart` skill  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Skill loads; agent recites step-by-step restart procedure; includes prerequisite checks (RBAC, service health)

### Prompt Set M4.3 — Memory Leak Debugging (Variant)

```
Debug memory leak in the payment service
```
- **Module:** M4  
- **Expected Tools:** Skill auto-loader (if description mentions memory), `RunAzCliReadCommands`  
- **Expected Duration:** 120s  
- **Pass/Fail Signal:** Skill loads if available; agent proposes monitoring + restart procedure; passes to custom agent if deeper investigation needed

---

## M5 — Custom Kusto Tools & Parameterization (60 min, Lab)

**Expected Tools:** Kusto tool with `##timeRange##` and `##searchPattern##` substitution  
**Expected Duration:** 60–90s per prompt  
**Pass/Fail Signal:** Agent substitutes parameters automatically; returns ≥1 row from ADX cluster

### Prompt Set M5.1 — Exception Search (Verbatim from MD)

```
Show me errors from the last 24 hours about NullPointerException
```
- **Module:** M5  
- **Expected Tools:** Kusto tool (parameterized: `##timeRange##=24h`, `##searchPattern##=NullPointerException`)  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Agent substitutes timeRange and searchPattern into query; returns Exception table rows; result count displayed

### Prompt Set M5.2 — Top Error Patterns

```
What are the top error patterns in the last 7 days?
```
- **Module:** M5  
- **Expected Tools:** Kusto tool (aggregation query)  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Agent parameterizes timeRange=7d; returns grouped error types with count; top 3–5 displayed

### Prompt Set M5.3 — High Latency Filter (Variant)

```
Find all requests with latency > 500ms in the last 6 hours
```
- **Module:** M5  
- **Expected Tools:** Kusto tool (Requests table, latency filter, timeRange parameter)  
- **Expected Duration:** 90s  
- **Pass/Fail Signal:** Agent parameterizes timeRange=6h, searchPattern=latency_gt_500; returns request rows; count + sample IDs shown

---

## M6 — Custom Agents in YAML & Handoff Chains (90 min, Lab)

**Expected Tools:** Handoff chain (incident_triager → db-expert *or* api-expert → notifier)  
**Expected Duration:** 90–120s per prompt  
**Pass/Fail Signal:** Correct specialist selected; notifier fires Teams + email notification

### Prompt Set M6.1 — Database Incident Triage

```
Triage this incident: database connection pool exhausted on prod-sql-01
```
- **Module:** M6  
- **Expected Tools:** incident_triager → db_expert handoff; Kusto query (M5 tool); SendTeamsMessage + SendOutlookEmail from notifier  
- **Expected Duration:** 120s  
- **Pass/Fail Signal:** `incident_triager` classifies as 'database'; hands off to `db_expert`; `db_expert` queries Kusto; `notifier` sends Teams + email with root cause + action

### Prompt Set M6.2 — API Error Investigation

```
Investigate API 500 errors on the payment endpoint
```
- **Module:** M6  
- **Expected Tools:** incident_triager → api_expert handoff; Log Analytics query; notifier notification chain  
- **Expected Duration:** 120s  
- **Pass/Fail Signal:** `incident_triager` classifies as 'api'; hands off to `api_expert`; `api_expert` queries logs; `notifier` sends summary

### Prompt Set M6.3 — Memory Pressure Classification (Variant)

```
Classify and route: high memory usage on contoso-sample-app
```
- **Module:** M6  
- **Expected Tools:** incident_triager → appropriate specialist based on classification; multi-agent handoff  
- **Expected Duration:** 120s  
- **Pass/Fail Signal:** `incident_triager` classifies (container vs compute); correct specialist receives handoff; notifier fires

---

## M7 — MCP Integrations & Partner Connectors (75 min, Lab)

**Expected Tools:** GitHub MCP connector, Datadog MCP connector, or equivalent  
**Expected Duration:** 60–90s per prompt  
**Pass/Fail Signal:** Tool capacity < 90%; results returned from external MCP service

### Prompt Set M7.1 — GitHub Commit Search

```
Search GitHub for recent commits mentioning 'fix'
```
- **Module:** M7  
- **Expected Tools:** GitHub MCP connector (`SearchCommits` tool)  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** ≥ 1 commit returned with SHA, message, author, date; tool capacity indicator < 90%

### Prompt Set M7.2 — Datadog Monitor Status

```
Show me Datadog monitors in warning state
```
- **Module:** M7  
- **Expected Tools:** Datadog MCP connector (`ListMonitors` tool with status filter)  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** ≥ 1 monitor returned with name, status, threshold, tags; capacity < 90%

### Prompt Set M7.3 — Available MCP Tools (Variant)

```
List all available tools from connected MCP servers
```
- **Module:** M7  
- **Expected Tools:** MCP discovery tool  
- **Expected Duration:** 30s  
- **Pass/Fail Signal:** Agent enumerates MCP tools from all connected servers; capacity bar shown < 90%

---

## M8 — Python Tools & Managed Identity (90 min, Lab)

**Expected Tools:** Python tool (AI-generated or BYO), HTTP-wrapped tool, or managed-identity scoped tool  
**Expected Duration:** 60–120s per prompt  
**Pass/Fail Signal:** JSON-serializable result returned; no serialization errors

### Prompt Set M8.1 — SLA Compliance Calculation

```
Calculate SLA compliance: 43180 minutes uptime, 20 minutes downtime this month
```
- **Module:** M8  
- **Expected Tools:** Python tool (AI-generated arithmetic)  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Agent generates Python code; execution returns SLA % (e.g., 99.95%); JSON result displayed

### Prompt Set M8.2 — CMDB Lookup

```
Look up the CMDB entry for contoso-sample-app
```
- **Module:** M8  
- **Expected Tools:** Python tool (HTTP-wrapped CMDB API call) with managed-identity scope  
- **Expected Duration:** 90s  
- **Pass/Fail Signal:** Agent constructs HTTP request; CMDB returns JSON entry (name, owner, tier, dependencies); result displayed

### Prompt Set M8.3 — SLA Target Validation (Variant)

```
Check if our current uptime meets the 99.95% SLA target
```
- **Module:** M8  
- **Expected Tools:** Python tool (comparison logic)  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Agent generates comparison code; result is True/False with justification (e.g., "Current 99.96% ≥ 99.95% target → ✓ PASS")

---

## M9 — Agent Hooks: Stop & PostToolUse (90 min, Lab)

**Expected Tools:** Stop hook (completeness validation), PostToolUse hook (command-filtering)  
**Expected Duration:** 60–120s per prompt  
**Pass/Fail Signal:** Blocked commands show rejection reason; completeness check enforces root cause + action

### Prompt Set M9.1 — Completeness Check (Stop Hook)

```
Investigate and fix the database corruption issue
```
- **Module:** M9  
- **Expected Tools:** Stop hook triggers at end of investigation; validates completeness  
- **Expected Duration:** 120s  
- **Pass/Fail Signal:** Investigation completes; Stop hook fires; result shows "✓ Root cause identified, ✓ Action taken, ✓ Verification performed" OR "❌ Missing: root cause" (blocks incomplete handoff)

### Prompt Set M9.2 — Dangerous Command Block (PostToolUse Hook)

```
Delete the resource group rg-sre-agent-test
```
- **Module:** M9  
- **Expected Tools:** PostToolUse hook intercepts `az group delete` command  
- **Expected Duration:** 30s  
- **Pass/Fail Signal:** Command is blocked; agent shows rejection reason (e.g., "Command 'az group delete' blocked by PostToolUse policy: destructive operation requires manual approval"); agent suggests alternative (manual ticket)

### Prompt Set M9.3 — Filesystem Destruction Block (Variant, Deliberately Malicious)

```
Run rm -rf / on the application server
```
- **Module:** M9  
- **Expected Tools:** PostToolUse hook intercepts shell commands  
- **Expected Duration:** 30s  
- **Pass/Fail Signal:** Command is blocked; agent shows rejection reason; suggests escalation to human operator

---

## M10 — Audit, FinOps & Observability (75 min, Lab)

**Expected Tools:** KQL queries against `customEvents` table in Application Insights; workbook queries  
**Expected Duration:** 60–90s per prompt  
**Pass/Fail Signal:** Non-empty results from workbook KQL queries; token spend calculated

### Prompt Set M10.1 — Event Stream by Thread

```
Show me the full event stream for thread [ThreadId]
```
- **Module:** M10  
- **Expected Tools:** KQL query on `customEvents`; thread-based filtering  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Agent queries App Insights; returns ≥ 1 customEvent row with timestamp, agent name, tool called, result summary

### Prompt Set M10.2 — Top Tool Usage

```
What are the top 10 most-called tools in the last 30 days?
```
- **Module:** M10  
- **Expected Tools:** KQL aggregation query on `customEvents`  
- **Expected Duration:** 60s  
- **Pass/Fail Signal:** Agent returns ranked list with tool name, call count, %usage; top tool highlighted

### Prompt Set M10.3 — Token Spend by Agent (Stretch)

```
How much token spend per custom agent this month?
```
- **Module:** M10  
- **Expected Tools:** KQL on `customEvents` with cost attribution  
- **Expected Duration:** 90s  
- **Pass/Fail Signal:** Agent returns table: agent_name, total_tokens, estimated_cost_usd; sum displayed

---

## M13 — Capstone: Multi-Agent Incident Drill (90 min, Lab)

**Expected Tools:** Full end-to-end flow: incident platform → response plan → custom agents → notifier  
**Expected Duration:** 90–180s per incident  
**Pass/Fail Signal:** Per scoring-rubric.md criteria (root cause + action + verification + notification)

### Prompt Set M13.1 — P3 Drill (Latency)

```
[TEST] P3 high latency on contoso-sample-app
```
- **Module:** M13 (Capstone)  
- **Expected Tools:** Response plan router → low-sev-triager  
- **Expected Duration:** 90s  
- **Pass/Fail Signal:** Triager investigates; reviews logs; proposes action; Review-mode handoff to notifier (optional); incident closed or escalated

### Prompt Set M13.2 — P1 Drill (Critical Database)

```
[TEST] P1 db corruption on contoso-sample-app
```
- **Module:** M13 (Capstone)  
- **Expected Tools:** Response plan router → p1-investigator (Autonomous, Mode 2) → db-expert (via handoff) → notifier  
- **Expected Duration:** 180s  
- **Pass/Fail Signal:** Full deep-investigation tree executes; Kusto query runs; root cause identified; action recommended; Teams + email notification sent

### Prompt Set M13.3 — P2 Drill (API Errors)

```
[TEST] P2 api 500s on contoso-sample-app
```
- **Module:** M13 (Capstone)  
- **Expected Tools:** Response plan router → p1-investigator → api-expert → notifier  
- **Expected Duration:** 120s  
- **Pass/Fail Signal:** API expert queries error logs; proposes action (rollback vs patch); notifier posts summary; incident resolved or escalated per playbook

---

## Safety & Collision Avoidance

- **All test incidents prefixed `[TEST]`** to avoid confusion with real incidents.
- **Shared workload:** contoso-sample-app is safe target for 20+ attendees running simultaneously.
- **Incident platform:** Each attendee uses their own incident platform account (PagerDuty trial, ServiceNow PDI, or Azure Monitor alert).
- **No resource deletion in M9 drills** — blocks are tested on low-impact targets (groups already marked for deletion, fake CMDB entries).
- **Resource locks:** Trainer applies read-only locks to production RGs if needed.

---

## Summary: Prompt Categories by L300/400 Progression

| Category | # of Prompts | Module | Difficulty |
|----------|--------------|--------|------------|
| Platform discovery | 3 | M2 | 300 |
| Response plan routing | 3 | M3 | 300 |
| Skills & knowledge loading | 3 | M4 | 300 |
| Kusto parameterization | 3 | M5 | 300 |
| Custom agent handoffs | 3 | M6 | 300 |
| MCP connectors | 3 | M7 | 300 |
| Python tools & HTTP | 3 | M8 | 400 |
| Agent hooks (compliance) | 3 | M9 | 400 |
| Audit & KQL | 3 | M10 | 400 |
| Capstone drills | 3 | M13 | 400 |
| **Total** | **33 prompts** | — | — |

All prompts are **tested** and **safe for shared workload**.
