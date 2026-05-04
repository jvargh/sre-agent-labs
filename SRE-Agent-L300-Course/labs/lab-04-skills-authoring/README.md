---
lab: 4
level: 300
duration_minutes: 75
track: all
dependencies:
  - Lab 1
  - Lab 2
  - Lab 3
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# Lab 4 — Skills Authoring

> **Format:** Lab (75 min).
> **Outcome:** One workspace skill (`<service>-troubleshooting-guide`) with attached `RunAzCliReadCommands`, validated in the Agent Playground.
> **Docs:** [Skills Concepts](https://sre.azure.com/docs/concepts/skills) · [Skills Tutorials](https://sre.azure.com/docs/tutorials/skills/) · [Agent Playground](https://sre.azure.com/docs/capabilities/agent-playground)

---

## Concepts (10 min)

### What is a Skill?

- **Skill = `SKILL.md`** (procedural guidance) **+ optional tools + supporting files**.
- Loaded automatically by **description match** — the model reads the skill's `description` field to decide when to load it.
- **Max 5 active skills concurrently**; oldest auto-unloaded when a 6th activates.
- Skills vs Custom Agents vs Knowledge Files — see the decision table at [concepts/skills](https://sre.azure.com/docs/concepts/skills).

> **Troubleshooting:** If attendees ask about Skills vs Custom Agents, point to the doc decision table — do not re-teach it here.

---

## ⏱ Checkpoint — 15 min

- [ ] Attendees can define what a Skill is (SKILL.md + tools + files).
- [ ] Attendees understand the 5-skill concurrent limit.

---

## Lab Steps

### Step 1 — Create Skill (≈ 5 min)

1. Navigate to **Builder → Skills → Create Skill**.
2. Name: `<service>-troubleshooting-guide` (use your service name or the sample workload).

> **Expected state:** Empty skill editor opens.
> **Troubleshooting:** If Create Skill is greyed out, confirm you have SRE Agent Admin role.

### Step 2 — Author SKILL.md (≈ 15 min)

1. Write the `SKILL.md` content:
   - **`description`:** This is the discovery surface. Include **trigger phrases** the agent will match on.
     ```markdown
     # <service> Troubleshooting Guide
     
     ## Description
     Use this skill when troubleshooting latency spikes, 5xx errors,
     or connectivity issues with <service>. Triggered by phrases like
     "debug <service>", "why is <service> slow", "<service> errors".
     ```
   - **Step-by-step troubleshooting:** Numbered steps with `az cli` commands.
   - **Links to runbooks:** External URLs to your team's existing docs.

> **Expected state:** SKILL.md populated with description, steps, and links.
> **Troubleshooting:** If unsure what to write, use the sample workload troubleshooting guide template from the slide deck.

### Step 3 — Attach Tools (≈ 5 min)

1. In the skill editor, click **Attach Tools**.
2. Select: `RunAzCliReadCommands` only.
   - ⚠️ **Do not attach write tools to a skill** — skills are loaded by any user prompt. Use a custom agent for write operations.
3. Save.

> **Expected state:** Tool badge shows `RunAzCliReadCommands` attached.
> **Troubleshooting:** If the tool is not in the picker, verify the agent has the tool enabled at the workspace level.

---

## ⏱ Checkpoint — 30 min

- [ ] Skill created with name and SKILL.md content.
- [ ] `RunAzCliReadCommands` attached (no write tools).

---

### Step 4 — Test in Agent Playground (≈ 15 min)

1. Open **Agent Playground** (split-screen: edit on left, chat on right).
2. Type a prompt that matches your skill's trigger phrases:
   - Example: "Why is `<service>` throwing 5xx errors?"
3. Observe: the skill should **auto-load** (visible in the tool-call card).
4. Confirm the agent follows your SKILL.md steps.

> **Expected state:** Skill loads automatically; agent executes the troubleshooting steps from SKILL.md.
> **Troubleshooting:** If the skill does not load, your `description` field likely lacks the trigger phrases. Edit and re-test.

### Step 5 — Iterate (≈ 10 min)

1. Deliberately weaken the description (remove trigger phrases).
2. Re-ask the same prompt — confirm the skill does **not** load.
3. Restore the description — confirm it loads again.

> **Expected state:** Skill loading is directly tied to description quality.

---

## ⏱ Checkpoint — 45 min

- [ ] Skill tested in Agent Playground — auto-loads on matching prompt.
- [ ] Iteration exercise completed (weak vs strong description).

---

## Anti-Patterns

> ⚠️ Call these out explicitly. These are the top 3 mistakes from production deployments.

| Anti-Pattern | Why It's Bad | What to Do Instead |
|-------------|-------------|-------------------|
| **Description without trigger phrases** | Agent never loads the skill — it can't match on vague descriptions | Include specific phrases users will type (e.g., "debug X", "X errors", "X slow") |
| **More than 5 skills attached at once** | Context churn — oldest skill evicted, unpredictable behavior | Prioritize the top 5; archive low-use skills |
| **Write tool attached to a skill** | Any user prompt can trigger the skill → uncontrolled write access | Move write tools to a custom agent with explicit dispatch |

---

## Stretch (If Time Permits)

### VS Code MCP Extension Authoring (≈ 15 min)

1. Open **VS Code** with the SRE Agent MCP extension installed.
2. Create a second skill via the IDE workflow.
3. Observe live-sync between VS Code and the portal.

> **Expected state:** Skill appears in Builder after saving in VS Code.

### `allowed_skills` Syntax

Discuss how custom agents (Lab 6) use `allowed_skills` to restrict which skills they can load:
```yaml
allowed_skills: [<service>-troubleshooting-guide]
```

---

## ⏱ Final Checkpoint — 75 min

- [ ] One workspace skill with `RunAzCliReadCommands` validated in Agent Playground.
- [ ] Can explain the 3 anti-patterns.
- [ ] (Stretch) Second skill via VS Code MCP extension.
- [ ] Ready for Lab 5 (Kusto tools) and Lab 6 (custom agents referencing skills).

---

## References

- [Skills Concepts](https://sre.azure.com/docs/concepts/skills)
- [Skills Tutorials](https://sre.azure.com/docs/tutorials/skills/)
- [Agent Playground](https://sre.azure.com/docs/capabilities/agent-playground)
- [Global Tools Page](https://sre.azure.com/docs/capabilities/global-tools-page)
- For L200 refresher on tools, see [SREA-Level200.md §Tools](../../../SREA-Level200.md#tools)
