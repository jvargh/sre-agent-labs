# Cost-Cap Watcher — SRE Agent L300 Workshop (D12)

> **Reference:** [SREA-Level300.md §6](../../SREA-Level300.md#6-success-metrics) — per-attendee per-day spend ≤ USD 50

## Overview

Enforces the workshop cost cap with a two-tier budget alert system:

| Threshold | USD | Action |
|-----------|-----|--------|
| 80% | $40 | ⚠️ **Warning** — Email notification to attendee + workshop admin |
| 100% | $50 | 🛑 **Critical** — Email + automated teardown of attendee sandbox |

## How It Works

1. **Azure Budget** (`Microsoft.Consumption/budgets`) monitors actual spend against the $50 cap, filtered by `workshop=srea-l300` tag.
2. At **80% ($40)**, a warning email is sent to the configured contact.
3. At **100% ($50)**, a critical notification fires and the Action Group triggers the teardown process.
4. The **Action Group** can be configured to call a webhook, automation runbook, or Logic App that executes `teardown.sh <attendee>`.

## Deployment

### Deploy with the main sandbox

The cost-cap is included in the main provisioning flow. To deploy standalone:

```bash
ATTENDEE="<attendee-handle>"
RG="rg-srea-l300-${ATTENDEE}"

az deployment group create \
  --resource-group "$RG" \
  --template-file ./bicep/cost-alert.bicep \
  --parameters \
    attendeeHandle="$ATTENDEE" \
    contactEmail="workshop-admin@example.com"
```

### PowerShell

```powershell
$attendee = "<attendee-handle>"
$rg = "rg-srea-l300-$attendee"

az deployment group create `
  --resource-group $rg `
  --template-file .\bicep\cost-alert.bicep `
  --parameters `
    attendeeHandle=$attendee `
    contactEmail="workshop-admin@example.com"
```

## Dry-Run Verification

Before the workshop, verify the cost cap works correctly:

### Step 1 — Deploy the budget alert

```bash
az deployment group create \
  --resource-group "rg-srea-l300-testuser" \
  --template-file ./bicep/cost-alert.bicep \
  --parameters attendeeHandle=testuser contactEmail=you@example.com
```

### Step 2 — Verify budget exists

```bash
az consumption budget show \
  --budget-name "budget-srea-l300-testuser" \
  --resource-group "rg-srea-l300-testuser"
```

### Step 3 — Verify action group

```bash
az monitor action-group show \
  --name "ag-srea-teardown-testuser" \
  --resource-group "rg-srea-l300-testuser"
```

### Step 4 — Test notification delivery

```bash
# Trigger a test notification from the action group
az monitor action-group test-notifications create \
  --resource-group "rg-srea-l300-testuser" \
  --action-group-name "ag-srea-teardown-testuser" \
  --alert-type "budget" \
  --contact-points '[{"emailAddress": "you@example.com"}]'
```

### Step 5 — Simulate budget breach

To test the full teardown flow without actual spend:

1. Create a budget with a very low threshold (e.g., $1).
2. Deploy a small resource that costs more than $1/day.
3. Wait for the budget evaluation cycle (up to 24 hours for Consumption API).
4. Verify the email notification arrives.
5. Verify the teardown action fires (if webhook is configured).

## Configuring Auto-Teardown

To enable fully automated teardown at 100%:

### Option A — Webhook to Azure Function

1. Deploy an Azure Function that calls `teardown.sh`.
2. Add the Function's URL as a webhook receiver in the Action Group.

### Option B — Automation Runbook

1. Create an Automation Account with a PowerShell runbook that runs `teardown.ps1`.
2. Add it as an automation runbook receiver in the Action Group.

### Option C — Logic App

1. Create a Logic App triggered by the Action Group.
2. Add steps: parse alert → extract attendee handle from tags → call `az group delete`.

## Cost Components

Typical per-attendee per-day spend breakdown:

| Resource | Estimated Daily Cost |
|----------|---------------------|
| Container App (min replicas=0) | ~$0-2 |
| ADX Free Tier | $0 |
| Log Analytics (per GB) | ~$2-5 |
| App Insights | ~$1-3 |
| Key Vault (operations) | ~$0.01 |
| UAMI | $0 |
| **Total estimated** | **~$3-10** |

The $50 cap provides ample headroom. Overruns typically come from:
- ADX accidentally provisioned on non-free tier
- Container App scaled to multiple replicas
- Excessive Log Analytics ingestion
