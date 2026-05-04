# Runbook: Restart Azure Container App (contoso-sample-app)

**Purpose:** Step-by-step guide to restart the `contoso-sample-app` (frontend or backend) running on Azure Container Apps. Used by SRE agents and operators to resolve performance, memory leak, or unresponsiveness issues.

**Audience:** SRE operators, on-call engineers, custom agents.

**Last Updated:** 2025-02-01  
**Owner:** Platform Engineering Team  
**Review Cadence:** Quarterly

---

## 1. When to Use This Runbook

### Symptoms Indicating Container Restart Is Needed

| Symptom | Indicator | Action |
|---------|-----------|--------|
| **High CPU** (> 85%) sustained > 10 min | Container process consuming all vCPU | Restart container (suspect memory leak or runaway loop) |
| **Memory leak** | Memory % growing over hours; no release | Restart container (new revision cleans up) |
| **Unresponsive API** | Timeouts on all endpoints; no crashes in logs | Restart container (may be deadlocked connection pool or event loop stall) |
| **High latency spike** (p95 suddenly > 2s) | Recent code deploy or dependency failure | Check dependencies first; restart only if no external cause found |
| **Container restart loop** (CrashLoopBackOff) | Repeated container exits within 30s | **Do not use this runbook.** Investigate logs; contact platform team. |
| **Scheduled maintenance** | Planned update or config change | Can use restart during maintenance window. |

### When NOT to Restart

- **Within 2 min of deployment:** Wait for health probes to stabilize.
- **During active incident investigation:** Restart loses in-memory diagnostics; capture logs/metrics first.
- **If previous restart within last 5 min:** Suggests systemic issue; escalate to platform team.

---

## 2. Prerequisites

### Required RBAC Permissions

Your identity must have **one** of the following roles on the resource group (`rg-sre-agent-workshop`) or subscription:

| Role | Required Permissions |
|------|----------------------|
| **Contributor** | Full permissions; allows restart |
| **Azure Container Apps Operator** | `Microsoft.App/containerApps/revisions/restart/action` ✓ |
| **Custom role** | At minimum: `Microsoft.App/containerApps/revisions/restart/action` |

**Check your permissions:**

```bash
# If you have Contributor or Container Apps Operator: ✓ You can proceed
az role assignment list --assignee $(az account show --query user.name -o tsv) --resource-group rg-sre-agent-workshop
```

If permission is denied during restart, contact the subscription owner or platform team.

### Service Health Check

Before restarting, verify Azure services are healthy:

```bash
# Check Container Apps service status (eastus region)
az rest --method GET \
  --url "https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.App/locations/eastus/operationStatuses" \
  --query "value[0].status"
  # Expected output: "Succeeded" (not "Failed" or "InProgress" with stalled deployment)
```

### DNS & Network Connectivity

Verify you can reach the Container App endpoint:

```bash
# Resolve DNS
nslookup contoso-sample-app.eastus.azurecontainerapps.io

# Test connectivity
curl -I https://contoso-sample-app.eastus.azurecontainerapps.io/health 2>/dev/null | grep -E "HTTP|200"
# Expected: HTTP/1.1 200 OK (or 503 Unavailable if restarting)
```

---

## 3. Pre-Restart Checklist

Complete this before proceeding:

- [ ] **Issue confirmed:** High CPU/memory/latency visible in Application Insights for ≥ 5 min
- [ ] **Dependencies checked:** Database, Key Vault, external APIs are responding (check dependency latency in App Insights)
- [ ] **Permissions verified:** You have `Microsoft.App/containerApps/revisions/restart/action` (or Contributor)
- [ ] **Logs captured:** Saved recent error/warning logs to shared drive for root-cause analysis (optional but recommended)
- [ ] **Incident ticket created:** Link to PagerDuty/ServiceNow incident (if applicable)
- [ ] **Stakeholders notified:** Informed team lead / on-call manager of planned restart

---

## 4. Step-by-Step Restart Procedure

### Step 1: Identify the Container App to Restart

**Scenario A: Restart frontend container**

```bash
# Set variables
export RESOURCE_GROUP="rg-sre-agent-workshop"
export APP_NAME="contoso-sample-app-frontend"
export LOCATION="eastus"

# Verify the container app exists and get current revision
az containerapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query "{Name: name, Status: properties.provisioningState, ActiveRevision: properties.latestRevisionName}"
```

**Expected output:**
```json
{
  "Name": "contoso-sample-app-frontend",
  "Status": "Succeeded",
  "ActiveRevision": "contoso-sample-app-frontend--active-20250201-1"
}
```

**Scenario B: Restart backend container**

```bash
export APP_NAME="contoso-sample-app-backend"
# (same command as above with different app name)
```

### Step 2: Capture Pre-Restart Metrics

Before restarting, collect diagnostic data for post-mortem:

