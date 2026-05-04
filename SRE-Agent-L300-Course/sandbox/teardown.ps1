<#
.SYNOPSIS
    SRE Agent L300/400 Workshop — Per-attendee sandbox teardown (D1)
.DESCRIPTION
    Removes the per-attendee resource group. Keeps shared infrastructure.
.PARAMETER AttendeeHandle
    Attendee GitHub handle or alias.
.EXAMPLE
    ./teardown.ps1 -AttendeeHandle "jdoe"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$AttendeeHandle
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RgName = "rg-srea-l300-$AttendeeHandle"

Write-Host "============================================================"
Write-Host "SRE Agent L300 Workshop - Tearing down sandbox"
Write-Host "  Attendee: $AttendeeHandle"
Write-Host "  RG:       $RgName"
Write-Host "============================================================"

# ---- Verify RG exists ----
$rgExists = az group show --name $RgName 2>$null
if (-not $rgExists) {
    Write-Host "  ✗ Resource group $RgName does not exist - nothing to tear down."
    return
}

$tag = az group show --name $RgName --query "tags.workshop" -o tsv 2>$null
if ($tag -ne 'srea-l300') {
    Write-Host "  ✗ Resource group $RgName does not have workshop=srea-l300 tag - refusing to delete."
    exit 1
}

# ---- Delete RG (async) ----
Write-Host "[1/2] Deleting resource group $RgName..."
az group delete --name $RgName --yes --no-wait
Write-Host "  ✓ Deletion initiated (async)"

# ---- Clean up credentials file ----
Write-Host "[2/2] Removing local credentials file..."
$credsFile = Join-Path $ScriptDir "credentials-$AttendeeHandle.env"
if (Test-Path $credsFile) {
    Remove-Item $credsFile -Force
    Write-Host "  ✓ Removed $credsFile"
} else {
    Write-Host "  (no credentials file found)"
}

Write-Host "============================================================"
Write-Host "  ✓ Teardown initiated for $AttendeeHandle"
Write-Host "  Note: RG deletion is async - may take a few minutes."
Write-Host "  Shared infrastructure is preserved."
Write-Host "============================================================"
