# Lab C — First Investigation in Chat: Completion Checklist

Use this checklist to confirm you've completed every step of Lab C.

---

## Pre-Lab

- [ ] Lab A complete — agent in `Running` state
- [ ] Lab B complete — 1 repo + 1 RG (Reader) + 2 knowledge docs connected
- [ ] Chat interface open from end of Lab B (or navigated to agent → Chat)
- [ ] Sample workload running and generating telemetry

## Warm-Up Prompts

- [ ] **Step 1:** Ran `What Azure resources can you see?`
  - [ ] Observed a **Resource Graph** tool-call card
  - [ ] Agent listed resources in the connected RG
- [ ] **Step 2:** Ran `Summarize the health of the resources in my managed resource group.`
  - [ ] Observed tool-call cards (Resource Graph, KQL, App Insights, and/or Azure CLI)
  - [ ] Agent provided a correlated health summary (not a raw log dump)
- [ ] **Step 3:** Ran `Show me any errors in <sample-app-name> in the last hour.`
  - [ ] Observed a **KQL query** or **App Insights** tool-call card
  - [ ] Agent listed errors with timestamps and context

## Mini Exercise — Approve/Deny

- [ ] **Step 4:** Asked agent to perform a write operation (e.g., restart)
  - [ ] Observed **Approve/Deny** buttons or **OBO authorization** request
- [ ] **Step 5:** Approved a safe, low-risk operation (e.g., list revisions)

## Key Observations

- [ ] Understood that **tool-call cards** are the agent's audit/explainability surface
- [ ] Noticed the agent **correlates** data from multiple sources (not just dumps)
- [ ] Observed **citations** from uploaded knowledge docs (if applicable)
- [ ] Understood the Approve/Deny flow in Review mode

## Checkpoint

- [ ] ✅ Ran at least **3 diagnostic prompts**
- [ ] ✅ Read at least **1 tool-call card** in detail
- [ ] ✅ Saw the **Approve/Deny** or **OBO authorization** flow

## Status

| Activity | Expected |
|----------|----------|
| Diagnostic prompts completed | ≥ 3 |
| Tool-call cards observed | ≥ 1 per prompt |
| Approve/Deny flow tested | ✅ |

> **Next up:** Lab D — Deep Investigation (chat mode only)
