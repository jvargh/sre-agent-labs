---
title: SRE Agent L300/400 Workshop — Minute-by-Minute Facilitator Script
source_md_sha: placeholder
srea_version: srea-l300-v1.0.0
---

# Timing Script — Full 2-Day Workshop

**Target audience:** Trainers delivering the Azure SRE Agent L300/400 Advanced Workshop.  
**Purpose:** Minute-by-minute facilitator guide with checkpoints, track synchronization pulse points, and contingency timings.

---

## Day 1 — Modules M1–M7 (8.0 hours)

### 09:00–09:45 — M1: Promotion Playbook (45 min)

**Setup (T-10 min):** Confirm all attendees logged into Builder. Display decision matrix.

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 9:00–9:10 | Lecture: L200 vs L300 stance shift (10 min). Read aloud: "You are no longer in Reader/Review by default..." | Attendees see the matrix slide. |
| 9:10–9:25 | Guided walkthrough of each row (15 min): permissions, run modes, deep investigation, approver pools. | Ask: "When do you flip to Privileged?" → expect: "Azure write OR P1 response plan." |
| 9:25–9:40 | Paired exercise (15 min): attendees fill in their own service decision matrix with names of approvers + triggers. Trainer spot-checks 3 examples live. | 3 attendees show filled matrix. Approve or challenge. |
| 9:40–9:45 | Wrap: M1 rule recap. "Never promote to Autonomous on SendOutlookEmail + az write without M9 hooks in place." | Poll: "Who has a use case for Autonomous + write?" → good sign if 30 % yes. |

**Troubleshooting:**
- Attendee unsure what "Autonomous" means in their org? → Reference L200 Run Modes docs, don't re-teach.
- Time overrun? → Shorten exercise to 2 examples instead of 3.

**SYNC PULSE:** M1 ends at 9:45. All three tracks (PagerDuty, ServiceNow, Azure Monitor) start M2 at same time.

---

### 09:45–10:45 — M2: Incident Platform Connection (60 min)

**Setup:** Pre-stage three breakout rooms or separate labs for each track.

| Time | Activity | Track A (PagerDuty) | Track B (ServiceNow) | Track C (Azure Monitor) |
|------|----------|-------------------|----------------------|-------------------------|
| 9:45–10:00 | Introduction (all together, 15 min): "Connect to your chosen platform. Same learning outcome. Verify in Builder → Incidents page." | Demo: PagerDuty console layout | Demo: ServiceNow layout | Demo: Azure Portal alerts |
| 10:00–10:30 | Lab hands-on (30 min) | Generate API token, Builder → Connectors → PagerDuty → connect, test with CLI | Service-account setup, connector auth, test incident pull | Pre-existing alert on sample workload, connector setup |
| 10:30–10:40 | Convergence checkpoint (10 min): Each track lead confirms Incidents page shows historical incidents | Verify "Connected" heartbeat, delete quickstart plan | Verify "Connected" heartbeat, delete quickstart plan | Verify "Connected" heartbeat, delete quickstart plan |
| 10:40–10:45 | Wrap: Why delete quickstart? "L300 bug: double-route. Now you decide the routing logic in M3." (5 min) | All three | All three | All three |

**Contingency:**
- PagerDuty trial expired? → Swap to trainer's trial account; attendee proceeds with read-only access (discuss at wrap).
- ServiceNow PDI slow? → Pre-stage a snapshot; catch up later.
- Azure Monitor alert hasn't fired yet? → Manually trigger via portal; proceed.

**Troubleshooting:** Connectivity check before 9:45. Known timeouts on connectors? Restart Builder once.

**SYNC PULSE:** M2 ends at 10:45. All tracks reconverge for break.

---

### 10:45–11:00 — Break (15 min)

**Trainer activity:** Walk the room. Spot-check: Is every attendee's Incidents page showing historical data? Flag any "Disconnected" status for post-break triage.

---

### 11:00–12:30 — M3: Response Plans + Deep Investigation Mode 2 (90 min)

