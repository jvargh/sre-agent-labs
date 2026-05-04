# 📘 SRE Agent — Glossary Reference Card

> **Quick Reference** · Keep this card handy during the workshop.

---

| Term | Definition |
|------|------------|
| **Agent** | The deployed SREA resource. |
| **Connector** | Bridge to an external system (GitHub, Teams, Datadog, MCP). |
| **Tool** | Atomic capability the agent can invoke (KQL query, `kubectl`, `az cli`, send email). |
| **Skill** | Procedural guidance (`SKILL.md`) + optional tools, auto-loaded by relevance. |
| **Custom Agent (Subagent)** | Explicitly invoked specialist (`/agent` in chat). |
| **Knowledge Base / Memory** | Uploaded docs + auto-extracted session insights + `#remember` user memories. |
| **Response Plan** | Incident-platform trigger that routes incidents to a custom agent. |
| **Scheduled Task** | Recurring, agent-executed work item. |
| **Run Mode** | **Review** (asks before acting on Azure infra) vs **Autonomous** (acts, then reports). |

---

### How They Fit Together

```
┌─────────────────────────────────────────────────┐
│                    AGENT                        │
│                                                 │
│   ┌─────────────┐    ┌──────────────────────┐   │
│   │ Connectors  │───▶│  Tools               │   │
│   │ (GitHub,    │    │  (KQL, kubectl,      │   │
│   │  Teams,     │    │   az cli, email)     │   │
│   │  Datadog,   │    └──────────────────────┘   │
│   │  MCP)       │                               │
│   └─────────────┘    ┌──────────────────────┐   │
│                      │  Skills (SKILL.md)   │   │
│   ┌─────────────┐    │  auto-loaded by      │   │
│   │ Knowledge   │    │  relevance           │   │
│   │ Base /      │    └──────────────────────┘   │
│   │ Memory      │                               │
│   └─────────────┘    ┌──────────────────────┐   │
│                      │  Custom Agents       │   │
│   ┌─────────────┐    │  (/agent in chat)    │   │
│   │ Run Mode    │    └──────────────────────┘   │
│   │ Review |    │                               │
│   │ Autonomous  │    ┌──────────────────────┐   │
│   └─────────────┘    │  Response Plans      │   │
│                      │  Scheduled Tasks     │   │
│                      └──────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

### Memory Commands

| Command | Action |
|---------|--------|
| `#remember <fact>` | Save a fact to the agent's memory |
| `#retrieve` | View stored memories |
| `#forget` | Delete a stored memory |

---

*Source: SREA-Level200.md — Glossary Slide*
