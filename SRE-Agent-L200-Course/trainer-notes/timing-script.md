# Workshop Facilitator Timing Script

> **Total duration:** ~4 hours 10 minutes (including one 10-minute break)
> **Target audience:** 20+ attendees, mixed DevOps and SRE-Ops roles
> **TA ratio:** Recommend 1 TA per 10 attendees for hands-on modules

---

## Timeline at a Glance

| Time | Duration | Module | Mode |
|------|----------|--------|------|
| 0:00 – 0:30 | 30 min | M1 — What & Why: SRE Agent Concepts | Lecture |
| 0:30 – 1:00 | 30 min | M2 — Access Control Model | Lecture + diagram |
| 1:00 – 1:45 | 45 min | M3 — Lab A: Provision Your First Agent | Hands-on |
| 1:45 – 2:30 | 45 min | M4 — Lab B: Connect Code, Resources, Knowledge | Hands-on |
| 2:30 – 2:40 | 10 min | ☕ Break | — |
| 2:40 – 3:10 | 30 min | M5 — Lab C: First Investigation in Chat | Hands-on |
| 3:10 – 3:40 | 30 min | M6 — Lab D: Deep Investigation | Hands-on |
| 3:40 – 4:25 | 45 min | M7 — Lab E: Automate (Connector + Agent + Task) | Hands-on |
| 4:25 – 4:45 | 20 min | M8 — Operate, Audit, Share | Lecture + click-through |
| 4:45 – 5:00 | 15 min | M9 — Wrap-Up + Bridge to Level 300 | Lecture |

---

## Module-by-Module Script

### M1 — What & Why: SRE Agent Concepts (0:00 – 0:30)

**Opening (0:00 – 0:05)**
- Welcome attendees, confirm audio/video, point to the support channel.
- "By the end of today, every one of you will have a running SRE Agent that can investigate your Azure resources, run deep investigations, and send automated health reports."
- Set expectations: we go from zero to a working agent in ~4 hours.

**Core Content (0:05 – 0:25)**
- Present the "3 AM, 5 tabs" problem — how on-call engineers currently triage.
- Introduce the four outcomes: Autonomous Incident Response, Lightning-Fast RCA, Extensible Automation, Knowledge That Never Leaves.
- Walk through the architecture diagram: Connect → Enhance → Achieve.
- Cover the glossary: Agent, Connector, Tool, Skill, Custom Agent (Subagent), Knowledge Base/Memory, Response Plan, Scheduled Task, Run Mode.
- Explain the "Day 1 → Week 1 → Month 1" maturity curve.

**🎯 DevOps vs SRE-Ops Talking Points (flag these)**
- **DevOps lens:** SREA as a teammate that reads your repo + deployment history + Azure Monitor in one place.
- **SRE-Ops lens:** SREA as MTTR reduction, runbook executor, knowledge retainer.
- Tailor your examples based on the room's composition. If mostly developers, lean into the code-aware investigation angle. If mostly ops, emphasize the runbook and automation story.

**Transition (0:25 – 0:30)**
- "Before we touch the portal, we need to understand who can do what — that's M2."

**🧑‍🏫 TA Notes:** TAs are passive during lecture. Have them verify the support channel is working and confirm each attendee's browser can reach `sre.azure.com`.

---

### M2 — Access Control Model (0:30 – 1:00)

**Opening (0:30 – 0:33)**
- "This module prevents 80% of 'why didn't this work?' issues during the labs."

**Core Content (0:33 – 0:55)**
- Whiteboard (or slide) the three-layer model:
  - **User Roles** (what a human can do) — Reader, Standard User, Administrator.
  - **Run Modes** (agent asks before acting?) — Review vs Autonomous.
  - **Agent Permissions** (what the agent can read/do) — Reader vs Privileged, plus OBO fallback.
- Emphasize: Start every new agent in **Review** mode + **Reader** permission level.
- Call out OBO clearly: only Administrators with work/school Entra accounts can authorize, token is scoped to a single investigation task.
- Mention always-assigned RBAC roles: Reader, Log Analytics Reader, Monitoring Reader (RG), Monitoring Contributor (subscription).

**Transition (0:55 – 1:00)**
- "Now you know the access model. Let's go build an agent. Open your browser to sre.azure.com."

**🧑‍🏫 TA Notes:** TAs should be ready to help with Entra ID sign-in issues at the start of M3.

---

### M3 — Lab A: Provision Your First Agent (1:00 – 1:45)

**Opening (1:00 – 1:05)**
- Demo the create flow on your screen: sre.azure.com → Create agent → Basics wizard.
- Show the fields: Subscription, Resource Group, Agent Name, Region, Model Provider, App Insights.
- **Demo, then let attendees follow.**

