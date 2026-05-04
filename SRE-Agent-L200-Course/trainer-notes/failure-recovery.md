# Failure Recovery Guide — "What to Do When X Breaks Live"

> **Purpose:** Quick-reference for trainers and TAs when attendees hit issues during the workshop.
> **Escalation path:** Post in the workshop support channel (Teams/Slack). Tag the workshop lead if unresolved after the listed time estimate.

---

## Failure Mode Table

| # | Symptom | Lab | Root Cause | Fix | Time to Resolve |
|---|---------|--------|-----------|-----|-----------------|
| 1 | `DeploymentNotFound` error during agent creation | Lab A | `Microsoft.App` resource provider is not registered in the subscription | Run `az provider register --namespace "Microsoft.App"` and wait 1–2 minutes, then retry agent creation | 2–3 min |
| 2 | "Create" button greyed out in agent wizard | Lab A | Attendee lacks Contributor/Owner on the subscription, or selected an unsupported region | Verify RBAC role on the subscription. Switch region to Sweden Central, East US 2, or Australia East | 2–5 min |
| 3 | Application Insights creation fails during deployment | Lab A | Quota limit or region constraint on App Insights | In the wizard, select **Use existing** and pick a pre-provisioned App Insights instance in the sandbox subscription | 1–2 min |
| 4 | Agent not seeing connected resources (empty results from "What Azure resources can you see?") | Lab B/C | RBAC role assignments not propagated, or wrong resource group selected during connection | Wait 2–3 minutes for RBAC propagation. Verify with `az role assignment list --assignee <uami-id> --scope <rg-scope> --output table`. If missing, re-add the resource group in Builder → Azure Resources | 3–5 min |
| 5 | Code repo connection fails (OAuth error) | Lab B | GitHub/Azure DevOps OAuth redirect blocked by corporate proxy, or user lacks read access to the repo | Try PAT-based authentication instead of OAuth. Confirm the attendee has read access to the target repo | 3–5 min |
| 6 | OBO authorization card times out | Lab D | Authorization window is 10 minutes. Attendee did not approve in time, or is signed in with a personal MSA instead of a work/school Entra account | Have the attendee re-trigger the deep investigation and approve the OBO card promptly. Confirm they are signed in with their work/school Entra ID (not a personal Microsoft account) | 2–3 min |
| 7 | Deep investigation shows partial results after cancel | Lab D | Investigation was cancelled mid-flight (user clicked X or browser refreshed) | Partial results are preserved — this is expected behavior. Start a new deep investigation for complete results. Assure the attendee this is not an error | 1 min |
| 8 | Outlook connector sign-in fails | Lab E | M365 account mismatch (different tenant), browser cookie conflict, or conditional access policy blocking the OAuth flow | Try in an InPrivate/Incognito window. Ensure the M365 account is in the same Entra ID tenant as the Azure subscription. Clear browser cookies for `login.microsoftonline.com` if needed | 3–5 min |
| 9 | Scheduled task not executing | Lab E | Task was saved but never triggered, or the subagent's tool list doesn't include `SendOutlookEmail` | Go to Builder → Scheduled Tasks → select task → **Run task now**. If that doesn't work, verify the subagent has the `SendOutlookEmail` tool attached. Re-save the task if needed | 2–3 min |
| 10 | Custom agent (subagent) not appearing on canvas | Lab E | Browser did not refresh after save | Hard-refresh the browser (Ctrl+Shift+R). If still missing, delete and recreate the subagent | 1–2 min |

---

## General Fallbacks

### Attendee falls behind

| Situation | Action |
|-----------|--------|
| Behind by 1 session | TA pairs with the attendee to fast-track through the missed steps while the group continues |
| Behind by 2+ sessions | TA helps the attendee complete the critical checkpoint (Running agent from Lab A) and joins the group at the current session. Catch up on skipped labs after the workshop |
| Cannot complete any lab due to subscription/access issues | Pair the attendee with a neighbor for screen-sharing so they can observe the labs. File an access request for post-workshop follow-up |

### Portal UI differs from screenshots

| Situation | Action |
|-----------|--------|
| Button moved or renamed | The docs at [sre.azure.com/docs](https://sre.azure.com/docs) are the source of truth. Navigate by feature name rather than exact button position. Announce the discrepancy to the room |
| Feature behind a preview flag | Check the agent's region and feature availability. Some features may only be available in specific regions. If a feature is unavailable, skip that step and explain what it would do |
| New wizard steps appeared | Walk through them live. The core flow (Basics → Review → Create) is stable; additional optional fields can be left at defaults |

### Agent returns thin/unhelpful results

| Situation | Action |
|-----------|--------|
| Agent says "I don't have access to..." | Check resource connections in Builder → Azure Resources. Re-add the resource group if needed |
| Agent gives a generic answer with no tool calls | Rephrase the prompt to be more specific. Include resource names, time ranges, and the type of data requested. E.g., instead of "check my app", try "Show me HTTP 5xx errors in contoso-payments-app in the last 30 minutes" |
| Agent cites no knowledge docs | Verify uploads in Builder → Knowledge Base. Re-upload if documents are missing. Use `#retrieve` to check what the agent remembers |
| Agent is slow (>60 seconds per response) | Deep investigations are token-intensive and expected to be slower. For regular chat, this may indicate a service-side issue — check the support channel for known outages |

---

## Escalation Path

1. **First line:** TA resolves using this guide (target: <5 min).
2. **Second line:** Post in the workshop support channel with:
   - Attendee alias
   - Session/lab reference
   - Screenshot of the error
   - Steps already attempted
3. **Third line:** Tag the workshop lead in the support channel. If it's a platform issue (sre.azure.com down, deployment API errors), the lead contacts the SRE Agent product team.

---

## Pre-Workshop Checklist (Prevent Failures)

- [ ] `Microsoft.App` provider registered in the sandbox subscription
- [ ] Each attendee has Owner or User Access Administrator on their personal RG
- [ ] Sandbox subscription has quota in at least one supported region
- [ ] Sample workload is deployed and healthy
- [ ] `*.azuresre.ai` is on the corporate firewall allowlist
- [ ] Pre-provisioned App Insights instance exists as a fallback (for failure #3)
- [ ] Workshop support channel is created and all TAs + attendees are added
