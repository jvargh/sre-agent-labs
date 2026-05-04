---
title: SRE Agent L300/400 — 10-Step Production Rollout Playbook
source_md_sha: placeholder
srea_version: srea-l300-v1.0.0
---

# 10-Step Production Rollout Playbook

**Print this. Share with your team. Follow it in order. Do not skip step 6.**

---

## The 10 Steps

### 1. Land agent IaC PR
Deploy the agent resource (Bicep/Terraform) from version control. Include UAMI, App Insights, Log Analytics, role assignments per your M1 decision matrix. **Review board:** Must see that UAMI scope matches your team's approval-pool definitions.

### 2. Delete the quickstart response plan
In the Builder UI, go to Incident response plans and delete the auto-generated default plan. This prevents the L300 double-route bug. You now own all routing logic.

### 3. Author skills
Create 3–5 workspace skills for your team's top known runbooks (e.g., postgres-troubleshooting, 
etwork-diagnostics, pi-quota-recovery). Use clear trigger phrases in the SKILL.md description so the agent loads them automatically.

### 4. Wire custom agents + handoff chain
Define your incident-triager → specialist chain in YAML (or Agent Canvas). Example:
- incident-triager: classifies severity + root cause type; hands off.
- db-expert, pi-expert: deep investigation; produce root cause + action.
- 
otifier: summarizes + posts to Teams/email/PagerDuty.

Commit YAML to your repo.

### 5. Add Kusto + Python tools
Create one Kusto tool (parameterized query on your ADX cluster) + one Python tool (HTTP wrapper to an internal API or Azure Function). Attach both to your specialists. Add a screenshot of each tool's portal test to your PR.

### 6. **Wire hooks (M9 types) BEFORE flipping any response plan to Autonomous**
Install at minimum:
- **Stop hook (prompt):** Validate that responses include root cause + recommended action.
- **PostToolUse hook (command):** Block dangerous patterns (m -rf, sudo, z group delete).

**No exceptions.** Review board checks that hooks are in the agent-level configuration.

### 7. Build the audit workbook
Import the KQL workbook JSON (from the rollout pack) into your App Insights. Customize the parameters (ThreadId, lookbackDays, agentName). Save and share the workbook URL with your team's on-call rotation.

### 8. Set per-task + per-hook model tiers
**Hooks:** Use Fast reasoning (default). Promote to Reasoning only for policy-critical decisions.  
**Scheduled tasks:** Use Fast for polling tasks; use Reasoning for deep RCA tasks.  
**Custom agents:** Document in a runbook table which agents use which model tier and why.

### 9. Rollout: Shadow mode (Review on every plan) for 2 weeks
Deploy your response plans with **Review mode on all plans**, no Autonomous. Every incident generates an approval request. Your team reviews, learns, audits.

After 2 weeks:
- Review IncidentActivitySnapshot in your KQL workbook. Measure accuracy, tool coverage, token cost per incident.
- **Only then:** Promote individual plans from Review → Autonomous if the audit data justifies it.

### 10. Operations: Weekly audit review + monthly spend retro
Every week: query IncidentActivitySnapshot + ApprovalDecision. Spot-check 1–2 incidents end-to-end.  
Every month: sum token spend by custom agent. Adjust model tiers if spend is above budget.

---

## Decision Gates

| Step | Gate | Owner | Approval |
|------|------|-------|----------|
| 1 | IaC PR | Platform Eng | RBAC matrix reviewed by Security Eng |
| 2 | Quickstart deleted | Trainer | Incident response plans page confirms no default plan |
| 3 | Skills authored | Team Lead | At least 3 skills in the Builder UI |
| 4 | Agents + chain | SRE Eng | YAML reviewed in PR; canvas shows handoff edges |
| 5 | Tools + screenshots | Platform Eng | 1 Kusto + 1 Python tool attached; playground test shown |
| 6 | Hooks wired | Security Eng | Stop hook + PostToolUse block hook at agent level; test incident blocked dangerous command |
| 7 | Workbook shared | Observability Eng | Workbook URL + 5 query screenshots shared in Slack |
| 8 | Model tiers documented | FinOps Eng | Runbook table filed in team wiki |
| 9 | Shadow mode live | Ops Lead | Review mode on all plans; 2-week audit data collected |
| 10 | Operations cadence | On-call Rotation | Weekly review + monthly retro scheduled in team calendar |

---

## Rollback Plan

If at any step you discover a critical issue (e.g., hooks blocking legitimate traffic, runaway token spend), **rollback is immediate:**

1. Flip all response plans back to **Review mode**.
2. File a bug with reproduction steps (tag: srea-l300-production-issue).
3. Escalate to the SRE Agent team via your named contact (from the workshop operations runbook).
4. Await guidance before re-attempting Autonomous promotion.

---

## Contingencies

**What if my Entra ID admin is unavailable for cross-tenant connectors (M11)?**  
→ Defer to async post-workshop. Reference capabilities/cross-tenant-access docs. You can still land step 1–9 with single-tenant connectors.

**What if token spend exceeds budget in shadow mode?**  
→ Review the KQL workbook. Identify the expensive agent/model tier. Dial back Reasoning to Fast for low-stakes decisions. Or shorten the LLM prompt in your custom agent's system_prompt.

**What if an incident gets stuck in Review mode and the SLA timer is running?**  
→ Operator: Manually approve in Builder UI. Async: review why the approval took so long; add a shorter timeout, or mark the plan as lower-risk so it auto-promotes to Autonomous sooner.

---

## Success Criteria

✓ All 10 steps completed within 2 weeks of the workshop.  
✓ Incident response plans dispatching to custom agents (≥80 % of triggered incidents).  
✓ Hooks blocking dangerous commands (≥1 per audit period).  
✓ Token spend ≤ budget (≤ USD 50/attendee/day).  
✓ Team confidence: "We know how to add a new response plan and wire hooks before going Autonomous."

---

**Version:** srea-l300-v1.0.0  
**Reference:** SREA-Level300.md §M13  
**Last reviewed:** TBD