```bash
# Get current resource metrics
az monitor metrics list-definitions \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.App/containerApps" \
  --resource $APP_NAME \
  --query "value[].name.value" -o table
  # Lists available metrics (CPU, Memory, Replicas, etc.)

# Example: Capture CPU % in last 15 min
az monitor metrics list \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.App/containerApps" \
  --resource $APP_NAME \
  --metric "EffectiveOutboundIPCount" \
  --start-time $(date -u -d '15 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --interval PT1M
```

**Alternative (faster): Use Azure Portal or Application Insights UI**
- Navigate to Container Apps → contoso-sample-app-frontend → Metrics
- Note: CPU %, Memory %, Replica count for the last 15 min
- Screenshot or export to CSV

### Step 3: Identify the Active Revision

```bash
# List all revisions for the container app
az containerapp revision list \
  --resource-group $RESOURCE_GROUP \
  --container-app $APP_NAME \
  --query "[].{Name: name, Status: status, Active: trafficWeight}" -o table
```

**Expected output:**
```
Name                                    Status    Active
────────────────────────────────────    ────────  ──────
contoso-sample-app-frontend--xxxxxxxxxx  Active    100
contoso-sample-app-frontend--yyyyyyyyy    Inactive  0
```

The revision with `Active` = `True` (or `100` traffic weight) is the one being restarted.

### Step 4: Restart the Active Revision

```bash
# Get the active revision name (one-liner)
ACTIVE_REVISION=$(az containerapp revision list \
  --resource-group $RESOURCE_GROUP \
  --container-app $APP_NAME \
  --query "max_by(properties.createdTime).name" -o tsv)

echo "Restarting revision: $ACTIVE_REVISION"

# Restart the revision (creates new pods)
az containerapp revision restart \
  --resource-group $RESOURCE_GROUP \
  --revision $ACTIVE_REVISION

# Expected output:
# Command ran successfully with no output (exit code 0)
```

**What happens internally:**
1. Azure receives restart request.
2. Old pod(s) receive SIGTERM signal (graceful shutdown, 30s timeout).
3. New pod(s) are created with same configuration.
4. Load balancer shifts traffic to new pod(s) as they pass health checks.
5. Old pod terminated after graceful shutdown period.

### Step 5: Monitor Restart Progress

**Option A: Watch restart in real-time (CLI polling)**

```bash
# Poll container app status every 5 seconds (press Ctrl+C to stop)
while true; do
  echo "=== $(date) ==="
  az containerapp show \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --query "{Replicas: properties.runningReplicas, Provisioning: properties.provisioningState, LatestRevision: properties.latestRevisionName}" -o table
  sleep 5
done
```

**Option B: Monitor in Azure Portal**
1. Navigate to Container Apps → contoso-sample-app-frontend → Revisions.
2. Watch replica count: should drop to 0, then increase back to configured count (2 for workshop).
3. Check "Status" column: should show `Running` once restart completes.

**Option C: Monitor with Application Insights**
1. Navigate to Application Insights → contoso-sample-app (shared instance).
2. Watch "Live Metrics" dashboard: watch request count drop to 0, then resume.
3. Check for new exceptions during restart window.

### Step 6: Verify Container Is Healthy

**Health Check #1: Endpoint Responsiveness**

```bash
# Wait 30 seconds for container to start
sleep 30

# Test HTTP endpoint
curl -i https://contoso-sample-app.eastus.azurecontainerapps.io/health

# Expected output:
# HTTP/1.1 200 OK
# Content-Type: application/json
# {"status": "healthy", "uptime": "0s"}
```

**Health Check #2: Application Insights Metrics**

```bash
# Check error rate in Application Insights (query on your own subscription)
# Run KQL query in Portal:
requests
| where timestamp > ago(5m)
| summarize FailureCount=sumif(1, success == false), TotalCount=count() by bin(timestamp, 1m)
```

Expected: **Error rate < 1% in first 5 min after restart.**

**Health Check #3: Dependency Connectivity**

```bash
# From a test pod or your local machine, verify backend can reach database
# Run a test query via the API:

curl -X GET https://contoso-sample-app.eastus.azurecontainerapps.io/api/health \
  -H "Authorization: Bearer $YOUR_JWT_TOKEN"

# Expected output:
# HTTP/1.1 200 OK
# {"database": "connected", "keyVault": "connected", "appInsights": "connected"}
```

---

## 5. Post-Restart Validation

### Checkpoint 1: Replicas Running

```bash
az containerapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query "properties.runningReplicas"
# Expected: 2 (or your configured replica count)
```

### Checkpoint 2: No Restart Loops

```bash
# Check for CrashLoopBackOff (indicates restart loops)
az containerapp logs show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --container default \
  --tail 50 | grep -i "crashloop\|exit\|error"
  
# Expected: No "exit" messages in last 50 lines; healthy startup logs
```

### Checkpoint 3: Metrics Normalized

In Application Insights:
- **CPU %:** Should return to baseline (typically < 20% at idle).
- **Memory %:** Should stabilize (no longer climbing).
- **Request latency (p95):** Should return to < 200ms (or pre-incident baseline).
- **Error rate:** < 0.1% (no spike).

**Example KQL Query:**

