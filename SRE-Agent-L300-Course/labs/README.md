---
title: SRE Agent L300/400 Workshop — Labs Index
source_md_sha: placeholder
srea_version: srea-l300-v1.0.0
---

# Labs Index — Quick Navigation

**All 13 lab guides at a glance.**

---

## Lab Reference Table

| # | Level | Title | Duration | Mode | Track | Status |
|---|-------|-------|----------|------|-------|--------|
| 1 | 300 | Promotion playbook: Privileged + Autonomous safely | 45 min | Lecture + exercise | All | [→ Lab Guide](./lab-01-promotion-playbook/) |
| 2 | 300 | Incident platform connection (PagerDuty / ServiceNow / Azure Monitor) | 60 min | Lab | Parallel tracks | [→ Lab Guide](./lab-02-incident-platform/) |
| 3 | 300 | Response Plans: severity routing, custom-agent dispatch, deep-investigation Mode 2 | 90 min | Lab | All | [→ Lab Guide](./lab-03-response-plans/) |
| 4 | 300 | Skills authoring (SKILL.md + tool attachments + Agent Playground) | 75 min | Lab | All | [→ Lab Guide](./lab-04-skills-authoring/) |
| 5 | 300 | Custom Tools I — Kusto (parameterized) and Link tools | 60 min | Lab | All | [→ Lab Guide](./lab-05-kusto-link-tools/) |
| 6 | 300 | Custom Agents in YAML — handoff chains, allowed_skills, multi-specialist patterns | 90 min | Lab | All | [→ Lab Guide](./lab-06-custom-agents-yaml/) |
| 7 | 300 | MCP integrations II — partner connectors, connection-id/* wildcards, 80-tool budget, Plugin Marketplace | 75 min | Lab | All | [→ Lab Guide](./lab-07-mcp-integrations/) |
| 8 | 400 | Custom Tools II — Python tools (AI-generated, BYO, HTTP-wrap) + managed-identity scopes | 90 min | Lab | All | [→ Lab Guide](./lab-08-python-tools/) |
| 9 | 400 | Agent Hooks — Stop + PostToolUse, prompt vs command, model tiers, sandbox limits | 90 min | Lab | All | [→ Lab Guide](./lab-09-agent-hooks/) |
| 10 | 400 | Audit, FinOps & observability — KQL on customEvents, token-cost analytics, model-tier strategy | 75 min | Lab | All | [→ Lab Guide](./lab-10-audit-finops/) |
| 11 | 400 | Enterprise topology — VNET-isolated observability, cross-tenant connectors, Agent Identity sidecar / Entra Agent ID OBO | 90 min | Lab + lecture | All | [→ Lab Guide](./lab-11-enterprise-topology/) |
| 12 | 400 | Configuration as code — Bicep/ARM for the agent, YAML + REST API v2, knowledge-base persistence files, Kusto schema enrichment | 90 min | Lecture + lab | All | [→ Lab Guide](./lab-12-config-as-code/) |
| 13 | 400 | Production rollout playbook + capstone (multi-agent incident drill end-to-end) | 90 min | Capstone exercise | All | [→ Lab Guide](./lab-13-capstone/) |

---

## How to Use This Index

1. **Start with Lab 1** — Do not skip the promotion playbook. It sets the decision framework for everything that follows.
2. **Follow the timeline** — Days 1 and 2 run in parallel tracks (Labs 2, 3, 13 are synchronized; others can be done independently if needed).
3. **Access each lab** — Click the [→] link in the table to open the full lab guide.
4. **Self-paced?** — If you're working through this async, you can do the labs in order, but watch the prerequisite dependencies below.

---

## Prerequisites & Dependencies

### Hard Prerequisites
- **L200 completion:** REQUIRED. Every L300/400 lab assumes you completed SREA-Level200.md.
- **Lab 1 first:** The decision matrix from Lab 1 is referenced in Lab 9 (hooks) and Lab 13 (capstone).
- **Lab 2 before Lab 3:** You must connect an incident platform (Lab 2) before creating response plans (Lab 3).

### Soft Prerequisites (suggested order, but not hard blockers)
- **Lab 3 before Lab 6:** Lab 6 builds custom agents that are dispatched by Lab 3 response plans.
- **Lab 5 before Lab 8:** Lab 5 (Kusto tools) + Lab 8 (Python tools) are combined in the Lab 9 hooks labs.
- **Lab 9 before Lab 12:** Lab 9 hooks are wired via the REST API in Lab 12 (configuration as code).
- **Lab 13 capstone:** Requires Labs 1–12 concepts intact (no skip).

---

## Quick Filters

### If you only have 1 day, prioritize:
1. Lab 1 (promotion playbook)
2. Lab 2 (incident platform)
3. Lab 3 (response plans)
4. Lab 9 (hooks for safety)
5. Lab 10 (audit to verify)
6. Lab 13 (capstone)

*Skip:* Labs 5, 7, 11 (but read the docs links as reference).

### If you only have 4 hours, do:
1. Lab 1 (45 min)
2. Lab 2 (30 min, condensed)
3. Lab 3 (30 min, condensed)
4. Lab 13 capstone (45 min)

### For deep-dive L400 advanced topics:
1. Start with Labs 8–12 (assumes Labs 1–7 mastery).
2. Lab 11 (enterprise topology) requires hands-on Entra ID admin consent.

---

## Getting Help

- **Lab-specific questions?** See the **Troubleshooting** section in each lab guide.
- **Trainer notes?** Reference 	rainer-notes/operations-runbook.md.
- **Escalation?** See the operations runbook escalation contact tree.

---

## Feedback

Which lab did you find most valuable? Which was most challenging?  
→ Complete the **post-workshop survey** in eedback/post-workshop-survey.md and share your thoughts.

---

## Reference

- **Full curriculum:** SREA-Level300.md (536 lines, source of truth)
- **Implementation prompt:** SREA-Level300-prompt.md (16 deliverables, acceptance criteria)
- **Workshop README:** README.md (overview + course map + prerequisites)
- **Trainer runbook:** 	rainer-notes/operations-runbook.md
- **Timing script:** 	rainer-notes/timing-script.md (minute-by-minute facilitator guide)

---

**Version:** srea-l300-v1.0.0  
**Last updated:** [timestamp at build time]  
**Feedback:** srea-l300-feedback@sre.azure.com
