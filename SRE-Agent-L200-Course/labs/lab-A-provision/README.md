# Lab A — Provision Your First Agent

> **L200 — 45 min hands-on lab**
> Maps to docs: [Create and Set Up](https://sre.azure.com/docs/get-started/create-and-setup)

---

## 1. Outcome

A `contoso-sre-agent` (or attendee-named) agent in `Running` state with App Insights + Log Analytics + UAMI.

---

## 2. Prerequisites

| # | Requirement | Details |
|---|------------|---------|
| 1 | Azure subscription | Contributor or higher on the workshop subscription. **Owner** or **User Access Administrator** required for role assignments. |
| 2 | Network access | `*.azuresre.ai` reachable from your browser (check corporate proxy / firewall allowlist). |
| 3 | Region quota | Subscription must allow resource creation in **Sweden Central**, **East US 2**, or **Australia East**. |
| 4 | Entra ID account | A **work or school** account — personal MSAs cannot authorize OBO. |
| 5 | Provider registration | `Microsoft.App` provider registered. Run beforehand: `az provider register --namespace "Microsoft.App"` |
| 6 | Lecture sections complete | You should understand SRE Agent concepts, user roles, permissions, and run modes from the lecture sessions. |

> **Pre-read (15 min):** [Overview — What is SRE Agent?](https://sre.azure.com/docs/overview) and [Get Started — Your Journey](https://sre.azure.com/docs/get-started).

---

## 3. Time Budget

| Phase | Duration |
|-------|----------|
| Portal sign-in & orientation | 5 min |
| Create agent wizard | 15 min |
| Deployment wait + verification | 10 min |
| Troubleshooting & discussion | 10 min |
| Checkpoint confirmation | 5 min |
| **Total** | **45 min** |

---

## 4. Lab Steps

### Step 1 — Sign in to the SRE Agent Portal (5 min)

1. Open your browser and navigate to **[https://sre.azure.com](https://sre.azure.com)**.
2. Sign in with your **work or school Entra ID account**.
3. You should land on the SRE Agent home page.

![Step 1 — SRE Agent portal home page](screenshots/step-1-portal-home.png)

---

### Step 2 — Start the Create Agent Wizard (2 min)

1. Click **Create agent** on the home page.
2. The wizard opens with the flow: **Basics → Review → Deploy**.

![Step 2 — Create agent button](screenshots/step-2-create-agent-button.png)

---

### Step 3 — Fill in the Basics Tab (10 min)

Fill in each field as follows:

| Field | Value |
|-------|-------|
| **Subscription** | Select your workshop subscription |
| **Resource group** | `rg-sre-agent-<your-alias>` (create new if it doesn't exist) |
| **Agent name** | `contoso-sre-agent` (or choose your own name) |
| **Region** | Pick one: **Sweden Central**, **East US 2**, or **Australia East** |
| **Model provider** | **Anthropic** (default, works in most regions) or **Azure OpenAI** (required for Sweden Central EUDB compliance) |
| **Application Insights** | Select **Create new** |

> ⚠️ **Naming convention:** Use `rg-sre-agent-<your-alias>` for your resource group (e.g., `rg-sre-agent-jdoe`). This keeps resources isolated per attendee.

![Step 3 — Basics tab filled in](screenshots/step-3-basics-tab.png)

---

### Step 4 — Review and Create (2–5 min)

1. Click **Review** at the bottom of the Basics tab.
2. Review your selections on the Review tab.
3. Click **Create**.
4. Wait for the deployment to complete — this typically takes **2–5 minutes**.

![Step 4 — Review tab before deployment](screenshots/step-4-review-tab.png)

![Step 4 — Deployment in progress](screenshots/step-4-deployment-progress.png)

---

### Step 5 — Verify the Deployment (5 min)

Once the deployment completes, verify that **all five resources** were created:

| Resource | What to Check |
|----------|---------------|
| **User-Assigned Managed Identity (UAMI)** | Listed in the deployment outputs; visible in the resource group. |
| **Log Analytics Workspace** | Created in the same resource group. |
| **Application Insights** | Connected to the Log Analytics workspace. |
| **Role Assignments** | UAMI has been granted the necessary RBAC roles automatically. |
| **Azure SRE Agent Resource** | Agent resource shows status `Running`. |

Navigate to the Azure portal → your resource group (`rg-sre-agent-<your-alias>`) and confirm each resource appears.

![Step 5 — Resource group showing all deployed resources](screenshots/step-5-resource-group-view.png)

---

## 5. Checkpoint

> **✅ Checkpoint:** Click **Set up your agent** on the deployment success page. You should land on the **"More context. Better investigations."** page. If you see this page, your agent is provisioned and ready for Lab B.

![Checkpoint — More context better investigations page](screenshots/checkpoint-setup-page.png)

---

## 6. Expected Output

After deployment, your resource group should contain:

```
rg-sre-agent-<your-alias>/
  ├── contoso-sre-agent            (SRE Agent — Running)
  ├── contoso-sre-agent-uami       (User-Assigned Managed Identity)
  ├── contoso-sre-agent-law        (Log Analytics Workspace)
  ├── contoso-sre-agent-ai         (Application Insights)
  └── [Role assignments]           (auto-assigned to UAMI)
```

The agent status should read **Running** in the portal. The "Set up your agent" link should take you to the onboarding page where you will connect code, resources, and knowledge in Lab B.

---

## 7. Troubleshooting Table

| Symptom | Cause | Fix |
|---------|-------|-----|
| `DeploymentNotFound` error during creation | `Microsoft.App` resource provider is not registered on your subscription. | Run `az provider register --namespace "Microsoft.App"` and wait 1–2 minutes for propagation, then retry. |
| **Create** button is greyed out | Insufficient permissions on the subscription, or an unsupported region is selected. | Verify you have **Contributor** (or **Owner**) role. Switch region to Sweden Central, East US 2, or Australia East. |
| Application Insights creation fails | Quota or naming conflict on the auto-generated App Insights resource. | Choose **Use existing** and select a pre-existing App Insights instance in your subscription. |
| Deployment takes longer than 10 minutes | Transient Azure capacity issue in the selected region. | Wait up to 15 min. If still pending, cancel and retry in a different supported region. |
| Agent shows `Failed` state after deployment | UAMI role assignment propagation delay or networking restriction. | Check the Activity Log in the resource group for detailed errors. Ask your instructor for help. |
| "You do not have access" on sre.azure.com | Entra ID account is a personal MSA or guest account. | Use a **work or school** account in the workshop tenant. |

---

## 8. Cleanup Steps

**No cleanup is needed after Lab A.** The agent and all associated resources (UAMI, Log Analytics, App Insights) persist and are required for Lab B and subsequent labs.

> ⚡ **Do not delete your resource group.** If you accidentally delete it, you will need to re-run Lab A from the beginning before continuing.

---

## References

- [Overview — What is SRE Agent?](https://sre.azure.com/docs/overview)
- [Get Started — Your Journey](https://sre.azure.com/docs/get-started)
- [Create and Set Up Your Agent](https://sre.azure.com/docs/get-started/create-and-setup)
- [User Roles](https://sre.azure.com/docs/concepts/user-roles)
- [Permissions](https://sre.azure.com/docs/concepts/permissions)
- [Run Modes](https://sre.azure.com/docs/concepts/run-modes)
