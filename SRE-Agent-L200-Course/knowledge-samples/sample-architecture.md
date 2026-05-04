# Contoso Payments — Container App Architecture

> **Last updated:** 2026-04-15
> **Owner:** Platform Engineering — Contoso Payments Team
> **Classification:** Internal

---

## Overview

Contoso Payments is a containerized payment-processing service running on **Azure Container Apps**. It handles transaction authorization, settlement, and webhook delivery for Contoso's e-commerce platform.

---

## Resource Inventory

| Resource | Name | Resource Group | Region |
|----------|------|----------------|--------|
| Container App | `contoso-payments-app` | `rg-contoso-payments` | East US 2 |
| Container App Environment | `contoso-payments-env` | `rg-contoso-payments` | East US 2 |
| Application Insights | `contoso-payments-ai` | `rg-contoso-payments` | East US 2 |
| Log Analytics Workspace | `contoso-payments-law` | `rg-contoso-payments` | East US 2 |
| Azure Container Registry | `contosopaymentsacr` | `rg-contoso-payments` | East US 2 |
| Azure Key Vault | `contoso-payments-kv` | `rg-contoso-payments` | East US 2 |

---

## Container App Configuration

- **Image:** `contosopaymentsacr.azurecr.io/payments-api:latest`
- **CPU:** 0.5 vCPU
- **Memory:** 1.0 Gi
- **Min replicas:** 1
- **Max replicas:** 10
- **Ingress:** External, port 443 (TLS termination at environment level)

### Scaling Rules

| Rule | Type | Trigger |
|------|------|---------|
| HTTP scaling | HTTP | 100 concurrent requests per replica |
| Queue scaling | Azure Queue | 50 messages in `payments-queue` |

### Environment Variables

| Name | Source |
|------|--------|
| `APPINSIGHTS_CONNECTION_STRING` | Key Vault reference (`contoso-payments-kv`) |
| `DATABASE_URL` | Key Vault reference (`contoso-payments-kv`) |
| `QUEUE_CONNECTION` | Key Vault reference (`contoso-payments-kv`) |

---

## Health Endpoints

| Endpoint | Path | Expected Response | Interval |
|----------|------|-------------------|----------|
| Liveness probe | `/healthz` | HTTP 200 | 10 seconds |
| Readiness probe | `/ready` | HTTP 200 | 5 seconds |
| Startup probe | `/healthz` | HTTP 200 | 1 second (max 30 retries) |

---

## Dependencies

| Dependency | Type | Notes |
|------------|------|-------|
| Azure SQL Database | Data store | Primary transaction database (`contoso-payments-sql.database.windows.net`) |
| Azure Queue Storage | Messaging | Settlement queue (`payments-queue` in `contosopaymentssa`) |
| Azure Key Vault | Secrets | All connection strings and API keys stored here |
| External Payment Gateway | HTTP API | `https://api.paymentgateway.example.com/v2` — timeout 30s |

---

## Observability

- **Application Insights** (`contoso-payments-ai`) collects traces, requests, exceptions, and custom metrics.
- **Log Analytics Workspace** (`contoso-payments-law`) receives:
  - Container App system logs (`ContainerAppSystemLogs_CL`)
  - Container App console logs (`ContainerAppConsoleLogs_CL`)
  - Application Insights data (linked workspace)
- **Alerts configured:**
  - HTTP 5xx rate > 5% over 5 minutes → PagerDuty + `#oncall-payments` Teams channel
  - P95 latency > 2 seconds over 10 minutes → email to on-call
  - Container restart count > 3 in 15 minutes → PagerDuty

---

## Deployment

- **CI/CD:** GitHub Actions → build image → push to ACR → `az containerapp update`
- **Revision mode:** Single active revision (traffic 100% on latest)
- **Rollback:** Re-deploy previous image tag from ACR
