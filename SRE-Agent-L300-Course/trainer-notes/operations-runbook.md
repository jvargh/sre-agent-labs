---
title: Azure SRE Agent L300/400 Workshop Operations Runbook
version: srea-l300-v1.0.0
source_md_sha: placeholder
created_at: 2026-05-03T15:51:18Z
---

# Operations Runbook — SRE Agent L300/400 Workshop

**Trainer-only guide.** This document contains the day-of checklist, credentials inventory template, track setup procedures, FAQs, escalation contacts, and fallback strategies for the 2-day L300/400 workshop.

---

## 1. Day-of Checklist

### T-7 days: Pre-workshop verification

- [ ] **Attendee registrations locked.** Confirm all attendees have:
  - [ ] L200 completion verified
  - [ ] Incident platform chosen (PagerDuty / ServiceNow / Azure Monitor)
  - [ ] Two subscriptions provisioned
  - [ ] ADX cluster URL confirmed
  - [ ] Entra admin contact name provided (Lab 11 requirement)
  - [ ] Budget cap acknowledged (USD 50/day)

- [ ] **Sandboxes staged.** All 3 tracks have:
  - [ ] PagerDuty trial workspace: 1 service, 1 escalation policy, 1 API token (rotate for cohort)
  - [ ] ServiceNow PDI: 1 CMDB CI, 1 assignment group, 1 service-account user
  - [ ] Azure Monitor: 1 metric alert + 1 log search alert on sample workload

- [ ] **Pre-seeded ADX cluster:**
  - [ ] Tables created: `AppEvents`, `Errors`, `Requests`
  - [ ] ≥10k rows loaded (incl. 3 NullPointerException events in last 24h for Lab 5 demo)
  - [ ] Loader is idempotent (safe to re-run)
  - [ ] AllDatabasesViewer role grants ready for Lab 5

- [ ] **Synthetic-incident generator tested:**
  - [ ] `./synthetic-incidents.sh --platform pagerduty --count 3 --prefix [TEST]` fires cleanly
  - [ ] Incidents appear in each platform within 60 s
  - [ ] Incident IDs logged for Lab 13 capstone scoring

- [ ] **Slides + lab guides:**
  - [ ] Screenshots regenerated against current portal UI (drift check)
  - [ ] Lab 1 decision matrix printed (handout)
  - [ ] Lab 9 hook YAML examples syntax-checked
  - [ ] Lab 13 capstone rubric reviewed

- [ ] **Trainer dry run (internal, 1–2 people, 1 track):**
  - [ ] Provision one sandbox via `./sandbox/provision.sh` — completes in <12 min
  - [ ] Lab 1 exercise: complete decision matrix for a sample service
  - [ ] Lab 2: connect incident platform, delete quickstart plan, verify heartbeat green
  - [ ] Lab 3 (abbreviated): create 1 custom agent + 1 response plan, fire 1 synthetic incident
  - [ ] Log any friction → document in FAQ / fallback section below

### T-1 day: Final prep

- [ ] **Credentials audit:**
  - [ ] PagerDuty API tokens rotated (not shared across cohorts)
  - [ ] ServiceNow PDI passwords reset
  - [ ] Azure Monitor sample workload alert rules enabled
  - [ ] All credentials stored in Key Vault (NEVER inline)
  - [ ] Trainer access verified (can read all Key Vault secrets)

- [ ] **Sandbox URLs + connection strings:**
  - [ ] Agent endpoint URLs collected in spreadsheet
  - [ ] App Insights instrumentation keys verified
  - [ ] ADX cluster URLs reachable from workshop network
  - [ ] MCP reference servers health-checked (if external)

- [ ] **Cost-cap watcher deployed:**
  - [ ] Logic App / Function provisioned for each attendee's RG
  - [ ] Alert rule set to trigger at USD 40 (80%) and USD 50 (100%)
  - [ ] Teardown automation tested in a dry-run RG

- [ ] **Trainer comms:**
  - [ ] Zoom/Teams meeting links verified (with waiting room)
  - [ ] Chat room created (for checkpoint pulses, escalations)
  - [ ] Incident-platform vendor support contacts listed (see §4 escalation)

### T-0 (Day 1, 8:30 AM): 30-min early start

- [ ] **All attendees in sandbox:** re-run provisioning script for any latecomers
  - [ ] Endpoints reachable (curl test)
  - [ ] Incident sources have ≥1 pre-existing incident

