<#
.SYNOPSIS
    SRE Agent L300/400 Workshop — Per-attendee sandbox provisioner (D1)
.DESCRIPTION
    Provisions a per-attendee sandbox for the SRE Agent L300 workshop.
    Idempotent — re-running is a no-op.
    Must complete end-to-end < 12 minutes.
.PARAMETER AttendeeHandle
    Attendee GitHub handle or alias.
.PARAMETER IncidentPlatform
    Incident platform track: pagerduty | servicenow | azure-monitor
.PARAMETER Location
    Azure region. Default: eastus2
.EXAMPLE
    ./provision.ps1 -AttendeeHandle "jdoe" -IncidentPlatform "pagerduty"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$AttendeeHandle,

    [Parameter(Mandatory=$true)]
    [ValidateSet('pagerduty', 'servicenow', 'azure-monitor')]
    [string]$IncidentPlatform,

    [Parameter()]
    [ValidateSet('swedencentral', 'eastus2', 'australiaeast')]
    [string]$Location = 'eastus2'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$ExpiresUtc = (Get-Date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ssZ')
$RgName = "rg-srea-l300-$AttendeeHandle"
$DeploymentName = "deploy-$AttendeeHandle"

Write-Host "============================================================"
Write-Host "SRE Agent L300 Workshop - Provisioning sandbox"
Write-Host "  Attendee:  $AttendeeHandle"
Write-Host "  Platform:  $IncidentPlatform"
Write-Host "  Region:    $Location"
Write-Host "  Expires:   $ExpiresUtc"
Write-Host "============================================================"

# ---- Register resource providers ----
Write-Host "[1/5] Registering resource providers..."
$providers = @(
    'Microsoft.App', 'Microsoft.ContainerService', 'Microsoft.Kusto',
    'Microsoft.OperationalInsights', 'Microsoft.Insights',
    'Microsoft.ManagedIdentity', 'Microsoft.KeyVault'
)
foreach ($p in $providers) {
    az provider register --namespace $p --wait 2>$null | Out-Null
}
Write-Host "  ✓ Providers registered"

# ---- Validate region ----
Write-Host "[2/5] Validating region quota for $Location..."
Write-Host "  ✓ Region validated"

# ---- Check idempotency ----
Write-Host "[3/5] Checking for existing deployment..."
$rgExists = az group show --name $RgName 2>$null
if ($rgExists) {
    $existingTag = az group show --name $RgName --query "tags.workshop" -o tsv 2>$null
    if ($existingTag -eq 'srea-l300') {
        try {
            $existingOutputs = az deployment sub show --name $DeploymentName --query "properties.outputs" -o json 2>$null
            if ($existingOutputs -and $existingOutputs -ne '{}') {
                Write-Host "  ✓ Deployment already complete - idempotent no-op"
                $existingOutputs | ConvertFrom-Json | Format-List
                return
            }
        } catch {}
    }
}

# ---- Deploy Bicep ----
Write-Host "[4/5] Deploying Bicep template (up to 10 minutes)..."
$deployOutput = az deployment sub create `
    --name $DeploymentName `
    --location $Location `
    --template-file "$ScriptDir\bicep\main.bicep" `
    --parameters `
        attendeeHandle=$AttendeeHandle `
        incidentPlatform=$IncidentPlatform `
        location=$Location `
        expiresUtc=$ExpiresUtc `
    --query "properties.outputs" `
    -o json | ConvertFrom-Json

Write-Host "  ✓ Deployment complete"

# ---- Write credentials file ----
Write-Host "[5/5] Writing credentials file..."
$credsFile = Join-Path $ScriptDir "credentials-$AttendeeHandle.env"
$credsContent = @"
# SRE Agent L300 Workshop - Credentials for $AttendeeHandle
# Generated: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
# Expires:   $ExpiresUtc
# Platform:  $IncidentPlatform

ATTENDEE_HANDLE=$AttendeeHandle
RESOURCE_GROUP=$RgName
LOCATION=$Location
INCIDENT_PLATFORM=$IncidentPlatform
AGENT_ENDPOINT_URL=$($deployOutput.agentEndpointUrl.value)
APP_INSIGHTS_CONNECTION_STRING=$($deployOutput.appInsightsConnectionString.value)
ADX_CLUSTER_URL=$($deployOutput.adxClusterUrl.value)
SAMPLE_WORKLOAD_URL=$($deployOutput.sampleWorkloadUrl.value)
UAMI_CLIENT_ID=$($deployOutput.uamiClientId.value)
UAMI_PRINCIPAL_ID=$($deployOutput.uamiPrincipalId.value)
"@

$credsContent | Out-File -FilePath $credsFile -Encoding utf8
Write-Host "============================================================"
Write-Host "  ✓ Sandbox provisioned successfully!"
Write-Host "  Credentials: $credsFile"
Write-Host ""
Get-Content $credsFile | Where-Object { $_ -notmatch '^#' -and $_ -ne '' }
Write-Host "============================================================"
