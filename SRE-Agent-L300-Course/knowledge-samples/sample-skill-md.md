# SKILL.md Template: Container App Troubleshooting Guide

**Purpose:** This is an example SKILL.md file for the L300 workshop (Lab 4 — Skills Authoring). Attendees use this as a template to author their own skills.

**What is a SKILL.md?**

A SKILL.md is a procedural guidance document that teaches an SRE agent how to troubleshoot or remediate a specific operational scenario. The agent loads the skill automatically when it detects a user query matching the `description` field (trigger phrases). The skill contains:

1. **Metadata** (`description`, `trigger_phrases`, `scope`, `owner`)
2. **Step-by-step procedure** (investigation, diagnosis, action)
3. **Related runbooks/links** (context for automation)
4. **Examples** (when/when-not-to-use)

---

## SKILL: Troubleshoot High CPU on Azure Container App

### Metadata

```yaml
name: container-app-cpu-troubleshooting
description: |
  Investigates and resolves high CPU usage (>80% sustained) on Azure Container Apps.
  Covers memory leaks, runaway loops, misconfigured resources. Provides step-by-step
  diagnostics and recommends restart, scaling, or code review. 
  Trigger on: "high CPU", "CPU spike", "cpu exhaustion", "container hot", "why is my container using so much CPU"
scope: contoso-sample-app-frontend, contoso-sample-app-backend
owner: Platform Engineering Team
created_at: 2025-02-01
version: 1.0.0
max_concurrent_sessions: 5
```

### Description & Trigger Phrases

**Agent sees:** A user asking a question like one of these:

- "Why is my Container App using so much CPU?"
- "How do I debug high CPU on contoso-sample-app?"
- "Help me troubleshoot container CPU exhaustion"
- "My frontend is running hot — what should I check?"
- "CPU spike on backend API — where do I start?"

**Agent loads this skill** and begins Step 1 of the investigation.

---

## Investigation Procedure

### STEP 1: Confirm High CPU State (Tool: `RunAzCliReadCommands`)

**Objective:** Verify CPU usage is actually elevated and sustained.

**Commands:**

```bash
# Get current metrics from Container App
az containerapp show \
  --resource-group rg-sre-agent-workshop \
  --name contoso-sample-app-frontend \
  --query "properties.{ProvisioningState: provisioningState, Running: runningReplicas, Status: status}"

# Get resource limits
az containerapp show \
  --resource-group rg-sre-agent-workshop \
  --name contoso-sample-app-frontend \
  --query "properties.template.containers[0].resources"
# Returns: {"cpu": 0.5, "memory": "1Gi"}
```

**Interpretation:**

- If `RunningReplicas` < expected: Container is restarting (check Step 2 for CrashLoop).
- If `cpu` (request) = 0.5: Max vCPU available per replica; if using >0.4, that's elevated.
- If Container Apps environment is shared, high CPU may indicate noisy neighbor.

**Pass/Fail Signal:** Container is running; replication count is stable; CPU resource is visible.

---

### STEP 2: Check Application Insights Metrics (Tool: `RunAzCliReadCommands` + KQL Query)

**Objective:** Get CPU timeline and correlate with request volume.

**Commands:**

```bash
# Query Application Insights for CPU trend in last 60 min
# (Attendee runs this; agent auto-interprets results)

az monitor metrics list \
  --resource-group rg-sre-agent-workshop \
  --resource-type "Microsoft.App/containerApps" \
  --resource "contoso-sample-app-frontend" \
  --metric "CpuUsagePercentage" \
  --start-time $(date -u -d '60 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --interval PT5M \
  --aggregation Average
```

**Or (via Application Insights KQL):**

```kql
customMetrics
| where name == "cpuUsagePercent"
| where timestamp > ago(1h)
| summarize Avg=avg(value), Max=max(value), Min=min(value) by bin(timestamp, 5m)
| render timechart
```

**Interpretation:**

