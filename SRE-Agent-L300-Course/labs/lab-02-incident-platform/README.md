---
lab: 2
level: 300
duration_minutes: 60
track: pagerduty|servicenow|azure-monitor
dependencies:
  - Lab 1
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# Lab 2 — Incident Platform Connection

> **Format:** Lab (60 min) — three parallel tracks.
> **Outcome:** A connected incident platform with the quickstart plan deleted and at least one historical incident visible.

Each attendee follows **one** track based on their registration form selection.

---

## Track A — PagerDuty

### Step 1 — Generate API Token (≈ 5 min)

1. Log in to your PagerDuty trial workspace.
2. Navigate to **Integrations → API Access Keys → Create New API Key**.
3. Scope: `services-read` + `incidents-write`.
4. Copy the token — you will not see it again.

> **Expected state:** A new API key visible in the API Access Keys list.
> **Troubleshooting:** If the key creation fails, confirm your PagerDuty user has Admin role on the trial workspace.

### Step 2 — Connect in Builder (≈ 5 min)

1. Open the SRE Agent portal → **Builder → Connectors → Incidents → PagerDuty**.
2. Paste the API token.
3. Click **Connect**.

> **Expected state:** Connector status shows `Connecting…` then `Connected`.
> **Troubleshooting:** If status stays `Connecting` for > 90 s, verify the API token has the correct scopes. See [PagerDuty setup tutorial](https://sre.azure.com/docs/tutorials/incident-platforms/setup-pagerduty-indexing).

### Step 3 — Verify Services and Incidents (≈ 5 min)

1. Navigate to **Builder → Knowledge Sources**.
2. Confirm your PagerDuty services and incident types appear.

> **Expected state:** At least one service listed.
> **Troubleshooting:** If no services appear, confirm the API token user is associated with the correct PagerDuty team.

### Step 4 — Trigger Synthetic Incident (≈ 5 min)

1. Use the PagerDuty CLI or API to create a test incident:
   ```bash
   curl -X POST https://api.pagerduty.com/incidents \
     -H "Authorization: Token token=<YOUR_TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{"incident":{"type":"incident","title":"[TEST] Synthetic P3 latency","service":{"id":"<SERVICE_ID>","type":"service_reference"},"urgency":"low"}}'
   ```
2. Switch to the Agent Canvas and confirm the agent acknowledges the incident.

> **Expected state:** Incident visible in Builder → Incidents page.
> **Troubleshooting:** If the incident doesn't appear within 60 s, check the connector heartbeat status.

---

## ⏱ Checkpoint — 15 min

- [ ] Connector status is `Connected`.
- [ ] At least one service visible in Knowledge Sources.

---

## Track B — ServiceNow

### Step 1 — Service Account Credentials (≈ 5 min)

1. Log in to your ServiceNow PDI.
2. Create (or confirm) a service-account user with roles: `incident.read` + `incident.write`.
3. Note the instance URL, username, and password.

> **Expected state:** Service account can log in and query incidents.
> **Troubleshooting:** If the service account cannot access incidents, verify the `incident` table ACLs in your PDI. See [ServiceNow setup tutorial](https://sre.azure.com/docs/tutorials/incident-platforms/setup-servicenow-indexing).

### Step 2 — Connect in Builder (≈ 5 min)

1. Open the SRE Agent portal → **Builder → Connectors → Incidents → ServiceNow**.
2. Enter instance URL and service-account credentials.
3. Click **Connect**.

> **Expected state:** Connector status shows `Connected`.
> **Troubleshooting:** If connection fails, verify the PDI is accessible from the public internet (PDIs have a sleep timer — wake it first).

### Step 3 — Validate Mapping (≈ 5 min)

1. Confirm priority mapping (P1–P5) and impacted-service mapping appear correctly.
2. Verify at least one CMDB CI matches your sample workload.

> **Expected state:** Priority and service mappings populated.
> **Troubleshooting:** If mappings are empty, verify the CMDB CI exists and is associated with the assignment group.

---

## ⏱ Checkpoint — 30 min

- [ ] ServiceNow connector status `Connected`.
- [ ] Priority and service mappings populated correctly.

---

## Track C — Azure Monitor

### Step 1 — Alert Rule (≈ 5 min)

1. Confirm a sample alert rule exists on your L200 sample workload.
   - If not, create a metric alert on the sample App Service (e.g., `Http5xx > 0`).
2. Verify the alert rule is **Enabled**.

> **Expected state:** Alert rule visible in Azure Portal → Monitor → Alerts → Alert Rules.
> **Troubleshooting:** If no alert rule exists, create one from the sample workload's Monitoring blade.

### Step 2 — Connect in Builder (≈ 5 min)

1. Open the SRE Agent portal → **Builder → Connectors → Incidents → Azure Monitor**.
2. Select the subscription containing your sample workload.
3. Click **Connect**.

> **Expected state:** Connector status shows `Connected`.
> **Troubleshooting:** If connection fails, verify the agent's UAMI has the correct subscription-level role assignment. See [Azure Monitor Alerts](https://sre.azure.com/docs/capabilities/azure-monitor-alerts).

### Step 3 — Verify Monitoring Contributor (≈ 5 min)

1. In Azure Portal → **Subscriptions → Access Control (IAM)**.
2. Confirm the agent's UAMI has **Monitoring Contributor** role.
   - The agent needs this to acknowledge and close alerts.
3. If missing, add the role assignment now.

> **Expected state:** `Monitoring Contributor` role assigned to agent UAMI.
> **Troubleshooting:** If you lack permissions to assign roles, contact your subscription Owner.

---

## ⏱ Checkpoint — 45 min

- [ ] Azure Monitor connector status `Connected`.
- [ ] Monitoring Contributor role confirmed on agent UAMI.

---

## Common Verification (All Tracks)

### Step 5 — Confirm Incidents Page (≈ 5 min)

1. Navigate to **Builder → Incidents**.
2. Confirm at least **1 historical incident** is listed.

> **Expected state:** Incidents page shows at least one entry.
> **Troubleshooting:** If no incidents appear, fire a test incident from your platform (see track-specific Step 4 / API calls).

### Step 6 — DELETE the Quickstart Response Plan (≈ 5 min)

> ⚠️ **Critical:** The default quickstart response plan causes double-routing when you create L300-class plans in Lab 3. Delete it now.

1. Navigate to **Builder → Incident Response Plans**.
2. Find the pre-existing **quickstart response plan**.
3. Click **Delete** → Confirm.

> **Expected state:** No response plans listed.
> **Troubleshooting:** If you cannot find the quickstart plan, it may already have been deleted. Confirm the plans list is empty.

---

## ⏱ Final Checkpoint — 60 min

- [ ] Connector status: `Connected` (60 s heartbeat green).
- [ ] Quickstart response plan: **deleted**.
- [ ] At least 1 historical incident visible in Builder → Incidents.

---

## References

- [PagerDuty Incidents](https://sre.azure.com/docs/capabilities/pagerduty-incidents)
- [ServiceNow Incidents](https://sre.azure.com/docs/capabilities/servicenow-incidents)
- [Azure Monitor Alerts](https://sre.azure.com/docs/capabilities/azure-monitor-alerts)
- [Setup PagerDuty Indexing](https://sre.azure.com/docs/tutorials/incident-platforms/setup-pagerduty-indexing)
- [Setup ServiceNow Indexing](https://sre.azure.com/docs/tutorials/incident-platforms/setup-servicenow-indexing)
- For L200 connector basics, see [SREA-Level200.md §Connectors](../../../SREA-Level200.md#connectors)
