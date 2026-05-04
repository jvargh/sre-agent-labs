# Lab D — Deep Investigation: Troubleshooting Guide

---

## Common Issues

| # | Symptom | Likely Cause | Fix |
|---|---------|-------------|-----|
| 1 | **OBO authorization card times out** | The OBO token is valid for 10 minutes. If you don't approve in time, or if the investigation exceeds 10 minutes, the token expires. | Click **Approve** again when the agent re-prompts for authorization. The investigation pauses (not fails) while waiting. |
| 2 | **Investigation stuck in Phase 2 (Forming hypotheses)** | The agent needs sufficient telemetry data to form hypotheses. If the sample app has minimal traffic or logging, hypothesis generation may stall. | Wait up to 5 minutes. If still stuck, cancel and retry with a more specific prompt targeting a known issue. Ensure the sample workload is generating traffic. |
| 3 | **Thin results — only 1 hypothesis or vague conclusion** | The investigation prompt is too broad, or the sample app has very little activity to analyze. | Try a more targeted prompt, e.g., "Investigate the spike in HTTP 500 errors on `<sample-app>` between 10:00 and 10:30 UTC today." See [lab-prompts.md](../../prompts/lab-prompts.md) for variant prompts. |
| 4 | **"Deep investigation" option missing from the + menu** | Agent is not in `Running` state, or you lack the required role. | Verify agent status at [sre.azure.com](https://sre.azure.com). Confirm you have the **SRE Agent Administrator** role on the agent resource. |
| 5 | **OBO authorization card never appears** | The agent's UAMI already has sufficient permissions for the requested resources (Reader permission level with adequate RBAC). | This is expected behavior — OBO is only triggered when the UAMI lacks permission for a specific action. Proceed without OBO. |
| 6 | **Investigation completes but conclusion says "insufficient data"** | The sample workload has not generated enough telemetry (logs, metrics, traces) for the agent to draw conclusions. | Generate traffic against the sample app before retrying. Run a load test or manually trigger errors. Ensure App Insights and Log Analytics are receiving data. |
| 7 | **"Authorization failed" error after approving OBO** | Your Entra ID account is a personal MSA, or you lack write permissions on the target resource group. | Switch to a work/school Entra ID account. Verify you have at least Contributor on the resource group. |
| 8 | **Investigation tree shows but no phases progress** | Network connectivity issue to `*.azuresre.ai` or the agent backend is temporarily unavailable. | Check network access to `*.azuresre.ai`. Refresh the browser. If the issue persists, wait 2 minutes and retry. |
| 9 | **Phase 3 shows all hypotheses as "Inconclusive"** | The agent found correlations but could not definitively validate or invalidate any hypothesis given the available data. | This is a valid outcome. Review the evidence in each node — the partial findings may still be useful. Try a narrower investigation scope with a revised prompt. |
| 10 | **Sparkle badge won't turn off** | UI glitch — the X button may not respond on first click. | Refresh the browser page. Deep investigation mode will be off after refresh (any in-progress investigation continues in the background). |

---

## Escalation Path

If none of the above resolves your issue:

1. **Check the support channel** (Teams/Slack) — a trainer can help in real time.
2. **Capture a screenshot** of the error or stuck state.
3. **Note the investigation thread URL** (click ⋯ → Copy link to thread in the chat).
4. Post all three in the support channel and tag the trainer.

---

## Key Facts to Remember

- **OBO timeout:** 10 minutes per authorization.
- **Partial results:** Always preserved on cancel — you do not lose work.
- **Cost:** Deep investigations consume more tokens than standard chat. Use them for complex, multi-signal problems.
- **Mode 1 only:** This lab uses chat-triggered deep investigation. Mode 2 (response-plan triggered) is Level 300.