- **Baseline CPU** (normal): 5–15% at idle; 30–50% under load.
- **High CPU** (alert): > 80% sustained > 10 min.
- **Spike pattern:** Sudden jump to 100% at specific time → might indicate deployment, traffic spike, or batch job.
- **Gradual ramp:** CPU grows over hours → memory leak or connection pool leak.

**Next step:**
- If **spike correlates with deployment:** Check code diff for performance regression.
- If **gradual ramp:** Investigate memory leak (Step 4).
- If **constant high CPU:** Check request volume vs. replica count (Step 3).

---

### STEP 3: Correlate with Request Volume & Replica Scaling

**Objective:** Determine if CPU elevation is due to legitimate load or misconfiguration.

**Commands:**

```bash
# Get replica count history
az monitor metrics list \
  --resource-group rg-sre-agent-workshop \
  --resource-type "Microsoft.App/containerApps" \
  --resource "contoso-sample-app-frontend" \
  --metric "ReplicaCount" \
  --start-time $(date -u -d '60 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --interval PT5M \
  --aggregation Average

# Get request rate from Application Insights
az rest --method POST \
  --url "https://api.applicationinsights.io/v1/apps/{app-id}/query" \
  --body @- <<EOF
{
  "query": "requests | where timestamp > ago(1h) | summarize Count=count() by bin(timestamp, 5m)"
}
EOF
```

**Interpretation:**

- **Request rate low, CPU high:** Indicates inefficient code (memory leak, O(N²) loop, thread contention).
- **Request rate high, CPU proportional:** Expected behavior; may need to scale replicas up or optimize code.
- **Replicas maxed out (10 replicas), CPU still 100%:** Need to increase resource request or optimize app.

**Action decision:**
- If replicas < 3 and request rate high: Scale up replicas (temporary) + investigate code.
- If replicas adequate and CPU high: Proceed to Step 4 (memory leak) or Step 5 (profiling).

---

### STEP 4: Check for Memory Leak

**Objective:** Determine if high CPU is caused by memory exhaustion and garbage-collection pressure.

**Queries:**

```kql
customMetrics
| where name in ("memoryUsagePercent", "gcTimeMsec")
| where timestamp > ago(1h)
| summarize Avg=avg(value), Max=max(value), Min=min(value) by name, bin(timestamp, 10m)
| render timechart
```

**Interpretation:**

- **Memory % growing over time + GC time spiking:** Classic memory leak. Each GC takes longer as heap fills.
- **Memory stable, CPU high:** Not a memory leak; proceed to Step 5.
- **Memory % > 90% + replica crashes:** Memory limit exceeded; restart container immediately (see runbook).

**If memory leak detected:**

1. **Temporary mitigation:** Increase memory request (e.g., 1 Gi → 2 Gi) to buy time.
2. **Long-term fix:** Code review → identify event listeners not unsubscribed, static collections accumulating, etc.
3. **Escalate to dev team:** With memory profile and timestamps; request hotspot analysis.

---

### STEP 5: Analyze Request Latency & Exception Rate

**Objective:** Determine if high CPU is impacting user experience or if it's an internal resource constraint.

**Queries:**

```kql
requests
| where timestamp > ago(1h)
| summarize 
    Count=count(), 
    AvgDuration=avg(duration), 
    P95Duration=percentile(duration, 95),
    P99Duration=percentile(duration, 99),
    FailureCount=sumif(1, success == false)
| by bin(timestamp, 5m)
| render timechart
```

**Interpretation:**

- **Latency spiked WITH CPU spike:** CPU is user-facing; users experiencing slowness.
- **CPU high, latency stable:** CPU not the bottleneck (may be external service, network, or artifact).
- **Failure rate spiked:** CPU pressure causing timeouts or crashes; recommend immediate restart.

**Action:**
- **High CPU + high latency + low failure rate:** Can optimize code; no immediate danger.
- **High CPU + high latency + high failure rate (> 1%):** Container is under distress; restart recommended.

---

### STEP 6: Decision Tree & Action

