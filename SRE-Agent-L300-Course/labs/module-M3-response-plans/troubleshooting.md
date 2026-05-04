# M3 — Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| Autonomous mode greyed out on `p1-investigator` | Agent resource not set to Privileged permissions | Update agent permissions per M1 matrix; see [Manage Permissions](https://sre.azure.com/docs/tutorials/agent-config/manage-permissions) |
| Deep Investigation Mode 2 toggle missing | Feature not enabled on the agent resource | Confirm agent supports deep investigation; see [Deep Investigation](https://sre.azure.com/docs/capabilities/deep-investigation) |
| Mode 2 prompts for OBO authorization | Mode 1 is active instead of Mode 2 | Edit the response plan → toggle to Mode 2 (auto-trigger, uses agent UAMI) |
| Incident routes to wrong custom agent | Overlapping severity filters between plans | Open unified grid view → check for overlap → adjust filters to be non-overlapping |
| Incident not routed at all | `[TEST]` filter too restrictive or plan turned off | Remove `[TEST]` from title filter after validation; confirm plan is turned on |
| Double-routing (incident processed twice) | Quickstart plan still exists from L200 | Delete the quickstart plan in Builder → Incident Response Plans (should have been done in M2) |
| Response plan fails to save | Conflicting filter with existing plan | Check unified grid for conflicts; ensure severity ranges don't overlap |
| P1 investigation does not show 4-phase tree | Deep investigation not enabled on Plan B | Edit Plan B → confirm Deep Investigation toggle is ON and set to Mode 2 |
| `[TEST]` incidents not matching preview | Incident title missing `[TEST]` prefix or wrong severity | Verify the synthetic incident includes `[TEST]` in the title and correct priority level |