**Setup:** Return to unified cohort. Three custom agents (low-sev-triager, p1-investigator) must exist in Builder before lab starts.

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 11:00–11:10 | Lecture (10 min): Response plan concept. Show diagram: incident arrives → filter → custom agent dispatch → handoff chain. Read aloud the failure mode: "Two overlapping plans = double-route. The unified grid surfaces this." | Ask: "Who has seen a double-route in production?" → use answer to ground the example. |
| 11:10–11:30 | Step 1–2: Custom agents (20 min). Attendees open Agent Canvas, inspect or create low-sev-triager (Review mode) and p1-investigator (Autonomous + Deep Investigation ON). Pause at the Autonomous-mode dialog: "Read this aloud. Understand the liability." | Every attendee has both agents created. Trainer checks canvas view on 2 machines. |
| 11:30–11:50 | Step 3–4: Response plans A + B (20 min). Test incident routes correctly. Show the unified grid table view afterward. | Test incident arrives; low-sev-triager threads open in canvas. Data flows. No manual routing. |
| 11:50–12:20 | Step 5: Maintenance practice (30 min). Click Through → Turn off response plan B → verify no new incidents route. Turn on → confirm resumed routing. | Attendees toggle plans live. |
| 12:20–12:30 | Wrap: Failure mode talk-track (10 min). Show unified grid; point out where overlapping plans would be visible. Segue to M4. | All 13 attendees show green checkmarks on at least one response plan. |

**Contingency:**
- A custom agent can't be created? → Use trainer's pre-baked agent; catch up in async later.
- Test incident not routing? → Check connector status (M2 checkpoint); reset Builder session.
- Time overrun? → Cut the "Turn off/on" lifecycle to one cycle instead of two; save the rest for post-workshop Q&A.

**Troubleshooting:** Attendees often miss the Autonomous-mode dialog. Pause for 30 s and have them read it aloud.

**SYNC PULSE:** M3 ends at 12:30. All tracks break for lunch.

---

### 12:30–13:00 — Lunch (30 min)

**Trainer activity:** Debrief with track leads. Any hidden issues? Update the operations runbook contingencies.

---

### 13:00–14:15 — M4: Skills Authoring (75 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 13:00–13:10 | Concepts (10 min): Skill = SKILL.md + tools + trigger phrases. Show the 5-skill max constraint. "Each skill auto-unloads the oldest. Why? Context churn." | Ask: "Why does description matter?" → expect: "Discovery surface." |
| 13:10–13:35 | Lab step 1–3 (25 min): Create skill in Builder. Author SKILL.md with troubleshooting steps. Attach RunAzCliReadCommands (read-only). | Every attendee has one skill with a description that includes trigger phrases. |
| 13:35–14:00 | Step 4: Test in Agent Playground (25 min). Split-screen edit on left, chat on right. Ask the agent a phrase from the skill description; watch it load. Iterate if needed. | Attendee's skill loads in a chat. Tool call card shows it. |
| 14:00–14:15 | Stretch + wrap (15 min): Discuss llowed_skills syntax for custom agents (M6 preview). Show VS Code extension loop. Anti-patterns: description without trigger phrases → never loads. | Trainer demos the VS Code extension (no editing required; just demo). |

**Troubleshooting:** First-time SKILL.md authors often write generic descriptions. Trainer: "What phrase would *you* type to get this skill?" → iterate the description.

---

### 14:15–14:30 — Break (15 min)

---

### 14:30–15:30 — M5: Custom Tools I — Kusto + Link (60 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 14:30–14:40 | Setup (10 min): Connector hygiene. Attendees add Azure Data Explorer connector (cluster URL incl. database). Trainer checks that AllDatabasesViewer role grant is in place (Kusto CLI .add command run beforehand). | All attendees can see the connector "Connected" in Builder. |
| 14:40–14:55 | Step 2 (15 min): Author Kusto tool. Builder → Agent Canvas → Create Tool → Kusto tool. Demo: bounded time window ##timeRange##, bounded result 	ake 100, explicit project. Attach to p1-investigator from M3. | Each attendee has one Kusto tool with at least 2 parameters. |
| 14:55–15:15 | Step 3 (20 min): Test in chat. Attach tool to p1-investigator. Ask naturally: "Show me errors from the last 24 hours about NullPointerException." Watch agent substitute parameters. | Attendee chat shows tool call with parameters automatically filled. |
| 15:15–15:25 | Step 4 (10 min): Link tool. URL template with parameters. Quick demo: agent now returns one-click portal jump. | One attendee shows Link tool working. |
| 15:25–15:30 | Wrap (5 min): Kusto tool vs ad-hoc query trade-off. "Lock down queries for repeatability; use ad-hoc for exploratory." | No questions = success. |

