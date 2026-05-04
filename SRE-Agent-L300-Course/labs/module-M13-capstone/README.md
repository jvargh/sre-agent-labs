---
module: M13
level: 400
duration_minutes: 90
track: all
dependencies: [M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12]
source_md_sha: placeholder
---

# M13 — Capstone: Production Rollout Playbook + Multi-Agent Incident Drill

## Learning Outcome

Attendees demonstrate end-to-end multi-agent incident handling without manual intervention. Three synthetic incidents are fired back-to-back at different severities. The drill validates every skill from M1–M12 in a single integrated exercise.

---

## Prerequisites

- **All M1–M12 labs completed** — response plans, custom agents, skills, tools, hooks, audit workbook, and IaC all deployed.
- All hooks (Stop + PostToolUse) wired at agent level.
- All custom agents deployed and reachable via handoff chain.
- Incident platform connector active and showing "Connected."

---

## Time Budget (90 minutes)

| Phase | Duration | Activity |
|-------|----------|----------|
| Setup | 15 min | Verify prerequisites, confirm all response plans active, run connectivity smoke test |
| Drill | 45 min | Fire 3 synthetic incidents, observe agent behavior, capture evidence |
| Scoring | 15 min | Score against `capstone/scoring-rubric.md`, review results |
| Rollout Discussion | 15 min | Walk through the 10-step production rollout playbook, Q&A |

---

## The Drill

The trainer fires three synthetic incidents back-to-back. After the trigger, **no human input** should be required.

### Incident 1: `[TEST] P3 high latency`

| Aspect | Expected Behavior |
|--------|-------------------|
| Routing | Routed to `low-sev-triager` (M3) |
| Run Mode | **Review** mode — agent proposes one mitigation, human approves |
| Deep Investigation | OFF (not triggered for P3) |
| Hooks | Tool calls are audited via PostToolUse hook |
| Validation | Verify in audit workbook that the correct agent handled this incident |

### Incident 2: `[TEST] P1 db corruption`

| Aspect | Expected Behavior |
|--------|-------------------|
| Routing | `incident_triager` → `db-expert` → `notifier` (M6 handoff chain) |
| Deep Investigation | **Mode 2** fires automatically (auto-triggered for P1) |
| Stop Hook (M9) | Ensures the response includes both **root cause** and **recommended action** |
| PostToolUse Hook | Blocks any `az group delete` command the model might hallucinate |
| Notifier | Sends both **Teams message** and **email** notification |
| Validation | Full handoff chain visible in audit workbook per-thread replay |

### Incident 3: `[TEST] P2 api 500s`

| Aspect | Expected Behavior |
|--------|-------------------|
| Routing | Same chain as Incident 2, but branches to `api-expert` instead of `db-expert` |
| Agent Selection | Audit query (M10) shows which custom agent was selected |
| Token Cost | Audit query returns total token cost for this incident |
| Notifier | Sends both Teams + email for P2 severity |
| Validation | Agent selection + token cost visible in KQL workbook |

---

## Scoring

Reference: [`capstone/scoring-rubric.md`](../../capstone/scoring-rubric.md)

**Pass threshold: ≥ 80%**

The rubric covers machine-checkable items (routing correctness, hook enforcement, notification delivery, audit data completeness) and judgment items (root-cause quality, mitigation relevance). See `checklist.md` for the full checkpoint list.

---

## Production Rollout Playbook (10 Steps)

Take this home. This is the sequence for rolling out the SRE Agent to production:

1. **Land agent IaC PR** (M12) → review → merge.
2. **Connect incident platform** (M2) → delete the quickstart response plan.
3. **Author skills** (M4) for the team's top 5 known runbooks.
4. **Wire custom agents + handoff chain** (M6) in YAML; review in PR.
5. **Add Kusto + Python tools** (M5, M8) — one PR per tool, each with a portal-playground test screenshot.
6. **Wire hooks** (M9) **before** flipping any response plan to Autonomous.
7. **Build the audit workbook** (M10).
8. **Set per-task and per-hook model tiers** per the FinOps overlay.
9. **Rollout: shadow mode** (Review on every plan) for 2 weeks → promote individual plans to Autonomous as the audit data justifies.
10. **Operations:** weekly review of `IncidentActivitySnapshot`, monthly review of token spend by custom agent.

---

## Cleanup

After the drill:

1. Tear down all test incidents (close/resolve in the incident platform).
2. Export audit data from the KQL workbook for post-workshop review.
3. Optionally destroy the sandbox resource group if no longer needed.

---

## References

- [SREA-Level300.md §M13](../../../SREA-Level300.md) — Source curriculum
- [Scoring Rubric](../../capstone/scoring-rubric.md)
- [Checklist](./checklist.md)
- [Troubleshooting](./troubleshooting.md)
