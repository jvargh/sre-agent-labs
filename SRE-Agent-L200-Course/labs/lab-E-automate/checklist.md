# Lab E — Automate: Completion Checklist

Use this checklist to confirm you have successfully completed every step of Lab E.

---

## Pre-Lab Readiness

- [ ] Agent is in `Running` state (Lab A complete)
- [ ] At least one resource group connected (Lab B complete)
- [ ] Successfully ran diagnostic chat prompts (Lab C complete)
- [ ] Completed at least one deep investigation (Lab D complete)
- [ ] Have a Microsoft 365 Outlook account (work or school)
- [ ] Hold **SRE Agent Administrator** role on the agent resource

---

## Step 1 — Outlook Connector

- [ ] Navigated to Builder → Connectors → Add connector
- [ ] Selected **Send email (Office 365 Outlook)**
- [ ] Completed sign-in with work/school account
- [ ] Verified connector shows all three tools:
  - [ ] `SendOutlookEmail`
  - [ ] `GetOutlookEmail`
  - [ ] `ListOutlookEmails`

---

## Step 2 — Custom Agent (Subagent)

- [ ] Navigated to Builder → Agent Canvas → Create subagent
- [ ] Set name to `email-notifications`
- [ ] Set autonomy to **Autonomous**
- [ ] Selected **only** `SendOutlookEmail` as the tool
- [ ] Saved the subagent
- [ ] Confirmed the `email-notifications` node appears on the canvas with `SendOutlookEmail` tool

> ⚠️ Autonomous is correct here because this subagent's only tool is email — it cannot touch Azure infrastructure.

---

## Step 3 — Scheduled Task

- [ ] Clicked **+** on the left side of the `email-notifications` subagent node
- [ ] Selected **Add scheduled task**
- [ ] Set name to `daily-resource-health-report`
- [ ] Set schedule to every 24 hours or cron `0 8 * * *`
- [ ] Pasted the exact prompt template:
  ```
  Check the health of our Azure resources:
  1. Verify all container apps are running
  2. Check CPU and memory metrics over the last hour
  3. Review any recent warning logs
  4. Summarize findings and send a report via email using SendOutlookEmail
  ```
- [ ] Saved the scheduled task
- [ ] Confirmed the task appears connected to the subagent on the canvas

---

## Step 4 — Verify Execution

- [ ] Navigated to Builder → Scheduled tasks
- [ ] Selected `daily-resource-health-report`
- [ ] Clicked **Run task now**
- [ ] Watched tool invocations in the chat thread:
  - [ ] Saw Azure resource queries (Resource Graph, metrics, logs)
  - [ ] Saw `SendOutlookEmail` tool invocation
- [ ] **Received email** in Outlook inbox with health summary

---

## Checkpoints

| # | Checkpoint | Pass? |
|---|-----------|-------|
| 1 | Outlook connector shows `SendOutlookEmail`, `GetOutlookEmail`, `ListOutlookEmails` tools | ☐ |
| 2 | `email-notifications` subagent node visible on canvas with `SendOutlookEmail` tool | ☐ |
| 3 | Scheduled task `daily-resource-health-report` connected to subagent on canvas | ☐ |
| 4 | Health report email received in Outlook inbox | ☐ |

---

## Stretch Activities (Optional)

- [ ] Discussed swapping Outlook for Teams connector
- [ ] Discussed model tier selection (Fast vs Reasoning)
- [ ] Reviewed execution artifacts concept (CSV/PDF)
- [ ] Explored edit-in-place on the scheduled task

---

## Success Criteria

✅ **Lab E is complete when:**
- The Outlook connector is active with three tools
- The `email-notifications` subagent exists on the canvas with Autonomous mode and `SendOutlookEmail` only
- The `daily-resource-health-report` scheduled task ran successfully
- You received the health summary email in your Outlook inbox
