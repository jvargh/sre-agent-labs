<#
.SYNOPSIS
    Deploys the SRE Agent L200 Workshop sandbox environment.

.DESCRIPTION
    Registers providers, validates quota, deploys Bicep templates at subscription scope,
    and generates per-attendee credential files for workshop distribution.

.PARAMETER AttendeeAliases
    Array of attendee alias strings (e.g., @("alice","bob","charlie")).

.PARAMETER Location
    Azure region. Must be one of: swedencentral, eastus2, australiaeast.

.PARAMETER SubscriptionId
    Target Azure subscription ID.

.PARAMETER WorkshopPrefix
    Prefix for shared resource naming. Default: "sre-workshop".

.PARAMETER SharedResourceGroupName
    Name of the shared resource group. Default: "rg-sre-workshop-shared".

.EXAMPLE
    .\deploy.ps1 -AttendeeAliases @("alice","bob") -Location swedencentral -SubscriptionId "00000000-0000-0000-0000-000000000000"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$AttendeeAliases,

    [Parameter(Mandatory)]
    [ValidateSet("swedencentral", "eastus2", "australiaeast")]
    [string]$Location,

    [Parameter(Mandatory)]
    [string]$SubscriptionId,

    [string]$WorkshopPrefix = "sre-workshop",

    [string]$SharedResourceGroupName = "rg-sre-workshop-shared"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# ─── Helpers ──────────────────────────────────────────────────
function Write-Step { param([string]$Message) Write-Host "`n>> $Message" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Message) Write-Host "   [OK] $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "   [WARN] $Message" -ForegroundColor Yellow }
function Write-Err  { param([string]$Message) Write-Host "   [ERROR] $Message" -ForegroundColor Red }

# ─── Pre-flight: Set subscription ─────────────────────────────
Write-Step "Setting active subscription to $SubscriptionId"
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) { Write-Err "Failed to set subscription. Ensure you are logged in (az login)."; exit 1 }
Write-Ok "Subscription set."

# ─── Pre-flight: Register Microsoft.App provider ──────────────
Write-Step "Registering Microsoft.App resource provider"
az provider register --namespace "Microsoft.App" --wait 2>$null
$providerState = az provider show --namespace "Microsoft.App" --query "registrationState" -o tsv
if ($providerState -ne "Registered") {
    Write-Warn "Microsoft.App state is '$providerState'. Waiting up to 120s..."
    $timeout = 120; $elapsed = 0
    while ($providerState -ne "Registered" -and $elapsed -lt $timeout) {
        Start-Sleep -Seconds 10; $elapsed += 10
        $providerState = az provider show --namespace "Microsoft.App" --query "registrationState" -o tsv
    }
    if ($providerState -ne "Registered") {
        Write-Err "Microsoft.App failed to register within ${timeout}s. Current state: $providerState"
        exit 1
    }
}
Write-Ok "Microsoft.App is Registered."

# ─── Pre-flight: Validate region quota ───────────────────────
Write-Step "Checking Microsoft.App/containerApps quota in $Location"
try {
    $quotaJson = az quota show --resource-name "ContainerApps" --scope "/subscriptions/$SubscriptionId/providers/Microsoft.App/locations/$Location" 2>$null
    if ($quotaJson) {
        $quota = $quotaJson | ConvertFrom-Json
        $limit = $quota.properties.limit.value
        $currentUsage = $quota.properties.usages.value
        $required = $AttendeeAliases.Count
        if (($limit - $currentUsage) -lt $required) {
            Write-Warn "Quota may be tight: $currentUsage/$limit used, need $required more Container Apps."
        } else {
            Write-Ok "Quota check passed ($currentUsage/$limit used, deploying $required)."
        }
    } else {
        Write-Warn "Could not query quota (az quota extension may not be installed). Proceeding with deployment."
    }
} catch {
    Write-Warn "Quota check skipped: $($_.Exception.Message). Proceeding."
}

# ─── Deploy Bicep ─────────────────────────────────────────────
Write-Step "Deploying Bicep template at subscription scope ($($AttendeeAliases.Count) attendee(s))"

$aliasesJson = ($AttendeeAliases | ConvertTo-Json -Compress)
$deploymentName = "sre-workshop-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$bicepPath = Join-Path $PSScriptRoot "bicep" "main.bicep"

$deployOutput = az deployment sub create `
    --name $deploymentName `
    --location $Location `
    --template-file $bicepPath `
    --parameters attendeeAliases=$aliasesJson `
                 location=$Location `
                 sharedResourceGroupName=$SharedResourceGroupName `
                 workshopPrefix=$WorkshopPrefix `
    --query "properties.outputs" `
    -o json

if ($LASTEXITCODE -ne 0) {
    Write-Err "Deployment failed. Check the Azure Portal for details: deployment name = $deploymentName"
    exit 1
}
Write-Ok "Deployment '$deploymentName' succeeded."

$outputs = $deployOutput | ConvertFrom-Json

# ─── Generate per-attendee credential files ───────────────────
Write-Step "Generating attendee credential files"
$credsDir = Join-Path $PSScriptRoot "attendee-credentials"
if (-not (Test-Path $credsDir)) { New-Item -ItemType Directory -Path $credsDir -Force | Out-Null }

foreach ($entry in $outputs.attendeeSummary.value) {
    $alias = $entry.alias
    $filePath = Join-Path $credsDir "$alias.txt"
    $content = @"
╔══════════════════════════════════════════════════════════════╗
║  SRE Agent L200 Workshop — Attendee Credentials             ║
║  Attendee: $alias
╚══════════════════════════════════════════════════════════════╝

Resource Group:        $($entry.resourceGroup)
SRE Agent Portal:      https://sre.azure.com
Container App URL:     $($entry.containerAppUrl)
App Insights Conn Str: $($entry.appInsightsConnectionString)
Log Analytics ID:      $($entry.lawWorkspaceId)

──────────────────────────────────────────────────────────────
 Lab guide: Follow the trainer's instructions for Labs A–E.
 Support:   Raise your hand or post in the workshop chat.
──────────────────────────────────────────────────────────────
"@
    Set-Content -Path $filePath -Value $content -Encoding UTF8
    Write-Ok "Created $filePath"
}

# ─── Summary Table ────────────────────────────────────────────
Write-Step "Deployment Summary"
Write-Host ""
Write-Host ("{0,-12} {1,-28} {2,-50}" -f "Alias", "Resource Group", "Container App URL") -ForegroundColor White
Write-Host ("{0,-12} {1,-28} {2,-50}" -f "-----", "--------------", "-----------------") -ForegroundColor DarkGray
foreach ($entry in $outputs.attendeeSummary.value) {
    Write-Host ("{0,-12} {1,-28} {2,-50}" -f $entry.alias, $entry.resourceGroup, $entry.containerAppUrl)
}
Write-Host ""
Write-Host "Shared RG:  $SharedResourceGroupName" -ForegroundColor Cyan
Write-Host "Shared LAW: $($outputs.sharedLawId.value)" -ForegroundColor Cyan
Write-Host ""
Write-Ok "Workshop sandbox deployed. Distribute files from attendee-credentials/ to each attendee."
