# Azure SRE Agent — Level 100/200 Workshop

> **Audience:** DevOps and SRE-Ops teams (developers, on-call engineers, platform/cloud admins, SRE leads)
> **Level:** 100 (foundational concepts) → 200 (hands-on first-value scenarios)
> **Duration:** ~4 hours (half-day workshop) or 5-module self-paced track (~45 min each)
> **Delivery model:** Slides for L100 modules, live demo + lab for L200 modules. Each lab uses a shared non-prod sandbox subscription.

---

## Prerequisites Checklist

Send to attendees **1 week before** the workshop:

| # | Item | Notes |
|---|------|-------|
| 1 | Azure subscription access | Contributor on the subscription (needed to register `Microsoft.App` provider and create resources). For the full lab, **Owner** or **User Access Administrator** is required to create role assignments. |
| 2 | Network access | `*.azuresre.ai` reachable from the browser (corporate proxies / firewall allowlist). |
| 3 | Region | Subscription must allow resource creation in **Sweden Central**, **East US 2**, or **Australia East**. |
| 4 | Identity | A **work or school (Entra ID)** account — personal MSAs cannot authorize OBO. |
| 5 | GitHub or Azure DevOps | Read access to one repo containing a small service for Lab 2. |
| 6 | Microsoft 365 | Outlook + Teams account for the notifications lab. |
| 7 | Provider registration | Run `az provider register --namespace "Microsoft.App"` before the workshop. |
| 8 | Sample workload (optional but recommended) | Deploy a sample Container App / App Service / Function from `github.com/microsoft/sre-agent/tree/main/samples` so the agent has something real to look at. |

