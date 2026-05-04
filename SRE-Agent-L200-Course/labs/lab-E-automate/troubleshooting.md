# Lab E — Automate: Troubleshooting Guide

---

## Common Issues

| # | Symptom | Likely Cause | Fix |
|---|---------|-------------|-----|
| 1 | **Outlook connector sign-in pop-up doesn't appear** | Browser pop-up blocker is active for `sre.azure.com`. | Allow pop-ups for `sre.azure.com` in your browser settings. Retry the sign-in. |
| 2 | **Outlook sign-in fails with "need admin approval"** | Your M365 tenant requires admin consent for OAuth apps. | Contact your tenant admin to approve the SRE Agent Outlook integration, or use a sandbox M365 tenant. |
| 3 | **Connector appears but `SendOutlookEmail` tool is missing** | Sign-in completed partially or the connector didn't fully register. | Remove the Outlook connector (Builder → Connectors → ⋯ → Remove), then re-add it and complete sign-in fully. |
| 4 | **"Create subagent" button is greyed out** | You don't have the SRE Agent Administrator role, or the Agent Canvas hasn't loaded fully. | Verify your role assignment. Refresh the page and try again. |
| 5 | **Subagent node doesn't appear on the canvas after saving** | Intermittent UI refresh issue. | Refresh the browser. Navigate away from Agent Canvas and back. The subagent should appear. |
| 6 | **"Add scheduled task" option not visible on the + menu** | The + button on the wrong side of the node, or the subagent wasn't saved properly. | Click the **+** on the **left** side of the subagent node. If missing, verify the subagent saved (check Builder → Agent Canvas). |
| 7 | **Scheduled task won't save — validation error** | Invalid cron expression or missing required fields. | Use exactly `0 8 * * *` for the cron. Ensure all fields (name, schedule, prompt template) are filled. |
| 8 | **"Run task now" does nothing** | Task didn't save, or there's a backend delay. | Wait 10 seconds. Refresh the Scheduled tasks page. Verify the task exists, then retry. |
| 9 | **Task runs but email not received** | Email landed in spam/junk, or the Outlook connector token expired. | Check your junk/spam folder. Check connector health: Builder → Connectors — look for a red badge on the Outlook connector. If unhealthy, remove and re-add. |
| 10 | **Task runs but shows "tool invocation failed" for SendOutlookEmail** | The Outlook connector lost authentication (token refresh failed). | Go to Builder → Connectors → Outlook → re-authenticate by signing in again. Retry the task. |
| 11 | **Chat thread opens but agent doesn't query Azure resources** | The agent's UAMI lost resource group access, or the resource group connection was removed. | Verify in Builder → Azure Resources that your resource group is still connected. Re-add if missing. |
| 12 | **Email arrives but body is empty or malformed** | The agent's health check found no data (no container apps, no metrics). | Ensure the sample workload is deployed and generating telemetry. The prompt expects container apps — if your sample uses App Service, modify the prompt accordingly. |
| 13 | **Multiple attendees creating same-named subagent causes conflict** | Subagent names must be unique per agent instance. | The lab instructions already include `<your-alias>` in the name. Verify you used your actual alias, not the literal placeholder. |
| 14 | **"Autonomous" autonomy level not available** | The agent was created with a policy restricting autonomy options. | Use **Review** mode instead. You will need to approve each task execution manually. Discuss with the trainer. |

---

## Connector Health Check

If the Outlook connector shows a red badge in Builder → Connectors:

1. Click the connector to expand details.
2. Check the **last heartbeat** timestamp — it should be within the last 60 seconds.
3. If stale, click **Re-authenticate** and sign in again.
4. If re-authentication fails, remove and re-add the connector.

---

## Escalation Path

If none of the above resolves your issue:

1. **Check the support channel** (Teams/Slack) — a trainer can help in real time.
2. **Capture a screenshot** of the error state.
3. **Note the scheduled task name** and the chat thread URL (click ⋯ → Copy link to thread).
4. Post all three in the support channel and tag the trainer.

---

## Key Facts to Remember

- **Autonomous is ONLY for this subagent** because `SendOutlookEmail` is its only tool. Never set Autonomous on agents with Azure infrastructure tools.
- **Connector heartbeat:** 60-second interval. A red badge means the connector is unhealthy.
- **Cron format:** `0 8 * * *` = daily at 8:00 AM UTC. Adjust for your timezone if needed.
- **Per-attendee isolation:** Each attendee has their own agent instance. Subagent and task names include `<your-alias>` to avoid collisions if agents are shared for any reason.
