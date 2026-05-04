<#
.SYNOPSIS
    PowerShell module for Azure SRE Agent REST API v2.
.DESCRIPTION
    Wraps PUT /api/v2/extendedAgent/agents/{agentName} for managing custom agents + hooks.
    Supports Export, Put, and Diff operations.
.PARAMETER Action
    The operation to perform: Export, Put, or Diff.
.PARAMETER AgentName
    The name of the custom agent.
.PARAMETER YamlPath
    Path to the YAML file (required for Put and Diff actions).
.PARAMETER BaseUrl
    The SRE Agent API base URL.
.PARAMETER OutputPath
    Output path for Export action (defaults to ./{AgentName}.agent.yaml).
.EXAMPLE
    ./Invoke-SREAgentApi.ps1 -Action Export -AgentName "incident_triager"
.EXAMPLE
    ./Invoke-SREAgentApi.ps1 -Action Put -AgentName "incident_triager" -YamlPath ./incident-triager.agent.yaml
.EXAMPLE
    ./Invoke-SREAgentApi.ps1 -Action Diff -AgentName "incident_triager" -YamlPath ./incident-triager.agent.yaml
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Export', 'Put', 'Diff')]
    [string]$Action,

    [Parameter(Mandatory)]
    [string]$AgentName,

    [string]$YamlPath,

    [string]$BaseUrl = $env:SRE_AGENT_API_URL,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Authentication — acquire a bearer token via Azure CLI
# ---------------------------------------------------------------------------
function Get-AccessToken {
    $tokenJson = az account get-access-token --resource "https://management.azure.com" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to acquire access token. Run 'az login' first. Error: $tokenJson"
    }
    return ($tokenJson | ConvertFrom-Json).accessToken
}

# ---------------------------------------------------------------------------
# API Helpers
# ---------------------------------------------------------------------------
function Get-ApiHeaders {
    $token = Get-AccessToken
    return @{
        'Authorization' = "Bearer $token"
        'Content-Type'  = 'application/yaml'
        'Accept'        = 'application/yaml'
    }
}

function Get-AgentUrl {
    param([string]$Name)
    if (-not $BaseUrl) {
        throw "BaseUrl is required. Set SRE_AGENT_API_URL environment variable or pass -BaseUrl."
    }
    return "$($BaseUrl.TrimEnd('/'))/api/v2/extendedAgent/agents/$Name"
}

# ---------------------------------------------------------------------------
# Export: GET the current agent config as YAML
# ---------------------------------------------------------------------------
function Invoke-Export {
    $url = Get-AgentUrl -Name $AgentName
    $headers = Get-ApiHeaders

    Write-Host "Exporting agent '$AgentName' from $url ..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

    $outFile = if ($OutputPath) { $OutputPath } else { "./$AgentName.agent.yaml" }
    $response | Out-File -FilePath $outFile -Encoding utf8
    Write-Host "Exported to $outFile" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Put: PUT the YAML config to create/update the agent
# ---------------------------------------------------------------------------
function Invoke-Put {
    if (-not $YamlPath -or -not (Test-Path $YamlPath)) {
        throw "YamlPath is required and must exist for Put action."
    }

    $url = Get-AgentUrl -Name $AgentName
    $headers = Get-ApiHeaders
    $body = Get-Content -Path $YamlPath -Raw

    Write-Host "Pushing agent '$AgentName' to $url ..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body
    Write-Host "Push complete. Response: $($response | ConvertTo-Json -Depth 5)" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Diff: Compare local YAML against the running agent
# ---------------------------------------------------------------------------
function Invoke-Diff {
    if (-not $YamlPath -or -not (Test-Path $YamlPath)) {
        throw "YamlPath is required and must exist for Diff action."
    }

    $url = Get-AgentUrl -Name $AgentName
    $headers = Get-ApiHeaders

    Write-Host "Fetching remote agent '$AgentName' ..." -ForegroundColor Cyan
    $remote = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    $local = Get-Content -Path $YamlPath -Raw

    $remoteNormalized = ($remote -split "`n" | ForEach-Object { $_.TrimEnd() }) -join "`n"
    $localNormalized  = ($local  -split "`n" | ForEach-Object { $_.TrimEnd() }) -join "`n"

    if ($remoteNormalized -eq $localNormalized) {
        Write-Host "No drift detected." -ForegroundColor Green
    }
    else {
        Write-Host "Drift detected! Differences:" -ForegroundColor Yellow
        # Simple line-by-line diff
        $remoteLines = $remoteNormalized -split "`n"
        $localLines  = $localNormalized  -split "`n"
        $maxLines = [Math]::Max($remoteLines.Count, $localLines.Count)
        for ($i = 0; $i -lt $maxLines; $i++) {
            $r = if ($i -lt $remoteLines.Count) { $remoteLines[$i] } else { '' }
            $l = if ($i -lt $localLines.Count)  { $localLines[$i]  } else { '' }
            if ($r -ne $l) {
                Write-Host "  Line $($i+1):" -ForegroundColor Red
                Write-Host "    Remote: $r" -ForegroundColor Red
                Write-Host "    Local:  $l" -ForegroundColor Yellow
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
switch ($Action) {
    'Export' { Invoke-Export }
    'Put'    { Invoke-Put }
    'Diff'   { Invoke-Diff }
}
