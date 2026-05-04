---
title: SRE Agent L300/400 Workshop — Labs Index
source_md_sha: placeholder
srea_version: srea-l300-v1.0.0
---

# Labs Index — Quick Navigation

**All 13 module lab guides at a glance.**

---

## Module Reference Table

| # | Level | Title | Duration | Mode | Track | Status |
|---|-------|-------|----------|------|-------|--------|
| M1 | 300 | Promotion playbook: Privileged + Autonomous safely | 45 min | Lecture + exercise | All | [→ Lab Guide](./module-M1-promotion-playbook/) |
| M2 | 300 | Incident platform connection (PagerDuty / ServiceNow / Azure Monitor) | 60 min | Lab | Parallel tracks | [→ Lab Guide](./module-M2-incident-platform/) |
| M3 | 300 | Response Plans: severity routing, custom-agent dispatch, deep-investigation Mode 2 | 90 min | Lab | All | [→ Lab Guide](./module-M3-response-plans/) |
| M4 | 300 | Skills authoring (SKILL.md + tool attachments + Agent Playground) | 75 min | Lab | All | [→ Lab Guide](./module-M4-skills-authoring/) |
| M5 | 300 | Custom Tools I — Kusto (parameterized) and Link tools | 60 min | Lab | All | [→ Lab Guide](./module-M5-kusto-link-tools/) |
| M6 | 300 | Custom Agents in YAML — handoff chains, allowed_skills, multi-specialist patterns | 90 min | Lab | All | [→ Lab Guide](./module-M6-custom-agents-yaml/) |
| M7 | 300 | MCP integrations II — partner connectors, connection-id/* wildcards, 80-tool budget, Plugin Marketplace | 75 min | Lab | All | [→ Lab Guide](./module-M7-mcp-integrations/) |
| M8 | 400 | Custom Tools II — Python tools (AI-generated, BYO, HTTP-wrap) + managed-identity scopes | 90 min | Lab | All | [→ Lab Guide](./module-M8-python-tools/) |
| M9 | 400 | Agent Hooks — Stop + PostToolUse, prompt vs command, model tiers, sandbox limits | 90 min | Lab | All | [→ Lab Guide](./module-M9-agent-hooks/) |
| M10 | 400 | Audit, FinOps & observability — KQL on customEvents, token-cost analytics, model-tier strategy | 75 min | Lab | All | [→ Lab Guide](./module-M10-audit-finops/) |
| M11 | 400 | Enterprise topology — VNET-isolated observability, cross-tenant connectors, Agent Identity sidecar / Entra Agent ID OBO | 90 min | Lab + lecture | All | [→ Lab Guide](./module-M11-enterprise-topology/) |
| M12 | 400 | Configuration as code — Bicep/ARM for the agent, YAML + REST API v2, knowledge-base persistence files, Kusto schema enrichment | 90 min | Lecture + lab | All | [→ Lab Guide](./module-M12-config-as-code/) |
| M13 | 400 | Production rollout playbook + capstone (multi-agent incident drill end-to-end) | 90 min | Capstone exercise | All | [→ Lab Guide](./module-M13-capstone/) |

---

## How to Use This Index

1. **Start with M1** — Do not skip the promotion playbook. It sets the decision framework for everything that follows.
2. **Follow the timeline** — Days 1 and 2 run in parallel tracks (M2, M3, M13 are synchronized; others can be done independently if needed).
3. **Access each lab** — Click the [→] link in the table to open the full module guide.
4. **Self-paced?** — If you're working through this async, you can do the modules in order, but watch the prerequisite dependencies below.

---

## Prerequisites & Dependencies

### Hard Prerequisites
- **L200 completion:** REQUIRED. Every L300/400 module assumes you completed SREA-Level200.md.
- **M1 first:** The decision matrix from M1 is referenced in M9 (hooks) and M13 (capstone).
- **M2 before M3:** You must connect an incident platform (M2) before creating response plans (M3).

### Soft Prerequisites (suggested order, but not hard blockers)
- **M3 before M6:** M6 builds custom agents that are dispatched by M3 response plans.
- **M5 before M8:** M5 (Kusto tools) + M8 (Python tools) are combined in the M9 hooks labs.
- **M9 before M12:** M9 hooks are wired via the REST API in M12 (configuration as code).
- **M13 capstone:** Requires M1–M12 concepts intact (no skip).

---

## Quick Filters

### If you only have 1 day, prioritize:
1. M1 (promotion playbook)
2. M2 (incident platform)
3. M3 (response plans)
4. M9 (hooks for safety)
5. M10 (audit to verify)
6. M13 (capstone)

*Skip:* M5, M7, M11 (but read the docs links as reference).

### If you only have 4 hours, do:
1. M1 (45 min)
2. M2 (30 min, condensed)
3. M3 (30 min, condensed)
4. M13 capstone (45 min)

### For deep-dive L400 advanced topics:
1. Start with M8–M12 (assumes M1–M7 mastery).
2. M11 (enterprise topology) requires hands-on Entra ID admin consent.

---

## Getting Help

- **Module-specific questions?** See the **Troubleshooting** section in each lab guide.
- **Trainer notes?** Reference 	rainer-notes/operations-runbook.md.
- **Escalation?** See the operations runbook escalation contact tree.

---

## Feedback

Which module did you find most valuable? Which was most challenging?  
→ Complete the **post-workshop survey** in eedback/post-workshop-survey.md and share your thoughts.

---

## Reference

- **Full curriculum:** SREA-Level300.md (536 lines, source of truth)
- **Implementation prompt:** SREA-Level300-prompt.md (16 deliverables, acceptance criteria)
- **Workshop README:** README.md (overview + module map + prerequisites)
- **Trainer runbook:** 	rainer-notes/operations-runbook.md
- **Timing script:** 	rainer-notes/timing-script.md (minute-by-minute facilitator guide)

---

**Version:** srea-l300-v1.0.0  
**Last updated:** [timestamp at build time]  
**Feedback:** srea-l300-feedback@sre.azure.com