**Attendee Work (1:05 – 1:35)**
- Each attendee creates their own agent in their personal resource group (`rg-sre-agent-<alias>`).
- Deployment takes 2–5 minutes — use this time to walk around and verify everyone's wizard is filled correctly.
- Verify the deployment created: UAMI, Log Analytics workspace, App Insights, role assignments, SRE Agent resource.

**Common Issues (see failure-recovery.md for details):**
- `DeploymentNotFound` → register `Microsoft.App` provider.
- "Create button greyed out" → permission issue or unsupported region.
- App Insights creation fails → use existing AI instance.

**Checkpoint (1:35 – 1:45)**
- Every attendee should click **Set up your agent** and land on the "More context. Better investigations." page.
- **Target: 100% of attendees have a Running agent.** Do not proceed until this is met. TAs help stragglers.

**🧑‍🏫 TA Notes:** Circulate actively. Prioritize unblocking attendees whose deployments fail. Use the failure-recovery guide.

---

### M4 — Lab B: Connect Code, Resources, Knowledge (1:45 – 2:30)

**Opening (1:45 – 1:50)**
- Demo Part 1 (code repo connection) on your screen. Show OAuth flow.

**Part 1 — Connect Code Repo (1:50 – 2:00)**
- Attendees connect a GitHub or Azure DevOps repo.
- Talking point: After connection, the agent starts background codebase analysis and may generate an `SREAGENT.md` PR. "Don't merge it now — just note it exists."

**Part 2 — Add Azure Resource Access (2:00 – 2:15)**
- Demo: Full Setup → Azure Resources → select RG → Reader permission → Add.
- Attendees do the same with their sample workload RG.
- Optional verification command for Azure-savvy attendees:
  ```pwsh
  az role assignment list --assignee <agent-uami-id> --scope /subscriptions/<sub>/resourceGroups/<rg> --output table
  ```

**Part 3 — Upload Knowledge (2:15 – 2:25)**
- Demo: Builder → Knowledge Base → Upload the two sample docs from `knowledge-samples/`:
  - `sample-architecture.md`
  - `sample-runbook-restart-containerapp.md`
- Demo `#remember our prod region is East US 2 and our paging channel is #oncall-payments`
- Briefly mention `#retrieve` and `#forget`.

**Checkpoint (2:25 – 2:30)**
- Click **Done and go to agent** — chat opens.
- Verify everyone sees the chat interface. TAs help anyone stuck.

**🧑‍🏫 TA Notes:** Circulate during Part 2 — resource connection is the most error-prone step. If an attendee's agent doesn't see resources, check RBAC assignments.

---

### ☕ Break (2:30 – 2:40)

- "10 minutes. When we come back, we start talking to the agent."
- TAs: use this time to catch up anyone who fell behind on M3 or M4.

---

### M5 — Lab C: First Investigation in Chat (2:40 – 3:10)

**Opening (2:40 – 2:45)**
- "Now the fun part. You're going to ask the agent questions and see it work."

**Guided Prompts (2:45 – 3:00)**
- Run these sequentially on your screen, have attendees follow:
  1. `What Azure resources can you see?`
  2. `Summarize the health of the resources in my managed resource group.`
  3. `Show me any errors in <sample-app-name> in the last hour.`
- While results load, talk through:
  - **Tool call cards** (Resource Graph, KQL, App Insights, Azure CLI) — the agent shows its work.
  - **Citations** from uploaded knowledge docs.
  - The agent correlates, it doesn't just dump logs.

**Mini Exercise (3:00 – 3:08)**
- "Ask the agent something it should NOT be able to do — e.g., restart a Container App."
- In Reader/Review mode, the agent should show **Approve / Deny** buttons or request OBO authorization.
- Demo approving one low-risk operation (e.g., reading revisions).

**Transition (3:08 – 3:10)**
- "Regular chat is powerful, but sometimes you need the agent to go deep. That's next."

**🧑‍🏫 TA Notes:** Circulate and verify each attendee gets at least 3 successful chat responses. If an agent returns thin results, check that resources and code repo are connected (M4).

---

### M6 — Lab D: Deep Investigation (3:10 – 3:40)

**Opening (3:10 – 3:13)**
- "Deep investigation is the heavy artillery. It's a multi-phase, hypothesis-driven investigation."
- Scope guard: "We're covering Mode 1 (chat-triggered) only. Mode 2 (auto-triggered from response plans) is Level 300."

**Demo + Attendee Work (3:13 – 3:30)**
1. In chat, click **+** → **Deep investigation** → Confirm dialog.
2. Confirm sparkle badge + status banner.
3. Enter:
   ```
   Investigate why the <sample-app> has elevated latency. Check logs, metrics,
   and recent deployments to identify the root cause.
   ```
