#!/usr/bin/env bash
# =============================================================================
# SRE Agent L300/400 Workshop — Per-attendee sandbox provisioner (D1)
# Usage: ./provision.sh <attendee-handle> <incident-platform>
#   incident-platform: pagerduty | servicenow | azure-monitor
# Idempotent — re-running is a no-op.
# Must complete end-to-end < 12 minutes.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- Args ------------------------------------------------------------------
ATTENDEE="${1:?Usage: ./provision.sh <attendee-handle> <incident-platform>}"
PLATFORM="${2:?Usage: ./provision.sh <attendee-handle> <incident-platform>}"

if [[ ! "$PLATFORM" =~ ^(pagerduty|servicenow|azure-monitor)$ ]]; then
  echo "ERROR: incident-platform must be one of: pagerduty, servicenow, azure-monitor"
  exit 1
fi

LOCATION="${SREA_LOCATION:-eastus2}"
EXPIRES_UTC=$(date -u -d "+1 day" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v+1d '+%Y-%m-%dT%H:%M:%SZ')
RG_NAME="rg-srea-l300-${ATTENDEE}"
DEPLOYMENT_NAME="deploy-${ATTENDEE}-$(date +%s)"

echo "============================================================"
echo "SRE Agent L300 Workshop — Provisioning sandbox"
echo "  Attendee:  ${ATTENDEE}"
echo "  Platform:  ${PLATFORM}"
echo "  Region:    ${LOCATION}"
echo "  Expires:   ${EXPIRES_UTC}"
echo "============================================================"

# ---- Pre-flight: register resource providers --------------------------------
echo "[1/5] Registering resource providers..."
for provider in Microsoft.App Microsoft.ContainerService Microsoft.Kusto Microsoft.OperationalInsights Microsoft.Insights Microsoft.ManagedIdentity Microsoft.KeyVault; do
  az provider register --namespace "$provider" --wait 2>/dev/null || true
done
echo "  ✓ Providers registered"

# ---- Pre-flight: validate region quota --------------------------------------
echo "[2/5] Validating region quota for ${LOCATION}..."
VALID_REGIONS=("swedencentral" "eastus2" "australiaeast")
REGION_VALID=false
for r in "${VALID_REGIONS[@]}"; do
  if [[ "$LOCATION" == "$r" ]]; then
    REGION_VALID=true
    break
  fi
done
if [[ "$REGION_VALID" != "true" ]]; then
  echo "ERROR: Region ${LOCATION} not in allowed list: ${VALID_REGIONS[*]}"
  exit 1
fi
echo "  ✓ Region validated"

# ---- Check idempotency ------------------------------------------------------
echo "[3/5] Checking for existing deployment..."
if az group show --name "$RG_NAME" &>/dev/null; then
  EXISTING_TAG=$(az group show --name "$RG_NAME" --query "tags.workshop" -o tsv 2>/dev/null || echo "")
  if [[ "$EXISTING_TAG" == "srea-l300" ]]; then
    echo "  ✓ Resource group ${RG_NAME} already exists with correct tags — verifying resources..."
    EXISTING_OUTPUTS=$(az deployment sub show \
      --name "deploy-${ATTENDEE}" \
      --query "properties.outputs" -o json 2>/dev/null || echo "{}")
    if [[ "$EXISTING_OUTPUTS" != "{}" && "$EXISTING_OUTPUTS" != "" ]]; then
      echo "  ✓ Deployment already complete — idempotent no-op"
      echo "$EXISTING_OUTPUTS" | jq -r 'to_entries[] | "  \(.key): \(.value.value)"'
      exit 0
    fi
  fi
fi

# ---- Deploy Bicep -----------------------------------------------------------
echo "[4/5] Deploying Bicep template (this may take up to 10 minutes)..."
DEPLOY_OUTPUT=$(az deployment sub create \
  --name "deploy-${ATTENDEE}" \
  --location "$LOCATION" \
  --template-file "${SCRIPT_DIR}/bicep/main.bicep" \
  --parameters \
    attendeeHandle="$ATTENDEE" \
    incidentPlatform="$PLATFORM" \
    location="$LOCATION" \
    expiresUtc="$EXPIRES_UTC" \
  --query "properties.outputs" \
  -o json)

echo "  ✓ Deployment complete"

# ---- Output credentials file ------------------------------------------------
echo "[5/5] Writing credentials file..."
CREDS_FILE="${SCRIPT_DIR}/credentials-${ATTENDEE}.env"
cat > "$CREDS_FILE" <<EOF
# SRE Agent L300 Workshop — Credentials for ${ATTENDEE}
# Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')
# Expires:   ${EXPIRES_UTC}
# Platform:  ${PLATFORM}

ATTENDEE_HANDLE=${ATTENDEE}
RESOURCE_GROUP=${RG_NAME}
LOCATION=${LOCATION}
INCIDENT_PLATFORM=${PLATFORM}
AGENT_ENDPOINT_URL=$(echo "$DEPLOY_OUTPUT" | jq -r '.agentEndpointUrl.value')
APP_INSIGHTS_CONNECTION_STRING=$(echo "$DEPLOY_OUTPUT" | jq -r '.appInsightsConnectionString.value')
ADX_CLUSTER_URL=$(echo "$DEPLOY_OUTPUT" | jq -r '.adxClusterUrl.value')
SAMPLE_WORKLOAD_URL=$(echo "$DEPLOY_OUTPUT" | jq -r '.sampleWorkloadUrl.value')
UAMI_CLIENT_ID=$(echo "$DEPLOY_OUTPUT" | jq -r '.uamiClientId.value')
UAMI_PRINCIPAL_ID=$(echo "$DEPLOY_OUTPUT" | jq -r '.uamiPrincipalId.value')
EOF

echo "============================================================"
echo "  ✓ Sandbox provisioned successfully!"
echo "  Credentials: ${CREDS_FILE}"
echo ""
cat "$CREDS_FILE" | grep -v "^#"
echo "============================================================"
