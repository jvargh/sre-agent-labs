# M12 — Configuration as Code: Troubleshooting

## Common Issues

### IaC Deployment Fails: Provider Not Registered

- **Cause:** `Microsoft.AzureSREAgent` provider not registered in the subscription.
- **Fix:** Run `az provider register --namespace Microsoft.AzureSREAgent` and wait for registration (may take a few minutes).

### IaC Deployment Fails: Name Conflict

- **Cause:** Agent name already exists in the subscription.
- **Fix:** Use a unique name. Check existing agents with `az resource list --resource-type Microsoft.AzureSREAgent/agents`.

### What-If Shows Unexpected Changes

- **Cause:** Template has non-deterministic defaults (e.g., timestamps, generated names).
- **Fix:** Pin all values. Use `@description` annotations in Bicep or `default` values in Terraform to make the template fully deterministic.

### REST API v2 Returns 401 Unauthorized

- **Cause:** Authentication token expired or insufficient permissions.
- **Fix:** Re-authenticate. Verify the service principal or managed identity has the correct role on the agent resource.

### REST API v2 Returns 409 Conflict

- **Cause:** Another configuration change is in progress.
- **Fix:** Wait 10–30 seconds and retry. If persistent, check the agent's activity log for concurrent operations.

### Diff Shows Drift After API Push

- **Cause:** Portal-side normalization of YAML (e.g., field ordering, default values added).
- **Fix:** Normalize the local YAML to match the API's output format. Export → normalize → commit as the canonical version.

### AzureActivity Table Not Available

- **Cause:** Azure Activity Log diagnostic settings not enabled on the Log Analytics workspace.
- **Fix:** Enable diagnostic settings: Azure Portal → Log Analytics workspace → Diagnostic settings → Add → Send to Log Analytics workspace.

### Knowledge Directory Is Empty

- **Cause:** The agent has not yet synthesized knowledge (fresh sandbox).
- **Fix:** Expected for a new agent. Knowledge is synthesized from investigations over time. Run a few incidents to seed knowledge.

### CI Pipeline Fails on Authentication

- **Cause:** CI runner does not have a managed identity or service principal configured.
- **Fix:** Configure OIDC federation or a service principal for the CI runner. Follow the [Agent Hooks API tutorial](https://sre.azure.com/docs/tutorials/agent-config/agent-hooks) for auth setup.

## Escalation

If issues persist, escalate to the trainer with:
1. Which part (1–4) is failing
2. The error message or deployment output
3. The IaC template or REST API request/response