- [ ] **Trainer station setup:**
  - [ ] Three monitor setup (1 = slides, 1 = chat/clock, 1 = demo agent)
  - [ ] Microphone + webcam tested
  - [ ] Screen-share permissions confirmed

- [ ] **Backup MCP server online:** if using self-hosted stdio MCP demo server, health-check it
  - [ ] Verify credentials for all attendees

- [ ] **Three parallel chat channels (Slack / Teams):**
  - [ ] `#srea-l300-pagerduty`, `#srea-l300-servicenow`, `#srea-l300-azure-monitor`
  - [ ] `#srea-l300-announcements` (trainer broadcasts)

- [ ] **First checkpoint (9:15 AM, 15 min into Lab 1):**
  - [ ] All attendees present + on camera
  - [ ] No provisioning errors in the logs
  - [ ] "OK to proceed" from each track lead

### T+1 day (Day 2 end): Teardown verification

- [ ] **All sandboxes still running:** run a final health check
  - [ ] No cost overages (query Azure cost API if available)
  - [ ] Cost-cap watcher logs clean (no false alarms)

- [ ] **Capstone artifacts collected:**
  - [ ] Lab 13 rubric scored for all attendees
  - [ ] Audit workbooks exported (Lab 10)
  - [ ] Photos/screenshots of whiteboard exercises (Lab 1, Lab 11)

- [ ] **Attendee feedback forms distributed:**
  - [ ] Post-workshop survey link (See `feedback/post-workshop-survey.md`)
  - [ ] Anonymous QR code or email link

### T+7 days: Post-workshop retrospective

- [ ] **Trainer debrief:**
  - [ ] FAQ items added to this runbook
  - [ ] Any P1 / P2 defects logged (see QA protocol)
  - [ ] Drift detection: any docs changed since workshop design? (§8 in prompt)

- [ ] **Cost reconciliation:**
  - [ ] Final bill per attendee vs. USD 50 cap
  - [ ] Any cost overages? Root-cause analysis

- [ ] **Cascade results to FinOps:**
  - [ ] Tag usage report: `workshop=srea-l300, cohort=<date>, attendee=<handle>`

---

## 2. Trainer-Only Credentials Inventory Template

**DO NOT COMMIT TO GIT.** Store in a password manager (Keeper, 1Password, or secure folder).

```
COHORT: <DATE>
TRAINER: <NAME>
CREATED_AT: <ISO8601>
NOTES: <Any special setup notes>

---

PAGERDUTY TRACK
Workspace URL: https://aaa.pagerduty.com
User: srea-l300+<handle>@company.com
API Token: [REDACTED] — expires <DATE>, rotate before next cohort
Service name: sample-app-prod
Escalation policy: L3-on-call
Incident types: High latency, DB corruption, API 500s

ServiceNow PDI TRACK
Instance URL: https://dev12345.service-now.com
Service account user: srea_l300_bot
Password: [REDACTED]
CMDB CI: sample-app (sys_id: <GUID>)
Assignment group: SRE-Incident-Response
Impersonation allowed: YES

AZURE MONITOR TRACK
Alert rule RG: srea-l300-<date>
Alert rule name: sample-app-high-latency-metric
Sample workload RG: srea-l300-workload-<date>
Sample workload app: contoso-api-prod
App Insights instrumentation key: [REDACTED]
Action group: srea-l300-responders
Email: sre-team+alerts@company.com

ADX CLUSTER
Cluster URL: https://srea-l300-adx.<region>.kusto.windows.net
Database: workshopdata
Loader credential: [REDACTED] (service principal)
AllDatabasesViewer assignments: [List of attendee UAMIs]

MCP REFERENCE SERVERS
Datadog trial URL: https://trial-123.datadoghq.com
API key: [REDACTED]
Splunk free tier URL: https://splunk-free.internal.company.com
Stdio server (if self-hosted): git clone <url>

COST-CAP WATCHER
Logic App resource ID: /subscriptions/<sub>/resourceGroups/.../providers/Microsoft.Logic/workflows/...
Threshold 80%: USD 40
Threshold 100%: USD 50 (teardown triggered)
Contact for overages: <FinOps email>
```

---

## 3. Track Setup Procedures

### Setup for all three tracks in parallel (T-7d to T-1d)

