# Lab B — Connect Code, Resources, and Knowledge: Completion Checklist

Use this checklist to confirm you've completed every step of Lab B.

---

## Pre-Lab

- [ ] Lab A complete — agent `contoso-sre-agent` in `Running` state
- [ ] On the **"More context. Better investigations."** onboarding page
- [ ] GitHub/Azure DevOps access to sample workload repo
- [ ] Two knowledge documents prepared (architecture overview + runbook)

## Part 1 — Connect Code Repository

- [ ] **Step 1:** Opened the Code connection card
- [ ] **Step 2:** Authenticated to GitHub (or Azure DevOps) via OAuth/PAT
- [ ] **Step 3:** Selected and added the sample workload repository
- [ ] **Step 4:** Confirmed repository is connected (✅ status visible)
- [ ] Noted: SREAGENT.md PR may appear later — **do not merge during workshop**

## Part 2 — Add Azure Resource Access

- [ ] **Step 5:** Opened the Azure Resources card
- [ ] **Step 6:** Selected **Resource groups** scope
- [ ] **Step 7:** Filtered by subscription, selected workload RG, permission = **Reader**
- [ ] **Step 8:** Reviewed auto-assigned roles → clicked **Add resource group**
- [ ] **Step 9:** (Optional) Verified role assignments via `az role assignment list`

## Part 3 — Add Team Knowledge

- [ ] **Step 10:** Uploaded 2 documents to Knowledge base:
  - [ ] `sample-architecture.md` (architecture overview)
  - [ ] `sample-runbook.md` (runbook)
- [ ] **Step 11:** Ran `#remember` command in chat:
  ```
  #remember our prod region is East US 2 and our paging channel is #oncall-payments
  ```
- [ ] Noted `#retrieve` and `#forget` commands for future use

## Checkpoint

- [ ] ✅ Clicked **Done and go to agent** → chat interface opened

## Status

| Connection | Expected State |
|-----------|----------------|
| Code repository | ✅ Connected |
| Azure resources (1 RG) | ✅ Reader access |
| Knowledge documents | 2 uploaded |
| Memory facts | 1 stored |

> **Next up:** [Lab C — First Investigation in Chat](../lab-C-first-investigation/README.md)
