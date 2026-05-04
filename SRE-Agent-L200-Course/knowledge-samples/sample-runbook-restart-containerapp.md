# Restart Procedure for Contoso Payments Container App

> **Runbook ID:** RB-PAYMENTS-001
> **Severity:** Low risk (read-heavy, no data mutation)
> **Last reviewed:** 2026-04-15
> **Owner:** Platform Engineering — Contoso Payments Team

---

## When to Restart

- Container App returns persistent HTTP 5xx errors after a deployment.
- Memory usage is stuck at ceiling with no recovery from garbage collection.
- Application logs show a known deadlock pattern (error code `DEADLOCK_DETECTED`).
- After a Key Vault secret rotation, if the app has not picked up the new secret within 10 minutes.

> **Do NOT restart** if the issue is upstream (e.g., Azure SQL Database is unreachable, payment gateway timeout). Restarting will not help and may cause queue backlog.

---

## Pre-Checks

1. **Confirm the symptom** — verify the issue in Application Insights (`contoso-payments-ai`):
   ```kql
   requests
   | where timestamp > ago(15m)
   | where resultCode startswith "5"
   | summarize count() by bin(timestamp, 1m)
   ```

2. **Check active revision** — ensure you know which revision is currently serving traffic:
   ```bash
   az containerapp revision list \
     --name contoso-payments-app \
     --resource-group rg-contoso-payments \
     --output table
   ```

3. **Notify the team** — post in `#oncall-payments` Teams channel:
   > "Restarting contoso-payments-app — [brief reason]. ETA 2 minutes."

---

## Restart Steps

1. **Restart the active revision:**
   ```bash
   az containerapp revision restart \
     --name contoso-payments-app \
     --resource-group rg-contoso-payments \
     --revision <active-revision-name>
   ```

2. **Wait for health probes** — the liveness probe at `/healthz` should return HTTP 200 within 30 seconds of restart. Monitor in the portal or with:
   ```bash
   az containerapp show \
     --name contoso-payments-app \
     --resource-group rg-contoso-payments \
     --query "properties.latestReadyRevisionName"
   ```

---

## Post-Checks

1. **Verify HTTP traffic is healthy** — wait 2 minutes, then check:
   ```kql
   requests
   | where timestamp > ago(5m)
   | summarize total = count(), errors = countif(resultCode startswith "5")
   | extend error_rate = round(100.0 * errors / total, 2)
   ```
   - Expected: error rate < 1%.

2. **Verify replica count** — confirm at least 1 replica is running:
   ```bash
   az containerapp replica list \
     --name contoso-payments-app \
     --resource-group rg-contoso-payments \
     --revision <active-revision-name> \
     --output table
   ```

3. **Update the team** — post in `#oncall-payments`:
   > "contoso-payments-app restarted successfully. Error rate back to normal."

4. **Log the action** — record the restart in the incident timeline or on-call log.

---

## Escalation

If the restart does not resolve the issue within 5 minutes:
1. Escalate to the on-call lead via PagerDuty.
2. Consider rolling back to the previous container image revision.
3. Open a support ticket if the Container App Environment itself is unhealthy.
