# M12 — Configuration as Code: Checklist

## Pre-Lab Checklist

- [ ] M1–M11 completed and verified
- [ ] Reference repos available (agent-as-code, rest-api-v2-client)
- [ ] Write access to the workshop repo for landing the PR
- [ ] `az` CLI authenticated with Contributor access to a fresh RG

## During Lab Checklist

- [ ] CP1: Part 1 — IaC deployed to fresh RG; what-if confirms idempotent
- [ ] CP2: Part 2 — Custom agents + hooks pushed via REST API v2; CI step authored
- [ ] CP3: Part 3 — Knowledge persistence file structure reviewed
- [ ] CP4: Part 4 — Drift-detection query saved as sixth query in M10 workbook
- [ ] CP5: PR opened with all artifacts (IaC, YAML, hooks, CI, drift query)

## Post-Lab Verification

- [ ] Agent resource exists in the fresh RG, deployed via IaC
- [ ] `az deployment group what-if` shows no changes (idempotent)
- [ ] REST API v2 round-trip: export → modify → push → diff = empty
- [ ] CI pipeline step committed and functional
- [ ] Six queries saved in the M10 App Insights workbook
- [ ] Attendee can explain the knowledge persistence file structure
- [ ] Attendee can articulate the drift-detection workflow
