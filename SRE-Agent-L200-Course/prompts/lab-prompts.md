# Prompt Library — SRE Agent L200 Workshop

> All prompts in this library are safe for 20+ attendees running against the same shared sample workload without collisions. They are **read-only diagnostic queries** unless explicitly noted otherwise.

---

## Table of Contents

- [Lab B — Memory & Knowledge](#lab-b--memory--knowledge)
- [Lab C — First Investigation in Chat](#lab-c--first-investigation-in-chat)
- [Lab D — Deep Investigation](#lab-d--deep-investigation)
- [Lab E — Automate (Scheduled Task)](#lab-e--automate-scheduled-task)

---

## Lab B — Memory & Knowledge

### Primary Prompt

**`#remember` command:**

```
#remember our prod region is East US 2 and our paging channel is #oncall-payments
```

| Field | Value |
|-------|-------|
| **Expected tools** | Memory write (internal) |
| **Expected duration** | < 5 seconds |
| **Pass/fail signal** | ✅ Agent confirms the memory was stored. ❌ Error message or no acknowledgment. |

> Also mention `#retrieve` (read memories) and `#forget` (delete a memory) as companion commands.

---

## Lab C — First Investigation in Chat

### Primary Prompts

Run these **sequentially** — each builds on the context of the previous.

---

#### C-1: Resource Inventory

```
What Azure resources can you see?
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Resource Graph |
| **Expected duration** | 10–30 seconds |
| **Pass/fail signal** | ✅ Agent returns a list of resources in the connected resource group(s) with resource types and names. ❌ "I don't have access to any resources" or empty list. |

---

#### C-2: Health Summary

```
Summarize the health of the resources in my managed resource group.
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Resource Graph, Azure Monitor metrics, Resource Health |
| **Expected duration** | 15–45 seconds |
| **Pass/fail signal** | ✅ Agent returns a structured summary with resource status (healthy/degraded/unavailable). ❌ Generic response with no specific resource data. |

---

#### C-3: Error Investigation

```
Show me any errors in <sample-app-name> in the last hour.
```

> Replace `<sample-app-name>` with your actual sample app name (e.g., `contoso-api`).

| Field | Value |
|-------|-------|
| **Expected tools** | Application Insights (KQL), Log Analytics |
| **Expected duration** | 15–45 seconds |
| **Pass/fail signal** | ✅ Agent returns error logs with timestamps, error messages, and potentially stack traces — or confirms "no errors found." ❌ Agent cannot query App Insights or returns a permission error. |

---

### Variant Prompts (Trainer Fallbacks)

Use these if primary prompts produce thin results or if attendees finish early.

---

#### C-V1: Specific Metric Query

```
What is the average CPU utilization for <sample-app-name> over the last 2 hours?
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Monitor metrics |
| **Expected duration** | 10–30 seconds |
| **Pass/fail signal** | ✅ Agent returns a numeric CPU percentage or a time-series summary. ❌ "I can't access metrics" or no data returned. |

---

#### C-V2: Deployment History

```
What were the most recent deployments to <sample-app-name>?
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Resource Graph, Activity Log, or code repo connector |
| **Expected duration** | 10–30 seconds |
| **Pass/fail signal** | ✅ Agent returns deployment records with timestamps and deployer identity. ❌ No deployment data or permission error. |

---

#### C-V3: Resource Inventory (Detailed)

```
List all container apps in my resource group with their current revision status and replica count.
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Resource Graph, Azure CLI (`az containerapp revision list`) |
| **Expected duration** | 15–30 seconds |
| **Pass/fail signal** | ✅ Agent returns container apps with revision names, status (active/inactive), and replica counts. ❌ Empty results or access error. |

---

## Lab D — Deep Investigation

### Primary Prompt

```
Investigate why the <sample-app> has elevated latency. Check logs, metrics, and recent deployments to identify the root cause.
```

> Replace `<sample-app>` with your actual sample app name.

| Field | Value |
|-------|-------|
| **Expected tools** | Application Insights (KQL), Azure Monitor metrics, Log Analytics, Azure Resource Graph, Activity Log |
| **Expected duration** | 2–5 minutes (deep investigation runs through 4 phases) |
| **Pass/fail signal** | ✅ Investigation tree completes all 4 phases with a conclusion node containing a root cause and recommended actions. ❌ Investigation stalls in Phase 2, or conclusion says "insufficient data" with no hypotheses validated. |

---

### Variant Prompts (Trainer Fallbacks)

Use these if the primary prompt produces thin results or to give attendees different investigation angles.

---

#### D-V1: Error Rate Investigation

```
Investigate the recent increase in HTTP 500 errors for <sample-app>. Analyze application logs, exception telemetry, and dependency failures to find the root cause.
```

| Field | Value |
|-------|-------|
| **Expected tools** | Application Insights (exceptions, requests, dependencies KQL), Log Analytics |
| **Expected duration** | 2–5 minutes |
| **Pass/fail signal** | ✅ Investigation reaches Phase 4 with hypotheses about error sources (dependency failure, code exception, timeout). ❌ Stalls or returns "no errors found" (sample app may need traffic). |

---

#### D-V2: Memory / Resource Pressure

```
Investigate whether <sample-app> is experiencing memory pressure or resource exhaustion. Check container metrics, OOM events, and scaling behavior over the past 6 hours.
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Monitor metrics (memory, CPU), Container App logs, App Insights performance counters |
| **Expected duration** | 2–5 minutes |
| **Pass/fail signal** | ✅ Investigation identifies memory trends and scaling events, or confirms resources are healthy. ❌ "No metrics available" — ensure sample workload is generating telemetry. |

---

#### D-V3: Container Restart Investigation

```
Investigate why <sample-app> containers have been restarting. Check for crash loops, health probe failures, and resource limits.
```

| Field | Value |
|-------|-------|
| **Expected tools** | Container App system logs, Azure Monitor, health probe configuration, App Insights availability |
| **Expected duration** | 2–5 minutes |
| **Pass/fail signal** | ✅ Investigation identifies restart patterns and potential causes (OOM, probe failure, startup crash). ❌ "No restarts detected" — this is still a valid conclusion if the app is stable. |

---

## Lab E — Automate (Scheduled Task)

### Primary Prompt (Scheduled Task Template)

This is the prompt template configured in the scheduled task. Paste it **verbatim**:

```
Check the health of our Azure resources:
1. Verify all container apps are running
2. Check CPU and memory metrics over the last hour
3. Review any recent warning logs
4. Summarize findings and send a report via email using SendOutlookEmail
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Resource Graph, Azure Monitor metrics, Log Analytics (KQL), `SendOutlookEmail` |
| **Expected duration** | 1–3 minutes (automated execution) |
| **Pass/fail signal** | ✅ Chat thread shows tool invocations for Azure queries AND `SendOutlookEmail`; email arrives in Outlook inbox. ❌ Task fails to run, or email is not sent (check connector health). |

---

### Variant Prompts (Trainer Fallbacks)

Use these if the primary prompt doesn't work well with the attendee's sample workload, or for stretch activities.

---

#### E-V1: Condensed Report Format

```
Generate a brief one-paragraph health status of our Azure resources. Include only critical issues or confirm all-clear. Send the summary via email using SendOutlookEmail with subject "Azure Health: Quick Status".
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Resource Graph, Azure Monitor metrics, `SendOutlookEmail` |
| **Expected duration** | 1–2 minutes |
| **Pass/fail signal** | ✅ Short, focused email arrives with subject matching the request. ❌ Email not sent or excessively verbose. |

---

#### E-V2: Weekly Schedule

```
Check the health of our Azure resources and compare key metrics (CPU, memory, error rate) to the same time last week. Highlight any significant changes. Send the comparison report via email using SendOutlookEmail.
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Monitor metrics (with time range comparison), Log Analytics (KQL), `SendOutlookEmail` |
| **Expected duration** | 2–4 minutes |
| **Pass/fail signal** | ✅ Email includes a comparison with week-over-week delta. ❌ Agent only reports current metrics without comparison (partial success — may lack historical data in sandbox). |

---

#### E-V3: Focused Resource Check

```
Check the status of all container apps in my resource group. For any that are not in "Running" state, include the last 5 log entries. Send findings via email using SendOutlookEmail.
```

| Field | Value |
|-------|-------|
| **Expected tools** | Azure Resource Graph, Container App logs, `SendOutlookEmail` |
| **Expected duration** | 1–3 minutes |
| **Pass/fail signal** | ✅ Email lists container apps with status and includes logs for any non-running apps (or confirms all running). ❌ Agent cannot enumerate container apps. |

---

## General Notes for Trainers

1. **Replace `<sample-app>` and `<sample-app-name>`** with the actual name of the deployed sample workload before the workshop. Distribute the correct name to all attendees.

2. **All prompts are read-only safe.** None of these prompts instruct the agent to modify, restart, scale, or delete Azure resources. The only write action is `SendOutlookEmail` in Lab E.

3. **20+ attendee safety:** All prompts query shared resources without modifying state. No prompt creates, updates, or deletes resources. Attendees can run identical prompts simultaneously without interference.

4. **If results are thin:** Ensure the sample workload is generating traffic and telemetry. Consider running a simple load generator against the sample app before the lab.

5. **Prompt customization:** Trainers may adapt variant prompts to match the specific sample workload. Keep the structure (expected tools, duration, pass/fail) intact.
