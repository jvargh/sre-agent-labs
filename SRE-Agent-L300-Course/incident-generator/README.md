# Synthetic Incident Generator — SRE Agent L300 Workshop (D11)

> **Reference:** [SREA-Level300.md §M13](../../SREA-Level300.md#m13--capstone-production-rollout-playbook--multi-agent-incident-drill)

## Overview

Generates synthetic incidents across PagerDuty, ServiceNow, or Azure Monitor for the M3 lab exercises and M13 capstone drill. All incidents use `[TEST]` prefix by default. Emits a JSON report with incident IDs and timestamps for the capstone scorer.

## Prerequisites

- Azure CLI authenticated
- Key Vault with platform credentials (set up via D2 incident platform kits)
- `jq` installed (for bash script)

## Usage

### PowerShell

```powershell
# Single P1 incident on PagerDuty
./generate-incidents.ps1 `
  -Platform pagerduty `
  -Severity P1 `
  -KeyVaultName "kv-srea-xxx" `
  -AttendeeHandle "jdoe"

# 3 P2 incidents on ServiceNow, 10s apart
./generate-incidents.ps1 `
  -Platform servicenow `
  -Severity P2 `
  -Count 3 `
  -Rate 10 `
  -KeyVaultName "kv-srea-xxx" `
  -AttendeeHandle "jdoe"

# Azure Monitor alert
./generate-incidents.ps1 `
  -Platform azure-monitor `
  -Severity P3 `
  -AttendeeHandle "jdoe"
```

### Bash

```bash
# Single P1 incident on PagerDuty
./generate-incidents.sh \
  --platform pagerduty \
  --severity P1 \
  --keyvault "kv-srea-xxx" \
  --attendee "jdoe"

# 3 P2 incidents on ServiceNow, 10s apart
./generate-incidents.sh \
  --platform servicenow \
  --severity P2 \
  --count 3 \
  --rate 10 \
  --keyvault "kv-srea-xxx" \
  --attendee "jdoe"

# Azure Monitor alert
./generate-incidents.sh \
  --platform azure-monitor \
  --severity P3 \
  --attendee "jdoe"
```

## CLI Flags

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--platform` | Yes | — | `pagerduty`, `servicenow`, or `azure-monitor` |
| `--severity` | No | `P2` | `P1`, `P2`, `P3`, or `P4` |
| `--service` | No | `srea-l300-sample-app` | Impacted service name |
| `--count` | No | `1` | Number of incidents to generate |
| `--rate` | No | `5` | Seconds between incidents |
| `--prefix` | No | `[TEST]` | Incident title prefix |
| `--keyvault` | No* | — | Key Vault name (* required for PagerDuty/ServiceNow) |
| `--attendee` | No* | — | Attendee handle (* required for credential lookup) |

## Capstone Drill (M13)

For the capstone, fire three incidents back-to-back:

```powershell
# Incident 1: P3 high latency → routes to low-sev-triager
./generate-incidents.ps1 -Platform pagerduty -Severity P3 -KeyVaultName "kv-srea-xxx" -AttendeeHandle "jdoe"

# Incident 2: P1 db corruption → routes via incident_triager → db-expert → notifier
./generate-incidents.ps1 -Platform pagerduty -Severity P1 -KeyVaultName "kv-srea-xxx" -AttendeeHandle "jdoe"

# Incident 3: P2 api 500s → routes via incident_triager → api-expert → notifier
./generate-incidents.ps1 -Platform pagerduty -Severity P2 -KeyVaultName "kv-srea-xxx" -AttendeeHandle "jdoe"
```

## Output

Each run produces a JSON report file (`incident-report-<timestamp>.json`) with:

```json
[
  {
    "index": 1,
    "timestamp": "2026-05-03T19:51:18.000Z",
    "platform": "pagerduty",
    "severity": "P1",
    "title": "[TEST] P1 high latency",
    "incidentId": "PXXXXXX",
    "service": "srea-l300-sample-app"
  }
]
```

This report is consumed by the M13 capstone scoring sheet (D13) to verify end-to-end incident handling.

## Credential Security

All platform credentials are retrieved from Azure Key Vault at runtime — **never stored inline or in environment variables**. The Key Vault secrets are set up by the D2 incident platform kits:

- `pagerduty-api-token-<attendee>`
- `servicenow-instance-url-<attendee>`
- `servicenow-username-<attendee>`
- `servicenow-password-<attendee>`
