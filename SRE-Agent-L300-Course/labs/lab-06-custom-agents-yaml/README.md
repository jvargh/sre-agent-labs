# Lab 6 — Custom Agents in YAML: Handoff Chains

> **Format:** Lab (90 min).
> **Outcome:** A 3-agent handoff chain — `incident-triager` → `db-expert` *or* `api-expert` → `notifier` — checked in to the workshop repo as YAML.
> **Docs:** [Custom Agents (Subagents)](https://sre.azure.com/docs/concepts/subagents) · [Agent Config Tutorials](https://sre.azure.com/docs/tutorials/agent-config/)

---

## Step 1 — Convert Canvas Agent to YAML (≈ 15 min)

### 1a. Export Existing Agent

1. Open **Agent Canvas → `p1-investigator`**.
2. Click **YAML view → Copy**.
3. Paste into a local file: `p1-investigator.agent.yaml`.

### 1b. Inspect the YAML Structure

Review the key fields:
- `name` — unique identifier
- `system_prompt` — agent instructions
- `handoff_description` — what upstream agents read to decide whether to route here
- `tools` — attached tools
- `connectors` — attached connectors
- `enable_skills` / `allowed_skills` — skill access

> **Expected state:** YAML file with all agent configuration exported.
> **Troubleshooting:** If YAML view is empty, the custom agent may not have been saved in Lab 3. Re-create and save.

---

## ⏱ Checkpoint — 15 min

- [ ] `p1-investigator` exported to YAML.
- [ ] Can identify all key fields in the YAML structure.

---

## Step 2 — Author 4 Specialist YAMLs (≈ 30 min)

Using VS Code with the SRE Agent MCP extension for live-sync, create these files:

### incident-triager.agent.yaml

```yaml
# incident-triager.agent.yaml
name: incident_triager
system_prompt: |
  You triage incoming incidents. Classify as 'database', 'api', or 'unknown'.
  Hand off to the matching specialist via handoff. Do not investigate yourself.
handoff_description: First-line classifier for incoming incidents.
allowed_skills: [incident-classification-guide]
```

### db-expert.agent.yaml

```yaml
# db-expert.agent.yaml
name: db_expert
system_prompt: |
  You diagnose Postgres/Azure SQL issues. Use Kusto tools first, then az cli.
  Hand off to notifier when you have a root cause.
handoff_description: Handles SQL, Postgres, and managed-DB incidents.
allowed_skills: [postgres-troubleshooting]
tools:
  - GetRecentDbErrors        # Kusto tool from Lab 5
  - RunAzCliReadCommands
```

### api-expert.agent.yaml

```yaml
# api-expert.agent.yaml
name: api_expert
system_prompt: |
  You diagnose API and web service issues (5xx, latency, connectivity).
  Use Kusto tools and az cli to investigate. Hand off to notifier with root cause.
handoff_description: Handles API, HTTP, and web service incidents.
allowed_skills: [api-troubleshooting]
tools:
  - GetRecentErrors          # Kusto tool from Lab 5
  - RunAzCliReadCommands
```

### notifier.agent.yaml

```yaml
# notifier.agent.yaml
name: notifier
system_prompt: |
  You summarize root cause + recommended action and post to Teams + email.
  Never investigate. Never run az cli.
handoff_description: Final notifier step.
tools: [SendTeamsMessage, SendOutlookEmail]
```

> ⚠️ **Production safety:** The `notifier` is the **only** custom agent in this chain running Autonomous with `SendOutlookEmail` / `SendTeamsMessage` tools. Per Lab 1, this requires a PostToolUse hook (installed in Lab 9).

> **Expected state:** Four YAML files in your workshop repo.
> **Troubleshooting:** If the MCP extension doesn't sync, save the files and manually import them via Builder → Agent Canvas → Import YAML.

---

## ⏱ Checkpoint — 30 min

- [ ] All 4 YAML files authored.
- [ ] Each agent has a unique `name` and clear `handoff_description`.

---

## Step 3 — Wire the Handoff Chain to Response Plan B (≈ 15 min)

### 3a. Push YAMLs via REST API v2

Use the D6 REST API client to push each YAML:
```bash
# Example using the Python client
python sre-api-client.py put-agent --name incident_triager --file incident-triager.agent.yaml
python sre-api-client.py put-agent --name db_expert --file db-expert.agent.yaml
python sre-api-client.py put-agent --name api_expert --file api-expert.agent.yaml
python sre-api-client.py put-agent --name notifier --file notifier.agent.yaml
```

> **Expected state:** All 4 agents visible in Agent Canvas.
> **Troubleshooting:** If the PUT returns 400, validate YAML syntax — common issues are indentation and missing required fields.

### 3b. Update Response Plan B

1. Navigate to **Builder → Incident Response Plans → Plan B** (P1/P2 plan from Lab 3).
2. Change the handler from `p1-investigator` to `incident_triager`.
3. Save.
4. Verify in the **canvas view**: handoff edges visible — `incident_triager` → `db_expert` / `api_expert` → `notifier`.
5. Verify tools are grouped per node.

> **Expected state:** Canvas shows the full handoff chain with edges and tool badges.
> **Troubleshooting:** If handoff edges don't appear, confirm each agent's `handoff_description` is populated — this is what the upstream agent reads.

---

## ⏱ Checkpoint — 45 min

- [ ] All 4 agents deployed via REST API v2.
- [ ] Response Plan B updated to dispatch to `incident_triager`.
- [ ] Canvas view shows handoff chain with edges.

---

## Step 4 — Test in Agent Playground (≈ 20 min)

### 4a. Playground Test

1. Open **Agent Playground**.
2. Select `incident_triager` as the active agent.
3. Submit a test prompt: "We have a P1 incident — database corruption detected on the primary SQL instance."
4. Observe the handoff chain:
   - `incident_triager` classifies as `database` → hands off to `db_expert`.
   - `db_expert` investigates using Kusto tool → hands off to `notifier`.
   - `notifier` summarizes and sends notification.

> **Expected state:** Full chain executes in the playground; each agent's contribution visible in the thread.
> **Troubleshooting:** If the chain breaks at handoff, verify the `handoff_description` matches the classification terms in `incident_triager`'s system prompt.

### 4b. Test the API Branch

1. Submit: "P1 — api-gateway returning 500 errors across all endpoints."
2. Confirm `incident_triager` routes to `api_expert` (not `db_expert`).

> **Expected state:** Correct branch taken based on incident classification.

---

## ⏱ Checkpoint — 60 min

- [ ] Playground test: database incident → `db_expert` branch works.
- [ ] Playground test: API incident → `api_expert` branch works.
- [ ] `notifier` produces summary in both cases.

---

## Concepts to Land (≈ 15 min)

### Shared Context

Context is **shared** across the handoff chain (not copied) — every specialist sees the full investigation thread. This means:
- `db_expert` sees the triager's classification reasoning.
- `notifier` sees the full investigation from the specialist.

### Per-Agent Tool Budget

Each custom agent has its **own** ≤ 80-tool budget. Tools assigned to `incident_triager` do not count against `db_expert`'s budget.

### `allowed_skills` Shorthand

`allowed_skills` automatically enables skills on the agent — no separate `enable_skills: true` needed. If `allowed_skills` is present, skills are enabled.

---

## Check-In to Repo (≈ 15 min)

1. Commit all 4 YAML files to your workshop repo.
2. Create a PR with the handoff chain for review.

> **Expected state:** PR with 4 `.agent.yaml` files merged to the repo.

---

## ⏱ Final Checkpoint — 90 min

- [ ] 3-agent handoff chain operational: `incident_triager` → `db_expert` / `api_expert` → `notifier`.
- [ ] YAMLs checked in to the workshop repo.
- [ ] Response Plan B dispatches to `incident_triager`.
- [ ] Playground tests pass for both database and API incident branches.
- [ ] Understands shared context, per-agent tool budget, `allowed_skills`.
- [ ] Ready for Lab 7+ Labs.

---

## References

- [Custom Agents (Subagents)](https://sre.azure.com/docs/concepts/subagents)
- [Agent Config Tutorials](https://sre.azure.com/docs/tutorials/agent-config/)
- [REST API v2](https://sre.azure.com/docs/tutorials/agent-config/agent-hooks)
- For L200 refresher on agents, see [SREA-Level200.md §Agents](../../../SREA-Level200.md#agents)
