# Lab 9 — Agent Hooks: Stop + PostToolUse, Prompt vs Command, Model Tiers, Sandbox Limits

> ⚠️ **THE most important L400 Lab for production safety.** Pair with the Lab 1 promotion playbook. Never demonstrate Autonomous mode without the hook stack from this Lab.

## Learning Outcome

Three hooks deployed at the agent level — a Stop prompt hook (completeness check), a PostToolUse command hook (block dangerous shell patterns), and a PostToolUse command hook (audit every tool call). Attendees re-fire an Lab 3 P1 incident and verify hooks in action.

> **Pre-read:** [Agent Hooks](https://sre.azure.com/docs/capabilities/agent-hooks) · [Create/Manage Hooks (UI)](https://sre.azure.com/docs/tutorials/agent-config/create-manage-hooks-ui) · [Agent Hooks (API)](https://sre.azure.com/docs/tutorials/agent-config/agent-hooks)

---

## Checkpoint Schedule

| Time | Checkpoint |
|------|-----------|
| 0:00 | Lab start — verify Lab 8 tools functional |
| 0:15 | ✅ CP1 — Concepts understood: events, levels, types |
| 0:30 | ✅ CP2 — Hook A (Stop, prompt) created and tested |
| 0:50 | ✅ CP3 — Hook B (PostToolUse, command, block) created and tested |
| 0:65 | ✅ CP4 — Hook C (PostToolUse, command, audit) created and tested |
| 0:80 | ✅ CP5 — All three wired at agent level, Lab 3 P1 re-fired |
| 0:90 | ✅ CP6 — Limits memorized, best-practices reviewed |

---

## Concepts (15 min)

### Hook Events Supported

| Event | When It Fires | Use Case |
|-------|--------------|----------|
| **Stop** | Agent is about to finalize its response | Validate completeness, force continuation |
| **PostToolUse** | After any tool call returns | Audit, block dangerous patterns, inject context |

### Two Levels

| Level | Where Configured | Scope |
|-------|-----------------|-------|
| **Agent-level** | Builder → Hooks | Fires for **every** custom agent under this agent |
| **Custom-agent-level** | Agent Canvas → Manage Hooks | Fires only for that specific custom agent |

Both fire if both match — **agent-level fires first**.

> For full details on level interaction, see [Agent Hooks](https://sre.azure.com/docs/capabilities/agent-hooks).

### Two Execution Types

| Type | How It Runs | Best For |
|------|------------|----------|
| **Prompt** | LLM evaluates `$ARGUMENTS` + your prompt text | Semantic checks (completeness, quality) |
| **Command** | Bash / `python3` script in sandboxed code-interpreter | Pattern matching, regex blocking, audit logging |

### Hook Context

- **Prompt hooks:** JSON context available via `$ARGUMENTS`.
- **Command hooks:** JSON context via **stdin**. `execution_summary` is a transcript file path, not inline.
- **Response format (simple):** `{"ok": true|false, "reason": "..."}`
- **Response format (expanded):** `{"decision": "allow|block", "reason": "...", "hookSpecificOutput": {"additionalContext": "..."}}`
- **Command hooks:** exit code `0` = allow, exit code `2` = block.

> **🔖 Checkpoint CP1** — You can explain Stop vs PostToolUse, agent-level vs custom-agent-level, prompt vs command.

---

## Hook A — Stop Hook, Prompt Type: Completeness Check (15 min)

### A.1 Create the Hook

- **Action:** Navigate to **Builder → Hooks → Create hook**. Configure:

  ```yaml
  hooks:
    Stop:
      - type: prompt
        model: ReasoningFast
        prompt: |
          Does the response include both a root cause statement and a recommended action?
          $ARGUMENTS
          Respond {"ok": true} or {"ok": false, "reason": "..."}.
        timeout: 30
        maxRejections: 3
  ```

- **Expected state:** Hook appears in the Hooks list with event = `Stop`, type = `prompt`.
- **Troubleshooting:** If the hook editor does not accept YAML, switch to the form-based UI and enter each field individually.

### A.2 Test with a Deliberately Incomplete Response

- **Action:** In Agent Playground, craft a prompt that causes the agent to respond with only a root cause (no action). Verify the Stop hook rejects and the agent continues.
- **Expected state:** The hook card in the conversation shows `{"ok": false, "reason": "Missing recommended action"}`. The agent auto-retries (up to `maxRejections: 3`).
- **Troubleshooting:** If the hook never triggers, verify it is set to event `Stop` (not `PostToolUse`). Check that `maxRejections` is ≥ 1.

> **🔖 Checkpoint CP2** — Hook A blocks an incomplete response and forces continuation.

---

## Hook B — PostToolUse, Command Type: Block Dangerous Shell Patterns (20 min)

### B.1 Create the Hook

- **Action:** Create a second hook with the following configuration:

  ```yaml
  hooks:
    PostToolUse:
      - type: command
        matcher: "Bash|ExecuteShellCommand|RunAzCliWriteCommands"
        timeout: 30
        failMode: block
        script: |
          #!/usr/bin/env python3
          import sys, json, re
          ctx = json.load(sys.stdin)
          cmd = ctx.get('tool_input', {}).get('command', '')
          for pat in [r'\brm\s+-rf\b', r'\bsudo\b', r'\bchmod\s+777\b',
                      r'az\s+(group|account)\s+delete']:
              if re.search(pat, cmd):
                  print(json.dumps({"decision": "block", "reason": f"Blocked: {pat}"}))
                  sys.exit(0)
          print(json.dumps({"decision": "allow"}))
  ```

- **Expected state:** Hook appears with event = `PostToolUse`, type = `command`, matcher showing `Bash|ExecuteShellCommand|RunAzCliWriteCommands`.
- **Troubleshooting:** If the script fails to save, check that it is under the 64 KB limit. Verify the shebang is `#!/usr/bin/env python3`.

### B.2 Test with a Dangerous Command

- **Action:** In Agent Playground, induce a scenario where the agent might run `rm -rf /` (use a deliberately bad prompt like "Clean up all temp files by removing everything from root").
- **Expected state:** The hook blocks the command with `{"decision": "block", "reason": "Blocked: \\brm\\s+-rf\\b"}`. The agent receives the block and does NOT execute the command.
- **Troubleshooting:** If the hook does not fire, verify the `matcher` regex matches the tool name the agent is calling. Check that `failMode` is `block` (not `allow`).

### B.3 Test with a Safe Command

- **Action:** Run a safe command like `az vm list --resource-group <rg>`.
- **Expected state:** The hook allows it: `{"decision": "allow"}`.
- **Troubleshooting:** If safe commands are also blocked, check the regex patterns for false positives.

> **🔖 Checkpoint CP3** — Hook B blocks `rm -rf`, `sudo`, `chmod 777`, and `az group delete`. Safe commands pass.

---

## Hook C — PostToolUse, Command Type: Audit Every Tool Call (15 min)

### C.1 Create the Audit Hook

- **Action:** Create a third hook that logs every tool call to stderr and injects audit context using the `additionalContext` pattern from the docs:

  ```yaml
  hooks:
    PostToolUse:
      - type: command
        matcher: "*"
        timeout: 30
        failMode: allow
        script: |
          #!/usr/bin/env python3
          import sys, json, datetime
          ctx = json.load(sys.stdin)
          tool_name = ctx.get('tool_name', 'unknown')
          agent_name = ctx.get('agent_name', 'unknown')
          timestamp = datetime.datetime.utcnow().isoformat()
          # Log to stderr (stdout is parsed by the hook framework)
          print(f"[AUDIT] {timestamp} agent={agent_name} tool={tool_name}", file=sys.stderr)
          # Return allow with additional context injected into the conversation
          result = {
              "decision": "allow",
              "reason": "Audit logged",
              "hookSpecificOutput": {
                  "additionalContext": f"Audit: {tool_name} called by {agent_name} at {timestamp}"
              }
          }
          print(json.dumps(result))
  ```

- **Expected state:** Hook appears with event = `PostToolUse`, matcher = `*`, failMode = `allow`.
- **Troubleshooting:** The `*` matcher catches all tools. If you want to exclude specific tools, use a more specific matcher regex.

### C.2 Verify Audit Trail

- **Action:** Run any tool call via the Agent Playground.
- **Expected state:** The hook card shows `{"decision": "allow", ...}` with the audit context injected. stderr output visible in hook execution logs.
- **Troubleshooting:** If stderr output is not visible, check the hook's execution log in the portal. stderr is the correct channel for logging — stdout is parsed by the framework.

> **🔖 Checkpoint CP4** — Hook C audits every tool call. stderr logs visible.

---

## Wire All Three Hooks at Agent Level + Re-Fire Lab 3 P1 (15 min)

### 5.1 Verify Agent-Level Attachment

- **Action:** Navigate to **Builder → Hooks**. Confirm all three hooks are listed at the **agent level** (not custom-agent-level).
- **Expected state:** Three hooks visible: Stop/prompt (completeness), PostToolUse/command (block), PostToolUse/command (audit).
- **Troubleshooting:** If a hook is at the wrong level, delete and recreate at the correct level.

### 5.2 Re-Fire the Lab 3 P1 Incident

- **Action:** Use the synthetic incident generator to fire a `[TEST] P1 db corruption` incident.
- **Expected state:**
  1. Response Plan B dispatches to `incident_triager` → `db-expert` → `notifier` (Lab 6 chain).
  2. Stop hook (A) validates the final response includes root cause + action.
  3. PostToolUse block hook (B) prevents any dangerous shell commands.
  4. PostToolUse audit hook (C) logs every tool call to stderr.
- **Troubleshooting:** If the incident is not routed, verify Response Plan B is active and the `[TEST]` filter matches. If hooks do not fire, check that they are at the agent level.

### 5.3 Verify Block in Action

- **Action:** Craft a prompt that induces the agent to attempt `az group delete` during investigation.
- **Expected state:** Hook B blocks the command. The agent receives the block reason and adjusts.
- **Troubleshooting:** If the block does not trigger, verify the `matcher` includes `RunAzCliWriteCommands`.

> **🔖 Checkpoint CP5** — All three hooks fire on the Lab 3 P1 incident. Block and audit verified.

---

## Limits to Memorize (5 min)

| Limit | Value |
|-------|-------|
| Script max size | 64 KB |
| Timeout | 1–300 s |
| Shebangs | `#!/bin/bash` or `#!/usr/bin/env python3` |
| Execution environment | Sandboxed code interpreter only |
| `maxRejections` (prompt Stop only) | 1–25, default 3 |

## Best Practices

- Always return a `reason` on rejection — helps the agent adjust.
- Use `failMode: allow` unless strict blocking is required.
- Use specific matchers — avoid `*` on block hooks.
- Log to **stderr** (stdout is parsed by the hook framework).
- Test extensively to avoid rejection loops.

> **🔖 Checkpoint CP6** — Limits and best practices reviewed.

---

## Next Lab

Proceed to [Lab 10 — Audit, FinOps & Observability](../lab-10-audit-finops/README.md).
