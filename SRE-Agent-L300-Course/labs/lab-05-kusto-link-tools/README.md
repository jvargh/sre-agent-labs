# Lab 5 — Custom Tools I: Kusto + Link Tools

> **Format:** Lab (60 min).
> **Outcome:** One reusable, parameterized Kusto tool callable by the `p1-investigator` from Lab 3.
> **Pre-requisite:** Pre-provisioned ADX cluster with ≥ 10k rows (see D9).
> **Docs:** [Kusto Tools](https://sre.azure.com/docs/capabilities/kusto-tools) · [Create Kusto Tool](https://sre.azure.com/docs/tutorials/tools/create-kusto-tool) · [Setup Kusto Connector](https://sre.azure.com/docs/tutorials/connectors/setup-kusto-connector)

---

## Step 1 — ADX Connector + UAMI Grant (≈ 15 min)

### 1a. Add the Azure Data Explorer Connector

1. Navigate to **Builder → Connectors → Create → Azure Data Explorer**.
2. Enter your ADX **cluster URL** (including database name).
3. Click **Connect**.

> **Expected state:** Connector status shows `Connected`.
> **Troubleshooting:** If connection fails, verify the cluster URL format: `https://<cluster>.<region>.kusto.windows.net/<database>`.

### 1b. Grant UAMI AllDatabasesViewer

1. Open a Kusto query window (Azure Portal → ADX cluster → Query).
2. Run:
   ```kql
   .add cluster AllDatabasesViewer ('aadapp=<ManagedIdentityClientId>;<TenantId>')
   ```
   Replace `<ManagedIdentityClientId>` and `<TenantId>` with the agent's UAMI values.
3. Verify:
   ```kql
   .show cluster principals
   ```

> **Expected state:** UAMI listed as `AllDatabasesViewer` in cluster principals.
> **Troubleshooting:** If the command fails with `Forbidden`, you need Cluster Admin rights. Contact the ADX cluster owner. The grant is idempotent — re-running is safe.

### 1c. Choose Query Mode

- **Database query** (deterministic) — locked KQL template, parameterized. Use for production.
- **Database indexing** (auto schema for ad-hoc) — agent discovers schema and writes KQL on the fly.

> For this lab, use **Database query** mode.

---

## ⏱ Checkpoint — 15 min

- [ ] ADX connector status: `Connected`.
- [ ] UAMI granted `AllDatabasesViewer`.

---

## Step 2 — Author a Parameterized Kusto Tool (≈ 15 min)

1. Navigate to **Builder → Agent Canvas → Create → Tool → Kusto Tool**.
2. Fill in:
   - **Name:** `GetRecentErrors`
   - **Description:** "Retrieves recent errors from the AppEvents table filtered by time range and search pattern. Use when investigating application errors, exceptions, or failures."
   - **Connector:** Select your ADX connector.
   - **Database:** Select the target database.
   - **Query:**
     ```kql
     AppEvents
     | where Timestamp > ago(##timeRange##)
     | where Message has "##searchPattern##"
     | project Timestamp, Message, ErrorType, StackTrace
     | take 100
     ```
   - **Parameters:** `##timeRange##` (e.g., `24h`), `##searchPattern##` (e.g., `NullPointerException`).
3. Click **Test** with sample values: `timeRange=24h`, `searchPattern=NullPointerException`.
4. Confirm results return (≥ 3 rows from the seed data).
5. **Save** the tool.

> **Expected state:** Tool saved; test returns rows from the seeded ADX data.
> **Troubleshooting:** If test returns 0 rows, verify the table name (`AppEvents`) and column names match the D9 seed schema. Check that data was loaded within the last 24h.

---

## ⏱ Checkpoint — 30 min

- [ ] Kusto tool `GetRecentErrors` created with `##timeRange##` and `##searchPattern##` placeholders.
- [ ] Test returned non-empty results.

---

## Step 3 — Attach to `p1-investigator` + Test (≈ 15 min)

### 3a. Attach

1. Open **Agent Canvas → `p1-investigator` → Edit → Tools**.
2. Add `GetRecentErrors`.
3. Save.

> **Expected state:** `GetRecentErrors` appears in `p1-investigator`'s tool list.

### 3b. Natural Language Invocation

1. Open a chat with `p1-investigator`.
2. Prompt: **"Show me errors from the last 24 hours about NullPointerException."**
3. Observe: the agent should call `GetRecentErrors` with `timeRange=24h, searchPattern=NullPointerException` automatically.

> **Expected state:** Agent substitutes parameters and returns Kusto results.
> **Troubleshooting:** If the agent doesn't call the tool, check the tool's `description` — it must describe the tool's purpose clearly enough for the model to match.

---

## ⏱ Checkpoint — 45 min

- [ ] `GetRecentErrors` attached to `p1-investigator`.
- [ ] Natural language prompt triggers automatic parameter substitution.

---

## Step 4 — Link Tool (≈ 15 min)

### 4a. Create the Link Tool

1. Navigate to **Builder → Agent Canvas → Create → Tool → Link Tool**.
2. Fill in:
   - **Name:** `AzurePortalJump`
   - **Description:** "Generates a direct Azure Portal link for a given resource."
   - **URL template:** `https://portal.azure.com/#@<tenant>/resource/##resourceId##/overview`
   - **Parameters:** `##resourceId##` — the full ARM resource ID.
3. Save.

> **Expected state:** Link tool saved and functional.

### 4b. Demo

1. In a chat with `p1-investigator`, ask: "Give me a portal link for the sample app service."
2. Confirm the agent returns a one-click portal jump URL.

> **Expected state:** Agent generates a clickable portal link.
> **Troubleshooting:** If the link doesn't resolve, verify the `<tenant>` placeholder matches your tenant ID.

---

## Discussion (Remaining Time)

### Kusto Tool vs Ad-hoc

- **Kusto tool:** Locked-down, parameterized query. Use when the query pattern is known and should be reused.
- **Ad-hoc (Database indexing mode):** Agent discovers schema and writes KQL. Use for exploratory investigation — more flexible, less predictable.

### YAML `mode` Values

| Mode | Meaning |
|------|---------|
| `Query` | Direct KQL query template (what we built today) |
| `Function` | Calls a stored ADX function |
| `Script` | Executes an external `.kql` file |

---

## ⏱ Final Checkpoint — 60 min

- [ ] One parameterized Kusto tool (`GetRecentErrors`) callable by `p1-investigator`.
- [ ] Natural language invocation tested with NullPointerException prompt.
- [ ] Link tool created and demoed.
- [ ] Can explain Kusto tool vs ad-hoc trade-offs.
- [ ] Ready for Lab 6 (custom agents in YAML referencing this tool).

---

## References

- [Kusto Tools](https://sre.azure.com/docs/capabilities/kusto-tools)
- [Create Kusto Tool Tutorial](https://sre.azure.com/docs/tutorials/tools/create-kusto-tool)
- [Setup Kusto Connector](https://sre.azure.com/docs/tutorials/connectors/setup-kusto-connector)
- For L200 refresher on connectors, see [SREA-Level200.md §Connectors](../../../SREA-Level200.md#connectors)