```kql
customMetrics
| where name in ("CPU%", "Memory%")
| where timestamp > ago(10m)
| summarize Avg=avg(value), Max=max(value) by name
```

---

## 6. Rollback Procedure (If Issues After Restart)

If the restart made things worse, rollback to the previous revision:

```bash
# List revisions and find the previous one
az containerapp revision list \
  --resource-group $RESOURCE_GROUP \
  --container-app $APP_NAME \
  --query "sort_by([], &properties.createdTime) | reverse([])[0:2]" -o table

# Activate the previous revision (shift 100% traffic)
PREVIOUS_REVISION=$(az containerapp revision list \
  --resource-group $RESOURCE_GROUP \
  --container-app $APP_NAME \
  --query "sort_by([], &properties.createdTime) | reverse([])[1].name" -o tsv)

az containerapp revision activate \
  --resource-group $RESOURCE_GROUP \
  --revision $PREVIOUS_REVISION

echo "Rolled back to: $PREVIOUS_REVISION"
```

**Verification after rollback:**
- Confirm traffic shifted: `az containerapp show --resource-group $RESOURCE_GROUP --name $APP_NAME --query "properties.latestRevisionName"`
- Check error rate: should drop within 2 min.
- If errors persist, **escalate to platform team** — do not attempt further restarts.

---

## 7. Troubleshooting Restart Failures

### Failure: "Permission Denied"

```
Error: Insufficient privileges to perform action 'Microsoft.App/containerApps/revisions/restart/action'
```

**Solution:**
- Request RBAC role from subscription owner (need `Azure Container Apps Operator` or `Contributor`).
- Alternatively, ask on-call platform engineer to perform restart.

### Failure: "Revision Not Found"

```
Error: The provided revision 'xxx' does not exist for container app 'yyy'
```

**Solution:**
- Verify container app name is correct: `az containerapp list --resource-group $RESOURCE_GROUP -o table`
- Verify region is correct (must be `eastus` for this workshop).

### Failure: "Restart Hangs" (Stuck for > 2 min)

**Solution:**
- Cancel the restart: Press Ctrl+C.
- Check Azure service health: https://status.azure.com/
- Try restarting again in 5 min; may be throttling.
- If still stuck, escalate to Azure support.

### Failure: "Container Immediately Crashes After Restart" (CrashLoopBackOff)

```
Status: CrashLoopBackOff
```

**Solution:**
- **Do not attempt further restarts.** This indicates a systemic problem (bad config, corrupted secrets, missing dependency).
- Check startup logs: `az containerapp logs show --resource-group $RESOURCE_GROUP --name $APP_NAME --container default --tail 100`
- Rollback to previous revision (see Step 6).
- **Escalate to platform team:** File incident with logs + timestamps.

---

## 8. Post-Mortem Documentation

After completing the restart and validating recovery, document the incident:

### Template

```markdown
## Incident Summary
- **Date/Time:** [YYYY-MM-DD HH:MM UTC]
- **Container App:** contoso-sample-app-[frontend|backend]
- **Symptom:** [High CPU / Memory leak / Unresponsiveness]
- **Trigger:** [Auto-detect / Manual escalation / Scheduled maintenance]
- **Root Cause:** [Identified during investigation] OR [Pending deep-dive]
- **Resolution:** Container restart
- **Impact:** [X users affected for Y minutes]

## Pre-Restart Metrics
- CPU % peak: [__]
- Memory % peak: [__]
- Error rate spike: [YES/NO]

## Restart Timing
- Started: HH:MM UTC
- Completed: HH:MM UTC
- Duration: [__] seconds

## Post-Restart Validation
- ✓ Replicas running: [2/2]
- ✓ Error rate: < 0.1%
- ✓ Latency normalized: [YES/NO]

## Follow-Up Actions
- [ ] Root cause analysis scheduled (if not identified)
- [ ] Code hotspot review (if CPU spike related)
- [ ] Memory profiling (if memory leak suspected)
- [ ] Config audit (if crash suspected)
```

---

## 9. Related Runbooks & Resources

- **Deployment rollback:** See `deployment-rollback-runbook.md`
- **Container debugging:** See `container-diagnostic-guide.md`
- **Database restart:** See `database-restart-runbook.md` (separate for Azure SQL)
- **On-call escalation matrix:** See `on-call-escalation.md`

---

## 10. Quick Reference Card

```bash
# One-liner: Full restart with verification
export RG="rg-sre-agent-workshop"
export APP="contoso-sample-app-frontend"
REVISION=$(az containerapp revision list --resource-group $RG --container-app $APP --query "max_by(properties.createdTime).name" -o tsv)
echo "Restarting $REVISION..." && \
az containerapp revision restart --resource-group $RG --revision $REVISION && \
sleep 30 && \
curl -i https://contoso-sample-app.eastus.azurecontainerapps.io/health && \
echo "✓ Restart complete"
```

---

**Document Version:** 1.0  
**Last Reviewed:** 2025-02-01  
**Next Review:** 2025-05-01
