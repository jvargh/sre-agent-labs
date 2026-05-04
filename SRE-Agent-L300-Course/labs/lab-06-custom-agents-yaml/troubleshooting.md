# Lab 6 — Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| YAML view empty for `p1-investigator` | Agent not saved properly in Lab 3 | Re-create and save `p1-investigator` in Agent Canvas |
| REST API PUT returns 400 | YAML syntax error (indentation, missing fields) | Validate YAML with a linter; check required fields: `name`, `system_prompt`, `handoff_description` |
| Handoff edges not visible in canvas | `handoff_description` missing or empty | Add a descriptive `handoff_description` to each agent YAML |
| Chain breaks at handoff — wrong agent selected | Classification terms in `incident_triager` prompt don't match downstream agent descriptions | Align the triager's classification labels with downstream `handoff_description` text |
| `notifier` runs `az cli` commands despite system prompt | System prompt is advisory, not a hard gate | Add a PostToolUse hook (Lab 9) to block non-notification tools on `notifier` |
| VS Code MCP extension doesn't sync | Extension not authenticated or not connected | Re-authenticate the extension; verify agent resource URL in extension settings |
| PR merge fails | YAML files have merge conflicts or invalid structure | Resolve conflicts; validate YAML syntax before re-pushing |
| Agent tool budget exceeded | Too many tools on one custom agent | Each agent has an 80-tool limit; remove unused tools |