4. **Approve** the OBO authorization card.
5. Watch the investigation tree: Incident research → Hypotheses → Validation → Conclusion.
6. Click nodes to inspect evidence.
7. Turn deep investigation off when done (X on badge).

**Discussion (3:30 – 3:38)**
- Cost/latency note: deep investigations consume more tokens — use for real complexity.
- OBO authorization timeout = 10 minutes.
- Partial results are preserved if you cancel.

**Checkpoint (3:38 – 3:40)**
- **Target: ≥ 90% of attendees completed at least one deep investigation.**

**🧑‍🏫 TA Notes:** OBO authorization is the most common blocker here. Ensure attendees are signed in with work/school Entra accounts. If authorization times out, have them retry (the 10-minute window resets).

---

### M7 — Lab E: Automate (3:40 – 4:25)

**Opening (3:40 – 3:45)**
- "This is the capstone. You'll wire up email notifications and a scheduled health check."
- Demo the full flow on your screen first.

**Step 1 — Outlook Connector (3:45 – 3:55)**
- Builder → Connectors → Add connector → Send email (Office 365 Outlook) → sign in.
- Verify: connector appears with `SendOutlookEmail`, `GetOutlookEmail`, `ListOutlookEmails` tools.

**Step 2 — Create Custom Agent (3:55 – 4:05)**
- Builder → Agent Canvas → Create subagent.
- Name: `email-notifications`
- Autonomy: **Autonomous** — emphasize this is safe because it only sends emails, it does NOT touch Azure infra.
- Tools: select `SendOutlookEmail`.
- Save and confirm the node appears on the canvas.

**Step 3 — Scheduled Task (4:05 – 4:15)**
- Click **+** on the subagent node → Add scheduled task.
- Name: `daily-resource-health-report`
- Schedule: every 24h or cron `0 8 * * *`
- Prompt template (show on screen, have attendees copy):
  ```
  Check the health of our Azure resources:
  1. Verify all container apps are running
  2. Check CPU and memory metrics over the last hour
  3. Review any recent warning logs
  4. Summarize findings and send a report via email using SendOutlookEmail
  ```

**Step 4 — Verify (4:15 – 4:23)**
- Builder → Scheduled tasks → select task → **Run task now**.
- Click the chat thread; watch tool invocations; confirm email arrives.

**Checkpoint (4:23 – 4:25)**
- **Target: ≥ 80% of attendees received the email.**
- Stretch goal (mention only): swap Outlook for Teams channel post.

**🧑‍🏫 TA Notes:** Outlook sign-in is a common friction point. If attendees get stuck, check that their M365 account matches their Entra ID account. See failure-recovery.md for connector troubleshooting.

---

### M8 — Operate, Audit, Share (4:25 – 4:45)

**Click-Through Tour (no lab) (4:25 – 4:43)**
- This is presenter-led. Attendees watch and follow along in their own portals.

1. **Session Insights** (3 min) — Show auto-extracted symptoms, steps, root cause, pitfalls from today's threads.
2. **Audit Agent Actions** (3 min) — Show what the agent did, who approved it, which identity was used.
3. **Share an Investigation Thread** (3 min) — Open a thread → ⋯ → Copy link to thread → paste in Teams. Discuss post-incident review usage.
4. **Memory at Work** (5 min) — Ask the agent:
   - `What knowledge documents do you have?`
   - `What have you learned about <sample-app>?`
   - Show the overview.md / topic-file pattern conceptually (no editing).
5. **Connector Health** (4 min) — Builder → Connectors. Show the red badge on collapsed categories when a connector has issues. Mention 60-second heartbeat.

**Transition (4:43 – 4:45)**
- "That's the operator toolkit. Now let's wrap up."

**🧑‍🏫 TA Notes:** Passive during this module. Use this time to note any attendees who still need help with Lab E.

---

### M9 — Wrap-Up + Bridge to Level 300 (4:45 – 5:00)

**Recap Slide (4:45 – 4:50)**
- "5 things every team member should now do day-to-day:"
  1. Ask the agent before opening 5 portal tabs.
  2. Use Deep Investigation for the gnarly stuff.
  3. `#remember` env-specific facts your team would otherwise re-explain.
  4. Upload runbooks instead of emailing them.
  5. Share investigation thread links in incident bridges.

**Level 300 Bridge (4:50 – 4:55)**
- Show the "what we did NOT cover" table — incident platforms, response plans, Privileged/Autonomous for production, MCP connectors, Skills authoring, custom tools, agent hooks, knowledge deep dive.
- "If you want to go deeper, the Level 300 workshop will cover these."

**Close (4:55 – 5:00)**
- Share the feedback form.
- Point to the support channel for post-workshop questions.
- "Your agent is yours to keep in the sandbox. Experiment over the next week."

**🧑‍🏫 TA Notes:** Collect feedback forms. Note any attendees who want to be in the Level 300 cohort.
