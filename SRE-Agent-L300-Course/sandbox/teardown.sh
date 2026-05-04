#!/usr/bin/env bash
# =============================================================================
# SRE Agent L300/400 Workshop — Per-attendee sandbox teardown (D1)
# Usage: ./teardown.sh <attendee-handle>
# Removes the per-attendee RG; keeps shared infrastructure.
# =============================================================================
set -euo pipefail

ATTENDEE="${1:?Usage: ./teardown.sh <attendee-handle>}"
RG_NAME="rg-srea-l300-${ATTENDEE}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "SRE Agent L300 Workshop — Tearing down sandbox"
echo "  Attendee: ${ATTENDEE}"
echo "  RG:       ${RG_NAME}"
echo "============================================================"

# ---- Verify RG exists and has correct tags ----------------------------------
if ! az group show --name "$RG_NAME" &>/dev/null; then
  echo "  ✗ Resource group ${RG_NAME} does not exist — nothing to tear down."
  exit 0
fi

TAG=$(az group show --name "$RG_NAME" --query "tags.workshop" -o tsv 2>/dev/null || echo "")
if [[ "$TAG" != "srea-l300" ]]; then
  echo "  ✗ Resource group ${RG_NAME} does not have workshop=srea-l300 tag — refusing to delete."
  exit 1
fi

# ---- Delete RG (async for speed) -------------------------------------------
echo "[1/2] Deleting resource group ${RG_NAME}..."
az group delete --name "$RG_NAME" --yes --no-wait
echo "  ✓ Deletion initiated (async)"

# ---- Clean up local credentials file ----------------------------------------
echo "[2/2] Removing local credentials file..."
CREDS_FILE="${SCRIPT_DIR}/credentials-${ATTENDEE}.env"
if [[ -f "$CREDS_FILE" ]]; then
  rm -f "$CREDS_FILE"
  echo "  ✓ Removed ${CREDS_FILE}"
else
  echo "  (no credentials file found)"
fi

echo "============================================================"
echo "  ✓ Teardown initiated for ${ATTENDEE}"
echo "  Note: RG deletion is async — may take a few minutes."
echo "  Shared infrastructure is preserved."
echo "============================================================"
