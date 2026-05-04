#!/usr/bin/env bash
# =============================================================================
# Synthetic Incident Generator — SRE Agent L300 Workshop (D11)
# Usage: ./generate-incidents.sh --platform <platform> --severity <sev> [options]
#
# CLI flags:
#   --platform   pagerduty | servicenow | azure-monitor (required)
#   --severity   P1 | P2 | P3 | P4 (default: P2)
#   --service    Impacted service name (default: srea-l300-sample-app)
#   --count      Number of incidents (default: 1)
#   --rate       Seconds between incidents (default: 5)
#   --prefix     Incident title prefix (default: [TEST])
#   --keyvault   Key Vault name for credentials
#   --attendee   Attendee handle for credential lookup
#
# Emits end-to-end report (incident IDs + timestamps) for capstone scorer.
# All incidents use [TEST] prefix per D11 spec.
# =============================================================================
set -euo pipefail

# ---- Defaults ----
PLATFORM=""
SEVERITY="P2"
SERVICE="srea-l300-sample-app"
COUNT=1
RATE=5
PREFIX="[TEST]"
KEYVAULT=""
ATTENDEE=""

# ---- Parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)  PLATFORM="$2"; shift 2;;
    --severity)  SEVERITY="$2"; shift 2;;
    --service)   SERVICE="$2"; shift 2;;
    --count)     COUNT="$2"; shift 2;;
    --rate)      RATE="$2"; shift 2;;
    --prefix)    PREFIX="$2"; shift 2;;
    --keyvault)  KEYVAULT="$2"; shift 2;;
    --attendee)  ATTENDEE="$2"; shift 2;;
    *) echo "Unknown option: $1"; exit 1;;
  esac
done

if [[ -z "$PLATFORM" ]]; then
  echo "ERROR: --platform is required (pagerduty | servicenow | azure-monitor)"
  exit 1
fi

