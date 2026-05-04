#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# deploy.sh — SRE Agent L200 Workshop sandbox deployment (Bash)
# Same functionality as deploy.ps1 for Linux/Mac trainers.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Defaults ─────────────────────────────────────────────────
WORKSHOP_PREFIX="sre-workshop"
SHARED_RG="rg-sre-workshop-shared"

# ─── Usage ────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $0 -a <aliases> -l <location> -s <subscription-id> [-p <prefix>] [-g <shared-rg>]

  -a  Comma-separated attendee aliases (e.g., "alice,bob,charlie")
  -l  Azure region (swedencentral | eastus2 | australiaeast)
  -s  Azure subscription ID
  -p  Workshop prefix (default: sre-workshop)
  -g  Shared resource group name (default: rg-sre-workshop-shared)

Example:
  $0 -a "alice,bob" -l swedencentral -s 00000000-0000-0000-0000-000000000000
EOF
    exit 1
}

# ─── Parse arguments ──────────────────────────────────────────
ALIASES_CSV=""
LOCATION=""
SUBSCRIPTION_ID=""

while getopts "a:l:s:p:g:h" opt; do
    case $opt in
        a) ALIASES_CSV="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        s) SUBSCRIPTION_ID="$OPTARG" ;;
        p) WORKSHOP_PREFIX="$OPTARG" ;;
        g) SHARED_RG="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[[ -z "$ALIASES_CSV" || -z "$LOCATION" || -z "$SUBSCRIPTION_ID" ]] && usage

# Validate region
if [[ "$LOCATION" != "swedencentral" && "$LOCATION" != "eastus2" && "$LOCATION" != "australiaeast" ]]; then
    echo "[ERROR] Invalid region '$LOCATION'. Must be one of: swedencentral, eastus2, australiaeast." >&2
    exit 1
fi

