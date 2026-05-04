# SRE Agent L200 Labs — Sequential Hands-On Exercises

Welcome to the **SRE Agent Level 200 (L200) labs**. These five labs form a **sequential learning path** — each lab builds on the previous one, taking you from agent provisioning through automation.

> **🎯 Goal:** By the end of all five labs, you'll have deployed a running SRE Agent, connected it to code and Azure resources, investigated issues, and automated daily health checks.

---

## Labs Overview

| Lab | Session | Title | Duration | Link |
|-----|--------|-------|----------|------|
| **A** | 3 (L200) | Provision Your First Agent | 45 min | [Lab A — Provision](./lab-A-provision/) |
| **B** | 4 (L200) | Connect Code, Resources, and Knowledge | 45 min | [Lab B — Connect](./lab-B-connect/) |
| **C** | 5 (L200) | First Investigation in Chat | 30 min | [Lab C — First Investigation](./lab-C-first-investigation/) |
| **D** | 6 (L200) | Deep Investigation (Chat Mode Only) | 30 min | [Lab D — Deep Investigation](./lab-D-deep-investigation/) |
| **E** | 7 (L200 Capstone) | Automate: Connector + Custom Agent + Scheduled Task | 45 min | [Lab E — Automate](./lab-E-automate/) |

**Total time commitment:** ~195 minutes (~3.25 hours)

---

## Prerequisites

Before starting **Lab A**, ensure you have completed the **pre-flight checklist**:

📋 **[Pre-Flight Checklist](../handouts/pre-flight-checklist.md)** — Verify Azure subscriptions, permissions, network access, and Entra ID account setup.

---

## Important: Labs Must Be Completed in Order

Labs **A → B → C → D → E** are **sequential and interdependent**:

- **Lab A** creates your agent and foundational Azure resources.
- **Lab B** connects code, Azure resources, and knowledge to the agent.
- **Lab C** uses the connected agent to run your first diagnostic prompts.
- **Lab D** advances from chat-triggered to deep investigation mode.
- **Lab E** automates health checks and notifications (the capstone).

**⚠️ Do not skip or reorder labs.** Each lab's outcome becomes a prerequisite for the next.

---

## Quick Navigation

- 📚 **[Prompt Library](../prompts/lab-prompts.md)** — Pre-written prompts and discussion talking points for all five labs.
- 🛠️ **[Troubleshooting](./troubleshooting.md)** — Common issues, root causes, and fixes across all labs.
- 📖 **[Access Control Cheatsheet](../handouts/access-control-cheatsheet.md)** — RBAC roles and permissions reference.
- 📝 **[Glossary Card](../handouts/glossary-card.md)** — Key SRE Agent concepts and terminology.

---

## Time Budget by Session

| Session | Lab | Duration | Cumulative |
|--------|-----|----------|-----------|
| 3 | Lab A | 45 min | 45 min |
| 4 | Lab B | 45 min | 90 min |
| 5 | Lab C | 30 min | 120 min |
| 6 | Lab D | 30 min | 150 min |
| 7 | Lab E | 45 min | 195 min |

---

## Getting Started

1. **Review the [Pre-Flight Checklist](../handouts/pre-flight-checklist.md)** to confirm your environment is ready.
2. **Start with [Lab A — Provision Your First Agent](./lab-A-provision/)**.
3. After each lab checkpoint, proceed to the next lab.
4. Use the [Prompt Library](../prompts/lab-prompts.md) for suggested talking points and prompts.
5. If you encounter issues, consult the [Troubleshooting](./troubleshooting.md) guide.

---

## Support

- **Instructor:** Available for clarification and troubleshooting during the workshop.
- **Documentation:** Links to full docs are embedded in each lab README.
- **Shared knowledge:** If you discover a workaround for a common issue, share it with the group.

---

**Ready? Let's go!** → [Start Lab A — Provision Your First Agent](./lab-A-provision/)
