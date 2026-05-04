# Lab B — Connect Code, Resources, and Knowledge

> **Module 4 (L200) — 45 min hands-on lab**
> Maps to docs: [Get Started Steps 2 & 3](https://sre.azure.com/docs/get-started), [Connectors](https://sre.azure.com/docs/concepts/connectors), [Memory & Knowledge](https://sre.azure.com/docs/concepts/memory)

---

## 1. Outcome

Agent has 1 repo, 1 RG of Azure resources, and 2 knowledge documents loaded.

---

## 2. Prerequisites

| # | Requirement | Details |
|---|------------|---------|
| 1 | Lab A complete | Agent `contoso-sre-agent` in `Running` state. You should be on the **"More context. Better investigations."** onboarding page. |
| 2 | GitHub or Azure DevOps access | Read access to one repo containing a sample workload (e.g., from `github.com/microsoft/sre-agent/tree/main/samples`). |
| 3 | Sample workload deployed | A Container App, App Service, or Function in a resource group you can grant the agent Reader access to. |
| 4 | Two knowledge documents | Prepared in Markdown or PDF format: one architecture overview and one runbook. |
| 5 | Entra ID account | Same work or school account from Lab A. |

---

## 3. Time Budget

| Phase | Duration |
|-------|----------|
| Part 1 — Connect code repository | 15 min |
| Part 2 — Add Azure resource access | 15 min |
| Part 3 — Add team knowledge | 10 min |
| Checkpoint confirmation | 5 min |
| **Total** | **45 min** |

---

## 4. Lab Steps

### Part 1 — Connect a Code Repository (15 min)

#### Step 1 — Open the Code Connection Card

1. On the **"More context. Better investigations."** page (or navigate: Builder → Connectors → Code), locate the **Code** card.
2. Click **Add repository**.

![Step 1 — Code card on onboarding page](screenshots/step-1-code-card.png)

#### Step 2 — Authenticate to GitHub (or Azure DevOps)

1. Choose your source control provider:
   - **GitHub** (recommended for this workshop)
   - **Azure DevOps**
2. Select authentication method: **OAuth** (preferred) or **PAT** (Personal Access Token).
3. Complete the sign-in flow. Authorize the SRE Agent app when prompted.

![Step 2 — GitHub OAuth authorization](screenshots/step-2-github-oauth.png)

#### Step 3 — Select and Add Repository

1. Browse or search for the repository containing your sample workload.
2. Select the repository.
3. Click **Add repository**.

![Step 3 — Repository selection](screenshots/step-3-select-repo.png)

> 💡 **Talking point:** After the connection is established, the agent starts a **background codebase analysis**. It will generate an `SREAGENT.md` pull request in your repo. **Do not merge** this PR during the workshop — just open and review it to see what the agent learned about your codebase.
>
> ⚠️ **Note:** The `SREAGENT.md` PR may take 5–15 minutes to appear and is **best-effort** — if it doesn't appear during the lab, that's fine. Proceed to the next step. The PR is not required for subsequent labs.

#### Step 4 — Confirm Repository Is Connected

1. The repository should appear in the Code connectors list with a ✅ status.
2. You may see a "Codebase analysis in progress" indicator — this is normal.

![Step 4 — Repository connected confirmation](screenshots/step-4-repo-connected.png)

---

### Part 2 — Add Azure Resource Access (15 min)

#### Step 5 — Open the Azure Resources Card

1. Navigate to the **Full setup** tab (or Builder → Connectors → Azure Resources).
2. Click on the **Azure Resources** card.

![Step 5 — Azure Resources card](screenshots/step-5-azure-resources-card.png)

#### Step 6 — Choose Resource Group Scope

1. Select **Resource groups** as the scope level.

> ⚠️ **Why Resource groups, not Subscription?** For a workshop with 20+ attendees, resource-group scope is safer — it limits the agent to only the resources you intend it to see. Never grant subscription-wide access in a shared lab environment.

![Step 6 — Resource group scope selection](screenshots/step-6-scope-selection.png)

#### Step 7 — Select the Target Resource Group

1. Filter by your workshop subscription.
2. Pick the resource group containing your **sample workload** (not `rg-sre-agent-<your-alias>` — pick the workload RG).
3. Set **Permission level** to **Reader** (recommended).

![Step 7 — Select resource group and permission level](screenshots/step-7-select-rg.png)

#### Step 8 — Review Roles and Add

1. Review the automatically-assigned roles that will be granted to your agent's UAMI.
2. Click **Add resource group**.

![Step 8 — Review role assignments](screenshots/step-8-review-roles.png)

#### Step 9 — (Optional) Verify Role Assignments via CLI

If you are comfortable with Azure CLI, verify the role assignments:

```bash
az role assignment list \
  --assignee <agent-uami-id> \
  --scope /subscriptions/<sub-id>/resourceGroups/<workload-rg> \
  --output table
```

Replace:
- `<agent-uami-id>` — your agent's UAMI object ID (find it in the resource group)
- `<sub-id>` — your subscription ID
- `<workload-rg>` — the resource group you just connected

> ⚠️ **Sanitization note:** Do not share real subscription IDs, tenant IDs, or UAMI object IDs. Replace with placeholders in screenshots and support requests.

---

### Part 3 — Add Team Knowledge (10 min)

#### Step 10 — Upload Knowledge Documents

1. Navigate to **Builder → Knowledge base**.
2. Click **Upload**.
3. Upload your two prepared documents:
   - `sample-architecture.md` — an architecture overview of your sample workload
   - `sample-runbook.md` (or PDF) — a runbook (e.g., "Restart procedure for Container App X")
4. Wait for upload confirmation.

![Step 10 — Knowledge base upload](screenshots/step-10-upload-knowledge.png)

#### Step 11 — Demo the #remember Command

1. Open the agent chat (if not already open).
2. Type the following and press Enter:

```
#remember <your-alias>: our prod region is East US 2 and our paging channel is #oncall-payments
```

> 💡 **Replace `<your-alias>`** with your workshop alias (e.g., `jdoe`). Prefixing with your alias prevents memory collisions when multiple attendees share the same agent instance.

3. The agent should confirm it has stored this fact.

![Step 11 — #remember command in chat](screenshots/step-11-remember-command.png)

> 💡 **Additional memory commands:**
> - `#retrieve` — recall stored facts
> - `#forget` — delete a stored fact
>
> See [Memory & Knowledge](https://sre.azure.com/docs/concepts/memory) for full details.

---

## 5. Checkpoint

> **✅ Checkpoint:** Click **Done and go to agent** on the setup page. The **chat interface** should open. If you see the chat input bar and the agent is ready to respond, Lab B is complete.

![Checkpoint — Chat interface open](screenshots/checkpoint-chat-open.png)

---

## 6. Expected Output

After completing Lab B, your agent should have:

| Connection Type | What Was Connected | Status |
|----------------|-------------------|--------|
| Code repository | 1 GitHub (or ADO) repo | ✅ Connected, codebase analysis running |
| Azure resources | 1 resource group (Reader) | ✅ Connected, roles assigned |
| Knowledge base | 2 documents uploaded | ✅ Uploaded |
| Memory | 1 fact stored via `#remember` | ✅ Stored |

**Verifying connections in the Builder:**
- Builder → Connectors → Code: your repo listed with a ✅
- Builder → Connectors → Azure Resources: your RG listed with Reader permission
- Builder → Knowledge base: 2 documents listed

---

## 7. Troubleshooting Table

| Symptom | Cause | Fix |
|---------|-------|-----|
| GitHub OAuth popup is blocked | Browser pop-up blocker preventing the auth window. | Allow pop-ups for `sre.azure.com` and retry. |
| "No repositories found" after GitHub auth | OAuth scope too narrow, or the repo is in an org that hasn't approved the SRE Agent app. | Ask an org admin to approve the app, or use a personal repo. Alternatively, use a PAT with `repo` scope. |
| Azure DevOps auth fails | PAT expired or lacks read scope. | Generate a new PAT with **Code (Read)** scope. |
| Resource group not visible in the filter | Wrong subscription selected, or you lack Reader role on the workload RG. | Switch subscription in the filter. Verify RBAC with `az role assignment list`. |
| "Add resource group" button greyed out | Permission level not selected, or the RG is already connected. | Ensure you selected **Reader**. Check if the RG was already added. |
| Knowledge document upload fails | File too large or unsupported format. | Use Markdown (.md) or PDF. Keep files under 10 MB. |
| `#remember` command not recognized | Typed in wrong input field, or chat session not initialized. | Ensure you're in the agent chat (not the search bar). Refresh the page and retry. |
| SREAGENT.md PR not appearing | Background codebase analysis is still in progress. | This is normal — analysis can take 5–15 min. Do not wait; proceed to Lab C. |

---

## 8. Cleanup Steps

**No cleanup is needed after Lab B.** All connections (code repository, Azure resources, knowledge documents, and memory facts) persist and are required for Lab C and subsequent labs.

> ⚡ **Do not disconnect your repository or remove resource access.** If you accidentally disconnect, re-add the connection using the same steps above.

---

## References

- [Get Started — Your Journey](https://sre.azure.com/docs/get-started)
- [Create and Set Up](https://sre.azure.com/docs/get-started/create-and-setup)
- [Connectors](https://sre.azure.com/docs/concepts/connectors)
- [Memory & Knowledge](https://sre.azure.com/docs/concepts/memory)
- [Permissions](https://sre.azure.com/docs/concepts/permissions)
- [User Roles](https://sre.azure.com/docs/concepts/user-roles)
