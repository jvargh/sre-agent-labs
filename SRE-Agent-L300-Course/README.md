# Azure SRE Agent L300/400 Advanced Workshop

A 2-day, 17-hour instructor-led advanced workshop for DevOps and SRE-Ops practitioners who have completed Level 200. Attendees choose one of three parallel tracks (PagerDuty, ServiceNow, or Azure Monitor) and learn to configure custom agents, hooks, tools, and response plans for production incident response.

## Workshop Overview

| Attribute | Details |
|-----------|---------|
| **Duration** | 2 days, ~17 hours |
| **Levels** | 300 (Advanced Operator) → 400 (Architect/Platform Owner) |
| **Format** | Instructor-led, 70% hands-on labs |
| **Attendee tracks** | PagerDuty / ServiceNow / Azure Monitor (choose one) |
| **Hard prerequisite** | [Level 200 Workshop](../SRE-Agent-L200-Course/) completion required |
| **Cost cap** | USD 50 per attendee per day |

## Prerequisites

Send this checklist to attendees **1 week before the workshop**.

### Required items (9)

| # | Item | Notes |
|---|------|-------|
| 1 | L200 completion | Confirmed by trainer — no exceptions. |
| 2 | Two non-prod sandbox subscriptions | One for the agent, one to simulate a "remote" tenant for the cross-tenant lab (Lab 11). |
| 3 | An incident platform sandbox | Choose **one**: free PagerDuty trial **or** ServiceNow PDI **or** Azure Monitor alert rule wired to a sample workload. Declare in registration form. |
| 4 | An ADX (Kusto) cluster | Free tier is fine; needs ≥10k rows for the Kusto-tools lab (Lab 5). |
| 5 | A reachable external MCP endpoint | Datadog trial, Splunk free tier, or self-hosted demo MCP server in workshop's shared sandbox. Trainer provides credentials. |
| 6 | Local toolchain | `az` CLI ≥latest, `kubectl`, Python 3.12, Node 20, .NET 9, `jq`, VS Code with SRE Agent MCP extension. |
| 7 | Repo write access | Attendee owns a repo where they will land agent IaC PR and `SKILL.md` PR. |
| 8 | Entra ID admin contact | Named individual reachable during Lab 11 to grant MI federation / app-registration consent. Without this, Lab 11 stops. |
| 9 | Budget owner sign-off | Cost cap per attendee per day (recommended: USD 50). Lab 12 references it. |

### Pre-read (45 min, mandatory)

Attendees must complete before Day 1:

