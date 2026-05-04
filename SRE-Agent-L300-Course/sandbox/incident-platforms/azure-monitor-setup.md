# Azure Monitor Setup — SRE Agent L300 Workshop (D2 Track C)

> **Reference:** [SREA-Level300.md §M2 Track C](../../../SREA-Level300.md#m2--incident-platform-connection)

## Overview

Configure Azure Monitor as the incident source: one metric alert + one log search alert against the sample workload (Container App). The agent's UAMI needs `Monitoring Contributor` to ack/close alerts. **All credentials via managed identity — no API keys needed.**

## Prerequisites

- Per-attendee sandbox provisioned via `provision.sh`
- UAMI already has `Monitoring Contributor` role (provisioned by Bicep)
- Sample Container App running

## Step 1 — Create Metric Alert (High CPU)

```bash
ATTENDEE="<attendee-handle>"
RG="rg-srea-l300-${ATTENDEE}"
ACA_NAME="aca-sample-${ATTENDEE}"
ACA_ID=$(az containerapp show -n "$ACA_NAME" -g "$RG" --query id -o tsv)

az monitor metrics alert create \
  --name "srea-l300-cpu-alert-${ATTENDEE}" \
  --resource-group "$RG" \
  --scopes "$ACA_ID" \
  --condition "avg UsageNanoCores > 500000000" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 2 \
  --description "[TEST] High CPU on sample workload - SRE Agent L300 workshop" \
  --tags workshop=srea-l300 attendee="$ATTENDEE"
```

## Step 2 — Create Log Search Alert (Error Rate)

```bash
LAW_ID=$(az monitor log-analytics workspace show \
  --workspace-name "law-srea-${ATTENDEE}" \
  --resource-group "$RG" \
  --query id -o tsv)

az monitor scheduled-query create \
  --name "srea-l300-error-alert-${ATTENDEE}" \
  --resource-group "$RG" \
  --scopes "$LAW_ID" \
  --condition "count > 5" \
  --condition-query "ContainerAppConsoleLogs_CL | where Log_s contains 'error' | where TimeGenerated > ago(5m)" \
  --window-size 5 \
  --evaluation-frequency 1 \
  --severity 1 \
  --description "[TEST] Error rate spike on sample workload - SRE Agent L300 workshop" \
  --tags workshop=srea-l300 attendee="$ATTENDEE"
```

## Step 3 — Connect to SRE Agent

1. SRE Agent portal → **Builder** → **Connectors** → **Incidents** → **Azure Monitor** → Connect.
2. Select the subscription and resource group containing the alerts.
3. Confirm `Monitoring Contributor` is assigned (the Bicep template handles this).
4. Verify alert rules appear in **Builder** → **Knowledge Sources**.

## Step 4 — Verify UAMI Permissions

```bash
# Confirm Monitoring Contributor role assignment
az role assignment list \
  --assignee "$(az identity show -n uami-srea-${ATTENDEE} -g $RG --query principalId -o tsv)" \
  --scope "/subscriptions/$(az account show --query id -o tsv)" \
  --query "[?roleDefinitionName=='Monitoring Contributor']" \
  -o table
```

## Verification

- [ ] Metric alert `srea-l300-cpu-alert-*` is active
- [ ] Log search alert `srea-l300-error-alert-*` is active  
- [ ] Connector status: `Connected` (60s heartbeat green)
- [ ] UAMI has `Monitoring Contributor` on the subscription
- [ ] Agent can acknowledge and close alerts programmatically
- [ ] At least 1 historical alert visible in Builder → Incidents
- [ ] Delete the quickstart response plan to avoid double-routing

## Alert Tuning for Workshop

The alert thresholds are intentionally low to trigger during the lab:
- CPU alert: 500m cores (half a core) — the sample app idles well below this
- Error alert: 5 errors in 5 minutes — use D11 synthetic generator to trigger

For the M3 lab, use the D11 incident generator to create `[TEST]` prefixed alerts.
