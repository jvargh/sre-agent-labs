<#
.SYNOPSIS
    Synthetic Incident Generator — SRE Agent L300 Workshop (D11)
.DESCRIPTION
    Generates synthetic incidents for PagerDuty, ServiceNow, or Azure Monitor.
    All incidents use [TEST] prefix. Emits end-to-end report for capstone scorer.
.PARAMETER Platform
    Incident platform: pagerduty | servicenow | azure-monitor
.PARAMETER Severity
    Incident severity: P1 | P2 | P3 | P4
.PARAMETER Service
    Impacted service name (default: srea-l300-sample-app)
.PARAMETER Count
    Number of incidents to generate (default: 1)
.PARAMETER Rate
    Delay in seconds between incidents (default: 5)
.PARAMETER Prefix
    Incident title prefix (default: [TEST])
.PARAMETER KeyVaultName
    Key Vault name for credential retrieval
.PARAMETER AttendeeHandle
    Attendee handle for credential lookup
.EXAMPLE
    ./generate-incidents.ps1 -Platform pagerduty -Severity P1 -Count 3 -KeyVaultName "kv-srea-xxx" -AttendeeHandle "jdoe"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('pagerduty', 'servicenow', 'azure-monitor')]
    [string]$Platform,

    [Parameter()]
    [ValidateSet('P1', 'P2', 'P3', 'P4')]
    [string]$Severity = 'P2',

    [Parameter()]
    [string]$Service = 'srea-l300-sample-app',

    [Parameter()]
    [int]$Count = 1,

    [Parameter()]
    [int]$Rate = 5,

    [Parameter()]
    [string]$Prefix = '[TEST]',

    [Parameter()]
    [string]$KeyVaultName,

    [Parameter()]
    [string]$AttendeeHandle
)

$ErrorActionPreference = 'Stop'

# Severity mapping
$severityMap = @{
    'P1' = @{ pagerduty = 'critical'; servicenow = '1'; azuremonitor = '0' }
    'P2' = @{ pagerduty = 'error';    servicenow = '2'; azuremonitor = '1' }
    'P3' = @{ pagerduty = 'warning';  servicenow = '3'; azuremonitor = '2' }
    'P4' = @{ pagerduty = 'info';     servicenow = '4'; azuremonitor = '3' }
}

# Incident scenarios for capstone (Lab 13)
$scenarios = @(
    @{ Title = "high latency"; Description = "Response times exceeding 5s on /api/v1/orders endpoint. P99 latency at 12s. Possible database connection pool exhaustion." }
    @{ Title = "db corruption"; Description = "Data integrity check failed on orders table. Checksum mismatch detected. Possible write corruption during failover." }
    @{ Title = "api 500s"; Description = "HTTP 500 error rate at 45% on /api/v1/users endpoint. Stack traces show NullPointerException in AuthHandler." }
    @{ Title = "memory leak"; Description = "Container memory usage at 95%. OOMKill events detected. Heap dump shows unreleased connection objects." }
    @{ Title = "certificate expiry"; Description = "TLS certificate expires in 2 hours. Downstream services reporting SSL handshake failures." }
    @{ Title = "deployment rollback"; Description = "Canary deployment showing 3x error rate vs baseline. Automated rollback triggered but stuck." }
)

$report = @()

Write-Host "============================================================"
Write-Host "Synthetic Incident Generator — SRE Agent L300 Workshop"
Write-Host "  Platform: $Platform"
Write-Host "  Severity: $Severity"
Write-Host "  Service:  $Service"
Write-Host "  Count:    $Count"
Write-Host "  Rate:     ${Rate}s between incidents"
Write-Host "  Prefix:   $Prefix"
Write-Host "============================================================"

