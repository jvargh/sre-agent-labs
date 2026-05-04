# Lab D — Deep Investigation (Chat Mode Only)

> **Outcome:** Each attendee completes a deep investigation using chat-triggered mode (Mode 1 only).

| | |
|---|---|
| **Module** | Lab D |
| **Level** | 200 (Hands-on) |
| **Duration** | 30 minutes |
| **Docs reference** | [Run a Deep Investigation](https://sre.azure.com/docs/tutorials/advanced/deep-investigation) |

> ⚠️ **Scope guard:** This lab covers **Mode 1 (chat-triggered)** only. Mode 2 (response-plan triggered) requires a connected incident platform and tuned response plans — that is a **Level 300** topic.

---

## Prerequisites

Before starting this lab, confirm the following are complete:

- [x] Lab A — Agent is in `Running` state
- [x] Lab B — At least one resource group connected; code repo connected; knowledge docs uploaded
- [x] Lab C — You have successfully run diagnostic chat prompts and seen tool-call cards
- [x] You hold the **SRE Agent Administrator** role (required for OBO authorization)
- [x] You are signed in with a **work or school (Entra ID)** account — personal MSAs cannot authorize OBO

---

## Time Budget

| Activity | Minutes |
|----------|---------|
| Steps 1–4: Trigger deep investigation + authorize | 5 |
| Steps 5–6: Observe investigation tree phases | 15 |
| Step 7: Turn off deep investigation | 2 |
| Discussion | 5 |
| Buffer | 3 |
| **Total** | **30** |

---

## Lab Steps

### Step 1 — Trigger Deep Investigation

1. Open your agent's chat interface at [sre.azure.com](https://sre.azure.com).
2. In the chat input bar, click the **+** button.
3. From the menu, select **Deep investigation**.
4. A confirmation dialog appears — click **Confirm** to enable deep investigation mode.

![Step 1](screenshots/step-1-trigger-deep-investigation.png)

---

### Step 2 — Confirm Activation

Verify that deep investigation mode is active:

- A **sparkle badge** (✨) appears on the chat input area.
- A **status banner** is visible at the top of the chat pane indicating deep investigation is on.

![Step 2](screenshots/step-2-sparkle-badge-banner.png)

> **Checkpoint ✅:** Sparkle badge and status banner are both visible.

---

### Step 3 — Run the Investigation Prompt

Paste the following prompt into the chat input and send it:

```
Investigate why ca-contoso-payments-<your-alias> has elevated latency. Check logs, metrics, and recent deployments to identify the root cause.
```

> Replace `<your-alias>` with your workshop alias (e.g., `jdoe`). The app name `ca-contoso-payments-<your-alias>` was deployed by the sandbox automation.

![Step 3](screenshots/step-3-run-investigation-prompt.png)

---

### Step 4 — Approve OBO Authorization

An **OBO authorization card** appears in the chat. This requests permission to use your identity for resource access during the investigation.

1. Review the permissions listed on the card.
2. Click **Approve**.

The agent now operates on behalf of your Entra ID identity for this investigation.

![Step 4](screenshots/step-4-approve-obo-card.png)

> ⏱️ **Important:** The OBO authorization token is valid for **10 minutes**. If the investigation takes longer, you may need to re-authorize.

---

### Step 5 — Observe the Investigation Tree

A right-panel **investigation tree** appears. Watch it progress through four phases:

| Phase | Name | What you see |
|-------|------|-------------|
| **Phase 1** | Incident research | The agent gathers initial context — logs, metrics, recent deployments, and resource state. |
| **Phase 2** | Forming hypotheses | 2–4 hypothesis nodes appear. Each represents a potential root cause the agent identified. |
| **Phase 3** | Validating in parallel | Hypothesis nodes update with status labels: **Validating**, **Validated** ✅, **Invalidated** ❌, or **Inconclusive** ⚪. Multiple hypotheses are validated concurrently. |
| **Phase 4** | Conclusion | A final node appears with the **root cause** determination and **recommended actions**. |

![Step 5](screenshots/step-5-investigation-tree-phases.png)

> **Checkpoint ✅:** The investigation tree reaches Phase 4 with a conclusion node visible.

---

### Step 6 — Inspect Evidence Nodes

1. Click on **any node** in the investigation tree (hypothesis or conclusion).
2. A detail panel opens showing:
   - The evidence the agent collected (KQL queries, metric snapshots, log excerpts).
   - The reasoning chain that led to the validation or invalidation.
   - Links to the original data sources (Log Analytics, App Insights, etc.).

![Step 6](screenshots/step-6-inspect-evidence-node.png)

> **Checkpoint ✅:** You can click a hypothesis node and see the evidence, including at least one KQL query result or metric graph.

---

### Step 7 — Turn Off Deep Investigation

When the investigation is complete:

1. Locate the **sparkle badge** (✨) on the chat input area.
2. Click the **X** on the badge to disable deep investigation mode.
3. Confirm the sparkle badge and status banner disappear.

![Step 7](screenshots/step-7-turn-off-deep-investigation.png)

> **Checkpoint ✅:** Deep investigation is off — badge and banner are gone. The investigation results remain in your chat history.

---

## Expected Output

After a successful deep investigation, you should see:

### Investigation Tree
- A tree structure with **4 phases** branching from left to right.
- **2–4 hypothesis nodes** in Phase 2, each with a short description (e.g., "Elevated latency caused by recent deployment," "Database connection pool exhaustion").

### Hypothesis Nodes
Each hypothesis node shows:
- A title summarizing the hypothesis.
- A status indicator: **Validated** ✅, **Invalidated** ❌, or **Inconclusive** ⚪.
- Expandable evidence including KQL results, metric charts, and log excerpts.

### Conclusion Node
The conclusion node contains:
- **Root cause statement** — a 1–3 sentence summary of the identified cause.
- **Recommended actions** — concrete steps to remediate (e.g., "Roll back deployment X," "Scale container app replicas to 5").
- **Evidence summary** — references to the validated hypotheses and supporting data.

---

## Discussion Points (5 min)

1. **Cost & latency:** Deep investigations consume significantly more tokens than standard chat queries. Reserve them for genuinely complex issues — not simple questions like "what is my CPU usage?"

2. **Authorization timeout:** The OBO token expires after **10 minutes**. If the investigation is still running, you will be prompted to re-authorize. The investigation pauses (does not fail) while waiting for re-authorization.

3. **Partial results on cancel:** If you turn off deep investigation before Phase 4 completes, any results gathered so far are **preserved** in the chat thread. You can review partial hypotheses and evidence even if no conclusion was reached.

---

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for the full table. Quick reference:

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| OBO card times out | Authorization token expired (10 min limit) | Click Approve again when re-prompted |
| Investigation stuck in Phase 2 | Insufficient data or complex environment | Wait up to 5 minutes; if still stuck, cancel and try a more specific prompt |
| Thin results / few hypotheses | Prompt too vague or sample app has minimal activity | Use a more targeted prompt (see [prompts/lab-prompts.md](../../prompts/lab-prompts.md)) |
| "Deep investigation" option missing from + menu | Agent not in Running state or missing permissions | Verify agent status in portal; confirm SRE Agent Administrator role |

---

## Cleanup

1. Turn off deep investigation mode (Step 7) if still active.
2. No resources to delete — deep investigation threads are retained in chat history for review in the Operate, Audit, Share module.

---

## Reference Links

- [Run a Deep Investigation](https://sre.azure.com/docs/tutorials/advanced/deep-investigation)
- [Root Cause Analysis](https://sre.azure.com/docs/capabilities/root-cause-analysis)
- [Diagnose with Azure Observability](https://sre.azure.com/docs/capabilities/diagnose-azure-observability)
- [Permissions](https://sre.azure.com/docs/concepts/permissions)
- [Run Modes](https://sre.azure.com/docs/concepts/run-modes)

---

*Next: [Lab E — Automate](../lab-E-automate/README.md)*
