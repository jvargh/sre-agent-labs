---
module: M3
level: 300
duration_minutes: 90
track: all
dependencies:
  - M1
  - M2
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# M3 — Response Plans: Severity Routing, Custom-Agent Dispatch, Deep-Investigation Mode 2

> **Format:** Lab (90 min).
> **Outcome:** Two non-overlapping response plans pointing at two different custom agents, one with deep investigation auto-enabled.
> **Docs:** [Incident Response Plans](https://sre.azure.com/docs/capabilities/incident-response-plans) · [Setup Response Plan](https://sre.azure.com/docs/tutorials/agent-config/setup-response-plan) · [Deep Investigation Mode 2](https://sre.azure.com/docs/tutorials/advanced/deep-investigation)

---

## Step 1 — Build Two Custom Agents (≈ 20 min)

### 1a. Create `low-sev-triager`

1. Navigate to **Builder → Agent Canvas → Create → Custom Agent**.
2. Name: `low-sev-triager`.
3. Autonomy: **Review**.
4. Tools: `RunAzCliReadCommands`, Log Analytics read-only.
5. Click **Save**.

> **Expected state:** `low-sev-triager` appears in the Agent Canvas as a node.
> **Troubleshooting:** If the custom agent fails to save, verify you have SRE Agent Admin permissions on the resource.

### 1b. Create `p1-investigator`

1. Create another custom agent: `p1-investigator`.
2. Autonomy: **Autonomous**.
3. Tools: `RunAzCliReadCommands`, Log Analytics read-only.
   - *Note:* We will attach the Kusto tool (M5) and Python tool (M8) in later modules. Leave hook placeholders for M9.
4. Click **Save**.

> **Expected state:** `p1-investigator` appears in the Agent Canvas.
> **Troubleshooting:** If Autonomous mode is greyed out, confirm your agent resource has Privileged permissions set (M1 matrix).

---

## ⏱ Checkpoint — 15 min

- [ ] Both `low-sev-triager` and `p1-investigator` exist in Agent Canvas.
- [ ] `low-sev-triager` is set to Review; `p1-investigator` is set to Autonomous.

---

## Step 2 — Create Response Plan A: Low-Severity (≈ 15 min)

### 2a. Pre-validate with [TEST] Filter

> ⚠️ **Important:** Always validate with `Title contains: [TEST]` first to avoid affecting real incident routing.

1. Navigate to **Builder → Incident Response Plans → Create**.
2. Filter criteria:
   - Priority: `P3, P4` (or Sev 3/4 depending on your platform).
   - Impacted service: `<sample-app>`.
   - **Title contains:** `[TEST]`.
3. Click **Preview matching incidents** — confirm only your test incidents match.

> **Expected state:** Preview shows only `[TEST]`-prefixed incidents at P3/P4.
> **Troubleshooting:** If no incidents match, fire a `[TEST] P3` synthetic incident first (see M2).

### 2b. Configure the Plan

1. Handler: `low-sev-triager`.
2. Run Mode: **Review**.
3. Deep investigation: **Off**.
4. Save the plan.

> **Expected state:** Response Plan A appears in the unified grid view.
> **Troubleshooting:** If the plan doesn't save, check for overlapping filters with any surviving quickstart plan (should have been deleted in M2).

---

## ⏱ Checkpoint — 30 min

- [ ] Response Plan A saved with P3/P4 filter → `low-sev-triager`, Review mode, deep investigation off.
- [ ] `[TEST]` pre-validation flow completed successfully.

---

## Step 3 — Create Response Plan B: P1/P2 (≈ 15 min)

1. Create a second response plan.
2. Filter criteria:
   - Priority: `P1, P2`.
   - Impacted service: `<sample-app>`.
   - **Title contains:** `[TEST]` (for now — remove after validation).
3. Handler: `p1-investigator`.
4. Run Mode: **Autonomous**.
   - ⚠️ Click through the **Autonomous-mode acknowledgement dialog**. Read it aloud — attendees must understand the liability terms.
5. Deep investigation: **ON** (Mode 2 — auto-trigger, uses agent UAMI, no OBO prompt).
6. Save the plan.

> **Expected state:** Response Plan B appears in the unified grid view alongside Plan A.
> **Troubleshooting:** If Mode 2 toggle is not available, confirm the agent resource supports deep investigation. See [Deep Investigation](https://sre.azure.com/docs/capabilities/deep-investigation).

---

## ⏱ Checkpoint — 45 min

- [ ] Response Plan B saved with P1/P2 filter → `p1-investigator`, Autonomous, Deep Investigation Mode 2 ON.
- [ ] Plans A and B have **non-overlapping** severity filters.

---

## Step 4 — Fire Test Incidents (≈ 20 min)

### 4a. Fire Incidents at Each Severity

1. Using your incident platform's CLI/API, create:
   - `[TEST] P3 high latency` incident.
   - `[TEST] P1 db corruption` incident.
2. Watch the **Agent Canvas** — the trigger node should light up.

> **Expected state:** Each incident routes to the correct custom agent.
> **Troubleshooting:** If incidents don't route, verify the response plan filters match the incident severity and service.

### 4b. Verify P3 Behavior

1. Confirm `low-sev-triager` receives the P3 handoff.
2. In Review mode, the agent proposes a mitigation but waits for approval.

> **Expected state:** Investigation thread opens; agent proposes action, awaits approval.

### 4c. Verify P1 Behavior

1. Confirm `p1-investigator` receives the P1 handoff.
2. Deep Investigation Mode 2 fires automatically — no authorization prompts.
3. Verify the investigation tree: **research → hypotheses → validation → conclusion** (4 phases).

> **Expected state:** Full autonomous investigation without human prompts; 4-phase tree visible.
> **Troubleshooting:** If Mode 2 prompts for OBO, you may have Mode 1 enabled instead. Toggle to Mode 2 in the response plan.

---

## ⏱ Checkpoint — 60 min

- [ ] P3 incident routed to `low-sev-triager` (Review mode).
- [ ] P1 incident routed to `p1-investigator` (Autonomous, Mode 2 investigation tree visible).

---

## Step 5 — Operations (≈ 15 min)

### 5a. Turn Off / Turn On Lifecycle

1. Select Response Plan B → **Turn off**.
2. Fire another P1 test incident — confirm it is **not** processed.
3. **Turn on** the plan — confirm the next incident routes correctly.

> **Expected state:** Turned-off plan does not process incidents; turned-on plan resumes.
> **Troubleshooting:** If the plan processes incidents while turned off, check for a second overlapping plan.

### 5b. Unified Grid View

1. Navigate to **Agent Canvas → Table View → Incident Response Plans**.
2. Confirm both plans appear with correct severity ranges, handlers, and modes.

> **Expected state:** Grid shows Plan A (P3/P4, Review) and Plan B (P1/P2, Autonomous).

---

## Failure Modes Discussion (≈ 15 min)

> Trainer-led discussion — no lab steps.

### Overlapping Plans

Two plans with overlapping severity filters → incident processed twice. The unified grid view surfaces this with a warning indicator. **Always verify non-overlapping filters before saving.**

### Missing PostToolUse Hook

A Privileged/Autonomous P1 plan **without** a PostToolUse hook means the agent can execute dangerous commands unchecked. This is the core M9 conversation — hooks are the enforcement boundary.

> **Forecast:** In M9, you will add Stop + PostToolUse hooks that make Response Plan B production-safe.

---

## ⏱ Final Checkpoint — 90 min

- [ ] Two non-overlapping response plans operational.
- [ ] P3 → `low-sev-triager` (Review, deep investigation off).
- [ ] P1/P2 → `p1-investigator` (Autonomous, Deep Investigation Mode 2 ON).
- [ ] Turn off / turn on lifecycle tested.
- [ ] Unified grid view confirms correct configuration.
- [ ] Attendee understands the missing-hook risk (to be addressed in M9).

---

## References

- [Incident Response Plans](https://sre.azure.com/docs/capabilities/incident-response-plans)
- [Setup Response Plan Tutorial](https://sre.azure.com/docs/tutorials/agent-config/setup-response-plan)
- [Deep Investigation (Mode 2)](https://sre.azure.com/docs/tutorials/advanced/deep-investigation)
- For L200 refresher on response plans, see [SREA-Level200.md §Response Plans](../../../SREA-Level200.md#response-plans)
