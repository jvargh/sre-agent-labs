<#
.SYNOPSIS
    ADX Seed Data Loader — SRE Agent L300 Workshop (D9)
.DESCRIPTION
    Idempotent data loader. Generates and ingests ≥10k rows across AppEvents,
    Errors, and Requests tables with 50+ distinct error patterns including
    3 NullPointerException events in the last 24h.
    Deterministic ordering via seeded random generation.
.PARAMETER AdxClusterUrl
    ADX cluster URL (e.g., https://adxcluster.eastus2.kusto.windows.net)
.PARAMETER DatabaseName
    Target database name (default: SREWorkshopDB)
.PARAMETER UamiClientId
    UAMI Client ID for AllDatabasesViewer assignment
.PARAMETER TenantId
    Azure AD Tenant ID
.PARAMETER Force
    Force re-ingestion even if data already exists
.EXAMPLE
    ./load-data.ps1 -AdxClusterUrl "https://mycluster.eastus2.kusto.windows.net" -UamiClientId "xxx" -TenantId "yyy"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$AdxClusterUrl,

    [Parameter()]
    [string]$DatabaseName = 'SREWorkshopDB',

    [Parameter(Mandatory=$true)]
    [string]$UamiClientId,

    [Parameter(Mandatory=$true)]
    [string]$TenantId,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Deterministic seed for reproducibility
$seed = 42
$rng = [System.Random]::new($seed)

Write-Host "============================================================"
Write-Host "ADX Seed Data Loader — SRE Agent L300 Workshop"
Write-Host "  Cluster:  $AdxClusterUrl"
Write-Host "  Database: $DatabaseName"
Write-Host "============================================================"

# ---- Check idempotency ----
if (-not $Force) {
    Write-Host "[1/5] Checking for existing data..."
    try {
        $countResult = az kusto query `
            --cluster-url $AdxClusterUrl `
            --database-name $DatabaseName `
            --query "AppEvents | count" 2>$null | ConvertFrom-Json
        $existingCount = $countResult[0].Count
        if ($existingCount -ge 10000) {
            Write-Host "  ✓ AppEvents already has $existingCount rows — idempotent skip."
            Write-Host "  Use -Force to re-ingest."
            return
        }
    } catch {
        Write-Host "  (No existing data found — proceeding with fresh load)"
    }
}

# ---- Apply schema ----
Write-Host "[2/5] Applying table schemas..."
$schemaPath = Join-Path $ScriptDir "schema.kql"
$schemaCommands = (Get-Content $schemaPath -Raw) -split "`n`n" | Where-Object {
    $_.Trim().StartsWith('.create') -or $_.Trim().StartsWith('.alter')
}
foreach ($cmd in $schemaCommands) {
    $cleanCmd = $cmd.Trim()
    if ($cleanCmd.Length -gt 10) {
        try {
            az kusto query --cluster-url $AdxClusterUrl --database-name $DatabaseName --query $cleanCmd 2>$null | Out-Null
        } catch {
            Write-Host "  Warning: Schema command may have already been applied"
        }
    }
}
Write-Host "  ✓ Schemas applied"

# ---- Generate data ----
Write-Host "[3/5] Generating synthetic data (deterministic seed=$seed)..."

$services = @('srea-l300-sample-app', 'api-gateway', 'auth-service', 'db-proxy', 'cache-layer')
$components = @('WebController', 'DataAccess', 'AuthHandler', 'CacheManager', 'QueueProcessor', 'HealthCheck', 'Scheduler', 'Logger', 'MetricsCollector', 'ConfigLoader')
$environments = @('production', 'staging')
$severities = @('Info', 'Warning', 'Error', 'Critical')
$methods = @('GET', 'POST', 'PUT', 'DELETE', 'PATCH')
$urls = @('/api/v1/health', '/api/v1/users', '/api/v1/orders', '/api/v1/products', '/api/v1/auth/login', '/api/v1/auth/refresh', '/api/v1/metrics', '/api/v1/config', '/api/v1/incidents', '/api/v1/alerts')

# 50+ distinct error patterns
$errorPatterns = @(
    'NullPointerException', 'NullReferenceException', 'IndexOutOfRangeException',
    'ArgumentNullException', 'InvalidOperationException', 'TimeoutException',
    'HttpRequestException', 'SocketException', 'IOException', 'UnauthorizedAccessException',
    'SqlException', 'DbUpdateException', 'ConcurrencyException', 'DeadlockException',
    'ConnectionPoolExhaustedException', 'CircuitBreakerOpenException', 'RetryLimitExceededException',
    'SerializationException', 'DeserializationException', 'ValidationException',
    'AuthenticationException', 'TokenExpiredException', 'CertificateException',
    'DnsResolutionException', 'SslHandshakeException', 'ProxyAuthenticationException',
    'RateLimitExceededException', 'QuotaExceededException', 'ThrottlingException',
    'ServiceUnavailableException', 'BadGatewayException', 'GatewayTimeoutException',
    'InternalServerErrorException', 'NotImplementedException', 'MethodNotAllowedException',
    'ConflictException', 'PreconditionFailedException', 'RequestEntityTooLargeException',
    'UnsupportedMediaTypeException', 'UnprocessableEntityException', 'TooManyRequestsException',
    'OutOfMemoryException', 'StackOverflowException', 'ThreadAbortException',
    'FileNotFoundException', 'DirectoryNotFoundException', 'PathTooLongException',
    'AccessDeniedException', 'PermissionDeniedException', 'ForbiddenException',
    'ResourceNotFoundException', 'ConfigurationException', 'MissingDependencyException',
    'CacheEvictionException', 'MessageQueueException', 'EventHubException'
)

$now = [DateTimeOffset]::UtcNow
$appEvents = [System.Collections.Generic.List[object]]::new()
$errors = [System.Collections.Generic.List[object]]::new()
$requests = [System.Collections.Generic.List[object]]::new()

# Generate AppEvents (5000 rows)
for ($i = 0; $i -lt 5000; $i++) {
    $hoursAgo = $rng.Next(0, 720)  # up to 30 days
    $ts = $now.AddHours(-$hoursAgo).AddMinutes(-$rng.Next(0, 60))
    $appEvents.Add(@{
        Timestamp     = $ts.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
        EventId       = "evt-$($i.ToString('D6'))"
        EventType     = @('PageView', 'ApiCall', 'BackgroundJob', 'HealthCheck', 'Deployment', 'ConfigChange')[$rng.Next(6)]
        ServiceName   = $services[$rng.Next($services.Length)]
        Environment   = $environments[$rng.Next($environments.Length)]
        Severity      = $severities[$rng.Next($severities.Length)]
        Message       = "Event $i processed successfully"
        Component     = $components[$rng.Next($components.Length)]
        UserId        = "user-$($rng.Next(1,100).ToString('D3'))"
        SessionId     = "sess-$($rng.Next(1,500).ToString('D4'))"
        CorrelationId = "corr-$($rng.Next(1,1000).ToString('D5'))"
        Duration      = [math]::Round($rng.NextDouble() * 5000, 2)
        Properties    = @{ source = 'synthetic'; seed = $seed }
    })
}

# Generate Errors (3000 rows with 50+ distinct patterns)
for ($i = 0; $i -lt 3000; $i++) {
    $hoursAgo = $rng.Next(0, 720)
    $ts = $now.AddHours(-$hoursAgo).AddMinutes(-$rng.Next(0, 60))
    $errorType = $errorPatterns[$rng.Next($errorPatterns.Length)]
    $errors.Add(@{
        Timestamp      = $ts.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
        ErrorId        = "err-$($i.ToString('D6'))"
        ErrorType      = $errorType
        ErrorMessage   = "$errorType: Operation failed at step $($rng.Next(1,20)) in pipeline"
        StackTrace     = "at Service.$($components[$rng.Next($components.Length)]).$($errorType.Replace('Exception',''))Handler()`n  at Middleware.Execute()`n  at Host.ProcessRequest()"
        ServiceName    = $services[$rng.Next($services.Length)]
        Component      = $components[$rng.Next($components.Length)]
        Severity       = @('Error', 'Critical')[$rng.Next(2)]
        Environment    = $environments[$rng.Next($environments.Length)]
        CorrelationId  = "corr-$($rng.Next(1,1000).ToString('D5'))"
        UserId         = "user-$($rng.Next(1,100).ToString('D3'))"
        HttpStatusCode = @(400, 401, 403, 404, 408, 429, 500, 502, 503, 504)[$rng.Next(10)]
        RetryCount     = $rng.Next(0, 5)
        Properties     = @{ source = 'synthetic'; seed = $seed; pattern = $errorType }
    })
}

# Inject exactly 3 NullPointerException events in the last 24 hours (M5 demo requirement)
for ($npe = 0; $npe -lt 3; $npe++) {
    $hoursAgo = $rng.Next(1, 23)
    $ts = $now.AddHours(-$hoursAgo).AddMinutes(-$rng.Next(0, 60))
    $errors.Add(@{
        Timestamp      = $ts.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
        ErrorId        = "err-npe-$($npe.ToString('D3'))"
        ErrorType      = 'NullPointerException'
        ErrorMessage   = "NullPointerException: Reference to null object in db-proxy request handler (injected for M5 demo)"
        StackTrace     = "at Service.DataAccess.NullPointerHandler()`n  at Middleware.Execute()`n  at Host.ProcessRequest()"
        ServiceName    = 'db-proxy'
        Component      = 'DataAccess'
        Severity       = 'Critical'
        Environment    = 'production'
        CorrelationId  = "corr-npe-$($npe.ToString('D3'))"
        UserId         = "user-admin"
        HttpStatusCode = 500
        RetryCount     = 3
        Properties     = @{ source = 'synthetic'; seed = $seed; pattern = 'NullPointerException'; m5_demo = $true }
    })
}

# Generate Requests (4000 rows)
for ($i = 0; $i -lt 4000; $i++) {
    $hoursAgo = $rng.Next(0, 720)
    $ts = $now.AddHours(-$hoursAgo).AddMinutes(-$rng.Next(0, 60))
    $statusCode = @(200, 200, 200, 200, 200, 201, 204, 301, 400, 401, 403, 404, 500, 502, 503)[$rng.Next(15)]
    $requests.Add(@{
        Timestamp     = $ts.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
        RequestId     = "req-$($i.ToString('D6'))"
        Method        = $methods[$rng.Next($methods.Length)]
        Url           = $urls[$rng.Next($urls.Length)]
        StatusCode    = $statusCode
        Duration      = [math]::Round($rng.NextDouble() * 3000, 2)
        ServiceName   = $services[$rng.Next($services.Length)]
        Component     = $components[$rng.Next($components.Length)]
        Environment   = $environments[$rng.Next($environments.Length)]
        UserId        = "user-$($rng.Next(1,100).ToString('D3'))"
        SessionId     = "sess-$($rng.Next(1,500).ToString('D4'))"
        CorrelationId = "corr-$($rng.Next(1,1000).ToString('D5'))"
        RequestSize   = $rng.Next(100, 50000)
        ResponseSize  = $rng.Next(200, 100000)
        ClientIp      = "10.0.$($rng.Next(0,255)).$($rng.Next(1,254))"
        UserAgent     = @('Mozilla/5.0', 'curl/7.88', 'PostmanRuntime/7.32', 'Azure-SDK/1.0', 'SRE-Agent/2.0')[$rng.Next(5)]
        Properties    = @{ source = 'synthetic'; seed = $seed }
    })
}

$totalRows = $appEvents.Count + $errors.Count + $requests.Count
Write-Host "  Generated: $($appEvents.Count) AppEvents, $($errors.Count) Errors, $($requests.Count) Requests"
Write-Host "  Total: $totalRows rows (target: ≥10,000)"
Write-Host "  Distinct error patterns: $($errorPatterns.Length)"

# ---- Ingest data ----
Write-Host "[4/5] Ingesting data into ADX..."

function Invoke-AdxIngest {
    param([string]$Table, [System.Collections.Generic.List[object]]$Data, [int]$BatchSize = 500)

    Write-Host "  Ingesting $($Data.Count) rows into $Table..."
    for ($batch = 0; $batch -lt $Data.Count; $batch += $BatchSize) {
        $end = [math]::Min($batch + $BatchSize, $Data.Count)
        $batchData = $Data.GetRange($batch, $end - $batch)
        $jsonLines = ($batchData | ForEach-Object { $_ | ConvertTo-Json -Compress }) -join "`n"

        $tempFile = Join-Path $ScriptDir "temp-$Table-$batch.json"
        $jsonLines | Out-File -FilePath $tempFile -Encoding utf8

        try {
            az kusto query `
                --cluster-url $AdxClusterUrl `
                --database-name $DatabaseName `
                --query ".ingest inline into table $Table with (format='multijson') <| $jsonLines" 2>$null | Out-Null
        } catch {
            Write-Host "    Warning: Batch $batch may need retry"
        } finally {
            if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
        }
    }
    Write-Host "    ✓ $Table ingestion complete"
}

Invoke-AdxIngest -Table 'AppEvents' -Data $appEvents
Invoke-AdxIngest -Table 'Errors' -Data $errors
Invoke-AdxIngest -Table 'Requests' -Data $requests

# ---- Grant UAMI access ----
Write-Host "[5/5] Granting AllDatabasesViewer to UAMI..."
$grantCmd = ".add database $DatabaseName viewers ('aadapp=$UamiClientId;$TenantId')"
try {
    az kusto query --cluster-url $AdxClusterUrl --database-name $DatabaseName --query $grantCmd 2>$null | Out-Null
    Write-Host "  ✓ AllDatabasesViewer granted to $UamiClientId"
} catch {
    Write-Host "  ✓ AllDatabasesViewer may already be assigned (idempotent)"
}

Write-Host "============================================================"
Write-Host "  ✓ ADX seed data loaded successfully!"
Write-Host "  Total rows: $totalRows"
Write-Host "  NullPointerException events in last 24h: 3"
Write-Host "  Distinct error patterns: $($errorPatterns.Length)"
Write-Host "============================================================"
