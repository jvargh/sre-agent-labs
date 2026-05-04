# Lab A — Provision Your First Agent: Troubleshooting Guide

Quick-reference error/fix table for Lab A issues.

---

## Error / Fix Table

| # | Symptom | Cause | Fix |
|---|---------|-------|-----|
| 1 | `DeploymentNotFound` error when clicking Create | `Microsoft.App` resource provider is not registered. | Run `az provider register --namespace "Microsoft.App"` in a terminal. Wait 1–2 min, then retry. |
| 2 | **Create** button is greyed out / cannot click | Insufficient permissions (need Contributor+) or an unsupported region selected. | Ask your instructor to verify your RBAC role. Switch to Sweden Central, East US 2, or Australia East. |
| 3 | App Insights creation fails during deployment | Naming conflict or quota limit on auto-generated Application Insights resource. | Go back, select **Use existing**, and choose a pre-provisioned App Insights instance. |
| 4 | Deployment stuck > 10 minutes | Transient Azure capacity issue in the selected region. | Wait up to 15 min. If still pending, cancel and retry in a different supported region. |
| 5 | Agent shows `Failed` state | Role assignment propagation delay or network restriction blocking the agent runtime. | Open the resource group → Activity Log for detailed error. Escalate to instructor. |
| 6 | "You do not have access" on sre.azure.com | Signed in with a personal Microsoft Account (MSA) or guest account. | Sign out, then sign in with your **work or school** Entra ID account. |
| 7 | Region dropdown doesn't show Sweden Central / East US 2 / Australia East | Subscription has region restrictions (Azure Policy or quota). | Ask instructor to verify subscription region allowlist. |
| 8 | "Subscription not found" in the wizard | You are signed into the wrong tenant or the subscription is disabled. | Click your profile icon → **Switch directory** → select the workshop tenant. |

---

## Escalation Path

If you are stuck for more than **5 minutes** on any issue:

1. Check this table first.
2. Ask a neighbor — they may have hit the same issue.
3. Post in the **workshop support channel** (Teams/Slack) with:
   - Your alias
   - The exact error message or screenshot
   - Which step you're on
4. Raise your hand for in-person instructor help.

---

## Useful Commands

```bash
# Check if Microsoft.App provider is registered
az provider show --namespace "Microsoft.App" --query "registrationState" --output tsv

# Register the provider if needed
az provider register --namespace "Microsoft.App"

# List resources in your resource group
az resource list --resource-group rg-sre-agent-<your-alias> --output table
```
