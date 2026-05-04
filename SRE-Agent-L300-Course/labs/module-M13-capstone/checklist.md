---
module: M13
level: 400
type: checklist
---

# M13 Capstone — Checklist

Use this checklist to verify all capstone drill requirements before scoring.

---

## Pre-Drill Setup

- [ ] All response plans active and non-overlapping
- [ ] All hooks (Stop + PostToolUse) wired at agent level
- [ ] Incident platform connector shows "Connected"
- [ ] All custom agents (low-sev-triager, incident_triager, db-expert, api-expert, notifier) deployed

---

## Incident 1: `[TEST] P3 high latency`

- [ ] P3 incident: routed to `low-sev-triager` in Review mode
- [ ] Agent proposes one mitigation (not auto-executed)
- [ ] PostToolUse audit hook logs the tool call

---

## Incident 2: `[TEST] P1 db corruption`

- [ ] P1 incident: full handoff chain executed (`incident_triager` → `db-expert` → `notifier`)
- [ ] P1 incident: Mode 2 deep investigation auto-triggered
- [ ] P1 incident: Stop hook enforces root cause + recommended action in response
- [ ] P1 incident: dangerous command (`az group delete`) blocked by PostToolUse hook
- [ ] Notifier sent Teams + email for P1

---

## Incident 3: `[TEST] P2 api 500s`

- [ ] P2 incident: correct specialist (`api-expert`) selected instead of `db-expert`
- [ ] Notifier sent Teams + email for P2

---

## Audit & Observability

- [ ] Audit workbook shows per-thread replay for all 3 incidents
- [ ] Token cost query returns data for all custom agents

---

## Scoring

- [ ] Score ≥ 80% on scoring rubric (`capstone/scoring-rubric.md`)
