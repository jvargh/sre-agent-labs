# M11 — Enterprise Topology: Checklist

## Pre-Lab Checklist

- [ ] M1–M10 completed and verified
- [ ] Second sandbox subscription available (prereq #2) — tenant ID noted
- [ ] Named Entra admin reachable (prereq #8)
- [ ] If either prerequisite missing → activate lecture-only fallback

## During Lab Checklist

- [ ] CP1: Lecture complete — VNET isolation, cross-tenant, Agent Identity concepts understood
- [ ] CP2: Cross-tenant prerequisites verified (two tenant IDs, Entra admin available)
- [ ] CP3: Consent flow completed with Entra admin (connector shows Consent granted)
- [ ] CP4: Cross-tenant connector tested — data flows from remote tenant
- [ ] CP5: One-page topology diagram drafted for attendee's real environment

## Post-Lab Verification

- [ ] Cross-tenant connector shows `Connected` status
- [ ] Agent can query data from the remote tenant
- [ ] Topology diagram includes: agent location, monitored services, private endpoints, cross-tenant trust, identity model
- [ ] Attendee can explain when cross-tenant is needed vs single-tenant design
- [ ] Attendee understands UAMI vs app registration vs OBO patterns

## Fallback Checklist (Lecture-Only Variant)

- [ ] Full lecture delivered (30 min)
- [ ] Trainer demo of cross-tenant flow observed (30 min)
- [ ] Topology diagram drafted from lecture content (30 min)
- [ ] Homework runbook distributed for post-workshop completion
- [ ] Fallback activation documented in operations runbook