# ---- Incident scenarios (rotate through for multiple incidents) ----
SCENARIOS=(
  "high latency|Response times exceeding 5s on /api/v1/orders endpoint. P99 latency at 12s."
  "db corruption|Data integrity check failed on orders table. Checksum mismatch detected."
  "api 500s|HTTP 500 error rate at 45% on /api/v1/users. NullPointerException in AuthHandler."
  "memory leak|Container memory at 95%. OOMKill events detected."
  "certificate expiry|TLS certificate expires in 2 hours. SSL handshake failures."
  "deployment rollback|Canary deployment 3x error rate vs baseline. Rollback stuck."
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_FILE="${SCRIPT_DIR}/incident-report-$(date +%Y%m%d-%H%M%S).json"

echo "============================================================"
echo "Synthetic Incident Generator — SRE Agent L300 Workshop"
echo "  Platform: ${PLATFORM}"
echo "  Severity: ${SEVERITY}"
echo "  Service:  ${SERVICE}"
echo "  Count:    ${COUNT}"
echo "  Rate:     ${RATE}s between incidents"
echo "  Prefix:   ${PREFIX}"
echo "============================================================"

# Start JSON report array
echo "[" > "$REPORT_FILE"

for ((i=0; i<COUNT; i++)); do
  IDX=$((i % ${#SCENARIOS[@]}))
  IFS='|' read -r SCENARIO_TITLE SCENARIO_DESC <<< "${SCENARIOS[$IDX]}"
  TITLE="${PREFIX} ${SEVERITY} ${SCENARIO_TITLE}"
  TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%S.000Z')
  INCIDENT_ID=""

  echo ""
  echo "[$((i+1))/${COUNT}] Creating incident: ${TITLE}"

  case "$PLATFORM" in
    pagerduty)
      TOKEN=$(az keyvault secret show --vault-name "$KEYVAULT" --name "pagerduty-api-token-${ATTENDEE}" --query value -o tsv)

      RESPONSE=$(curl -s -X POST "https://api.pagerduty.com/incidents" \
        -H "Authorization: Token token=${TOKEN}" \
        -H "Content-Type: application/json" \
        -H "From: sre-workshop@example.com" \
        -d "{
          \"incident\": {
            \"type\": \"incident\",
            \"title\": \"${TITLE}\",
            \"service\": {\"id\": \"${SERVICE}\", \"type\": \"service_reference\"},
            \"urgency\": \"$([ \"$SEVERITY\" = \"P1\" ] || [ \"$SEVERITY\" = \"P2\" ] && echo high || echo low)\",
            \"body\": {\"type\": \"incident_body\", \"details\": \"${SCENARIO_DESC}\"}
          }
        }")
      INCIDENT_ID=$(echo "$RESPONSE" | jq -r '.incident.id // "unknown"')
      ;;

    servicenow)
      INSTANCE_URL=$(az keyvault secret show --vault-name "$KEYVAULT" --name "servicenow-instance-url-${ATTENDEE}" --query value -o tsv)
      USERNAME=$(az keyvault secret show --vault-name "$KEYVAULT" --name "servicenow-username-${ATTENDEE}" --query value -o tsv)
      PASSWORD=$(az keyvault secret show --vault-name "$KEYVAULT" --name "servicenow-password-${ATTENDEE}" --query value -o tsv)

      # Map severity to ServiceNow urgency/impact
      case "$SEVERITY" in
        P1) SN_URGENCY=1;; P2) SN_URGENCY=2;; P3) SN_URGENCY=3;; P4) SN_URGENCY=4;;
      esac

      RESPONSE=$(curl -s -X POST "${INSTANCE_URL}/api/now/table/incident" \
        -u "${USERNAME}:${PASSWORD}" \
        -H "Content-Type: application/json" \
        -d "{
          \"short_description\": \"${TITLE}\",
          \"description\": \"${SCENARIO_DESC}\",
          \"urgency\": \"${SN_URGENCY}\",
          \"impact\": \"${SN_URGENCY}\",
          \"category\": \"Software\",
          \"cmdb_ci\": \"${SERVICE}\",
          \"assignment_group\": \"SRE-Workshop-Team\"
        }")
      INCIDENT_ID=$(echo "$RESPONSE" | jq -r '.result.number // "unknown"')
      ;;

    azure-monitor)
      RG="rg-srea-l300-${ATTENDEE}"
      # Map severity
      case "$SEVERITY" in
        P1) AZ_SEV=0;; P2) AZ_SEV=1;; P3) AZ_SEV=2;; P4) AZ_SEV=3;;
      esac

      ALERT_NAME="srea-test-${SEVERITY}-${i}-$(date +%H%M%S)"
      SUB_ID=$(az account show --query id -o tsv)

      az monitor scheduled-query create \
        --name "$ALERT_NAME" \
        --resource-group "$RG" \
        --scopes "/subscriptions/${SUB_ID}/resourceGroups/${RG}" \
        --condition "count > 0" \
        --condition-query "AzureActivity | where Level == 'Error' | take 1" \
        --window-size 5 \
        --evaluation-frequency 1 \
        --severity "$AZ_SEV" \
        --description "${TITLE} - ${SCENARIO_DESC}" \
        --tags workshop=srea-l300 attendee="$ATTENDEE" synthetic=true 2>/dev/null || true

      INCIDENT_ID="$ALERT_NAME"
      ;;
  esac

  echo "  ✓ Created: ${INCIDENT_ID} at ${TIMESTAMP}"

  # Append to JSON report
  COMMA=""
  if [[ $i -gt 0 ]]; then COMMA=","; fi
  cat >> "$REPORT_FILE" <<EOF
${COMMA}{
  "index": $((i+1)),
  "timestamp": "${TIMESTAMP}",
  "platform": "${PLATFORM}",
  "severity": "${SEVERITY}",
  "title": "${TITLE}",
  "incidentId": "${INCIDENT_ID}",
  "service": "${SERVICE}"
}
EOF

  if [[ $i -lt $((COUNT-1)) ]]; then
    echo "  Waiting ${RATE}s..."
    sleep "$RATE"
  fi
done

echo "]" >> "$REPORT_FILE"

echo ""
echo "============================================================"
echo "END-TO-END INCIDENT REPORT"
echo "============================================================"
echo "Platform:  ${PLATFORM}"
echo "Total:     ${COUNT} incidents"
echo "Severity:  ${SEVERITY}"
echo "Prefix:    ${PREFIX}"
echo ""
jq -r '.[] | "  [\(.index)] \(.incidentId) | \(.timestamp) | \(.severity) | \(.title)"' "$REPORT_FILE"
echo ""
echo "  Report saved: ${REPORT_FILE}"
echo "============================================================"
