# Lab C — First Investigation in Chat

> **Module 5 (L200) — 30 min hands-on lab**
> Maps to docs: [Diagnose with Azure Observability](https://sre.azure.com/docs/capabilities/diagnose-azure-observability), [Root Cause Analysis](https://sre.azure.com/docs/capabilities/root-cause-analysis)

---

## 1. Outcome

Each attendee runs at least 3 diagnostic chats and reads a tool-call card.

---

## 2. Prerequisites

| # | Requirement | Details |
|---|------------|---------|
| 1 | Lab A complete | Agent `contoso-sre-agent` in `Running` state. |
| 2 | Lab B complete | Agent has: 1 code repository connected, 1 resource group with Reader access, 2 knowledge documents uploaded. |
| 3 | Chat interface open | You should be in the agent chat from the end of Lab B. If not, navigate to your agent → **Chat**. |
| 4 | Sample workload running | At least one app (Container App, App Service, or Function) in the connected resource group should be running and generating telemetry. |

---

## 3. Time Budget

| Phase | Duration |
|-------|----------|
| Warm-up prompts (3 prompts) | 15 min |
| Mini exercise (Approve/Deny) | 10 min |
| Discussion & wrap-up | 5 min |
| **Total** | **30 min** |

---

## 4. Lab Steps

### Warm-Up Prompts — Run Sequentially (15 min)

> 📝 **Important:** Run these prompts one at a time. Wait for the agent to finish responding before entering the next prompt. Observe the **tool-call cards** that appear inline with each response.

---

#### Step 1 — Resource Discovery

Type the following prompt in the agent chat:

```
What Azure resources can you see?
```

**What to expect:**

The agent will execute a **Resource Graph query** to enumerate resources in your connected resource group. You will see:

- A **tool-call card** labeled "Resource Graph" or "Azure Resource Graph Query" — this shows the exact query the agent ran.
- A response listing the resources (Container Apps, App Services, storage accounts, etc.) in your connected RG.
- Resource names, types, locations, and status.

![Step 1 — Resource Graph tool-call card](screenshots/step-1-resource-graph-card.png)

> 💡 **Tool-call cards** are the agent's audit trail. They show exactly what the agent did — which API it called, what query it ran, and what data it got back. This is the explainability surface.

---

#### Step 2 — Health Summary

Type the following prompt:

```
Summarize the health of the resources in my managed resource group.
```

**What to expect:**

The agent will use multiple tools to assess health:

- **Tool-call cards** you may see:
  - **Resource Graph Query** — checking resource status and provisioning states
  - **Log Analytics KQL Query** — querying warning/error logs from the workspace
  - **App Insights Query** — checking application performance and exceptions
  - **Azure CLI** — running health-check commands

- The response will be a **correlated health summary** — not a raw log dump. The agent synthesizes information from multiple sources into a narrative like:
  - "All 3 Container Apps are in Running state."
  - "App Insights shows 12 exceptions in the last hour for `contoso-api`."
  - "CPU utilization is within normal range across all resources."

- If you uploaded knowledge documents, the agent may include **citations** referencing your architecture overview or runbook.

![Step 2 — Health summary with multiple tool-call cards](screenshots/step-2-health-summary.png)

> 💡 **Key observation:** The agent **correlates, not just dumps**. It pulls from Resource Graph, Log Analytics, and App Insights and presents a unified picture.

---

#### Step 3 — Error Investigation

Type the following prompt (replace `<sample-app-name>` with your actual app name):

```
Show me any errors in ca-contoso-payments-<your-alias> in the last hour.
```

> Replace `<your-alias>` with your workshop alias (e.g., `jdoe`). The app name `ca-contoso-payments-<your-alias>` was created by the sandbox deployment.

**What to expect:**

- A **Log Analytics KQL query card** showing the exact KQL the agent ran (e.g., querying `AppExceptions`, `AppTraces`, or `ContainerAppConsoleLogs`).
- An **App Insights query card** if the app has App Insights telemetry.
- A response listing errors with:
  - Timestamps
  - Error messages / exception types
  - Frequency (e.g., "occurred 7 times")
  - Possible correlations (e.g., "errors started after the 2:15 PM deployment")

![Step 3 — Error investigation with KQL query card](screenshots/step-3-error-investigation.png)

---

### Mini Exercise — Approve/Deny Flow (10 min)

#### Step 4 — Test the Agent's Boundaries

Ask the agent to do something that requires **write access** — which your Reader-mode agent should not be able to do autonomously:

```
Restart the container app ca-contoso-payments-<your-alias>.
```

> Replace `<your-alias>` with your workshop alias. This is a **deliberate test** of the agent's boundaries — the agent should block or prompt for approval, not execute the restart.

**What to expect in Review mode with Reader permission:**

The agent recognizes this is a **write operation** that exceeds its Reader-level permissions. You will see one of two flows:

**Flow A — Approve/Deny Buttons (Review Mode):**
- The agent proposes the action and displays **Approve** and **Deny** buttons.
- The tool-call card shows the exact command it wants to run (e.g., `az containerapp revision restart ...`).
- The agent will not execute until you click **Approve**.

**Flow B — OBO Authorization Request:**
- If the agent's UAMI lacks write permission entirely, it will request **On-Behalf-Of (OBO) authorization**.
- You'll see an authorization card asking you to consent to the agent using your identity for this specific action.
- Only **SRE Agent Administrators** with **work/school** Entra accounts can authorize.

![Step 4 — Approve/Deny buttons in Review mode](screenshots/step-4-approve-deny.png)

#### Step 5 — Demo Approve on a Safe Operation

1. Instead of restarting, try a **safe read-like operation** to demo the Approve flow:

```
List the revisions for container app ca-contoso-payments-<your-alias>.
```

2. If an Approve/Deny card appears, click **Approve** — this is a low-risk, read-only operation.
3. Observe the agent execute the command and return results.

> ⚠️ **Workshop safety:** In Reader/Review mode, always deny actual write operations (restarts, scaling, deletes) in a shared lab environment. Only approve operations you are confident are read-only or low-risk (e.g., listing revisions, updating a tag).

![Step 5 — Approving a safe operation](screenshots/step-5-approve-safe-op.png)

---

## 5. Checkpoint

> **✅ Checkpoint:** You have:
> 1. Run at least 3 diagnostic prompts
> 2. Observed tool-call cards (Resource Graph, KQL, App Insights)
> 3. Seen the Approve/Deny flow for a write-level request
>
> If all three are done, Lab C is complete.

---

## 6. Expected Output

### Tool-Call Card Reference

| Card Type | When It Appears | What It Shows |
|-----------|----------------|---------------|
| **Resource Graph Query** | Agent queries Azure resources (discovery, status) | The ARG query text, results count, and resource details |
| **Log Analytics KQL Query** | Agent queries logs from Log Analytics workspace | The KQL query, workspace name, time range, and result rows |
| **App Insights Query** | Agent queries application telemetry | The query, App Insights resource, and telemetry results |
| **Azure CLI** | Agent runs an Azure CLI command | The exact `az` command, parameters, and output |

### Typical Health Summary Response Shape

```
## Resource Health Summary — rg-<workload>

**Overall Status:** ✅ Healthy (with warnings)

### Container Apps
- `contoso-api` — Running, 2 active revisions
- `contoso-web` — Running, 1 active revision

### Recent Errors (last hour)
- 7 exceptions in `contoso-api` (NullReferenceException in /api/orders)
- 0 exceptions in `contoso-web`

### Metrics
- Average CPU: 23% (normal)
- Average Memory: 45% (normal)
- P95 Latency: 210ms (within SLO)

### Knowledge Context
- Per your architecture doc, `contoso-api` is the payment processing service.
- Per your runbook, the restart procedure for Container Apps is [documented here].
```

### Approve/Deny UI Shape

When the agent proposes a write operation in Review mode:

```
┌──────────────────────────────────────────────┐
│  🔧 Proposed Action                          │
│                                              │
│  Command: az containerapp revision restart   │
│  Target:  contoso-api                        │
│  Scope:   rg-<workload>                      │
│                                              │
│  [✅ Approve]    [❌ Deny]                   │
└──────────────────────────────────────────────┘
```

If OBO authorization is needed instead:

```
┌──────────────────────────────────────────────┐
│  🔐 Authorization Required                   │
│                                              │
│  The agent needs your identity to perform    │
│  this action (UAMI lacks write access).      │
│                                              │
│  [Authorize]    [Cancel]                     │
└──────────────────────────────────────────────┘
```

---

## 7. Troubleshooting Table

| Symptom | Cause | Fix |
|---------|-------|-----|
| Agent says "I don't have access to any Azure resources" | Resource group not connected in Lab B, or role assignment still propagating. | Go to Builder → Connectors → Azure Resources and verify the RG is connected. Wait 2–5 min for RBAC propagation. |
| No tool-call cards appear | The agent answered from general knowledge without querying Azure. | Rephrase your prompt to be more specific, e.g., include the resource group or app name explicitly. |
| KQL query card shows "No results" | The sample workload hasn't generated any logs/errors in the queried time range. | Generate some traffic to the sample app first, or widen the time range: "Show me errors in the last 24 hours." |
| "I cannot perform write operations" without Approve/Deny buttons | Agent is in **Autonomous** mode with Reader permissions — it simply can't write. | Verify agent is in **Review** mode (Builder → Settings → Run Mode). Review mode shows the Approve/Deny UI. |
| Approve/Deny buttons don't appear | Run mode is set to Autonomous, or the operation is already within the agent's permissions. | Check [Run Modes](https://sre.azure.com/docs/concepts/run-modes). For the exercise, use an explicit write command to trigger the flow. |
| OBO authorization fails | Your Entra account is a guest/personal MSA, or you don't have the SRE Agent Administrator role. | Use a **work or school** account. Verify your [User Role](https://sre.azure.com/docs/concepts/user-roles) is Administrator. |
| Agent response is very slow (> 2 min) | Complex query across many resources, or throttling. | Wait for the response to complete. For future prompts, narrow the scope (specific app, shorter time range). |
| Agent cites knowledge docs you don't recognize | Knowledge base contains docs from another attendee (shared agent scenario). | This shouldn't happen with per-attendee agents. Verify you're in your own agent's chat. |

---

## 8. Cleanup Steps

**No cleanup is needed after Lab C.** The chat history is retained for reference. Your agent and all connections persist for subsequent labs (Lab D: Deep Investigation, Lab E: Automate).

> 💡 **Tip:** You can revisit any of the prompts from Lab C at any time. The agent retains context from your conversation within the same chat session.

---

## References

- [Diagnose with Azure Observability](https://sre.azure.com/docs/capabilities/diagnose-azure-observability)
- [Root Cause Analysis](https://sre.azure.com/docs/capabilities/root-cause-analysis)
- [Run Modes](https://sre.azure.com/docs/concepts/run-modes)
- [Permissions](https://sre.azure.com/docs/concepts/permissions)
- [User Roles](https://sre.azure.com/docs/concepts/user-roles)
- [Memory & Knowledge](https://sre.azure.com/docs/concepts/memory)
