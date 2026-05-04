# Lab B — Connect Code, Resources, and Knowledge: Troubleshooting Guide

Quick-reference error/fix table for Lab B issues.

---

## Error / Fix Table

| # | Symptom | Cause | Fix |
|---|---------|-------|-----|
| 1 | GitHub OAuth popup is blocked | Browser pop-up blocker preventing the authorization window. | Allow pop-ups for `sre.azure.com`, then click **Add repository** again. |
| 2 | "No repositories found" after GitHub auth | OAuth scope too narrow, or the repository is in a GitHub org that hasn't approved the SRE Agent GitHub App. | Ask an org admin to approve the SRE Agent app in GitHub org settings. Alternatively, use a PAT with `repo` scope. |
| 3 | Azure DevOps authentication fails | PAT expired, revoked, or lacks the required scope. | Generate a new PAT with **Code (Read)** scope in Azure DevOps. |
| 4 | Resource group not visible in the subscription filter | Wrong subscription selected, or you lack Reader access on the workload resource group. | Switch to the correct subscription in the filter. Verify access: `az role assignment list --assignee <your-email> --scope /subscriptions/<sub-id>/resourceGroups/<rg>`. |
| 5 | "Add resource group" button greyed out | Permission level not selected, or the resource group is already connected. | Select **Reader** in the permission dropdown. Check the Connected list — the RG may already be added. |
| 6 | Knowledge document upload fails | File size exceeds limit, or format is unsupported. | Use Markdown (.md) or PDF files. Keep each file under 10 MB. |
| 7 | `#remember` command not recognized | Typed in the wrong input field (e.g., browser search bar instead of agent chat). | Click into the **agent chat input box** at the bottom of the chat pane, then retype the command. |
| 8 | SREAGENT.md PR not appearing in the repo | Background codebase analysis takes 5–15 minutes to complete. | This is expected. Do not wait — proceed to Lab C. Check back later. |
| 9 | "You don't have permission to add connectors" | Your user role is not SRE Agent Administrator or Responder on this agent. | Ask the instructor to verify your [User Role](https://sre.azure.com/docs/concepts/user-roles) assignment. |
| 10 | Role assignments show "Pending" after adding resource group | Azure RBAC propagation delay (can take up to 5 minutes). | Wait 2–5 minutes and refresh the page. If still pending after 5 min, ask the instructor. |

---

## Verification Commands

```bash
# Verify agent UAMI role assignments on the workload resource group
az role assignment list \
  --assignee <agent-uami-id> \
  --scope /subscriptions/<sub-id>/resourceGroups/<workload-rg> \
  --output table

# List resources the agent can see in the connected RG
az resource list \
  --resource-group <workload-rg> \
  --output table
```

Replace all `<placeholder>` values with your actual IDs. Do not share real IDs in support channels.

---

## Escalation Path

If you are stuck for more than **5 minutes** on any issue:

1. Check this table first.
2. Ask a neighbor — they may have hit the same issue.
3. Post in the **workshop support channel** (Teams/Slack) with:
   - Your alias
   - Which Part (1, 2, or 3) and Step you're on
   - The exact error message or screenshot
4. Raise your hand for in-person instructor help.
