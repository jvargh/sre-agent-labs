# Lab 10 — Audit, FinOps & Observability: Troubleshooting

## Common Issues

### No Events in customEvents Table

- **Cause:** Telemetry has not flushed yet, or App Insights is not configured.
- **Fix:** Wait 2–3 minutes after running an agent action. Verify the agent resource has App Insights linked. Re-fire a test incident from Lab 3.

### ThreadId Returns No Results

- **Cause:** Incorrect ThreadId or the thread has not generated telemetry yet.
- **Fix:** Copy the ThreadId from the conversation URL in the agent portal. Ensure the thread has completed (not still in progress).

### Token Counts Are Null

- **Cause:** Not all model calls emit InputTokens/OutputTokens.
- **Fix:** Filter to `ModelGenerationEnd` events only. Some event types may not include token data.

### IncidentActivitySnapshot Events Missing

- **Cause:** No incidents have been fully processed by a response plan.
- **Fix:** Re-fire a test incident and wait for the full chain to complete. Check that response plans are active.

### Save Button Disabled in KQL Editor

- **Cause:** Insufficient permissions on the App Insights resource.
- **Fix:** Verify you have Contributor (not Reader) access. Ask the trainer to grant access if needed.

### Activity Log Shows No Entries

- **Cause:** No manual changes have been made to the agent resource.
- **Fix:** This is actually the desired state for IaC-managed agents. If you expect to see entries, check the time range filter.

### ApprovalDecision Events Not Present

- **Cause:** All response plans are in Autonomous mode (no approvals needed).
- **Fix:** Expected if Lab 3 plans are Autonomous. Note in the workbook as "N/A." To generate data, temporarily set one plan to Review mode and process an incident.

## Escalation

If issues persist, escalate to the trainer with:
1. Which query number is failing
2. The KQL query text
3. Any error message from the query editor
4. The App Insights resource name
