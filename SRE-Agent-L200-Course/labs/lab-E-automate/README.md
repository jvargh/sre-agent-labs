# Lab E — Automate: Connector + Custom Agent + Scheduled Task

> **Outcome:** A daily scheduled health-check task that emails a summary via Outlook, executed by a small custom agent.

| | |
|---|---|
| **Module** | Lab E (L200 Capstone) |
| **Level** | 200 (Hands-on) |
| **Duration** | 45 minutes |
| **Docs reference** | [Step 5: Automate Actions](https://sre.azure.com/docs/get-started/automate-actions), [Scheduled Tasks](https://sre.azure.com/docs/capabilities/scheduled-tasks), [Send Notifications](https://sre.azure.com/docs/capabilities/send-notifications) |

> ⚠️ **Critical constraint:** This lab sets the `email-notifications` subagent to **Autonomous** because its **only tool is `SendOutlookEmail`** — a low-risk notification action that does not touch Azure infrastructure. Do **NOT** switch any agent or response plan that manages Azure infrastructure to Autonomous. Infrastructure actions must remain in **Review** mode.

---

## Prerequisites

Before starting this lab, confirm the following are complete:

- [x] Lab A — Agent is in `Running` state
- [x] Lab B — At least one resource group connected; code repo connected
- [x] Lab C — Successfully ran diagnostic chat prompts
- [x] Lab D — Completed at least one deep investigation
- [x] You have a **Microsoft 365 Outlook** account (work or school)
- [x] You have the **SRE Agent Administrator** role on the agent resource

---

## Time Budget

| Activity | Minutes |
|----------|---------|
| Step 1: Add Outlook connector | 8 |
| Step 2: Create custom agent (subagent) | 10 |
| Step 3: Add scheduled task | 10 |
| Step 4: Verify execution + email delivery | 10 |
| Stretch activities (optional) | 5 |
| Buffer | 2 |
| **Total** | **45** |

---

## Lab Steps

### Step 1 — Add the Outlook Connector

1. Navigate to **Builder** in the left sidebar.
2. Click **Connectors**.
3. Click **Add connector**.
4. Select **Send email (Office 365 Outlook)**.
5. Sign in with your Microsoft 365 work or school account when prompted.

![Step 1](screenshots/step-1-add-outlook-connector.png)

**Verify:** After sign-in, the connector appears in your connector list with the following tools:

| Tool | Description |
|------|-------------|
| `SendOutlookEmail` | Send an email via Office 365 Outlook |
| `GetOutlookEmail` | Read a specific email |
| `ListOutlookEmails` | List emails from a mailbox |

> **Checkpoint ✅:** The Outlook connector shows all three tools (`SendOutlookEmail`, `GetOutlookEmail`, `ListOutlookEmails`).

---

### Step 2 — Create a Custom Agent (Subagent)

1. Navigate to **Builder** → **Agent Canvas**.
2. Click **Create subagent**.
3. Configure the subagent:

| Field | Value | Why |
|-------|-------|-----|
| **Name** | `email-notifications-<your-alias>` | Unique per attendee — replace `<your-alias>` with your workshop alias |
| **Autonomy** | **Autonomous** | This subagent's only tool is `SendOutlookEmail` — a low-risk notification action. It does not touch Azure infrastructure. |
| **Tools** | Select **`SendOutlookEmail`** only | Least-privilege: only the tool this agent needs |

4. Click **Save**.

![Step 2](screenshots/step-2-create-subagent.png)

**Verify:** The `email-notifications-<your-alias>` node appears on the Agent Canvas with the `SendOutlookEmail` tool listed beneath it.

> **Checkpoint ✅:** Subagent node visible on canvas with exactly one tool (`SendOutlookEmail`).

> ⚠️ **Why Autonomous here?** The `email-notifications` subagent can only send emails. It cannot read, write, or modify Azure resources. Autonomous mode is safe because the blast radius is limited to email delivery. **Never** set Autonomous on agents that have Azure infrastructure tools.

---

### Step 3 — Add a Scheduled Task

1. On the Agent Canvas, locate the `email-notifications` subagent node.
2. Click the **+** button on the **left side** of the subagent node.
3. Select **Add scheduled task**.
4. Configure the task:

| Field | Value |
|-------|-------|
| **Name** | `daily-health-<your-alias>` |
| **Schedule** | Every 24 hours — or use cron: `0 8 * * *` (daily at 8:00 AM UTC) |
| **Prompt template** | See below |

5. Paste this prompt template **verbatim**:

```
Check the health of our Azure resources:
1. Verify all container apps are running
2. Check CPU and memory metrics over the last hour
3. Review any recent warning logs
4. Summarize findings and send a report via email using SendOutlookEmail
```

6. Click **Save**.

![Step 3](screenshots/step-3-add-scheduled-task.png)

> **Checkpoint ✅:** The scheduled task `daily-health-<your-alias>` appears connected to the `email-notifications-<your-alias>` subagent on the canvas.

---

### Step 4 — Verify Execution

1. Navigate to **Builder** → **Scheduled tasks**.
2. Find `daily-health-<your-alias>` in the task list.
3. Click the task, then click **Run task now**.
4. A chat thread opens — watch the tool invocations in real time:
   - The agent queries Azure resources (Resource Graph, metrics, logs).
   - The agent composes a health summary.
   - The agent invokes `SendOutlookEmail` to deliver the report.
5. **Check your Outlook inbox** — confirm the health report email arrived.

![Step 4](screenshots/step-4-verify-task-execution.png)

> **Checkpoint ✅:** Email received in your Outlook inbox with a health summary of your Azure resources.

---

## Expected Output

### Chat Thread
When the task runs, the chat thread shows:
- **Tool call cards** for each Azure query (Resource Graph, KQL, App Insights).
- A **tool call card for `SendOutlookEmail`** showing the recipient, subject, and body.
- A **completion message** confirming the email was sent.

### Email
The email you receive should contain:
- **Subject:** Something like "Daily Azure Resource Health Report" (agent-generated).
- **Body:** A structured summary including:
  - Container app status (running / stopped / degraded).
  - CPU and memory metrics over the last hour.
  - Any warning logs found (or "no warnings detected").
  - An overall health assessment.

---

## Stretch Activities (Optional — Only If Time Permits)

These are **discussion only** unless you finish early:

1. **Swap Outlook for Teams:** Remove the Outlook connector and add a Teams connector instead. Post the health report to a Teams channel rather than email. The flow is identical — change the connector and tool selection.

2. **Model tier selection:** Discuss the difference between the Fast and Reasoning model tiers for scheduled tasks. Fast is cheaper for routine checks; Reasoning is better for complex analysis. *(Do not change during the lab.)*

3. **Execution artifacts:** Mention that scheduled tasks can generate artifacts (CSV, PDF) attached to the chat thread. *(Reference: [Scheduled Tasks](https://sre.azure.com/docs/capabilities/scheduled-tasks))*

4. **Edit-in-place:** Show that you can click into a scheduled task and modify the prompt, schedule, or tool selection without recreating it.

> 📌 **Forward reference:** MCP custom connectors (Datadog, Splunk, Jira), Skills authoring, and Response Plans are **Level 300** topics. Mention them as the next step but do not build them in this lab.

---

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for the full table. Quick reference:

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Outlook connector sign-in fails | Pop-up blocked or wrong account type | Allow pop-ups for `sre.azure.com`; use a work/school account |
| `SendOutlookEmail` tool not listed | Connector added but not fully authenticated | Remove and re-add the connector; complete sign-in |
| Subagent node doesn't appear on canvas | Save didn't complete | Refresh the page; recreate the subagent |
| Scheduled task doesn't execute | Cron expression invalid or task not saved | Verify cron `0 8 * * *`; click Save again |
| Email not received | Email went to spam/junk, or Outlook connector lost auth | Check spam folder; verify connector health in Builder → Connectors |

---

## Cleanup

1. **Optional:** If you want to stop the recurring task, navigate to Builder → Scheduled tasks → `daily-health-<your-alias>` → disable or delete the task.
2. **Do not** remove the Outlook connector — other attendees may share the same connector.
3. The subagent and task can remain for the Operate, Audit, Share module review.

---

## Reference Links

- [Step 5: Automate Actions](https://sre.azure.com/docs/get-started/automate-actions)
- [Scheduled Tasks](https://sre.azure.com/docs/capabilities/scheduled-tasks)
- [Send Notifications](https://sre.azure.com/docs/capabilities/send-notifications)
- [Connectors](https://sre.azure.com/docs/concepts/connectors)
- [Custom Agents](https://sre.azure.com/docs/concepts/subagents)
- [Run Modes](https://sre.azure.com/docs/concepts/run-modes)

---

*Previous: [Lab D — Deep Investigation](../lab-D-deep-investigation/README.md)*
