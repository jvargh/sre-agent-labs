# Lab 1 — Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| Attendee has no production service to map | First-time SRE or lab-only environment | Use the workshop sample workload `<sample-app>` as the target service |
| Confusion between Run Modes and Hooks | Common L200 misconception that Autonomous blocks all dangerous actions | Clarify: Run Modes gate Azure actions only; Hooks gate everything (including email, Teams, MCP). Refer to [Agent Hooks](https://sre.azure.com/docs/capabilities/agent-hooks) |
| Attendee wants to skip to Autonomous for all triggers | Over-confidence from L200 | Walk through the matrix: show that even P1 response plans need Hooks (Lab 9) before Autonomous is safe |
| Matrix cells left blank | Attendee unsure how to classify a trigger | Trainer provides 1:1 guidance; use the sample workload as a worked example |
