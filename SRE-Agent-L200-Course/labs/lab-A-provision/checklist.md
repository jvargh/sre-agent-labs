# Lab A — Provision Your First Agent: Completion Checklist

Use this checklist to confirm you've completed every step of Lab A.

---

## Pre-Lab

- [ ] Signed in with a **work or school** Entra ID account
- [ ] `Microsoft.App` provider registered on subscription (`az provider register --namespace "Microsoft.App"`)
- [ ] Subscription allows resource creation in Sweden Central, East US 2, or Australia East

## Lab Steps

- [ ] **Step 1:** Navigated to [sre.azure.com](https://sre.azure.com) and signed in
- [ ] **Step 2:** Clicked **Create agent** — wizard opened
- [ ] **Step 3:** Filled in Basics tab:
  - [ ] Subscription selected
  - [ ] Resource group: `rg-sre-agent-<your-alias>`
  - [ ] Agent name entered (e.g., `contoso-sre-agent`)
  - [ ] Region: Sweden Central / East US 2 / Australia East
  - [ ] Model provider: Anthropic (default) or Azure OpenAI
  - [ ] Application Insights: **Create new**
- [ ] **Step 4:** Clicked **Review → Create** and waited for deployment (2–5 min)
- [ ] **Step 5:** Verified deployment created all five resources:
  - [ ] User-Assigned Managed Identity (UAMI)
  - [ ] Log Analytics Workspace
  - [ ] Application Insights
  - [ ] Role Assignments
  - [ ] Azure SRE Agent resource

## Checkpoint

- [ ] ✅ Clicked **Set up your agent** → landed on **"More context. Better investigations."** page

## Status

| Check | Expected |
|-------|----------|
| Agent state | `Running` |
| Resource group contents | 4+ resources visible |
| Onboarding page visible | "More context. Better investigations." |

> **Next up:** [Lab B — Connect Code, Resources, and Knowledge](../lab-B-connect/README.md)