#### A. PagerDuty Track Setup

1. Create a free trial workspace via https://www.pagerduty.com/trial/ (uses attendee email)
2. Accept the workspace invite in email
3. Create one **Service**:
   - Name: `sample-app-prod`
   - Type: Incidents
   - Escalation policy: (create) `L3-on-call` → assign default on-call
4. Create an **Incident Type** for each Lab 3 test case:
   - `high-latency` (P3/Sev 3)
   - `db-corruption` (P1/Sev 1)
   - `api-500s` (P2/Sev 2)
5. Generate **API token**:
   - Settings → API Access → Create Token
   - Scopes: `services:read`, `incidents:write`, `users:read`
   - Store token securely; share via Key Vault reference only
6. **Test webhook:** create one webhook to send incidents to the trainer's demo agent (for verification)

#### B. ServiceNow PDI Setup

1. Provision a **Personal Developer Instance (PDI)** via https://developer.servicenow.com/ (leads time: 1–6 hours)
2. Wait for provisioning email; accept the instance
3. Create a **service-account user**:
   - Admin → Users & Groups → Users → New
   - Username: `srea_l300_bot`
   - Password: generate strong random (store in Key Vault)
   - Roles: `admin` (temporary; belt-and-suspenders access)
4. Create a **CMDB CI**:
   - CMDB → Configuration Items → New
   - Name: `sample-app-prod`
   - Type: Application / Service
   - Owner: `SRE-Incident-Response` group
5. Create an **Assignment Group**:
   - Admin → Groups → New
   - Name: `SRE-Incident-Response`
   - Members: service-account user + trainer
6. Create **Incident types** (Incident table → new records with category = Lab 3 test cases)
7. **Grant permissions:**
   - Service account: can read/write `incident` table, can read CMDB CI

#### C. Azure Monitor Track Setup

1. Provision a **sample workload RG** in a non-prod subscription (if not already running):
   - Container app or App Service with sample HTTP endpoint
   - Application Insights instrumentation enabled
   - Metric alert on latency / error rate (configure for Lab 2 lab)
2. Create an **Alert Rule**:
   - Metric: Requests / Failed Requests / Response Time
   - Threshold: 50 th percentile > 2 sec (or ≥1 error/min)
   - Action group: [to be set by attendee in Lab 2]
   - Alert rule name: `sample-app-high-latency-metric`
3. Create a **Log Search Alert** (optional, for depth):
   - Workspace: agent's Log Analytics
   - Query: `AppEvents | where name == "error"`
   - Alert name: `sample-app-errors-log-search`
4. **Verify:** generate traffic to workload (e.g., `ab` or `hey` load test); confirm alert fires within 2 min
5. Store **alert rule IDs** and **sample workload URL** in Key Vault

### Pre-seeded ADX setup (T-7d)

1. Create **free-tier ADX cluster** (if not provisioned):
   ```bash
   az kusto cluster create \
     --name srea-l300-adx \
     --resource-group <rg> \
     --sku Standard/Dev(No SLA) \
     --location <region>
   ```

2. Create **database**:
   ```bash
   az kusto database create \
     --name workshopdata \
     --cluster-name srea-l300-adx \
     --resource-group <rg>
   ```

3. Create **tables** via KQL in Kusto Web Explorer (Web UI):
   ```kql
   .create table AppEvents (
     Timestamp:datetime,
     ThreadId:string,
     Severity:string,
     Message:string,
     ServiceName:string,
     properties:dynamic
   )
   
   .create table Errors (
     Timestamp:datetime,
     ErrorCode:int,
     ErrorType:string,
     StackTrace:string
   )
   
   .create table Requests (
     Timestamp:datetime,
     RequestId:string,
     ResponseTime:int,
     StatusCode:int,
     Endpoint:string
   )
   ```

4. **Load sample data** (idempotent loader script in Python/PowerShell):
   ```bash
   python3 load-sample-data.py \
     --cluster-url https://srea-l300-adx.<region>.kusto.windows.net \
     --database workshopdata \
     --table-prefix ALL
   ```
   - ≥10k rows per table
   - 3 NullPointerException events in last 24h
   - Deterministic ordering (seed = cohort date)

5. **Grant AllDatabasesViewer role** to each attendee's UAMI (after Lab 1 provisioning):
   ```kql
   .add cluster AllDatabasesViewer ('aadapp=<ManagedIdentityClientId>;<TenantId>')
   ```

