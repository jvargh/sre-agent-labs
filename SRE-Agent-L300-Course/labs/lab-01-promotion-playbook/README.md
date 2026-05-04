---
lab: 1
level: 300
duration_minutes: 45
track: all
dependencies: []
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# Lab 1 — Promotion Playbook: Privileged + Autonomous Safely

> **Format:** Lecture + paired exercise (45 min) — no hands-on lab.
> **Slides:** Lab 1 deck (printable handout included).
> **Pre-read:** [Run Modes](https://sre.azure.com/docs/capabilities/incident-response-plans) · [Permissions](https://sre.azure.com/docs/tutorials/agent-config/manage-permissions)

---

## Learning Outcome

Attendees complete a **per-trigger decision matrix** for their own service, mapping each trigger type to the correct Permission level, Run Mode, Deep Investigation setting, and Approver pool.

---

## Agenda

| Time | Activity |
|------|----------|
| 0:00–0:15 | Lecture: Why L300 starts here |
| 0:15–0:30 | Walk through the decision matrix |
| 0:30–0:45 | Paired exercise + live review |

---

## ⏱ Checkpoint — 15 min

- [ ] Attendees can state the L200 default stance (Reader / Review) from memory.
- [ ] Attendees understand that L300 is about *justifying every step away from that default*.

---

## Decision Matrix

> This is the matrix attendees leave with. Print it as a handout from the Lab 1 slide deck.

| Per-trigger decision | Read-only chat | Scheduled task (notifications only) | Scheduled task (Azure read) | Scheduled task (Azure write) | Response plan (low sev) | Response plan (P1/P2) |
|----------------------|----------------|-------------------------------------|------------------------------|------------------------------|--------------------------|------------------------|
| Permission level | Reader | Reader | Reader | Privileged (scoped) | Reader | Privileged (scoped) |
| Run mode | Review | Autonomous | Autonomous | Review → Autonomous after bake-in | Review | Autonomous w/ Hooks (Lab 9) |
| Deep investigation | On-demand | Off | Off | Off | Off | On (Mode 2) |
| Approver pool size | n/a | 0 | 0 | ≥ 2 SRE Agent Admins | ≥ 2 | ≥ 2, on-call rotation |

---

## Core L300 Rule — Run Modes vs Hooks

> **Run Modes do *not* gate non-Azure tool calls** (email, Teams, MCP). **Hooks do** (Lab 9).

Do **not** promote to Autonomous on a custom agent that has a `SendOutlookEmail` tool *and* an `az ... write` tool without a PostToolUse hook in place.

This distinction is the single most common production mistake at L300. Hooks (covered in [Lab 9](../lab-09-agent-hooks/README.md)) are the enforcement boundary for non-Azure actions.

---

## ⏱ Checkpoint — 30 min

- [ ] Attendees can explain the Run Modes vs Hooks distinction.
- [ ] Attendees know that Autonomous mode for notifier agents (SendOutlookEmail / SendTeamsMessage) requires a PostToolUse hook.

---

## Paired Exercise (15 min)

### Instructions

1. Pair up with a neighbor.
2. Open the blank matrix template (slide deck appendix or the handout).
3. For **your own production service**, fill in every cell:
   - Name your specific approvers (people, not roles).
   - Name your specific triggers (incident sources, scheduled tasks, chat use-cases).
   - For each trigger, justify the Permission level and Run Mode choice.
4. Swap matrices with your partner. Challenge each row:
   - "Why Autonomous here — what hook covers the blast radius?"
   - "Why Reader here — will the agent have enough access to be useful?"
5. Trainer reviews **3 volunteer examples** live.

### Expected Outcome

Each attendee has a completed matrix they will reference in every subsequent Lab. In Lab 3, you will wire response plans that match these decisions. In Lab 9, you will implement the hooks that make Autonomous safe.

> **Troubleshooting:** If an attendee has no production service to map, use the workshop sample workload (`<sample-app>`) as the target.

---

## References

- [Incident Response Plans](https://sre.azure.com/docs/capabilities/incident-response-plans)
- [Agent Hooks](https://sre.azure.com/docs/capabilities/agent-hooks)
- [Manage Permissions Tutorial](https://sre.azure.com/docs/tutorials/agent-config/manage-permissions)
- For L200 refresher on Run Modes 101, see [SREA-Level200.md §Run Modes](../../../SREA-Level200.md#run-modes)
