---
title: SRE Agent L300/400 Workshop — Production Rollout Pack
source_md_sha: placeholder
srea_version: srea-l300-v1.0.0
---

# Production Rollout Pack

**Attendees:** This is your take-home kit for rolling out the SRE Agent to production post-workshop.

**Contents:** Bicep skeleton, hook YAML stubs (3), KQL workbook export, 10-step rollout playbook from Lab 13.

---

## What's in the Box

| Item | File | Purpose |
|------|------|---------|
| Agent IaC skeleton | agent-iac.bicep (or .tf) | Starting point for your agent resource + UAMI + role assignments + App Insights. Customize per your environment. |
| Hook stubs (3) | stop-prompt-completeness.yaml, posttooluse-command-block.yaml, posttooluse-audit.yaml | Copy these into your agent's hook configuration. Customize matchers + timeouts per your organization's risk profile. |
| KQL workbook | audit-workbook.json | Import into your App Insights to start monitoring agent activity on day one. All 5 queries from Lab 10. |
| Rollout playbook | production-rollout-1pager.md | One-page summary of the 10 steps. Print it. Share it. Live by it. |

---

## Quick-Start: Smoke Test

Before you rollout to any real incidents:

1. **Deploy the agent skeleton** in a fresh test RG:
   ```bash
   az deployment group create \
     --resource-group <test-rg> \
     --template-file agent-iac.bicep \
     --parameters modelProvider=Anthropic
   ```

2. **Verify the agent is Running:**
   ```bash
   az sre-agent agent show --name <agent-name> --resource-group <test-rg>
   ```

3. **Connect one incident platform** (PagerDuty / ServiceNow / Azure Monitor) in the Builder UI.

4. **Fire a single test incident** with prefix [TEST]. Verify it routes to your lowest-severity response plan and returns audit messages.

5. **Check App Insights** for customEvents (should show AgentResponse + tool calls).

6. **Tear down the test RG:**
   ```bash
   az group delete --name <test-rg> --yes --no-wait
   ```

If all above complete without errors, you're ready to proceed to Step 1 of the rollout playbook.

---

## Acceptance Criteria

✓ Agent resource deploys without drift.  
✓ Incident platform connector shows "Connected" within 60 s.  
✓ Test incident routes automatically (no manual intervention).  
✓ App Insights query returns non-empty customEvents.  
✓ Teardown removes all resources in the RG.

---

## Directory Structure

`
rollout-pack/
├── README.md (this file)
├── production-rollout-1pager.md
├── agent-iac.bicep
├── agent-iac.tf (Terraform variant)
└── hook-stubs/
    ├── stop-prompt-completeness.yaml
    ├── posttooluse-command-block.yaml
    ├── posttooluse-audit.yaml
└── workbooks/
    └── audit-workbook.json
`

---

## Next Steps

1. Read the **one-pager** (production-rollout-1pager.md).
2. Customize the **agent skeleton** for your subscriptions, UAMI scopes, and model provider.
3. Customize the **hook stubs** for your organization's risk profile.
4. Run the **smoke test** above.
5. Follow the **10 steps** in order. Don't skip step 6 (wire hooks before Autonomous).

---

## Troubleshooting

**"Connector shows Disconnected"**  
→ Check incident-platform credentials in Key Vault. Rotate if needed. Restart Builder.

**"Test incident doesn't route"**  
→ Did you delete the quickstart response plan (Lab 2 checkpoint)? Verify at least one custom response plan exists in the unified grid view.

**"App Insights query returns no rows"**  
→ Generate agent activity by asking the agent a question in chat or firing another test incident. App Insights data appears within 60 s.

**"Agent deploy fails with ModelProvider error"**  
→ Check the Bicep parameter. Valid values: Anthropic, AzureOpenAi. If you choose AzureOpenAi, ensure the EUDB instance is already provisioned and the UAMI has access.

---

## FAQ

**Q: Can I rollout to production immediately after the workshop?**  
A: Not recommended. Follow the 10-step playbook, starting with shadow mode (Review on all plans) for 2 weeks. Build confidence before flipping to Autonomous.

**Q: What if I don't have an Entra ID admin for Lab 11?**  
A: Cross-tenant connectors require admin consent. If you skipped Lab 11 during the workshop, you can do this async. Reference capabilities/cross-tenant-access docs.

**Q: How do I add new incident response plans after rollout?**  
A: Create them in the Agent Canvas (portal UI) or via REST API v2 PUT /api/v2/extendedAgent/agents/{agentName}. Always attach hooks before promoting to Autonomous.

**Q: Where do I report bugs in the agent or this rollout pack?**  
A: File an issue in the workshop repository with the tag srea-l300-rollout-bug. Include reproduction steps + agent name + timestamps.

---

## Credits

This pack was generated from the Azure SRE Agent L300/400 Advanced Workshop curriculum (SREA-Level300.md).

For questions, escalate to the SRE Agent team via the operations runbook (shared during the workshop).

---

**Version:** srea-l300-v1.0.0  
**Last updated:**   
**Expiry:** None (living document; check for updates quarterly)
