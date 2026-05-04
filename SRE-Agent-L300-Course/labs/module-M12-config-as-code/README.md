---
module: M12
level: 400
duration_minutes: 90
track: all
dependencies: [M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11]
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# M12 — Configuration as Code: Bicep/ARM, YAML + REST API v2, Knowledge Persistence, Drift Control

## Learning Outcome

The attendee's M1 promotion-playbook decisions land as a PR: IaC for the agent (Bicep or Terraform), custom agents + hooks via REST API v2, knowledge persistence deep dive, and drift-detection query.

> **Pre-read:** [Memory & Knowledge (proactive persistence)](https://sre.azure.com/docs/concepts/memory#proactive-knowledge-persistence) · [Workspace Tools](https://sre.azure.com/docs/concepts/workspace-tools) · [REST API v2](https://sre.azure.com/docs/tutorials/agent-config/agent-hooks)

---

## Checkpoint Schedule

| Time | Checkpoint |
|------|-----------|
| 0:00 | Lab start — verify M11 topology diagram |
| 0:25 | ✅ CP1 — Part 1: IaC deployed to fresh RG |
| 0:50 | ✅ CP2 — Part 2: Custom agents + hooks pushed via REST API v2 |
| 0:65 | ✅ CP3 — Part 3: Knowledge persistence deep dive |
| 0:80 | ✅ CP4 — Part 4: Drift-detection query authored |
| 0:90 | ✅ CP5 — PR landed with all artifacts |

---

## Part 1 — IaC for the Agent (25 min)

### 1.1 Choose Your IaC Language

- **Action:** Choose **Bicep** or **Terraform AVM** (attendee picks). Open the reference repo:
  - Bicep: `reference-repos/agent-as-code/bicep/main.bicep`
  - Terraform: `reference-repos/agent-as-code/terraform/main.tf`
- **Expected state:** The template is open in your editor (VS Code or portal).
- **Troubleshooting:** If the reference repo is not available, clone it from the workshop materials repo.

### 1.2 Review the Resource Set

The IaC template creates:

| Resource | Type |
|----------|------|
| SRE Agent | `Microsoft.AzureSREAgent/agents` (or current GA RP name) |
| User-Assigned Managed Identity (UAMI) | `Microsoft.ManagedIdentity/userAssignedIdentities` |
| App Insights | `Microsoft.Insights/components` |
| Log Analytics Workspace | `Microsoft.OperationalInsights/workspaces` |
| Role Assignments | Per the M1 promotion-playbook matrix |

- **Action:** Review the parameterized model provider: `Anthropic` (default) vs `Azure OpenAI` (for EUDB compliance).
- **Expected state:** You understand which parameters to change for your environment.
- **Troubleshooting:** If the RP name `Microsoft.AzureSREAgent/agents` is not recognized, check the live docs for the current GA name and file a doc-drift issue.

### 1.3 Deploy to a Fresh RG

- **Action:** Deploy the template to a new resource group:
  ```bash
  # Bicep
  az deployment group create \
    --resource-group <fresh-rg> \
    --template-file main.bicep \
    --parameters agentName=<name> modelProvider=Anthropic

  # Terraform
  terraform init && terraform apply -var="agent_name=<name>" -var="model_provider=Anthropic"
  ```
- **Expected state:** Deployment succeeds. Agent resource visible in the Azure Portal.
- **Troubleshooting:** If deployment fails, run `az deployment group what-if` to preview changes. Common issues: missing provider registration, insufficient permissions, name conflicts.

### 1.4 Verify with What-If

- **Action:** Run `az deployment group what-if` to confirm the deployment is idempotent (re-running produces no changes).
- **Expected state:** What-if shows `No changes`.
- **Troubleshooting:** If changes are detected, the template may have non-deterministic defaults. Fix and redeploy.

> **🔖 Checkpoint CP1** — Agent deployed via IaC. What-if confirms idempotent.

---

## Part 2 — Custom Agents + Hooks via REST API v2 (25 min)

### 2.1 Review the REST API v2 Endpoint

- **Action:** Open the REST API v2 client reference:
  - PowerShell: `reference-repos/rest-api-v2-client/powershell/Invoke-SREAgentApi.ps1`
  - Python: `reference-repos/rest-api-v2-client/python/sre_agent_client.py`
- **Expected state:** The client wraps `PUT /api/v2/extendedAgent/agents/{agentName}`.
- **Troubleshooting:** If the endpoint path has changed, check the [Hooks API tutorial](https://sre.azure.com/docs/tutorials/agent-config/agent-hooks).

### 2.2 Export Current Configuration

- **Action:** Export the portal-built custom agents and hooks as YAML:
  ```powershell
  # PowerShell
  ./Invoke-SREAgentApi.ps1 -Action Export -AgentName "incident_triager"
  ```
- **Expected state:** YAML file with agent configuration including hooks from M9.
- **Troubleshooting:** If export fails, verify the agent name matches exactly. Check authentication (managed identity or bearer token).

### 2.3 Push via REST API v2

- **Action:** Modify the exported YAML (e.g., update a hook timeout) and push:
  ```powershell
  # PowerShell
  ./Invoke-SREAgentApi.ps1 -Action Put -AgentName "incident_triager" -YamlPath ./incident-triager.agent.yaml
  ```
- **Expected state:** The API returns `200 OK`. The portal reflects the change.
- **Troubleshooting:** If `409 Conflict`, another change is in progress. Retry after a few seconds.

### 2.4 Diff Against Running Agent

- **Action:** Diff the local YAML against the running agent's configuration to verify zero drift.
- **Expected state:** Diff is empty — local and remote match.
- **Troubleshooting:** If drift is detected, determine the source (portal edit vs API push) and reconcile.

### 2.5 Wrap in a CI Step

- **Action:** Author a GitHub Actions step (or Azure DevOps pipeline step) that runs the REST API v2 push on PR merge.
- **Expected state:** CI pipeline definition committed to the workshop repo.
- **Troubleshooting:** Ensure the CI runner has a managed identity or service principal with access to the agent API.

> **🔖 Checkpoint CP2** — Custom agents + hooks managed via REST API v2. CI step authored.

---

## Part 3 — Knowledge Persistence Files (15 min, Read-Only Deep Dive)

### 3.1 Explore the Knowledge Directory

- **Action:** In the agent portal, navigate to the knowledge persistence files. Review:

  | File / Directory | Purpose |
  |-----------------|---------|
  | `memories/synthesizedKnowledge/overview.md` | Always loaded (~2k char budget). High-level environment summary. |
  | `memories/synthesizedKnowledge/team.md` | Team structure and on-call info |
  | `memories/synthesizedKnowledge/architecture.md` | System architecture knowledge |
  | `memories/synthesizedKnowledge/logs.md` | Logging patterns and locations |
  | `memories/synthesizedKnowledge/deployment.md` | Deployment processes |
  | `memories/synthesizedKnowledge/auth.md` | Authentication patterns |
  | `memories/synthesizedKnowledge/debugging.md` | Debugging procedures |
  | `memories/synthesizedKnowledge/queries/*.md` | Saved KQL / query templates |

- **Expected state:** Files are visible and readable in the portal.
- **Troubleshooting:** If the knowledge directory is empty, the agent has not yet synthesized knowledge from investigations. This is expected for a fresh sandbox.

### 3.2 Understand the Knowledge Types

| Knowledge Type | Source | Editable? |
|---------------|--------|-----------|
| `#remember` user memories | User-initiated | Yes (user can add/remove) |
| Synthesized knowledge | Auto-generated from investigations | Read-only at v1 |
| Knowledge graph | Entity-relation model from investigations | Read-only |
| Kusto schema enrichment | Auto-discovered database schemas | Read-only |

> Reference: [Memory & Knowledge](https://sre.azure.com/docs/concepts/memory#proactive-knowledge-persistence)

> **🔖 Checkpoint CP3** — Knowledge persistence structure understood.

---

## Part 4 — Drift Control (15 min)

### 4.1 Author the Drift-Detection Query

- **Action:** In App Insights (from M10), author a new KQL query:

  ```kql
  AzureActivity
  | where ResourceProvider == "Microsoft.AzureSREAgent"
  | where OperationNameValue has "write" or OperationNameValue has "delete"
  | where TimeGenerated > ago(7d)
  | project TimeGenerated, Caller, OperationNameValue,
            ResourceGroup, _ResourceId, Properties
  | order by TimeGenerated desc
  ```

- **Expected state:** Shows any out-of-band changes to the agent resource (portal clicks instead of PR merges).
- **Troubleshooting:** If `AzureActivity` table is not available, verify the Log Analytics workspace has Azure Activity Log diagnostic settings enabled.

### 4.2 Save as Sixth Query

- **Action:** Save this query as `agent-config-drift` in the M10 workbook.
- **Expected state:** Six queries total in the workbook (five from M10 + this drift query).
- **Troubleshooting:** If the workbook is not editable, verify Contributor access.

> **🔖 Checkpoint CP4** — Drift-detection query saved.

---

## Part 5 — Land the PR (10 min)

### 5.1 Commit All Artifacts

- **Action:** In the workshop repo, commit:
  1. IaC template (Bicep or Terraform)
  2. Custom agent YAML files
  3. Hook configurations
  4. CI pipeline step
  5. Drift-detection query

- **Action:** Open a PR with title: `[M12] Agent-as-code: <attendee-name>`.
- **Expected state:** PR opened with all artifacts. CI step validates the deployment.
- **Troubleshooting:** If CI fails, check the pipeline logs for authentication or template errors.

> **🔖 Checkpoint CP5** — PR landed. All M12 artifacts committed.

---

## Next Module

Proceed to [M13 — Capstone](../../) (trainer-led).
