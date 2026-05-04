# M9 — Agent Hooks: Troubleshooting

## Common Issues

### Hook Does Not Fire

- **Cause:** Hook is at the wrong level (custom-agent-level instead of agent-level), or the event type is incorrect.
- **Fix:** Verify in Builder → Hooks that the hook is at the agent level. Check that the event matches (Stop vs PostToolUse).

### Prompt Hook Always Returns ok: true

- **Cause:** The prompt is too vague, or the model tier (ReasoningFast) is not evaluating correctly.
- **Fix:** Sharpen the prompt. Test with a deliberately incomplete response. Consider upgrading to `Reasoning` model tier for critical hooks.

### Command Hook Script Fails to Save

- **Cause:** Script exceeds 64 KB limit, invalid shebang, or syntax error.
- **Fix:** Check script size. Use only `#!/bin/bash` or `#!/usr/bin/env python3` shebangs. Validate Python syntax locally before pasting.

### Command Hook Returns Unexpected Exit Code

- **Cause:** Python exception before the print statement.
- **Fix:** Wrap the script in try/except. Exit code `0` = allow, `2` = block. Any other exit code follows `failMode`.

### Hook Triggers a Rejection Loop

- **Cause:** `maxRejections` is too high, or the hook always rejects because the agent cannot satisfy the condition.
- **Fix:** Lower `maxRejections` (default 3). Review the hook prompt/script to ensure the pass condition is achievable.

### Matcher Does Not Match the Tool Name

- **Cause:** Tool names are case-sensitive and must match the exact tool name the agent calls.
- **Fix:** Check the tool name in Builder → Tools. The matcher uses regex — `Bash|ExecuteShellCommand|RunAzCliWriteCommands` must match the exact names.

### stderr Output Not Visible

- **Cause:** Looking in the wrong place.
- **Fix:** Check the hook's execution log in the portal (not the agent's main conversation). Remember: stdout is parsed by the hook framework; stderr is for logging.

### Safe Commands Being Blocked by Hook B

- **Cause:** Regex false positive.
- **Fix:** Review the patterns. `\brm\s+-rf\b` uses word boundaries — but compound commands may trigger unexpectedly. Refine the regex.

## Escalation

If issues persist, escalate to the trainer with:
1. Hook name, event type, and execution type
2. The full YAML configuration
3. The hook execution log (include both stdout and stderr)
4. The tool call that triggered (or failed to trigger) the hook