```
    Is CPU > 80% sustained > 10 min?
    ├─ YES (proceed)
    │   ├─ Is memory also > 85%?
    │   │   ├─ YES → MEMORY LEAK or INSUFFICIENT RESOURCES
    │   │   │   ├─ IMMEDIATE: Increase memory request or restart container
    │   │   │   └─ FOLLOW-UP: Code review; identify leaked objects
    │   │   └─ NO (memory stable)
    │   │       ├─ Did CPU spike correlate with deployment?
    │   │       │   ├─ YES → CODE REGRESSION
    │   │       │   │   ├─ IMMEDIATE: Investigate code diff; consider rollback
    │   │       │   │   └─ FOLLOW-UP: Hotspot analysis; benchmark
    │   │       │   └─ NO (gradual ramp or constant high)
    │   │           ├─ Is request volume HIGH?
    │   │           │   ├─ YES → SCALE UP REPLICAS (temporary) + OPTIMIZE CODE
    │   │           │   │   ├─ IMMEDIATE: Scale replicas from 2 to 4–6
    │   │           │   │   └─ FOLLOW-UP: Profile code for hotspots
    │   │           │   └─ NO (low traffic, high CPU)
    │   │           │       └─ RUNAWAY PROCESS or SPIN LOOP
    │   │           │           ├─ IMMEDIATE: Restart container
    │   │           │           └─ FOLLOW-UP: Debug logs; thread dump
    │   └─ Correlate with latency + error rate
    │       ├─ Latency spiked? → Impacts users
    │       ├─ Error rate spiked? → Container distressed; recommend restart
    │       └─ Both stable? → No immediate user impact; can investigate

    └─ NO (CPU normal)
        └─ INVESTIGATION COMPLETE
            └─ No action needed; baseline normal
```

---

## Recommended Actions by Root Cause

| Root Cause | Immediate Action | Follow-Up |
|------------|------------------|-----------|
| **Memory leak** | Increase memory request; restart if > 90% | Code review; identify leaked objects; deploy fix |
| **Code regression** | Rollback recent deployment | Hotspot analysis; optimize hotspot; re-deploy |
| **Runaway thread** | Restart container | Thread dump analysis; identify stuck thread |
| **Resource starvation (too many replicas on shared env)** | Scale down other apps or request higher CPU tier | Capacity planning; VM upgrade or cluster expansion |
| **External dependency slow** | No action; wait for dependency recovery | Monitor external service; consider circuit breaker |
| **Misconfigured resource request** | Adjust CPU request (e.g., 0.5 → 1.0) | Benchmark typical workload; set correct steady-state |

---

## When NOT to Restart

❌ **Do not restart if:**
- Within 2 min of deployment (health checks still stabilizing).
- Investigating active incident (restart loses in-memory diagnostics).
- Previous restart < 5 min ago (indicates systemic issue; escalate instead).

✅ **OK to restart if:**
- Memory leak + memory > 90% (immediate danger).
- Runaway thread detected + error rate spike.
- Scheduled maintenance window.

---

## Related Documentation & Runbooks

- **Restart procedure:** See `sample-runbook-restart-containerapp.md`
- **Architecture context:** See `sample-architecture.md` (Lab 4 knowledge source)
- **Performance baseline:** See `performance-baseline.md` (CPU/memory normal ranges)
- **Code hotspot analysis:** See `profiling-guide.md` (profiler setup for Node/Python)

---

## Example Scenarios

### Scenario A: Memory Leak Suspected

**User query:** "Help me troubleshoot high CPU on contoso-sample-app-backend"

**Agent runs:**
1. Step 1: Confirms CPU at 95%, replicas running.
2. Step 2: CPU ramp over 2 hours (gradual).
3. Step 3: Request rate stable (20 req/s).
4. Step 4: Memory growing from 400 MB → 950 MB; GC time 100ms → 500ms.
5. Step 5: Latency stable (p95 = 150ms); no error spike.

**Agent concludes:** Memory leak.

**Agent recommends:**
```
✓ Immediate: Increase memory request from 1 Gi to 2 Gi (buys time)
✓ Follow-up: Code review for event listeners, static collections in Python backend
✓ Contact: Assign dev team to profile heap; file ticket for fix
```

