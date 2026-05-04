# Lab 4 — Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| Create Skill button greyed out | Missing SRE Agent Admin role | Verify RBAC on the agent resource |
| Skill does not auto-load when prompted | `description` field lacks trigger phrases | Edit SKILL.md — add specific phrases the model can match (e.g., "debug X", "X errors") |
| Skill loads for unrelated prompts | Description too broad or generic | Narrow the description to specific service names and failure modes |
| Tool picker does not show `RunAzCliReadCommands` | Tool not enabled at workspace level | Enable the tool in Builder → Tools before attaching to the skill |
| Agent Playground chat panel empty | Browser cache or session issue | Refresh the portal; clear browser cache if needed |
| VS Code MCP extension not syncing | Extension not installed or not authenticated | Confirm extension is installed and authenticated to the correct agent resource |
| More than 5 skills active — unexpected unloading | Exceeded concurrent skill limit | Archive low-priority skills; keep only top 5 active |
