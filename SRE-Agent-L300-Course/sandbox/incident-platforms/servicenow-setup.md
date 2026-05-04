# ServiceNow PDI Setup — SRE Agent L300 Workshop (D2 Track B)

> **Reference:** Lab 2 — Incident Platform Connection (Track B)

## Overview

Set up a ServiceNow Personal Developer Instance (PDI) for the workshop. Each attendee gets one CMDB CI matching the sample workload, one assignment group, and one service account. **All credentials stored in Key Vault — never inline.**

## Prerequisites

- ServiceNow Developer account ([signup](https://developer.servicenow.com/))
- Azure Key Vault provisioned (done by `provision.sh`)

## Step 1 — Request a PDI

1. Go to <https://developer.servicenow.com/> → **Request Instance**.
2. Choose the latest release (Washington or later).
3. Note your instance URL: `https://<instance-id>.service-now.com`.

## Step 2 — Create Service Account

1. Navigate to **System Security** → **Users** → **New**.
2. Set:
   - User ID: `sre-agent-workshop`
   - First name: `SRE`
   - Last name: `Agent`
   - Active: `true`
   - Roles: `itil`, `incident_manager`
3. Set a strong password.

## Step 3 — Create Assignment Group

1. **User Administration** → **Groups** → **New**.
2. Name: `SRE-Workshop-Team`.
3. Add the `sre-agent-workshop` user as a member.

## Step 4 — Create CMDB CI

1. **Configuration** → **CMDB** → **Servers** → **New**.
2. Set:
   - Name: `srea-l300-sample-app` (matches the Container App from sandbox provisioning)
   - Operational Status: `Operational`
   - Assignment Group: `SRE-Workshop-Team`
   - Support Group: `SRE-Workshop-Team`
3. Save.

## Step 5 — Store Credentials in Key Vault

```bash
ATTENDEE="<attendee-handle>"
KV_NAME="kv-srea-<unique-suffix>"

# Store ServiceNow instance URL
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "servicenow-instance-url-${ATTENDEE}" \
  --value "https://<instance-id>.service-now.com"

# Store service account credentials
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "servicenow-username-${ATTENDEE}" \
  --value "sre-agent-workshop"

az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "servicenow-password-${ATTENDEE}" \
  --value "<strong-password>"
```

## Step 6 — Connect to SRE Agent

1. SRE Agent portal → **Builder** → **Connectors** → **Incidents** → **ServiceNow** → Connect.
2. Enter credentials from Key Vault (instance URL, username, password).
3. Validate priority + impacted-service mapping shows `srea-l300-sample-app`.

## Verification

- [ ] Connector status: `Connected` (60s heartbeat green)
- [ ] CMDB CI `srea-l300-sample-app` visible in incident mapping
- [ ] Priority mapping: P1→Critical, P2→High, P3→Medium, P4→Low
- [ ] Service account has `incident.read` + `incident.write` permissions
- [ ] Synthetic incident from D11 creates and resolves correctly
- [ ] Delete the quickstart response plan to avoid double-routing

## Notes

- PDIs expire after 10 days of inactivity; reclaim before the workshop.
- PDI data resets periodically; re-run CMDB CI creation if needed.
- ServiceNow PDIs are single-user; for multi-attendee workshops, request one PDI per attendee.