---

### Scenario B: Code Regression (Post-Deployment)

**User query:** "My frontend CPU spiked after this morning's deploy"

**Agent runs:**
1. Step 1: CPU at 88%, replicas 2.
2. Step 2: CPU spike visible at 08:15 UTC (deployment timestamp: 08:14 UTC).
3. Step 3: Request rate stable; replica count stable.
4. Step 4: Memory stable at 600 MB.
5. Step 5: Latency spiked (p95 = 800ms); error rate 0.5% (low).

**Agent concludes:** Code regression post-deployment.

**Agent recommends:**
```
✓ Investigate: Diff HEAD~1 vs HEAD; look for loops, sync operations, added logging
✓ Consider: Rollback to previous revision for immediate relief
✓ Schedule: Hotspot analysis; benchmark before re-deploy
```

---

### Scenario C: Normal Behavior (No Action Needed)

**User query:** "Why is CPU at 75%? Should I worry?"

**Agent runs:**
1. Step 2: CPU at 75%, but request rate also high (500 req/s).
2. Step 3: Replicas auto-scaled to 6; CPU ratio reasonable (75% ÷ 6 = 12.5% per replica).
3. Step 5: Latency stable (p95 = 100ms); error rate < 0.1%.

**Agent concludes:** Normal under load.

**Agent recommends:**
```
✓ No action needed; baseline normal
✓ Inform: This is expected at current traffic level
✓ Info: If sustained > 1 hour, consider permanent replica scale-up or code optimization
```

---

## Troubleshooting This Skill

**If the agent doesn't load this skill:**

- Ensure description keywords match user query (e.g., "high CPU", "cpu spike", "cpu usage").
- Verify skill is attached to the active agent in Builder → Agent Canvas.
- Check agent's `allowed_skills` list includes this skill name.

**If the agent runs Steps 1–5 but recommends wrong action:**

- Review Step 2–5 logic; verify thresholds (e.g., "memory > 85%" may need adjustment for your app).
- Adjust `description` and trigger phrases if skill is loaded for unrelated queries.

---

## Skill Metadata for Lab 4 Authoring Template

Use this YAML template when creating your own skill in Lab 4:

```yaml
# skill-config.yaml
name: <service>-troubleshooting-guide
description: |
  Investigates and resolves <symptom> on <service>.
  Step-by-step diagnostics: <procedure>.
  Recommends: <actions>.
scope: <affected-services>
owner: <team>
created_at: YYYY-MM-DD
version: 1.0.0
tools_required:
  - RunAzCliReadCommands  # For `az` commands
  - RunAzCliWriteCommands # (if remediation needed; use sparingly)
related_links:
  - name: "Restart Runbook"
    url: "https://wiki.contoso.com/sre/runbooks/restart-containerapp"
  - name: "Architecture Reference"
    url: "https://wiki.contoso.com/sre/docs/sample-architecture"
trigger_phrases:
  - "how do I troubleshoot..."
  - "help me debug..."
  - "why is my... experiencing..."
  - "[symptom] on [service]"
```

---

## Best Practices for Skill Authors

✅ **DO:**
- Write clear, procedural steps (1. Do X, 2. Observe Y, 3. Conclude Z).
- Include tool invocations (commands) as examples.
- Provide decision trees for ambiguous cases.
- Link to related runbooks for deeper action.
- Limit scope to 3–5 related symptoms (avoid catch-all skills).

❌ **DON'T:**
- Make the skill description too broad ("General troubleshooting" — won't auto-load reliably).
- Include write commands in the skill; use custom agents for remediation.
- Reference internal wiki links without also providing brief context.
- Assume readers know your infrastructure; define jargon (e.g., "Container App" = Azure serverless containers).

---

**Document Version:** 1.0 (Example/Template)  
**Last Updated:** 2025-02-01  
**Author:** Platform Engineering Team  
**Usage:** Lab 4 Workshop (Skills Authoring) — attendees copy and adapt for their own services