# Convert CSV to JSON array
IFS=',' read -ra ALIAS_ARRAY <<< "$ALIASES_CSV"
ALIASES_JSON=$(printf '%s\n' "${ALIAS_ARRAY[@]}" | jq -R . | jq -sc .)
ATTENDEE_COUNT=${#ALIAS_ARRAY[@]}

step()  { echo -e "\n\033[36m>> $1\033[0m"; }
ok()    { echo -e "   \033[32m[OK]\033[0m $1"; }
warn()  { echo -e "   \033[33m[WARN]\033[0m $1"; }
err()   { echo -e "   \033[31m[ERROR]\033[0m $1"; }

# ─── Pre-flight: Set subscription ─────────────────────────────
step "Setting active subscription to $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"
ok "Subscription set."

# ─── Pre-flight: Register Microsoft.App ───────────────────────
step "Registering Microsoft.App resource provider"
az provider register --namespace "Microsoft.App" --wait 2>/dev/null || true
PROVIDER_STATE=$(az provider show --namespace "Microsoft.App" --query "registrationState" -o tsv)
if [[ "$PROVIDER_STATE" != "Registered" ]]; then
    warn "Microsoft.App state is '$PROVIDER_STATE'. Waiting up to 120s..."
    ELAPSED=0
    while [[ "$PROVIDER_STATE" != "Registered" && $ELAPSED -lt 120 ]]; do
        sleep 10; ELAPSED=$((ELAPSED + 10))
        PROVIDER_STATE=$(az provider show --namespace "Microsoft.App" --query "registrationState" -o tsv)
    done
    if [[ "$PROVIDER_STATE" != "Registered" ]]; then
        err "Microsoft.App failed to register within 120s. Current state: $PROVIDER_STATE"
        exit 1
    fi
fi
ok "Microsoft.App is Registered."

# ─── Pre-flight: Quota check ─────────────────────────────────
step "Checking Microsoft.App/containerApps quota in $LOCATION"
if az quota show --resource-name "ContainerApps" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.App/locations/$LOCATION" \
    -o json 2>/dev/null; then
    ok "Quota query succeeded (review output above)."
else
    warn "Quota check skipped (az quota extension may not be installed). Proceeding."
fi

# ─── Deploy Bicep ─────────────────────────────────────────────
step "Deploying Bicep template at subscription scope ($ATTENDEE_COUNT attendee(s))"
DEPLOYMENT_NAME="sre-workshop-$(date +%Y%m%d-%H%M%S)"
BICEP_PATH="$SCRIPT_DIR/bicep/main.bicep"

DEPLOY_OUTPUT=$(az deployment sub create \
    --name "$DEPLOYMENT_NAME" \
    --location "$LOCATION" \
    --template-file "$BICEP_PATH" \
    --parameters attendeeAliases="$ALIASES_JSON" \
                 location="$LOCATION" \
                 sharedResourceGroupName="$SHARED_RG" \
                 workshopPrefix="$WORKSHOP_PREFIX" \
    --query "properties.outputs" \
    -o json)

if [[ $? -ne 0 ]]; then
    err "Deployment failed. Check the Azure Portal for details: deployment name = $DEPLOYMENT_NAME"
    exit 1
fi
ok "Deployment '$DEPLOYMENT_NAME' succeeded."

# ─── Generate per-attendee credential files ───────────────────
step "Generating attendee credential files"
CREDS_DIR="$SCRIPT_DIR/attendee-credentials"
mkdir -p "$CREDS_DIR"

for alias in "${ALIAS_ARRAY[@]}"; do
    alias=$(echo "$alias" | xargs)  # trim whitespace
    RG="rg-sre-agent-${alias}"
    CA_URL=$(echo "$DEPLOY_OUTPUT" | jq -r ".attendeeSummary.value[] | select(.alias==\"$alias\") | .containerAppUrl")
    AI_CONN=$(echo "$DEPLOY_OUTPUT" | jq -r ".attendeeSummary.value[] | select(.alias==\"$alias\") | .appInsightsConnectionString")
    LAW_ID=$(echo "$DEPLOY_OUTPUT" | jq -r ".attendeeSummary.value[] | select(.alias==\"$alias\") | .lawWorkspaceId")

    cat > "$CREDS_DIR/${alias}.txt" <<CRED
╔══════════════════════════════════════════════════════════════╗
║  SRE Agent L200 Workshop — Attendee Credentials             ║
║  Attendee: ${alias}
╚══════════════════════════════════════════════════════════════╝

Resource Group:        ${RG}
SRE Agent Portal:      https://sre.azure.com
Container App URL:     ${CA_URL}
App Insights Conn Str: ${AI_CONN}
Log Analytics ID:      ${LAW_ID}

──────────────────────────────────────────────────────────────
 Lab guide: Follow the trainer's instructions for Labs A–E.
 Support:   Raise your hand or post in the workshop chat.
──────────────────────────────────────────────────────────────
CRED
    ok "Created $CREDS_DIR/${alias}.txt"
done

# ─── Summary Table ────────────────────────────────────────────
step "Deployment Summary"
echo ""
printf "%-12s %-28s %-50s\n" "Alias" "Resource Group" "Container App URL"
printf "%-12s %-28s %-50s\n" "-----" "--------------" "-----------------"
echo "$DEPLOY_OUTPUT" | jq -r '.attendeeSummary.value[] | "\(.alias)\t\(.resourceGroup)\t\(.containerAppUrl)"' | \
    while IFS=$'\t' read -r a rg url; do
        printf "%-12s %-28s %-50s\n" "$a" "$rg" "$url"
    done
echo ""
echo -e "\033[36mShared RG:  $SHARED_RG\033[0m"
SHARED_LAW_ID=$(echo "$DEPLOY_OUTPUT" | jq -r '.sharedLawId.value')
echo -e "\033[36mShared LAW: $SHARED_LAW_ID\033[0m"
echo ""
ok "Workshop sandbox deployed. Distribute files from attendee-credentials/ to each attendee."
