# PagerDuty Trial Setup — SRE Agent L300 Workshop (D2 Track A)

> **Reference:** Lab 2 — Incident Platform Connection (Track A)

## Overview

Set up a PagerDuty trial workspace for the workshop. Each attendee gets one service, one escalation policy, one user, and one API token. **All credentials stored in Key Vault — never inline.**

## Prerequisites

- PagerDuty 14-day trial account ([signup](https://www.pagerduty.com/sign-up/))
- Azure Key Vault provisioned (done by `provision.sh`)
- `jq` and `curl` installed

## Step 1 — Create PagerDuty Trial

1. Sign up at <https://www.pagerduty.com/sign-up/> with a workshop-specific email alias.
2. Subdomain: `srea-l300-<attendee-handle>`.
3. Complete onboarding wizard; skip integrations.

## Step 2 — Create Service

```bash
# Via PagerDuty API
PAGERDUTY_TOKEN="<your-api-token>"

curl -s -X POST "https://api.pagerduty.com/services" \
  -H "Authorization: Token token=${PAGERDUTY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "name": "sre-workshop-sample-app",
      "description": "SRE Agent L300 workshop sample workload",
      "escalation_policy": {
        "id": "<escalation-policy-id>",
        "type": "escalation_policy_reference"
      },
      "alert_creation": "create_alerts_and_incidents"
    }
  }'
```

## Step 3 — Create Escalation Policy

```bash
curl -s -X POST "https://api.pagerduty.com/escalation_policies" \
  -H "Authorization: Token token=${PAGERDUTY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "escalation_policy": {
      "name": "sre-workshop-escalation",
      "escalation_rules": [{
        "escalation_delay_in_minutes": 5,
        "targets": [{
          "id": "<user-id>",
          "type": "user_reference"
        }]
      }]
    }
  }'
```

## Step 4 — Create API Token

1. PagerDuty → **Integrations** → **API Access Keys** → **Create New API Key**.
2. Name: `srea-l300-<attendee-handle>`.
3. Scope: Read/Write (services-read + incidents-write).

## Step 5 — Store Token in Key Vault

```bash
# NEVER store PagerDuty tokens inline — always Key Vault reference
ATTENDEE="<attendee-handle>"
KV_NAME="kv-srea-<unique-suffix>"

az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "pagerduty-api-token-${ATTENDEE}" \
  --value "$PAGERDUTY_TOKEN"

# Retrieve for agent configuration
az keyvault secret show \
  --vault-name "$KV_NAME" \
  --name "pagerduty-api-token-${ATTENDEE}" \
  --query "value" -o tsv
```

## Step 6 — Connect to SRE Agent

1. SRE Agent portal → **Builder** → **Connectors** → **Incidents** → **PagerDuty** → Connect.
2. Enter the PagerDuty API token from Key Vault.
3. Confirm services + incident types appear in **Builder** → **Knowledge Sources**.

## Verification

- [ ] Connector status: `Connected` (60s heartbeat green)
- [ ] At least 1 service visible in Builder
- [ ] Synthetic incident from D11 fires and agent acknowledges
- [ ] Delete the quickstart response plan to avoid double-routing

## Cleanup (per cohort rotation)

Rotate API tokens between cohorts:
```bash
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "pagerduty-api-token-${ATTENDEE}" \
  --value "<new-token>"
```