---

## 4. FAQ & Troubleshooting

### General

**Q: Attendee says "My sandbox didn't provision."**

A: 
1. Check `az group show --resource-group srea-l300-<handle>` — does the RG exist?
2. If not, re-run `./sandbox/provision.sh` with the same handle (idempotent, safe to repeat).
3. If it times out, SSH into the provisioning machine and check `az deployment operation list --rg ... --name <deployment-id>`.
4. Most common: subscription quota exhausted (VMSS, App Insights) or Entra role assignment pending (refresh browser after 10 min).

**Q: "Connection refused" when trying to reach the agent URL.****

A:
1. Agent still starting (first time, takes 2–3 min).
2. NSG rule blocking traffic? Check `az network nsg rule list --resource-group <rg>`.
3. Private endpoint issue (if Lab 11 early)? Verify `--public-ip-address Enabled` in the agent resource.

**Q: Attendee can't see their incident in Builder → Incidents page.**

A:
1. Incident connector status must be `Connected` (not `Connecting`). Give it 60 s.
2. Incident platform is not firing incidents? Check the platform's activity log / webhook delivery.
3. Is the agent's UAMI assigned the right roles on the incident platform's webhook receiver? (platform-dependent)

### Lab-specific

**Lab 1 — Promotion playbook**

**Q: "I'm confused about when to use Review vs Autonomous."**

A: Refer attendee to the Lab 1 guide. Show the decision matrix (printed handout). The rule: **Review is default; justify every move away from it.** If the custom agent calls a write tool (e.g., `az deployment create`), stay in Review unless an Lab 9 hook guards it.

**Lab 2 — Incident platform connection**

**Q: "ServiceNow PDI provisioning is taking forever."**

A: PDI allocation queue is long (1–6 hours). Pre-provision 1–2 PDIs T-7d as spares.

**Q: "My PagerDuty trial expired mid-workshop."**

A: Generate a new trial for the attendee using a different email alias (srea-l300+<initials>@company.com). If this is the last attendee, escalate to PagerDuty sales (see §5).

**Q: "I can't trigger a test incident from the CLI."**

A: Most likely, the API token lacks the right scopes. Re-generate it with `incidents:write + services:read`. For ServiceNow, ensure the service-account user can write to the `incident` table.

**Lab 3 — Response Plans**

**Q: "My response plan fired twice — incident was processed by two handlers."**

A: You have two overlapping plans (e.g., both match P1 on the same service). Click "Unified grid view" in Agent Canvas → Incident response plans → sort by `Service + Severity` → remove the duplicate.

**Lab 4 — Skills**

**Q: "My skill never loads — the agent ignores it."**

A: Skill description doesn't include trigger phrases. The agent matches natural language to the description field to decide whether to load the skill. Add keywords: "troubleshooting", "error", "diagnosis", etc.

**Lab 5 — Kusto tools**

**Q: "AllDatabasesViewer grant is failing."**

A: Most likely, the UAMI's tenant ID and client ID are swapped. Double-check with `az identity show --name <uami> --query '{clientId:clientId, tenantId:principalTenantId}'`. Correct syntax: `.add cluster AllDatabasesViewer ('aadapp=<clientId>;<tenantId>')`.

**Q: "My Kusto query works in the Web Explorer but not in the tool."**

A: Likely a typo in the parameter substitution. Verify the query includes `##timeRange##` and `##searchPattern##` placeholders (exact syntax, double-hash). The tool replaces them with the attendee-supplied values.

**Lab 9 — Agent Hooks**

**Q: "My Stop hook keeps rejecting responses; the agent enters a loop."**

A: Set `maxRejections: 3` (limit retries). If the agent still loops, check the prompt: is it ambiguous or too strict? For testing, set `failMode: allow` temporarily.

**Q: "Command hook times out."**

A: Script is too slow or stuck. Timeout default is 120 s; max is 900 s. Check for infinite loops, missing error handling, or deadlocks. Set `timeout: 30` for quick tests.

**Lab 11 — Enterprise topology**

**Q: "Entra admin is unavailable for the MI federation consent step."**

A: **Use the Lab 11 fallback** (see §3 below). Switch attendee to lecture-only mode for Lab 11; skip the lab. Cover the conceptual material (VNET topology, cross-tenant connectors) verbally. Attendee can attempt the lab post-workshop with their own Entra admin.

