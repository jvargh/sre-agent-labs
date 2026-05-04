# ✈️ SRE Agent L200 Workshop — Pre-Flight Checklist

> **Send to attendees 1 week before the workshop.**
> Complete all 8 items below so you're ready to go on Day 1.

---

## Checklist

- [ ] **1. Azure Subscription Access**
  Contributor role on the workshop subscription.
  For full lab role assignments, **Owner** or **User Access Administrator** is required.

- [ ] **2. Network Access**
  Confirm `*.azuresre.ai` is reachable from your browser.
  If you're behind a corporate proxy or firewall, add it to your allowlist now.

- [ ] **3. Region**
  Your subscription must allow resource creation in at least one of:
  **Sweden Central** · **East US 2** · **Australia East**

- [ ] **4. Identity**
  You need a **work or school (Entra ID)** account.
  ⚠️ Personal Microsoft accounts (MSAs) cannot authorize OBO.

- [ ] **5. GitHub or Azure DevOps**
  Read access to one repo containing a small service (used in Lab B).

- [ ] **6. Microsoft 365**
  An **Outlook + Teams** account — needed for the notifications lab.

- [ ] **7. Provider Registration**
  Run this command in Azure CLI before the workshop:
  ```bash
  az provider register --namespace "Microsoft.App"
  ```

- [ ] **8. Sample Workload** *(optional but recommended)*
  Deploy a Container App from the samples repo so the agent has something real to investigate:
  [`github.com/microsoft/sre-agent/tree/main/samples`](https://github.com/microsoft/sre-agent/tree/main/samples)

---

## 📖 Pre-Read (15 min)

Complete these two short pages before the workshop:

1. [Overview — What is SRE Agent?](https://sre.azure.com/docs/overview)
2. [Get Started — Your Journey](https://sre.azure.com/docs/get-started)

---

## ✅ Verify Your Setup

Run these quick checks to confirm readiness:

```bash
# 1. Confirm you're logged in to the right subscription
az account show --query "{name:name, id:id, state:state}" -o table

# 2. Verify Contributor (or higher) role
az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) \
  --query "[?roleDefinitionName=='Contributor' || roleDefinitionName=='Owner'].{Role:roleDefinitionName, Scope:scope}" -o table

# 3. Check Microsoft.App provider is registered
az provider show --namespace Microsoft.App --query "registrationState" -o tsv
# Expected output: Registered

# 4. Confirm region availability
az account list-locations --query "[?name=='swedencentral' || name=='eastus2' || name=='australiaeast'].{Name:displayName, Region:name}" -o table

# 5. Test network access (from your browser or terminal)
curl -s -o /dev/null -w "%{http_code}" https://sre.azure.com
# Expected output: 200
```

---

*Questions? Post in the workshop support channel or email your facilitator.*