**Pre-read (15 min):** [Overview — What is SRE Agent?](https://sre.azure.com/docs/overview) and [Get Started — Your Journey](https://sre.azure.com/docs/get-started).

---

## Module Map

| Module | Level | Title | Mode | Duration |
|--------|-------|-------|------|----------|
| M1 | 100 | What & Why: SRE Agent Concepts | Lecture | 30 min |
| M2 | 100 | Access Control Model | Lecture + diagram walkthrough | 30 min |
| M3 | 200 | Lab A — Provision Your First Agent | Hands-on | 45 min |
| M4 | 200 | Lab B — Connect Code, Resources, and Knowledge | Hands-on | 45 min |
| — | — | ☕ Break | — | 10 min |
| M5 | 200 | Lab C — First Investigation in Chat | Hands-on | 30 min |
| M6 | 200 | Lab D — Deep Investigation (chat mode only) | Hands-on | 30 min |
| M7 | 200 | Lab E — Automate: Connector + Custom Agent + Scheduled Task | Hands-on | 45 min |
| M8 | 200 | Operate, Audit, Share | Lecture + click-through | 20 min |
| M9 | 100 | Wrap-Up + Bridge to Level 300 | Lecture | 15 min |

**Total:** ~4 hours 10 min (including break)

---

## Folder Structure

```
SRE-Agent-L200-Course/
├── README.md                          ← You are here — master workshop guide
├── knowledge-samples/
│   ├── sample-architecture.md         ← Sample architecture doc for Lab B upload
│   └── sample-runbook-restart-containerapp.md  ← Sample runbook for Lab B upload
└── trainer-notes/
    ├── timing-script.md               ← Minute-by-minute facilitator script
    └── failure-recovery.md            ← "What to do when X breaks live" guide
```

---

## Setup Instructions for Trainers

### Sandbox Deployment (1 Week Before)

1. **Provision a non-prod sandbox subscription** with `Microsoft.App` registered, quota in at least one of the three supported regions (Sweden Central, East US 2, Australia East).
2. **Create a personal resource group** for each attendee (`rg-sre-agent-<alias>`) with **Owner** role assigned.
3. **Deploy the sample workload** — use the Container App from [microsoft/sre-agent samples](https://github.com/microsoft/sre-agent/tree/main/samples) into a shared resource group so each agent has something to investigate.
4. **Prepare knowledge samples** — the `knowledge-samples/` folder in this course contains two ready-to-upload documents for Lab B.

### Pre-flight (3 Days + 24 Hours Before)

1. Send the prerequisites checklist (see above) to all attendees.
2. Verify each attendee's Entra ID account can reach `sre.azure.com`.
3. Confirm `Microsoft.App` provider is registered in the sandbox subscription.
4. Set up the workshop Slack/Teams support channel.
5. Print or share the feedback form referencing each module.
6. Walk through the `trainer-notes/timing-script.md` and `trainer-notes/failure-recovery.md`.

---

## How to Use the Lab Guides

Labs are **sequential** — each lab builds on the previous:

1. **Lab A (M3):** Provision the agent — creates the resource, managed identity, App Insights, and Log Analytics workspace.
2. **Lab B (M4):** Connect code, Azure resources, and upload knowledge documents — the agent needs these before it can investigate anything.
3. **Lab C (M5):** First investigation in chat — attendees run diagnostic prompts against the connected resources.
4. **Lab D (M6):** Deep investigation — a more complex, multi-phase investigation using the deep investigation feature.
5. **Lab E (M7):** Automate — wire up Outlook connector, create a custom agent, attach a scheduled task.

Each lab follows the corresponding page on [sre.azure.com/docs](https://sre.azure.com/docs). Screenshots and step-by-step instructions are on those doc pages.

---

## Reference Index

### Foundations
- [Overview](https://sre.azure.com/docs/overview)
- [Get Started](https://sre.azure.com/docs/get-started)

### Concepts (read in this order)
1. [User Roles](https://sre.azure.com/docs/concepts/user-roles)
2. [Permissions](https://sre.azure.com/docs/concepts/permissions)
3. [Run Modes](https://sre.azure.com/docs/concepts/run-modes)
4. [Connectors](https://sre.azure.com/docs/concepts/connectors)
5. [Tools](https://sre.azure.com/docs/concepts/tools)
6. [Memory & Knowledge](https://sre.azure.com/docs/concepts/memory)
7. [Skills](https://sre.azure.com/docs/concepts/skills) *(preview only)*
8. [Custom Agents](https://sre.azure.com/docs/concepts/subagents) *(preview only)*
9. [Deep Context / Workspace Tools](https://sre.azure.com/docs/concepts/workspace-tools)

### Capabilities (covered in this workshop)
- [Diagnose with Azure Observability](https://sre.azure.com/docs/capabilities/diagnose-azure-observability)
- [Root Cause Analysis](https://sre.azure.com/docs/capabilities/root-cause-analysis)
- [Incident Response](https://sre.azure.com/docs/capabilities/incident-response) *(read-only intro)*
- [Send Notifications](https://sre.azure.com/docs/capabilities/send-notifications)
- [Scheduled Tasks](https://sre.azure.com/docs/capabilities/scheduled-tasks)

### Tutorials (followed in labs)
- [Step 1: Create and Set Up](https://sre.azure.com/docs/get-started/create-and-setup)
- [Step 5: Automate Actions](https://sre.azure.com/docs/get-started/automate-actions)
- [Run a Deep Investigation](https://sre.azure.com/docs/tutorials/advanced/deep-investigation)

### Samples
- [microsoft/sre-agent samples](https://github.com/microsoft/sre-agent/tree/main/samples)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Attendees with a `Running` agent at end of Lab A | 100% |
| Attendees who completed at least one Deep Investigation in Lab D | ≥ 90% |
| Attendees whose scheduled task executed and emailed successfully in Lab E | ≥ 80% |
| Self-rated confidence (1–5) on "I can use SRE Agent for everyday triage" — pre vs post | +2 average |
| Tickets opened in support channel during week 1 post-training | < 1 per attendee |

---

## Hard Constraints (for trainers)

1. **Do not expand scope** beyond what's in the curriculum design document.
2. **Do not change the module order** — later labs depend on earlier ones.
3. **Do not switch attendees to Privileged/Autonomous for Azure infra** — Lab E's Autonomous mode is only for the `SendOutlookEmail` subagent.
4. **Do not introduce** MCP connectors, custom Python tools, Skills authoring, Response Plans, or incident-platform connections.
5. **Use non-prod sandbox subscription references only.**
6. **Use sanitized data** — no real subscription IDs, tenant IDs, or user emails.
7. **Mirror the docs URL set** in the Reference Index above.
8. **All prompts must be safe for 20+ attendees** against a shared workload.

---

## Curriculum Design Document

The file `SREA-Level200.md` at the repository root is the **curriculum design document**. It contains the full module map, learning outcomes, lab outlines, prerequisites, and success metrics used to build this workshop.

> ⚠️ **Do NOT distribute `SREA-Level200.md` to attendees.** It is an internal trainer resource only.
