# Lab 8 — Python Tools: Checklist

## Pre-Lab Checklist

- [ ] Labs 1–7 completed and verified
- [ ] Agent runtime supports Python 3.12
- [ ] Trainer-provided Azure Function URL and key available (for Tool 3)
- [ ] Agent has UAMI assigned with appropriate role assignments

## During Lab Checklist

- [ ] CP1: Tool 1 (AI-generated SLA compliance calculator) created and tested
- [ ] CP2: Tool 2 (BYO deployment-status-checker) created and tested
- [ ] CP3: Tool 3 (HTTP wrapper cmdb-lookup) created and tested
- [ ] CP4: Managed-identity scope enabled on Tool 3 — no secrets in code
- [ ] CP5: Tool 3 wired to `db-expert` from Lab 6 and callable from chat
- [ ] CP6: Compare/contrast discussion complete

## Post-Lab Verification

- [ ] Three Python tools in `Active` state in the Tools list
- [ ] At least one tool uses managed-identity (no hardcoded secrets)
- [ ] `db-expert` custom agent has the CMDB lookup tool attached
- [ ] Attendee can state execution-environment constraints (timeout, container, packages)
