<#
.SYNOPSIS
    Tears down the SRE Agent L200 Workshop sandbox environment.

.DESCRIPTION
    Deletes per-attendee resource groups. Optionally retains the shared
    resource group (default: keep). Requires confirmation unless -Force is used.

.PARAMETER AttendeeAliases
    Array of attendee alias strings (e.g., @("alice","bob","charlie")).

.PARAMETER SubscriptionId
    Target Azure subscription ID.

.PARAMETER KeepShared
    Switch to keep the shared resource group. Default: $true.

.PARAMETER Force
    Skip confirmation prompt.

.EXAMPLE
    .\teardown.ps1 -AttendeeAliases @("alice","bob") -SubscriptionId "00000000-..." -Force
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$AttendeeAliases,

    [Parameter(Mandatory)]
    [string]$SubscriptionId,

    [switch]$KeepShared = $true,

    [string]$SharedResourceGroupName = "rg-sre-workshop-shared",

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Step { param([string]$Message) Write-Host "`n>> $Message" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Message) Write-Host "   [OK] $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "   [WARN] $Message" -ForegroundColor Yellow }

# ─── Confirmation ─────────────────────────────────────────────
$rgList = $AttendeeAliases | ForEach-Object { "rg-sre-agent-$_" }
if (-not $KeepShared) { $rgList += $SharedResourceGroupName }

Write-Host "`nThe following resource groups will be DELETED:" -ForegroundColor Red
$rgList | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
if ($KeepShared) {
    Write-Host "`n  (Shared RG '$SharedResourceGroupName' will be KEPT)" -ForegroundColor Green
}

if (-not $Force) {
    $confirm = Read-Host "`nType 'yes' to confirm deletion"
    if ($confirm -ne "yes") {
        Write-Host "Aborted." -ForegroundColor Yellow
        exit 0
    }
}

# ─── Set subscription ────────────────────────────────────────
Write-Step "Setting active subscription to $SubscriptionId"
az account set --subscription $SubscriptionId

# ─── Delete per-attendee resource groups ──────────────────────
$deleted = @()
$failed  = @()

foreach ($alias in $AttendeeAliases) {
    $rgName = "rg-sre-agent-$alias"
    Write-Step "Deleting resource group: $rgName"

    $exists = az group exists --name $rgName -o tsv
    if ($exists -eq "true") {
        az group delete --name $rgName --yes --no-wait
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Deletion initiated for $rgName (async)."
            $deleted += $rgName
        } else {
            Write-Warn "Failed to delete $rgName."
            $failed += $rgName
        }
    } else {
        Write-Warn "$rgName does not exist. Skipping."
    }
}

# ─── Optionally delete shared RG ─────────────────────────────
if (-not $KeepShared) {
    Write-Step "Deleting shared resource group: $SharedResourceGroupName"
    $exists = az group exists --name $SharedResourceGroupName -o tsv
    if ($exists -eq "true") {
        az group delete --name $SharedResourceGroupName --yes --no-wait
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Deletion initiated for $SharedResourceGroupName (async)."
            $deleted += $SharedResourceGroupName
        } else {
            Write-Warn "Failed to delete $SharedResourceGroupName."
            $failed += $SharedResourceGroupName
        }
    }
}

# ─── Clean up credential files ────────────────────────────────
$credsDir = Join-Path $PSScriptRoot "attendee-credentials"
if (Test-Path $credsDir) {
    foreach ($alias in $AttendeeAliases) {
        $credFile = Join-Path $credsDir "$alias.txt"
        if (Test-Path $credFile) { Remove-Item $credFile -Force; Write-Ok "Removed $credFile" }
    }
}

# ─── Summary ──────────────────────────────────────────────────
Write-Step "Teardown Summary"
Write-Host ""
if ($deleted.Count -gt 0) {
    Write-Host "Deleted (async):" -ForegroundColor Green
    $deleted | ForEach-Object { Write-Host "  - $_" }
}
if ($failed.Count -gt 0) {
    Write-Host "Failed:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  - $_" }
}
if ($KeepShared) {
    Write-Host "`nShared RG '$SharedResourceGroupName' was retained." -ForegroundColor Cyan
}
Write-Host ""
Write-Ok "Teardown complete. Resource group deletions are running asynchronously."
Write-Host "   Use 'az group list --tag workshop=sre-agent -o table' to verify." -ForegroundColor DarkGray
