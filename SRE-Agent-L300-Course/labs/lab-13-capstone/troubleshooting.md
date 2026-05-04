---
lab: 13
level: 400
type: troubleshooting
---

# Lab 13 Capstone — Troubleshooting Guide

Common issues encountered during the capstone drill and how to resolve them.

---

## Response plan not firing

**Symptom:** Synthetic incident is created but no agent picks it up.

**Resolution:**
1. Check for filter overlap between response plans — overlapping severity filters can cause conflicts.
2. Verify the `[TEST]` prefix in the incident title matches the filter pattern configured in your response plans.
3. Confirm the response plan is in **Active** state (not Draft or Disabled).
4. Check the incident platform connector status — it must show "Connected."

---

## Wrong agent receives handoff

**Symptom:** A P1 incident routes to `low-sev-triager` instead of `incident_triager`, or vice versa.

**Resolution:**
1. Check the severity filters on Response Plan A (low-sev) vs. Response Plan B (high-sev). They must not overlap.
2. Verify that Plan A targets P3/P4 only, and Plan B targets P1/P2.
3. Re-check the handoff chain configuration — ensure the correct custom agent names are referenced.

---

## Deep investigation not auto-triggering

**Symptom:** P1 incident completes without deep investigation (Mode 2).

**Resolution:**
1. Verify Mode 2 toggle is **ON** in Response Plan B (the plan handling P1/P2 incidents).
2. Confirm the incident severity is correctly mapped — the platform must report it as P1 for auto-trigger.
3. Check that the agent has sufficient tool permissions to initiate deep investigation.

---

## Hook not blocking dangerous command

**Symptom:** `az group delete` executes instead of being blocked by the PostToolUse hook.

**Resolution:**
1. Check the matcher regex in the PostToolUse hook — it must match the exact command pattern (e.g., `az group delete`).
2. Verify the hook is attached at the **agent level**, not just at the response-plan level.
3. Confirm the hook action is set to **Block** (not Audit-only).
4. Test the regex independently against the expected command string.

---

## Notifier not sending Teams or email

**Symptom:** P1/P2 incidents complete but no Teams message or email is sent.

**Resolution:**
1. Verify that `SendOutlookEmail` and `SendTeamsMessage` tools are attached to the notifier agent.
2. Confirm the notifier agent is in **Autonomous** mode (it must execute without human approval).
3. Check that the handoff chain actually reaches the notifier (verify in audit trail).
4. Ensure the notifier has valid credentials/permissions for the email and Teams APIs.

---

## Audit query returns empty results

**Symptom:** KQL workbook queries return no rows after the drill.

**Resolution:**
1. Verify the App Insights connection is correctly configured on the agent resource.
2. Check that the `ThreadId` exists in the customEvents table — run a basic `customEvents | take 10` query first.
3. Allow up to 60 seconds for telemetry ingestion after the incident completes.
4. Confirm the Log Analytics workspace ID matches what the agent is configured to use.

---

## Scoring below 80%

**Symptom:** Attendee does not meet the pass threshold on the scoring rubric.

**Resolution:**
1. Review the scoring rubric (`capstone/scoring-rubric.md`) to identify which machine-checkable items failed.
2. Retry the specific incident that caused the failure — no need to re-run the entire drill.
3. Common causes: hook misconfiguration (most frequent), missing notifier tools, response plan filter overlap.
4. If a single incident fails repeatedly, check the troubleshooting entry for that specific symptom above.
