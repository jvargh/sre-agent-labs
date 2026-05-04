# 🔐 SRE Agent — Access Control Cheat Sheet

> **Module 2 Quick Reference** · The three-layer model you need for every lab.

---

## Three-Layer Access Control Model

| Layer | What It Controls | Where It Lives |
|-------|-----------------|----------------|
| **User Roles** | What a *human* can do with the agent | Azure IAM on the agent resource |
| **Run Modes** | Whether the agent asks before acting on Azure infra | Per Response Plan & per Scheduled Task |
| **Agent Permissions** | What the agent can read/do on Azure resources, with OBO as fallback | RBAC roles on the agent's UAMI |

---

## User Roles Matrix

| Role | Can Do |
|------|--------|
| **SRE Agent Reader** | View threads / logs / incidents |
| **SRE Agent Standard User** | Chat, run diagnostics, *request* actions |
| **SRE Agent Administrator** | *Approve* actions, manage connectors, authorize OBO |

---

## Permission Levels (chosen at agent creation)

| Level | Behavior |
|-------|----------|
| **Reader** *(recommended starter)* | Read-only diagnostics; agent prompts for OBO when it needs write access |
| **Privileged** | Resource-type-specific contributor roles; agent can execute approved actions directly |

### Always-Assigned RBAC Roles

| Scope | Roles |
|-------|-------|
| **Resource Group** | Reader · Log Analytics Reader · Monitoring Reader |
| **Subscription** | Monitoring Contributor *(for alert ack/close)* |

---

## Run Modes

| Mode | Behavior |
|------|----------|
| **Review** *(default)* | Approve / Deny gate on Azure infra ops only |
| **Autonomous** | Agent executes, then reports |

> ⚠️ **Run Mode does NOT gate** emails, Teams posts, or external data queries — those are governed by hooks (Level 300 topic).

---

## OBO (On-Behalf-Of) Quick Reference

| Aspect | Detail |
|--------|--------|
| **When** | UAMI lacks permission for a write action |
| **Who can authorize** | SRE Agent Administrators with work/school Entra accounts only |
| **Scope** | Token reused only for that investigation task; agent reverts to UAMI after |

---

## 💡 Recommended Starting Configuration

```
┌────────────────────────────────────────────┐
│  Start every new agent with:               │
│                                            │
│   ✅  Review mode    (approve before act)  │
│   ✅  Reader level   (read-only RBAC)      │
│                                            │
│  Promote later — per response plan,        │
│  per scheduled task.                       │
└────────────────────────────────────────────┘
```

---

*Source: SREA-Level200.md — Access Control Model*
