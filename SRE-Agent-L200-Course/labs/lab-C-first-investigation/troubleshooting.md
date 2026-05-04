# Lab C — First Investigation in Chat: Troubleshooting Guide

Quick-reference error/fix table for Lab C issues.

---

## Error / Fix Table

| # | Symptom | Cause | Fix |
|---|---------|-------|-----|
| 1 | Agent says "I don't have access to any Azure resources" | Resource group not connected in Lab B, or RBAC role assignment still propagating. | Go to Builder → Connectors → Azure Resources and verify the RG is connected. Wait 2–5 min for RBAC propagation. |
| 2 | No tool-call cards appear in the response | Agent answered from general knowledge without querying Azure (prompt too vague). | Be more specific: include the resource group name or app name in your prompt. |
| 3 | KQL query card shows "No results" | Sample workload hasn't generated logs/errors in the queried time range. | Generate traffic to the sample app, or broaden the query: "Show me errors in the last 24 hours." |
| 4 | "I cannot perform write operations" — no Approve/Deny UI | Agent is in Autonomous mode with only Reader permission — it silently cannot write. | Verify agent is in **Review** mode: Builder → Settings → Run Mode. Review mode shows Approve/Deny buttons. See [Run Modes](https://sre.azure.com/docs/concepts/run-modes). |
| 5 | Approve/Deny buttons don't appear for a write command | Run mode is Autonomous, or the operation falls within the agent's existing permission level. | Switch to **Review** mode. Try an explicit write command like `Restart the container app <name>`. |
| 6 | OBO authorization fails when clicking Authorize | Entra account is a guest/personal MSA, or user role is not SRE Agent Administrator. | Use a **work or school** account. Verify your [User Role](https://sre.azure.com/docs/concepts/user-roles) is Administrator. |
| 7 | Agent response is very slow (> 2 minutes) | Complex multi-tool query, or Azure throttling. | Wait for the response to complete. Narrow scope in future prompts (specific app name, shorter time range). |
| 8 | Agent says "I don't have any code repositories connected" | Code connector from Lab B was disconnected or failed. | Verify in Builder → Connectors → Code. Re-add the repository if needed. |
| 9 | Chat input is disabled / cannot type | Session timeout or browser issue. | Refresh the page. If issue persists, navigate away and back to the agent chat. |
| 10 | Agent doesn't cite knowledge documents | The knowledge docs haven't been indexed yet, or the prompt doesn't relate to the docs' content. | Ask a prompt that directly relates to your uploaded architecture doc, e.g., "What is the architecture of our system?" |

---

## Tool-Call Card Quick Reference

If you're unsure what a tool-call card means:

| Card Label | What the Agent Did |
|------------|-------------------|
| **Resource Graph Query** | Queried Azure Resource Graph to discover or check status of Azure resources. |
| **Log Analytics KQL Query** | Ran a KQL query against your Log Analytics workspace to search logs. |
| **App Insights Query** | Queried Application Insights telemetry (exceptions, requests, dependencies). |
| **Azure CLI** | Executed an `az` command (e.g., `az containerapp revision list`). |

Click on any card to expand and see the exact query/command the agent ran.

---

## Escalation Path

If you are stuck for more than **5 minutes** on any issue:

1. Check this table first.
2. Ask a neighbor — they may have hit the same issue.
3. Post in the **workshop support channel** (Teams/Slack) with:
   - Your alias
   - Which prompt / step you're on
   - The exact error message or screenshot
4. Raise your hand for in-person instructor help.
