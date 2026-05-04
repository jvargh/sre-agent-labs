#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# teardown.sh — SRE Agent L200 Workshop sandbox teardown (Bash)
# Same functionality as teardown.ps1 for Linux/Mac trainers.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Defaults ─────────────────────────────────────────────────
KEEP_SHARED=true
SHARED_RG="rg-sre-workshop-shared"
FORCE=false

# ─── Usage ────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $0 -a <aliases> -s <subscription-id> [-g <shared-rg>] [--delete-shared] [--force]

  -a  Comma-separated attendee aliases (e.g., "alice,bob,charlie")
  -s  Azure subscription ID
  -g  Shared resource group name (default: rg-sre-workshop-shared)
  --delete-shared  Also delete the shared resource group
  --force          Skip confirmation prompt

Example:
  $0 -a "alice,bob" -s 00000000-0000-0000-0000-000000000000 --force
EOF
    exit 1
}

# ─── Parse arguments ──────────────────────────────────────────
ALIASES_CSV=""
SUBSCRIPTION_ID=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a) ALIASES_CSV="$2"; shift 2 ;;
        -s) SUBSCRIPTION_ID="$2"; shift 2 ;;
        -g) SHARED_RG="$2"; shift 2 ;;
        --delete-shared) KEEP_SHARED=false; shift ;;
        --force) FORCE=true; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

[[ -z "$ALIASES_CSV" || -z "$SUBSCRIPTION_ID" ]] && usage

IFS=',' read -ra ALIAS_ARRAY <<< "$ALIASES_CSV"

step()  { echo -e "\n\033[36m>> $1\033[0m"; }
ok()    { echo -e "   \033[32m[OK]\033[0m $1"; }
warn()  { echo -e "   \033[33m[WARN]\033[0m $1"; }

# ─── Confirmation ─────────────────────────────────────────────
echo ""
echo -e "\033[31mThe following resource groups will be DELETED:\033[0m"
for alias in "${ALIAS_ARRAY[@]}"; do
    alias=$(echo "$alias" | xargs)
    echo -e "  \033[33m- rg-sre-agent-${alias}\033[0m"
done
if [[ "$KEEP_SHARED" == "false" ]]; then
    echo -e "  \033[33m- $SHARED_RG\033[0m"
else
    echo -e "\n  \033[32m(Shared RG '$SHARED_RG' will be KEPT)\033[0m"
fi

if [[ "$FORCE" != "true" ]]; then
    echo ""
    read -rp "Type 'yes' to confirm deletion: " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# ─── Set subscription ────────────────────────────────────────
step "Setting active subscription to $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"

# ─── Delete per-attendee resource groups ──────────────────────
DELETED=()
FAILED=()

for alias in "${ALIAS_ARRAY[@]}"; do
    alias=$(echo "$alias" | xargs)
    RG_NAME="rg-sre-agent-${alias}"
    step "Deleting resource group: $RG_NAME"

    EXISTS=$(az group exists --name "$RG_NAME" -o tsv)
    if [[ "$EXISTS" == "true" ]]; then
        if az group delete --name "$RG_NAME" --yes --no-wait; then
            ok "Deletion initiated for $RG_NAME (async)."
            DELETED+=("$RG_NAME")
        else
            warn "Failed to delete $RG_NAME."
            FAILED+=("$RG_NAME")
        fi
    else
        warn "$RG_NAME does not exist. Skipping."
    fi
done

# ─── Optionally delete shared RG ─────────────────────────────
if [[ "$KEEP_SHARED" == "false" ]]; then
    step "Deleting shared resource group: $SHARED_RG"
    EXISTS=$(az group exists --name "$SHARED_RG" -o tsv)
    if [[ "$EXISTS" == "true" ]]; then
        if az group delete --name "$SHARED_RG" --yes --no-wait; then
            ok "Deletion initiated for $SHARED_RG (async)."
            DELETED+=("$SHARED_RG")
        else
            warn "Failed to delete $SHARED_RG."
            FAILED+=("$SHARED_RG")
        fi
    fi
fi

# ─── Clean up credential files ────────────────────────────────
CREDS_DIR="$SCRIPT_DIR/attendee-credentials"
if [[ -d "$CREDS_DIR" ]]; then
    for alias in "${ALIAS_ARRAY[@]}"; do
        alias=$(echo "$alias" | xargs)
        CRED_FILE="$CREDS_DIR/${alias}.txt"
        if [[ -f "$CRED_FILE" ]]; then
            rm -f "$CRED_FILE"
            ok "Removed $CRED_FILE"
        fi
    done
fi

# ─── Summary ──────────────────────────────────────────────────
step "Teardown Summary"
echo ""
if [[ ${#DELETED[@]} -gt 0 ]]; then
    echo -e "\033[32mDeleted (async):\033[0m"
    for rg in "${DELETED[@]}"; do echo "  - $rg"; done
fi
if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo -e "\033[31mFailed:\033[0m"
    for rg in "${FAILED[@]}"; do echo "  - $rg"; done
fi
if [[ "$KEEP_SHARED" == "true" ]]; then
    echo -e "\n\033[36mShared RG '$SHARED_RG' was retained.\033[0m"
fi
echo ""
ok "Teardown complete. Resource group deletions are running asynchronously."
echo "   Use 'az group list --tag workshop=sre-agent -o table' to verify."