**Lab 12 — Configuration as code**

**Q: "My Bicep template syntax is wrong."**

A: Run `az bicep build --file bicep-skeleton.bicep` locally to validate. Check the error message; most common: misquoted strings, missing commas, or wrong type annotation (e.g., `bool` vs `string`).

**Q: "REST API v2 PUT call returned 401."**

A: Agent's UAMI must have consent for the agent resource. Ensure the agent was provisioned with the UAMI already, and the UAMI has `Managed Identity Operator` on the agent resource.

**Lab 13 — Capstone**

**Q: "Only 1 of 3 test incidents fired."**

A: Trainer's synthetic-incident generator may have failed. Check its logs: `./synthetic-incidents.sh --platform <track> --verbose`. Re-fire the missing incident via the platform's CLI/API.

---

## 5. Escalation Contact Tree

**Call tree for incident-platform emergencies:**

```
├─ PagerDuty issues (API, trial, webhooks)
│  ├─ Primary: PagerDuty Sales / Support
│  │  Email: support@pagerduty.com
│  │  Slack: #pagerduty-support (if available)
│  └─ Secondary: Trainer's PagerDuty account manager (escalation path)
│
├─ ServiceNow PDI issues (provisioning, access, table permissions)
│  ├─ Primary: ServiceNow developer.servicenow.com Help / Community
│  │  URL: https://community.servicenow.com/t5/PDI/ct-p/PDI
│  └─ Secondary: Trainer's ServiceNow account manager or internal PDI admin
│
├─ Azure Monitor / Alert Rule issues
│  ├─ Primary: Microsoft Support (if on support plan)
│  │  URL: https://support.microsoft.com/en-us/support-home
│  └─ Secondary: Azure SRE Agent product team (internal)
│
├─ ADX (Kusto) cluster issues
│  ├─ Primary: Microsoft Support for KustoDB / ADX
│  └─ Secondary: Data Eng team (internal)
│
├─ Agent sandbox provisioning / cost runaway
│  ├─ Primary: Trainer (run teardown.sh immediately)
│  └─ Secondary: FinOps team (cost cap exceptions) + Azure SRE Agent team (infrastructure)
│
└─ Entra ID / MI federation / consent issues (Lab 11)
   ├─ Primary: Named Entra admin contact (prerequisite #8)
   │  (Have their name + email before workshop starts)
   └─ Secondary: Identity & Access Governance team (internal)
```

**Critical contacts to collect before T-1d:**

| Role | Name | Email | Phone | Notes |
|------|------|-------|-------|-------|
| Trainer | | | | |
| Track lead — PagerDuty | | | | |
| Track lead — ServiceNow | | | | |
| Track lead — Azure Monitor | | | | |
| Entra admin | | | | (Lab 11 requirement) |
| FinOps escalation | | | | (cost cap) |
| SRE Agent product team | | | | (sandbox issues) |

---

## 6. Fallback Strategies

### Lab 11 fallback: Entra admin unavailable

