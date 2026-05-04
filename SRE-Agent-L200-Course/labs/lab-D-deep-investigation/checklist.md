# Lab D — Deep Investigation: Completion Checklist

Use this checklist to confirm you have successfully completed every step of Lab D.

---

## Pre-Lab Readiness

- [ ] Agent is in `Running` state (Lab A complete)
- [ ] At least one resource group connected to the agent (Lab B complete)
- [ ] Successfully ran diagnostic chat prompts in Lab C
- [ ] Signed in with a work or school (Entra ID) account
- [ ] Hold **SRE Agent Administrator** role on the agent resource

---

## Lab Steps

- [ ] **Step 1:** Clicked **+** → **Deep investigation** in chat input and confirmed the dialog
- [ ] **Step 2:** Verified sparkle badge (✨) and status banner are visible
- [ ] **Step 3:** Sent the investigation prompt:
  ```
  Investigate why the <sample-app> has elevated latency. Check logs, metrics,
  and recent deployments to identify the root cause.
  ```
- [ ] **Step 4:** Approved the OBO authorization card
- [ ] **Step 5:** Observed all four phases in the investigation tree:
  - [ ] Phase 1 — Incident research
  - [ ] Phase 2 — Forming hypotheses (2–4 nodes appeared)
  - [ ] Phase 3 — Validating in parallel (saw Validated / Invalidated / Inconclusive labels)
  - [ ] Phase 4 — Conclusion node with root cause and recommended actions
- [ ] **Step 6:** Clicked a hypothesis node and inspected evidence (KQL results, metrics, or logs)
- [ ] **Step 7:** Turned off deep investigation (clicked X on sparkle badge)

---

## Checkpoints

| # | Checkpoint | Pass? |
|---|-----------|-------|
| 1 | Sparkle badge and status banner visible after enabling deep investigation | ☐ |
| 2 | Investigation tree reached Phase 4 with a conclusion node | ☐ |
| 3 | Clicked a hypothesis node and viewed evidence detail panel | ☐ |
| 4 | Deep investigation turned off — badge and banner gone | ☐ |

---

## Discussion Topics Covered

- [ ] Understood cost/latency trade-off for deep investigations
- [ ] Noted OBO authorization timeout is 10 minutes
- [ ] Aware that partial results are preserved on cancel

---

## Success Criteria

✅ **Lab D is complete when:**
- All four phases of the investigation tree completed successfully
- You inspected at least one evidence node
- Deep investigation mode was turned off cleanly