for ($i = 0; $i -lt $Count; $i++) {
    $scenario = $scenarios[$i % $scenarios.Count]
    $title = "$Prefix $Severity $($scenario.Title)"
    $description = $scenario.Description
    $timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    $incidentId = $null

    Write-Host "`n[$($i+1)/$Count] Creating incident: $title"

    switch ($Platform) {
        'pagerduty' {
            # Retrieve API token from Key Vault (NEVER inline)
            $token = az keyvault secret show --vault-name $KeyVaultName --name "pagerduty-api-token-$AttendeeHandle" --query value -o tsv

            $body = @{
                incident = @{
                    type = 'incident'
                    title = $title
                    service = @{
                        id = $Service
                        type = 'service_reference'
                    }
                    urgency = if ($Severity -in @('P1','P2')) { 'high' } else { 'low' }
                    body = @{
                        type = 'incident_body'
                        details = $description
                    }
                }
            } | ConvertTo-Json -Depth 5

            $response = Invoke-RestMethod -Uri "https://api.pagerduty.com/incidents" `
                -Method Post `
                -Headers @{
                    'Authorization' = "Token token=$token"
                    'Content-Type' = 'application/json'
                    'From' = 'sre-workshop@example.com'
                } `
                -Body $body

            $incidentId = $response.incident.id
        }

        'servicenow' {
            $instanceUrl = az keyvault secret show --vault-name $KeyVaultName --name "servicenow-instance-url-$AttendeeHandle" --query value -o tsv
            $username = az keyvault secret show --vault-name $KeyVaultName --name "servicenow-username-$AttendeeHandle" --query value -o tsv
            $password = az keyvault secret show --vault-name $KeyVaultName --name "servicenow-password-$AttendeeHandle" --query value -o tsv

            $secPwd = ConvertTo-SecureString $password -AsPlainText -Force
            $cred = [PSCredential]::new($username, $secPwd)

            $body = @{
                short_description = $title
                description = $description
                urgency = $severityMap[$Severity].servicenow
                impact = $severityMap[$Severity].servicenow
                category = 'Software'
                cmdb_ci = $Service
                assignment_group = 'SRE-Workshop-Team'
            } | ConvertTo-Json

            $response = Invoke-RestMethod -Uri "$instanceUrl/api/now/table/incident" `
                -Method Post `
                -Credential $cred `
                -ContentType 'application/json' `
                -Body $body

            $incidentId = $response.result.number
        }

        'azure-monitor' {
            $RG = "rg-srea-l300-$AttendeeHandle"

            # Trigger via creating a test alert rule that fires immediately
            $alertBody = @{
                location = 'global'
                tags = @{
                    workshop = 'srea-l300'
                    attendee = $AttendeeHandle
                    synthetic = 'true'
                }
                properties = @{
                    description = "$title - $description"
                    severity = [int]$severityMap[$Severity].azuremonitor
                    enabled = $true
                    evaluationFrequency = 'PT1M'
                    windowSize = 'PT5M'
                    scopes = @(
                        "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG"
                    )
                    criteria = @{
                        allOf = @(@{
                            query = "AzureActivity | where Level == 'Error' | take 1"
                            timeAggregation = 'Count'
                            operator = 'GreaterThanOrEqual'
                            threshold = 0
                            resourceIdColumn = '_ResourceId'
                        })
                    }
                }
            } | ConvertTo-Json -Depth 10

            $alertName = "srea-test-$Severity-$($i)-$(Get-Date -Format 'HHmmss')"
            az monitor scheduled-query create `
                --name $alertName `
                --resource-group $RG `
                --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG" `
                --condition "count > 0" `
                --condition-query "AzureActivity | where Level == 'Error' | take 1" `
                --window-size 5 `
                --evaluation-frequency 1 `
                --severity $severityMap[$Severity].azuremonitor `
                --description "$title - $description" `
                --tags workshop=srea-l300 attendee=$AttendeeHandle synthetic=true 2>$null | Out-Null

            $incidentId = $alertName
        }
    }

    $entry = @{
        Index = $i + 1
        Timestamp = $timestamp
        Platform = $Platform
        Severity = $Severity
        Title = $title
        IncidentId = $incidentId
        Service = $Service
    }
    $report += $entry

    Write-Host "  ✓ Created: $incidentId at $timestamp"

    if ($i -lt ($Count - 1)) {
        Write-Host "  Waiting ${Rate}s..."
        Start-Sleep -Seconds $Rate
    }
}

# ---- End-to-end report for capstone scorer (Lab 13) ----
Write-Host "`n============================================================"
Write-Host "END-TO-END INCIDENT REPORT"
Write-Host "============================================================"
Write-Host "Platform:  $Platform"
Write-Host "Total:     $Count incidents"
Write-Host "Severity:  $Severity"
Write-Host "Prefix:    $Prefix"
Write-Host ""

$report | ForEach-Object {
    Write-Host "  [$($_.Index)] $($_.IncidentId) | $($_.Timestamp) | $($_.Severity) | $($_.Title)"
}

# Export report as JSON for machine consumption
$reportPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "incident-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$report | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding utf8
Write-Host "`n  Report saved: $reportPath"
Write-Host "============================================================"