**Trigger:** Named Entra admin (prerequisite #8) is not reachable during Lab 11 (around 2–3 PM Day 2).

**Action:**

1. **Convert Lab 11 to lecture-only** (60 min):
   - Trainer delivers the 30-min conceptual lecture (VNET, cross-tenant, Agent Identity sidecar).
   - Show slides + architecture diagrams.
   - Q&A: let attendees ask about their real-world enterprise topology.

2. **Defer the lab** (60 min):
   - Attendee receives a **post-workshop lab guide** to complete async with their own Entra admin.
   - Include: step-by-step MI federation setup, consent flow, test verification.
   - Timeline: complete within 2 weeks; share results in a follow-up sync.

3. **Document in the feedback survey:**
   - Ask attendee to rate Lab 11 lecture usefulness (1–5).
   - Ask if they plan to attempt the lab post-workshop.

### Lab 5 fallback: ADX cluster data load fails

**Trigger:** Loader script errors or ADX cluster is not ready by Lab 5 lab time.

**Action:**

1. **Pause Lab 5 (5 min).** Trainer diagnostic:
   - Check ADX cluster health: `az kusto cluster show --name <cluster-name>`
   - Re-run the loader: `python3 load-sample-data.py --verbose`

2. **Option A — Quick retry:** if cluster is up, re-run loader (idempotent) and resume in 2 min.

3. **Option B — Use a shared pre-loaded ADX cluster:**
   - If the dedicated cluster is stuck, point all attendees to a trainer-managed "fallback" ADX instance.
   - Grant attendees query-only access (read via script).
   - Note: this changes the "personal sandbox" experience but unblocks the lab.

4. **Option C — Defer to a shorter lab variant:**
   - Show a **pre-recorded demo** of the Kusto tool creation + invocation (5 min).
   - Attendee builds the tool in the Agent Canvas (no live data test).
   - Mark Lab 5 as "partial completion" in the capstone rubric.

### Cost runaway (Lab 12/Lab 13)

**Trigger:** Cost-cap watcher fires at USD 40 (80%) or USD 50 (100%) during workshop.

**Action:**

1. **At USD 40 alert:**
   - Trainer notified.
   - Alert message: "Heads up — attendee <handle> at 80% of daily budget. Cleanup old resources?"
   - Attendee can manually stop / deallocate resources if available (e.g., stop container app, pause ADX ingest).

2. **At USD 50 alert (100%):**
   - Logic App / Function triggers **automatic teardown** of the attendee's RG.
   - All resources deleted; sandbox is down.
   - **Attendee is kicked from Lab 13 capstone** (no sandbox to test).
   - Trainer reviews attendee's prior work (Labs 1–12) for partial credit.
   - **Root-cause analysis post-workshop:** why did this attendee's sandbox exceed budget?

3. **Prevention post-mortem:**
   - Check tagging: is the cost-cap watcher correctly filtering on `workshop=srea-l300`?
   - Check Azure Monitor configuration: are idle App Insights / Log Analytics clusters still writing?
   - Check attendee habits: did they provision multiple resource groups by accident?

---

## 7. Sandbox Monitoring During Workshop

### Live dashboard (for trainer / FinOps on-call)

**Option A — Azure Monitor workbook** (recommended):
- Query: sum of `resources` with tag `workshop=srea-l300, cohort=<date>` grouped by `attendee`.
- Metric: CPU, memory, network I/O, storage IOPS per attendee.
- Alert: if any attendee's RG goes dark (no metrics for 5 min), page trainer.

**Option B — CLI polling script** (backup):
```bash
#!/bin/bash
# Run every 5 min during workshop
for handle in <list of attendee handles>; do
  RG="srea-l300-$handle"
  COST=$(az costmanagement query \
    --scope "/subscriptions/<sub>/resourcegroups/$RG" \
    --timeframe MonthToDate \
    --query 'properties.rows[0][0]' -o tsv)
  echo "$(date) | $handle | USD $COST"
done
```

### Heartbeat checks (Lab 2 onwards)

- **Every 30 min:** trainer spot-checks one random attendee's agent:
  - `curl -H "Authorization: Bearer <token>" <agent-url>/healthz` → expect 200
  - If not: escalate to platform team; trigger sandbox rebuild

### Incident firing verification (Lab 3, Lab 13)

- Trainer monitors incident-platform logs:
  - PagerDuty: Activities page for `[TEST]` incidents
  - ServiceNow: Incident list filtered by created time + prefix
  - Azure Monitor: Alert history
- If no incidents in 5 min: re-fire via CLI; log the delay

---

## 8. Post-Workshop Ceremony

### Same day (5 PM Day 2)

- [ ] Collect feedback surveys (link or QR code).
- [ ] Thank attendees; recap success metrics hit.
- [ ] Announce post-workshop milestones: "Land your agent PR within 2 weeks → wins a swag item."
- [ ] Share the `rollout-pack/` (one-pager + hook stubs + Bicep skeleton) via email.

### Within 7 days

- [ ] Trainer + curriculum lead debrief:
  - Any P1/P2 defects logged?
  - FAQ items to add?
  - Drift detected in docs?
  - Dry-run feedback applied?

- [ ] Post survey results to leadership:
  - Success metrics hit / missed.
  - NPS (Net Promoter Score).
  - Top feedback themes.

- [ ] Update this runbook:
  - Add new FAQ entries.
  - Revise timing if sessions consistently ran over.

---

**Version:** srea-l300-v1.0.0  
**Effective:** 2026-05-03  
**Next review:** 2026-06-03 (post-first-delivery)
