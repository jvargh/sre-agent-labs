# Azure SRE Agent Training Curriculum

Welcome to the comprehensive training curriculum for **Azure SRE Agent**. This repository hosts two hands-on courses designed to take you from foundational concepts to production-ready advanced operations. Whether you're a DevOps engineer, SRE practitioner, or platform owner, you'll find a course tailored to your expertise level.

---

## 🎯 Training Overview

Azure SRE Agent is a production-grade tool for incident response, root-cause analysis, and operational automation in Azure environments. These courses teach you to provision agents, connect them to your infrastructure, and orchestrate sophisticated incident workflows at scale.

| Course | Level | Duration | Audience | Labs/Modules | Status |
|--------|-------|----------|----------|--------------|--------|
| **Level 200** | Foundational → Hands-On | ~3.25 hrs | DevOps/SRE teams, new to SRE Agent | 5 labs (A–E) | Core curriculum |
| **Level 300** | Advanced | ~17 hrs (2 days) | L200 graduates; operators & architects | 13 modules (M1–M13) | Advanced track |

---

## 📚 Level 200 Workshop — Introduction to SRE Agent

**Duration:** ~3.25 hours (or 5 modules × 45 min each for self-paced)  
**Audience:** DevOps and SRE-Ops teams (developers, on-call engineers, platform/cloud admins, SRE leads)

### What You'll Learn
- **Concepts:** SRE Agent architecture, access control, run modes, and permissions  
- **Hands-On Labs:** Provision an agent → Connect code & resources → Run diagnostics → Automate incident response  
- **Outcome:** A running agent connected to your Azure infrastructure, ready to triage incidents in chat mode

### Labs A–E
1. **Lab A:** Provision your first agent (resource creation, managed identity, observability)
2. **Lab B:** Connect code, Azure resources, and knowledge documents
3. **Lab C:** First investigation in chat mode (diagnostic prompts)
4. **Lab D:** Deep investigation (multi-phase triage using Mode 2)
5. **Lab E:** Automate with connectors, custom agents, and scheduled tasks

### Getting Started with L200
- **Prerequisites:** Azure Contributor access, Entra ID account, network access to `*.azuresre.ai`, region support (Sweden Central, East US 2, Australia East)
- **Setup:** Requires a non-prod sandbox subscription; trainers provision per-attendee resource groups
- **Resources:** [Read the L200 README →](SRE-Agent-L200-Course/README.md)

---

## 🚀 Level 300 Workshop — Advanced Agent Operations

**Duration:** ~17 hours (2-day instructor-led workshop)  
**Audience:** L200 graduates; advanced operators and platform owners  
**Tracks:** Choose one — PagerDuty, ServiceNow, or Azure Monitor

### What You'll Learn
- **Production-Grade Setup:** Privileged and Autonomous modes, safety playbooks, enterprise topology
- **Custom Agents & Tools:** YAML-defined agents, Python tools, Kusto analytics, MCP integrations
- **Incident Automation:** Response plans, hooks (Stop, PostToolUse), multi-agent handoff chains
- **Advanced Observability:** Audit trails, FinOps analytics, cross-tenant architectures
- **Capstone Project:** Deploy a multi-agent incident drill end-to-end

### Modules M1–M13
- **M1–M3:** Foundation (promotion playbook, incident-platform connection, response plans)
- **M4–M7:** Tools & Integrations (Skills, Kusto, custom agents, MCP ecosystem)
- **M8–M13:** Advanced Features & Architecture (Python tools, hooks, audit/FinOps, enterprise topology, IaC, capstone)

### Getting Started with L300
- **Hard Prerequisite:** Level 200 completion required (no exceptions)
- **Sandbox:** Two non-prod subscriptions + incident platform trial (PagerDuty/ServiceNow/Azure Monitor)
- **Local Toolchain:** Azure CLI, kubectl, Python 3.12, Node 20, .NET 9, VS Code
- **Resources:** [Read the L300 README →](SRE-Agent-L300-Course/README.md)

---

## 📖 Course Progression

**→ Start with Level 200** if you are new to SRE Agent or have not completed hands-on labs.

**→ Progress to Level 300** after:
- Completing all L200 labs (A–E) in a live or self-paced session
- Confirming your agent reached `Running` status
- Having access to an incident platform trial (PagerDuty, ServiceNow, or Azure Monitor)

The courses build sequentially; L300 assumes L200 knowledge and expects you to have provisioned an agent before Day 1.

---

## 🔗 Key Resources

### Official SRE Agent Documentation
- **Product Site:** [https://sre.azure.com](https://sre.azure.com)
- **Docs Home:** [https://sre.azure.com/docs](https://sre.azure.com/docs)
- **Get Started Guide:** [https://sre.azure.com/docs/get-started](https://sre.azure.com/docs/get-started)
- **Concepts & Capabilities:** [https://sre.azure.com/docs/concepts](https://sre.azure.com/docs/concepts) and [https://sre.azure.com/docs/capabilities](https://sre.azure.com/docs/capabilities)

### Course Materials
- **L200 Course:** [SRE-Agent-L200-Course/](SRE-Agent-L200-Course/)
  - Module map, prerequisites, trainer notes, knowledge samples
  - Labs follow the docs step-by-step
- **L300 Course:** [SRE-Agent-L300-Course/](SRE-Agent-L300-Course/)
  - 13 modules across 2 days, 3 parallel tracks
  - Sandbox provisioning scripts, trainer runbooks, rollout pack

### GitHub
- **SRE Agent Samples:** [github.com/microsoft/sre-agent/tree/main/samples](https://github.com/microsoft/sre-agent/tree/main/samples)

---

## 🎓 Success Metrics

### L200
- Attendees with a `Running` agent at end of Lab A: **100%**
- Attendees with ≥1 completed deep investigation (Lab D): **≥90%**
- Scheduled task execution success (Lab E): **≥80%**
- Post-training confidence improvement (1–5 scale): **+2 average**

### L300
- Attendees with non-default response plan dispatching to custom agent: **100%**
- Attendees with ≥1 Stop hook + ≥1 PostToolUse hook: **100%**
- Attendees with ≥1 Kusto tool + ≥1 Python tool in production: **≥90%**
- Capstone drill (M13) handled end-to-end: **≥80%**
- Agent-as-code PR landed within 2 weeks post-workshop: **≥75%**

---

## 🛠️ Trainer Information

Both courses include comprehensive trainer support:
- **Timing scripts** — minute-by-minute facilitator guidance
- **Failure recovery guides** — troubleshooting for live demos
- **Sandbox provisioning** — automation scripts for sandbox setup and teardown
- **Operations runbooks** — day-of checklists, FAQs, escalation trees
- **Feedback forms** — post-workshop surveys for continuous improvement

Trainers: refer to the `trainer-notes/` subdirectories in each course folder for detailed guidance.

---

## 📞 Support & Feedback

- For questions about course content, refer to the course-specific README files
- For SRE Agent product issues or documentation corrections, visit [https://sre.azure.com/docs](https://sre.azure.com/docs)
- Post-workshop feedback is collected via survey forms included in each course

---

**Last Updated:** 2026-05-03  
**Version:** srea-curriculum-1.0.0