**Contingency:**
- ADX cluster unreachable? → Pre-stage data in a shared cluster; attendee connects to trainer's ADX.
- Kusto tool parameter substitution not working? → Restart Builder. Check YAML syntax (## delimiters).

---

### 15:30–17:00 — M6: Custom Agents in YAML (90 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 15:30–15:40 | Lecture (10 min): Introduce the 3-agent handoff chain: incident-triager → db-expert OR pi-expert → 
otifier. Diagram on screen showing context flow (shared, not copied). | Ask: "Why is context shared?" → expect: "Every specialist sees the full thread." |
| 15:40–16:00 | Step 1 (20 min): YAML conversion. Open p1-investigator in canvas, click YAML view, copy and inspect schema: 
ame, system_prompt, handoff_description, 	ools, connectors, llowed_skills. | Attendees have YAML view open. No need to edit yet; just read. |
| 16:00–16:35 | Step 2 (35 min): Attendees author three YAML stubs (can paste templates). Show examples in chat: incident-triager (classifier), db-expert (Postgres/SQL), pi-expert (HTTP errors). Trigger discussion: allowed_skills, tool scoping, handoff_description phrasing. | Each attendee has 4 YAML files (incident-triager, db-expert, api-expert, notifier). No syntax errors; basic structure present. |
| 16:35–16:50 | Step 3 (15 min): Wire the chain. Update Response Plan B (M3) to dispatch to incident_triager. Canvas view shows handoff edges. | Response Plan B now dispatches to incident_triager; chain visible in canvas. |
| 16:50–17:00 | Wrap (10 min): Context sharing recap. Tools per agent budget. Segue to M7 MCP integrations. | All attendees have three specialists + notifier wired. |

**Troubleshooting:** YAML syntax errors (missing colons, indentation). Trainer: "Copy the template exactly, then customize descriptions."

---

### 17:00–18:15 — M7: MCP Integrations II (75 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 17:00–17:10 | Recap (10 min): L200 GitHub MCP intro + now we own multiple servers + capacity management. 80-tool budget per agent, independent budgets. | Ask: "How many tools can the agent use?" → expect: "80 per agent." |
| 17:10–17:30 | Lab step 1–2 (20 min): Add **two** partner connectors (Datadog + Splunk, OR Datadog + GitHub). Watch the capacity bar. | Each attendee has two connectors showing "Connected." |
| 17:30–17:50 | Step 3 (20 min): Stdio MCP server (npx-based). Trainer shares Docker/container details: Node 20, Python 3.12, .NET 9 runtimes. Demonstrates adding server config. | Attendee's stdio MCP server shows in the connector list. Optional: kill/restart process to see 60 s heartbeat flip "Disconnected" → "Connected". |
| 17:50–18:05 | Step 4–5 (15 min): Tool assignment methods. Show portal tool picker + YAML wildcards (datadog-mcp/*). Plugin Marketplace click-through (supply-chain talk). | Attendee assigns tools via both methods. YAML wildcard visible. |
| 18:05–18:15 | Wrap (10 min): Governance recap. 80-tool limit. Stdio servers run in agent container (same blast radius). | All attendees have at least 3 MCP connectors + capacity monitoring visible. |

**Contingency:**
- Stdio server won't start? → Pre-stage a shared server; attendee connects with trainer's config.
- Capacity bar going red? → Demonstrate removing unused tools to stay under 70 %.

**Day 1 ends at 18:15.**

---

## Day 2 — Modules M8–M13 (9.0 hours)

### 09:00–10:30 — M7 Recap + M8: Custom Tools II — Python Tools (90 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 09:00–09:10 | Day 2 welcome + M7 recap (10 min). "Yesterday you wired three MCP connectors. Today: Python tools with managed-identity scoping." | Attendees logged in, Day 2 slide visible. |
| 09:10–09:30 | Concepts (20 min): Three authoring paths — AI-generated, BYO existing function, HTTP wrapper. Demo each path on the slide. Execution environment: 5–900 s timeout, 700+ packages, /mnt/data for temp files, no persistent state. | Ask: "When do you use HTTP wrapper?" → expect: "For internal APIs or Azure Functions." |
| 09:30–09:50 | Tool 1: AI-generated (20 min). Dialog: "Calculate SLA compliance from uptime/downtime; return whether it meets 99.9%." Generate → test in playground → create. | Attendee has one AI-generated Python tool saved. |
| 09:50–10:10 | Tool 2: BYO function (20 min). Attendee pastes a real internal function that returns dict. Test in playground. | Attendee has one BYO Python tool saved. |
| 10:10–10:25 | Tool 3: HTTP wrapper (15 min). URL template for internal API/Azure Function. Enable managed-identity scope (ARM or Key Vault). Demonstrate that requests call works without secrets. | Attendee has one HTTP-wrapper Python tool with UAMI scope enabled. |
| 10:25–10:30 | Wrap (5 min): Attach Tool 3 to db-expert (M6). Talk-track: Python tool vs MCP connector decision table. | Tool 3 attached to db-expert. |

**Troubleshooting:** AI generation sometimes produces non-JSON output. Trainer: "Check the eturn statement. Must be JSON-serializable."

---

### 10:30–10:45 — Break (15 min)

---

### 10:45–12:15 — M9: Agent Hooks (90 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 10:45–11:00 | Concepts (15 min): Two events (Stop, PostToolUse), two levels (agent vs custom-agent), two types (prompt vs command). Hook context via $ARGUMENTS or stdin. Response schema. Demo on slide: Stop hook validation, PostToolUse block dangerous patterns. | Ask: "What's the difference between Stop and PostToolUse?" → expect: "Stop validates completeness; PostToolUse audits/blocks after tool call." |
| 11:00–11:20 | Hook A: Stop hook, prompt type (20 min). Attendees create a simple prompt hook: "Does the response include root cause AND recommended action?" Attach to agent-level hooks. | Every attendee has one Stop hook on the agent level. |
| 11:20–11:50 | Hook B: PostToolUse, command type (30 min). Demonstrate the Python script that blocks dangerous patterns (rm -rf, sudo, chmod 777, az group delete). Attendees copy the template, test it locally, create hook. | Every attendee has one command-type PostToolUse hook blocking dangerous patterns. |
| 11:50–12:05 | Hook C: PostToolUse, audit (15 min). Attendees author a Python hook that logs every tool call to stderr + injects audit context. Discuss the dditionalContext pattern. | Every attendee has one audit hook logging all tool calls. |
| 12:05–12:15 | Wire + wrap (10 min): All three hooks attached at **agent level** (cover every custom agent). Re-fire M3 P1 incident; verify audit messages appear. Test synthetic m -rf / block. | Audit messages visible in the incident thread. Dangerous command blocked. |

**Contingency:**
- Python script syntax error? → Restart, copy from docs example verbatim.
- Hook not firing? → Check matcher regex against tool name exactly.

**Limits to call out:** 64 KB script max, 1–300 s timeout, maxRejections 1–25 (default 3 for Stop only), shebangs #!/bin/bash or #!/usr/bin/env python3.

**SYNC PULSE:** M9 ends at 12:15. Core L300 content done. All three tracks on track. Safety culture reinforced: "Before Autonomous, hooks are in place."

---

### 12:15–13:00 — Lunch (45 min)

---

### 13:00–14:15 — M10: Audit, FinOps & Observability (75 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 13:00–13:10 | Setup (10 min): Agent portal → Monitor → Logs → opens App Insights for the agent. Familiarize with customEvents table. | All attendees see App Insights opened. |
| 13:10–13:20 | Event types (10 min): AgentResponse, ModelGeneration, AgentToolExecution, IncidentActivitySnapshot, ApprovalDecision. Show examples of each in the logs. | Trainer points to 3 real event rows; attendees identify event type. |
| 13:20–14:00 | Lab (40 min): Author and save 5 KQL queries. Templates provided: per-thread replay, top tools (30d), token cost by agent, incident outcomes (30d), approval rate. Attendees copy templates, customize, save workbook. | Every attendee has a saved workbook with all 5 queries green (no errors). |
| 14:00–14:10 | FinOps overlay (10 min): Model tier strategy. Hooks use Fast Reasoning; promote to Reasoning only for high-stakes policies. Show token-cost dashboard from the KQL queries. | Trainer shows one attendee's token-cost query result. |
| 14:10–14:15 | Wrap (5 min): Trace correlation. Segue to M11. | Attendees have a saved workbook + understand trace flow. |

**Troubleshooting:** KQL queries return no data. Likely causes: (a) no agent activity yet (fix: generate activity with manual test incident), (b) wrong TimeRange in query (fix: widen to last 7 days).

---

### 14:15–14:30 — Break (15 min)

---

### 14:30–16:00 — M11: Enterprise Topology (90 min)

**Lecture mode or Fallback: If Entra admin unavailable for cross-tenant consent, switch to 30-min lecture + Q&A only; skip hands-on lab. Document in feedback survey.**

| Time | Activity | Checkpoint (Full Lab) | Checkpoint (Fallback) |
|------|----------|----------------------|----------------------|
| 14:30–14:45 | Lecture (15 min): VNET-isolated observability (private endpoints). Cross-tenant connectors (federation, consent flow). Agent Identity sidecar / Entra Agent ID OBO. | Attendees see topology diagrams. | Same. |
| 14:45–15:45 | Lab (60 min): Wire cross-tenant connector from primary sandbox to "remote" tenant (2nd sandbox). Coordinate consent step with named Entra admin. Attendees output a one-page topology diagram per their real environment. | All attendees have 1 cross-tenant connector "Connected" OR a completed topology diagram. | (Skipped; see lecture.) |
| 15:45–16:00 | Wrap (15 min): Discussion — which monitored services need private connectivity? Which require cross-tenant trust? Attendees fill in their own topology notes. | Attendees have notes for their real environment. | Same. |

**Contingency:**
- Entra admin unavailable? → Immediately shift to **Fallback: Lecture-only (30 min) + Q&A (60 min)**. Update feedback survey: "Plan to attempt M11 lab post-workshop? Yes/No." Offer async post-workshop with attendee's own Entra admin.
- Cross-tenant connector times out? → Show a pre-configured example; discuss the topology instead of hands-on.

---

### 16:00–16:15 — Break (15 min)

---

### 16:15–17:45 — M12: Configuration as Code (90 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 16:15–16:30 | Overview (15 min): Four parts — IaC for agent (Bicep/Terraform), custom agents + hooks via REST API v2, knowledge persistence files (read-only deep dive), drift control (Azure Activity Log query). | All attendees understand the four parts. |
| 16:30–17:00 | Part 1 (30 min): Attendees choose Bicep OR Terraform. Reference repo provided. Deploy agent resource + UAMI + role assignments (per M1 matrix) + App Insights/Log Analytics. Param the model provider (Anthropic vs Azure OpenAI). | Every attendee has agent-iac.bicep (or .tf) file with at least one parameter. |
| 17:00–17:20 | Part 2 (20 min): REST API v2. Attendees use provided PowerShell/Python client to PUT /api/v2/extendedAgent/agents/{agentName} with the YAML schema from M9 (hooks here, not portal). | Every attendee has tested the REST client in a dry-run (no deployment yet). |
| 17:20–17:30 | Part 3 (10 min): Knowledge persistence files (read-only demo). Trainer shows memories/synthesizedKnowledge/ directory structure: overview.md, topic files, knowledge graph. No editing required; just awareness. | Attendees see the directory structure. |
| 17:30–17:45 | Part 4 + wrap (15 min): Drift control query (Azure Activity Log) to flag out-of-band portal changes. Segue to M13 capstone. | Attendees understand: "Configuration = Code; enforce via CI and drift detection." |

**Contingency:** If Bicep/Terraform deployment fails, attendees reference the pre-built template; continue with REST API v2.

---

### 17:45–18:00 — M13 Setup (15 min)

**Preparation:** Trainer fires synthetic incidents at each severity. Attendees prepare to demonstrate end-to-end incident handling without manual intervention.

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 17:45–17:55 | Setup (10 min): Trainer displays the three synthetic incidents queued: [TEST] P3 high latency, [TEST] P1 db corruption, [TEST] P2 api 500s. Walk through expected behavior per MD §M13. | All attendees see the incident list. No surprises. |
| 17:55–18:00 | Q&A (5 min): Any questions on routing, hooks, or the capstone scoring rubric? | No critical blockers. |

---

### 18:00–19:30 — M13: Production Rollout Playbook + Capstone Drill (90 min)

| Time | Activity | Checkpoint |
|------|----------|-----------|
| 18:00–18:10 | Rollout playbook review (10 min). Read aloud the 10 steps (M13 §MD): Land PR → delete quickstart → author skills → wire agents → add tools → wire hooks → build workbook → set tiers → rollout shadow mode → operations cadence. Attendees have a one-page printed/digital copy. | All attendees have the 1-pager. |
| 18:10–18:20 | Capstone briefing (10 min). Explain the three drill incidents: P3 (Review mode, review audit), P1 (autonomous chain, deep investigation, audit + block hook), P2 (chain variant). Scoring rubric: ≥80 % pass. | All attendees know what to expect. |
| 18:20–19:15 | Capstone drill (55 min). Trainer fires incidents; attendees watch their response plans route, custom agents dispatch, tools execute, hooks audit/block. | All three incidents handled end-to-end OR documented in the capstone scoring sheet why they didn't (e.g., "hook rejected due to incomplete root cause; attendee revised response and re-ran"). |
| 19:15–19:30 | Wrap + debrief (15 min). Review capstone scoring. Congratulations. Post-workshop next steps: (1) land agent-as-code PR within 2 weeks, (2) feedback survey, (3) optional async M11 if needed. | Attendees receive capstone scores. Positive tone. |

**Day 2 ends at 19:30.**

---

## Post-Workshop Ceremony

- [ ] Attendees complete feedback survey (15 min).
- [ ] Trainer exports capstone scoring sheet (signed off by trainer).
- [ ] Trainer shares rollout pack (one-pager, hook stubs, Bicep skeleton, KQL workbook JSON).
- [ ] Email: "Thank you for attending. Here's your rollout pack. Land your agent-as-code PR within 2 weeks. Questions? → escalation contact tree."

---

## Trainer Notes on Checkpoints

1. **After each module:** Verify at least 80 % of attendees have the checkpoint green (demo or screenshot).
2. **If a checkpoint fails:** Don't move forward. Pause, troubleshoot, or (last resort) move the attendee to the stretch-task list and catch up in async.
3. **Synchronization pulse points (M2, M3, M13):** All three tracks must restart at the same time. Waiting 15 min for a slow track to finish is acceptable; waiting 45 min is not (break early, catch up async).
4. **Buffer time:** The timings above include ~5 min of buffer per 60 min of content. If you're consistently running 10+ min behind, drop one stretch task or one discussion point. Never cut a hands-on checkpoint.
5. **Track-specific issues:** PagerDuty trial expiring? ServiceNow PDI slow? Azure Monitor alert not firing? Document in the operations runbook for the next cohort. Fallback: have a shared trainer account ready.

---

## Glossary of Trainer Callouts

- **"All three tracks, same checkpoint"** → synchronization pulse point; no one proceeds until this is green across all tracks.
- **"Paired exercise"** → attendees work individually or in pairs; trainer spot-checks 2–3 examples live.
- **"Stretch task"** → optional if time permits; not required for later modules.
- **"M9 first, then Autonomous"** → production safety culture. Never demonstrate Autonomous without hooks. Never.
- **"Audit messages in the thread"** → attendees should see PostToolUse hooks firing in the incident thread.
- **"Fallback: lecture-only"** → if a hands-on component is blocked (no Entra admin, no ADX, etc.), pivot to a 30-min conceptual lecture + Q&A. Offer async catch-up.

---

## Timing by Day (Summary)

| Day | Start | End | Total |
|-----|-------|-----|-------|
| Day 1 | 9:00 | 18:15 | 8.0 hrs (breaks: 1.25 hrs; content: 6.75 hrs) |
| Day 2 | 9:00 | 19:30 | 9.0 hrs (breaks: 1.5 hrs; content: 7.5 hrs) |
| **Total** | — | — | **17.0 hrs** |

**Note:** If you only have one day, cut M5, M7, or M11; do NOT cut M1, M3, M9, M10, or M13. Prioritize the promotion playbook, response plans, hooks, and capstone.