- [Capabilities → Incident Response Plans](https://sre.azure.com/docs/capabilities/incident-response-plans)
- [Capabilities → MCP Connectors & Tools](https://sre.azure.com/docs/capabilities/mcp-connectors)
- [Capabilities → Agent Hooks](https://sre.azure.com/docs/capabilities/agent-hooks)
- [Capabilities → Audit Agent Actions](https://sre.azure.com/docs/capabilities/audit-agent-actions)

## Course Map

| # | Level | Title | Mode | Duration | Track |
|----|-------|-------|------|----------|-------|
| 1 | 300 | [Promotion playbook: Privileged + Autonomous safely](labs/lab-01-promotion-playbook/) | Lecture + Exercise | 45 min | All |
| 2 | 300 | [Incident platform connection (PagerDuty / ServiceNow / Azure Monitor)](labs/lab-02-incident-platform/) | Lab | 60 min | All |
| 3 | 300 | [Response Plans: severity routing, custom-agent dispatch, deep-investigation Mode 2](labs/lab-03-response-plans/) | Lab | 90 min | All |
| 4 | 300 | [Skills authoring (`SKILL.md` + tool attachments + Agent Playground)](labs/lab-04-skills-authoring/) | Lab | 75 min | All |
| 5 | 300 | [Custom Tools I — Kusto (parameterized) and Link tools](labs/lab-05-kusto-link-tools/) | Lab | 60 min | All |
| 6 | 300 | [Custom Agents in YAML — handoff chains, `allowed_skills`, multi-specialist patterns](labs/lab-06-custom-agents-yaml/) | Lab | 90 min | All |
| 7 | 300 | [MCP integrations II — partner connectors, wildcards, 80-tool budget, Plugin Marketplace](labs/lab-07-mcp-integrations/) | Lab | 75 min | All |
| 8 | 400 | [Custom Tools II — Python tools (AI-generated, BYO, HTTP-wrap) + managed-identity scopes](labs/lab-08-python-tools/) | Lab | 90 min | All |
| 9 | 400 | [Agent Hooks — Stop + PostToolUse, prompt vs command, model tiers, sandbox limits](labs/lab-09-agent-hooks/) | Lab | 90 min | All |
| 10 | 400 | [Audit, FinOps & observability — KQL on `customEvents`, token-cost analytics, model-tier strategy](labs/lab-10-audit-finops/) | Lab | 75 min | All |
| 11 | 400 | [Enterprise topology — VNET-isolated observability, cross-tenant connectors, Agent Identity sidecar](labs/lab-11-enterprise-topology/) | Lab + Lecture | 90 min | All |
| 12 | 400 | [Configuration as code — Bicep/ARM for the agent, YAML + REST API v2, knowledge-base persistence](labs/lab-12-config-as-code/) | Lecture + Lab | 90 min | All |
| 13 | 400 | [Production rollout playbook + capstone (multi-agent incident drill end-to-end)](labs/lab-13-capstone/) | Capstone | 90 min | All |

**Total: ~17 hours.** If time is limited to one day, cut one of {Lab 5, Lab 7, Lab 11} but **do not** cut Lab 1, Lab 3, Lab 9, Lab 10, or Lab 13.

## Directory Structure

```
SRE-Agent-L300-Course/
├── README.md                          # This file
├── labs/
│   ├── README.md                      # Labs index
│   ├── lab-01-promotion-playbook/
│   ├── lab-02-incident-platform/
│   ├── lab-03-response-plans/
│   ├── lab-04-skills-authoring/
│   ├── lab-05-kusto-link-tools/
│   ├── lab-06-custom-agents-yaml/
│   ├── lab-07-mcp-integrations/
│   ├── lab-08-python-tools/
│   ├── lab-09-agent-hooks/
│   ├── lab-10-audit-finops/
│   ├── lab-11-enterprise-topology/
│   ├── lab-12-config-as-code/
│   └── lab-13-capstone/
├── trainer-notes/
│   ├── operations-runbook.md          # Day-of checklist, FAQs, escalation tree
│   ├── timing-script.md               # Minute-by-minute facilitator script
│   ├── credentials-template.md        # (Generated at provisioning time)
│   └── dry-run-feedback.md            # (QA & post-dry-run retrospective)
├── sandbox/
│   ├── provision.sh                   # Per-attendee sandbox provisioning
│   ├── teardown.sh                    # Sandbox cleanup
│   └── cost-cap-watcher.bicep         # Lab 12 cost-cap alert rule
├── rollout-pack/
│   ├── README.md                      # Production rollout pack overview
│   ├── production-rollout-1pager.md   # 10-step rollout playbook from Lab 13
│   ├── hook-stubs/
│   │   ├── stop-prompt-completeness.yaml
│   │   ├── posttooluse-command-block.yaml
│   │   └── posttooluse-audit.yaml
│   ├── bicep-skeleton.bicep           # Agent IaC skeleton
│   ├── terraform-skeleton.tf          # Terraform AVM skeleton
│   ├── workbook-export.json           # KQL workbook from Lab 10
│   └── deploy.sh                      # Smoke-test deployment script
├── feedback/
│   └── post-workshop-survey.md        # 8-metric survey + open feedback
└── reference/
    ├── slide-deck.md                  # Lab 1, Lab 11 lectures + Lab 3/Lab 9/Lab 10/Lab 12 reference slides
    ├── sample-skill-repo/             # D7: good & bad SKILL.md examples
    ├── mcp-reference-servers/         # D8: npx + Python stdio MCP repos
    └── rest-api-v2-clients/           # D6: PowerShell + Python PUT client
```

## How to Provision a Sandbox

### Prerequisites for provisioning

Ensure you have:
- Azure CLI (latest version)
- A non-prod subscription with Owner permissions
- An incident-platform trial account (PagerDuty, ServiceNow, or Azure Monitor)
- ADX cluster URL and database name

### Provisioning steps

1. **Clone the workshop repository:**
   ```bash
   git clone <workshop-repo-url>
   cd SRE-Agent-L300-Course
   ```

2. **Run the provisioning script:**
   ```bash
   ./sandbox/provision.sh \
     --attendee-handle <your-name> \
     --incident-platform pagerduty|servicenow|azure-monitor \
     --subscription-id <your-sub-id> \
     --rg-name srea-l300-<your-name>
   ```

3. **Script will output:**
   - Agent endpoint URL
   - App Insights connection string
   - ADX cluster URL
   - Sample-workload URL
   - Incident-platform credentials (via Key Vault references)

4. **Verify provisioning:**
   ```bash
   az sre-agent show \
     --resource-group srea-l300-<your-name> \
     --name agent-<your-name>
   ```

   Status should be `Running` (may take 2–3 min).

## How to Tear Down

When the workshop ends (or if you need to stop incurring costs):

```bash
./sandbox/teardown.sh \
  --attendee-handle <your-name> \
  --resource-group srea-l300-<your-name> \
  --subscription-id <your-sub-id>
```

This removes:
- Resource group (and all resources)
- Key Vault secrets
- ADX sample data
- Incident-platform test data

## Track Selection

Attendees choose **one** track during registration and stay with it for Labs 2, 3, and 13:

| Track | Pros | Cons | Use case |
|-------|------|------|----------|
| **PagerDuty** | Mature API, clear severity model, webhooks | Trial expires after 14 days | Organizations running PagerDuty |
| **ServiceNow** | CMDB integration, change-event correlation | PDI provisioning can take hours | Enterprises with ServiceNow |
| **Azure Monitor** | Native integration, cost-aware alerting | Limited cross-platform | Azure-first shops |

**Trainer responsibility:** ensure sandboxes are seeded with at least one live incident per platform before Day 1 starts.

## Day 1 vs Day 2 Split

### Day 1 (9 AM – 5 PM, ~8 hours)

| Time | Lab | Duration | Notes |
|------|--------|----------|-------|
| 9:00–9:45 | Lab 1: Promotion playbook | 45 min | Lecture + paired decision matrix |
| 9:45–10:45 | Lab 2: Incident platform | 60 min | Lab (parallel tracks) |
| 10:45–11:00 | Break | 15 min | |
| 11:00–12:30 | Lab 3: Response Plans | 90 min | Lab (multi-agent handoff) |
| 12:30–1:00 | Lunch | 30 min | |
| 1:00–2:15 | Lab 4: Skills authoring | 75 min | Lab + Agent Playground |
| 2:15–2:30 | Break | 15 min | |
| 2:30–3:30 | Lab 5: Kusto tools | 60 min | Lab (parameterized queries) |
| 3:30–5:00 | Lab 6: Custom Agents YAML | 90 min | Lab (3-agent chain) |

### Day 2 (9 AM – 5 PM, ~9 hours)

| Time | Lab | Duration | Notes |
|------|--------|----------|-------|
| 9:00–10:30 | Lab 7: MCP integrations | 90 min | Lab (80-tool budget, Plugin Marketplace) |
| 10:30–10:45 | Break | 15 min | |
| 10:45–12:15 | Lab 8: Python tools | 90 min | Lab (AI-gen + BYO + HTTP wrapper) |
| 12:15–1:00 | Lunch | 45 min | |
| 1:00–2:30 | Lab 9: Agent Hooks | 90 min | Lab (Stop + PostToolUse, prompt vs command) |
| 2:30–2:45 | Break | 15 min | |
| 2:45–4:00 | Lab 10: Audit & FinOps | 75 min | Lab (KQL workbook, token analytics) |
| 4:00–5:30 | Lab 11: Enterprise topology | 90 min | Lecture (30 min) + Lab (60 min) |

### Optional extension (if 2 days + 1 afternoon)

| Time | Lab |
|------|--------|
| Day 3, 9–10:30 | Lab 12: Configuration as code |
| Day 3, 10:45–12:15 | Lab 13: Capstone |

## Synchronization Points (Critical)

These labs **must** run in lockstep across all three tracks:

- **Lab 2:** All platforms connect their incident source at the same time (for synthetic-incident testing).
- **Lab 3:** All tracks fire test incidents and verify response plans fire simultaneously (checkpoint).
- **Lab 13:** Capstone drill — trainer fires three synthetic incidents; all attendees respond together.

Designate **one trainer** per track; one **lead trainer** coordinates the checkpoint pulses via chat/radio.

## Success Metrics

| Metric | Target |
|--------|--------|
| Attendees with a non-default response plan dispatching to a YAML-defined custom agent | 100% |
| Attendees with at least one Stop hook + one PostToolUse hook attached at agent level | 100% |
| Attendees with at least one Kusto tool **and** one Python tool wired into a custom agent | ≥90% |
| Capstone (Lab 13) — all three synthetic incidents handled end-to-end without manual intervention | ≥80% |
| Audit workbook (Lab 10) saved + shared with the attendee's team | ≥90% |
| Attendees who land an agent-as-code PR (Lab 12) within 2 weeks post-workshop | ≥75% |
| Production response plans flipped from Review → Autonomous within 6 weeks post-workshop | ≥50% (only where audit data supports it) |
| Cost per attendee per workshop day | ≤USD 50 |

## Reference Index

**Capabilities (advanced)**
- [Incident Response Plans](https://sre.azure.com/docs/capabilities/incident-response-plans)
- [PagerDuty Incidents](https://sre.azure.com/docs/capabilities/pagerduty-incidents)
- [ServiceNow Incidents](https://sre.azure.com/docs/capabilities/servicenow-incidents)
- [Azure Monitor Alerts](https://sre.azure.com/docs/capabilities/azure-monitor-alerts)
- [Deep Investigation (capability ref)](https://sre.azure.com/docs/capabilities/deep-investigation)
- [Workflow Automation](https://sre.azure.com/docs/capabilities/workflow-automation)
- [HTTP Triggers](https://sre.azure.com/docs/capabilities/http-triggers)
- [MCP Connectors & Tools](https://sre.azure.com/docs/capabilities/mcp-connectors)
- [Plugin Marketplace](https://sre.azure.com/docs/capabilities/plugin-marketplace)
- [Kusto Tools](https://sre.azure.com/docs/capabilities/kusto-tools)
- [Python Tools](https://sre.azure.com/docs/capabilities/python-code-execution)
- [Agent Hooks](https://sre.azure.com/docs/capabilities/agent-hooks)
- [Agent Playground](https://sre.azure.com/docs/capabilities/agent-playground)
- [Tools & Skills (global)](https://sre.azure.com/docs/capabilities/global-tools-page)
- [Audit Agent Actions](https://sre.azure.com/docs/capabilities/audit-agent-actions)
- [Monitor Agent Usage](https://sre.azure.com/docs/capabilities/monitor-agent-usage)
- [Track Incident Value](https://sre.azure.com/docs/capabilities/track-incident-value)
- [Azure Observability VNET](https://sre.azure.com/docs/capabilities/azure-observability-vnet)
- [Cross-Tenant Access](https://sre.azure.com/docs/capabilities/cross-tenant-access)

**Tutorials**
- [Agent Config](https://sre.azure.com/docs/tutorials/agent-config/*) — Manage Permissions, Setup Response Plan, Create/Manage Hooks (UI), Agent Hooks (API)
- [Tools](https://sre.azure.com/docs/tutorials/tools/*) — Create Kusto Tool, Create Python Tool
- [Connectors](https://sre.azure.com/docs/tutorials/connectors/*) — Setup Kusto, Setup MCP, Setup PagerDuty, Setup ServiceNow, Cross-Tenant ADO
- [Incident Platforms](https://sre.azure.com/docs/tutorials/incident-platforms/*) — Setup PagerDuty Indexing, ServiceNow Indexing
- [Automation](https://sre.azure.com/docs/tutorials/automation/create-scheduled-task)
- [Knowledge](https://sre.azure.com/docs/tutorials/knowledge/*) — Upload Knowledge Document, Connect Knowledge
- [Advanced](https://sre.azure.com/docs/tutorials/advanced/deep-investigation) — Run a Deep Investigation (Mode 2)

**Concepts (advanced re-reads)**
- [Agent Identity](https://sre.azure.com/docs/concepts/agent-identity)
- [Agent Reasoning](https://sre.azure.com/docs/concepts/agent-reasoning)
- [Threads](https://sre.azure.com/docs/concepts/threads)
- [Memory & Knowledge](https://sre.azure.com/docs/concepts/memory#proactive-knowledge-persistence) — Proactive persistence section
- [Deep Context / Workspace Tools](https://sre.azure.com/docs/concepts/workspace-tools)

**Reference**
- [REST API v2](https://sre.azure.com/docs/reference/*) — `PUT /api/v2/extendedAgent/agents/{agentName}`

---

**Version:** srea-l300-v1.0.0  
**Last updated:** 2026-05-03  
**Trainer runbook:** [trainer-notes/operations-runbook.md](trainer-notes/operations-runbook.md)
