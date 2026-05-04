---
lab: 11
level: 400
duration_minutes: 90
track: all
dependencies: [Lab 1, Lab 2, Lab 3, Lab 4, Lab 5, Lab 6, Lab 7, Lab 8, Lab 9, Lab 10]
source_md_sha: 37BDC62AD9BD827BE88ADFA55CFF3263C8EA120E6C4329BAA87C2968FA7DD102
---

# Lab 11 — Enterprise Topology: VNET-Isolated Observability, Cross-Tenant Connectors, Agent Identity Sidecar

## Learning Outcome

Conceptual mastery of enterprise networking and identity patterns + one hands-on cross-tenant connector. Each attendee produces a one-page topology diagram for their real environment.

> **Prerequisites:** Second sandbox subscription (prereq #2) + named Entra admin (prereq #8) reachable during this Lab.

> **Pre-read:** [Azure Observability VNET](https://sre.azure.com/docs/capabilities/azure-observability-vnet) · [Cross-Tenant Access](https://sre.azure.com/docs/capabilities/cross-tenant-access) · [Agent Identity](https://sre.azure.com/docs/concepts/agent-identity)

> ⚠️ **FALLBACK:** If the Entra admin is unavailable or the second sandbox subscription is not provisioned, switch to the **lecture-only variant** documented at the end of this guide. Do not attempt the lab without both prerequisites.

---

## Checkpoint Schedule

| Time | Checkpoint |
|------|-----------|
| 0:00 | Lab start — verify Lab 10 workbook saved |
| 0:30 | ✅ CP1 — Lecture complete (VNET, cross-tenant, Agent Identity) |
| 0:45 | ✅ CP2 — Cross-tenant connector prerequisites verified |
| 0:60 | ✅ CP3 — Consent flow completed with Entra admin |
| 0:75 | ✅ CP4 — Cross-tenant connector tested |
| 0:90 | ✅ CP5 — Topology diagram drafted |

---

## Part 1 — Lecture (30 min)

### 1.1 VNET-Isolated Observability (10 min)

**Topic:** How the agent reaches private App Insights / Log Analytics behind private endpoints.

Key points:
- Private endpoint topology for App Insights + Log Analytics
- Required NSG rules for agent egress
- Private DNS zone configuration
- Impact on telemetry flush latency

> Reference: [Azure Observability VNET](https://sre.azure.com/docs/capabilities/azure-observability-vnet)

### 1.2 Cross-Tenant Connectors (10 min)

**Topic:** When the agent and its monitored resources live in different tenants.

Key points:
- Managed-identity federation across tenant boundaries
- Consent flow requirements (Entra admin must approve)
- Data residency considerations
- When cross-tenant is needed vs when a single-tenant design suffices

> Reference: [Cross-Tenant Access](https://sre.azure.com/docs/capabilities/cross-tenant-access)

### 1.3 Agent Identity Sidecar / Entra Agent ID (10 min)

**Topic:** How built-in connectors use the UAMI, when you need a separate Entra app registration, and OBO patterns.

Key points:
- UAMI is the default identity for built-in connectors
- Entra app registration needed for: cross-tenant, non-Entra users, custom auth flows
- OBO (On-Behalf-Of) patterns for user-context operations
- Agent Identity sidecar architecture

> Reference: [Agent Identity](https://sre.azure.com/docs/concepts/agent-identity)

> **🔖 Checkpoint CP1** — Lecture complete. Attendees can explain VNET isolation, cross-tenant trust, and Agent Identity.

---

## Part 2 — Lab: Cross-Tenant Connector (60 min)

### 2.1 Verify Prerequisites (15 min)

- **Action:** Confirm you have:
  1. Primary sandbox subscription (agent lives here) — note the tenant ID
  2. Second sandbox subscription (simulates "remote" tenant) — note the tenant ID
  3. Named Entra admin is reachable (Slack, Teams, or in the room)
- **Expected state:** Two distinct tenant IDs. Entra admin has confirmed availability.
- **Troubleshooting:** If either prerequisite is missing, switch to the **lecture-only fallback** (see below).

> **🔖 Checkpoint CP2** — Prerequisites verified. Two tenant IDs noted.

### 2.2 Configure the Cross-Tenant Trust (15 min)

- **Action:** In the primary tenant (where the agent lives):
  1. Navigate to **Builder → Connectors → Add connector → Cross-tenant**.
  2. Enter the remote tenant ID.
  3. The portal generates a consent URL.

- **Action:** Send the consent URL to the Entra admin. They must:
  1. Open the URL in the remote tenant's context.
  2. Review the permissions requested (read access to specified resources).
  3. Grant admin consent.

- **Expected state:** The connector status changes from `Pending consent` to `Consent granted`.
- **Troubleshooting:** If consent is denied, the Entra admin may need Global Administrator or Cloud Application Administrator role. Do not proceed without consent — the connector will not function.

> **🔖 Checkpoint CP3** — Consent flow completed. Connector shows `Consent granted`.

### 2.3 Complete the Connector Configuration (15 min)

- **Action:** Back in the primary tenant:
  1. Select the resources in the remote tenant to monitor (e.g., a Log Analytics workspace, an App Insights instance).
  2. Configure the managed-identity federation.
  3. Test the connection.

- **Expected state:** Connector shows `Connected` with access to remote-tenant resources.
- **Troubleshooting:** If `Connection failed`, verify:
  - The UAMI in the primary tenant has been granted the correct role in the remote tenant (e.g., Log Analytics Reader).
  - NSG rules in the remote tenant allow inbound from the agent's VNET.
  - Private DNS resolves correctly if private endpoints are in use.

### 2.4 Test the Cross-Tenant Connector (15 min)

- **Action:** In Agent Playground, prompt the agent to query data from the remote tenant:
  > "Show me the last 10 errors from the remote Log Analytics workspace."
- **Expected state:** The agent returns data sourced from the remote tenant.
- **Troubleshooting:** If the query returns empty, verify that the remote workspace has data. Check that the UAMI role assignment propagated (can take up to 5 minutes).

> **🔖 Checkpoint CP4** — Cross-tenant connector tested. Data flows from remote tenant.

---

## Part 3 — Topology Diagram (15 min)

### 3.1 Draft Your Diagram

- **Action:** Using the template provided by the trainer (or a blank whiteboard / draw.io), create a one-page topology diagram for your **real environment**. Include:
  - Agent location (tenant + subscription + RG)
  - Monitored services (which tenant, which VNET)
  - Private endpoints needed
  - Cross-tenant trust relationships
  - Identity model (UAMI, app registration, OBO)

- **Expected state:** A single-page diagram showing network, identity, and trust relationships.
- **Troubleshooting:** If unsure about your real topology, sketch the workshop sandbox topology as a starting point and annotate what would differ in production.

> **🔖 Checkpoint CP5** — Topology diagram drafted.

---

## Lecture-Only Fallback

> Use this variant if the Entra admin is unavailable or the second sandbox subscription is not provisioned.

**Duration:** 90 min (all lecture + guided discussion)

1. Complete the full lecture (30 min) as described above.
2. **Demo walkthrough (30 min):** Trainer demonstrates the cross-tenant connector flow on a pre-configured pair of tenants. Attendees follow along on screen.
3. **Topology exercise (30 min):** Attendees draft their topology diagrams based on the lecture content and trainer demo, without hands-on connector setup.
4. **Homework:** Attendees are given a step-by-step runbook to complete the cross-tenant connector lab post-workshop with their own Entra admin.

> Document the fallback activation in the operations runbook (D16).

---

## Next Lab

Proceed to [Lab 12 — Configuration as Code](../lab-12-config-as-code/README.md).
