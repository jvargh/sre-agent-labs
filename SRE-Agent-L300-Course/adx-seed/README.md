# ADX Seed Data — SRE Agent L300 Workshop (D9)

> **Reference:** [SREA-Level300.md §M5](../../SREA-Level300.md#m5--custom-tools-i-kusto--link)

## Overview

Pre-seeded Azure Data Explorer (Kusto) database with synthetic telemetry for the workshop's Kusto tools lab (M5). Provides ≥10,000 rows across three tables with 50+ distinct error patterns.

## Tables

### AppEvents
Application-level telemetry events (page views, API calls, background jobs, health checks).

| Column | Type | Description |
|--------|------|-------------|
| Timestamp | datetime | Event timestamp (UTC) |
| EventId | string | Unique event identifier |
| EventType | string | PageView, ApiCall, BackgroundJob, HealthCheck, Deployment, ConfigChange |
| ServiceName | string | Originating service name |
| Environment | string | production, staging |
| Severity | string | Info, Warning, Error, Critical |
| Message | string | Human-readable event description |
| Component | string | Application component |
| UserId | string | User identifier |
| SessionId | string | Session identifier |
| CorrelationId | string | Cross-service correlation ID |
| Duration | real | Duration in milliseconds |
| Properties | dynamic | Additional key-value properties |

### Errors
Error and exception events with stack traces.

| Column | Type | Description |
|--------|------|-------------|
| Timestamp | datetime | Error timestamp (UTC) |
| ErrorId | string | Unique error identifier |
| ErrorType | string | Exception class name (50+ distinct patterns) |
| ErrorMessage | string | Error description |
| StackTrace | string | Call stack |
| ServiceName | string | Originating service |
| Component | string | Application component |
| Severity | string | Error, Critical |
| Environment | string | production, staging |
| CorrelationId | string | Cross-service correlation ID |
| UserId | string | User identifier |
| HttpStatusCode | int | HTTP status code |
| RetryCount | int | Number of retry attempts |
| Properties | dynamic | Additional properties |

### Requests
HTTP request telemetry with latency and size metrics.

| Column | Type | Description |
|--------|------|-------------|
| Timestamp | datetime | Request timestamp (UTC) |
| RequestId | string | Unique request identifier |
| Method | string | GET, POST, PUT, DELETE, PATCH |
| Url | string | Request URL path |
| StatusCode | int | HTTP response status |
| Duration | real | Duration in milliseconds |
| ServiceName | string | Handling service |
| Component | string | Application component |
| Environment | string | production, staging |
| UserId | string | User identifier |
| SessionId | string | Session identifier |
| CorrelationId | string | Cross-service correlation ID |
| RequestSize | long | Request body size (bytes) |
| ResponseSize | long | Response body size (bytes) |
| ClientIp | string | Client IP address |
| UserAgent | string | Client user agent |
| Properties | dynamic | Additional properties |

## Data Characteristics

- **Total rows:** ≥12,003 (5,000 AppEvents + 3,003 Errors + 4,000 Requests)
- **Time range:** 30 days trailing from load time
- **Distinct error patterns:** 55 (exceeds 50 minimum)
- **NullPointerException in last 24h:** Exactly 3 events (M5 demo requirement)
- **Deterministic:** Seeded RNG (seed=42) ensures identical data across runs
- **Idempotent:** Re-running the loader skips if ≥10k rows exist (use `-Force` to re-ingest)

## Usage

### Prerequisites

- Azure CLI with Kusto extension
- ADX cluster URL from sandbox provisioning
- UAMI Client ID and Tenant ID

### Load Data

```powershell
./load-data.ps1 `
  -AdxClusterUrl "https://<cluster>.eastus2.kusto.windows.net" `
  -UamiClientId "<uami-client-id>" `
  -TenantId "<tenant-id>"
```

### Force Reload

```powershell
./load-data.ps1 `
  -AdxClusterUrl "https://<cluster>.eastus2.kusto.windows.net" `
  -UamiClientId "<uami-client-id>" `
  -TenantId "<tenant-id>" `
  -Force
```

### Verify Data

```kql
// Count rows per table
AppEvents | count
Errors | count
Requests | count

// Verify NullPointerException events in last 24h (should return 3)
Errors
| where Timestamp > ago(24h)
| where ErrorType == 'NullPointerException'
| count

// Verify distinct error patterns (should be ≥50)
Errors | distinct ErrorType | count

// M5 demo query: errors from last 24h about NullPointerException
Errors
| where Timestamp > ago(24h)
| where ErrorType has 'NullPointerException'
| project Timestamp, ErrorType, ErrorMessage, ServiceName, Component, Severity
| order by Timestamp desc
| take 100
```

### UAMI Access Grant

The loader automatically grants `AllDatabasesViewer` to the agent's UAMI. To do it manually:

```kql
.add database SREWorkshopDB viewers ('aadapp=<UAMI_CLIENT_ID>;<TENANT_ID>')
```

This command is idempotent — re-running does not error.
