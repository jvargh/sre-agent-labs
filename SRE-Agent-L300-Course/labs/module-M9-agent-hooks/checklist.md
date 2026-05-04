# M9 — Agent Hooks: Checklist

## Pre-Lab Checklist

- [ ] M1–M8 completed and verified
- [ ] M3 Response Plan B still active and dispatching to M6 chain
- [ ] Synthetic incident generator available
- [ ] Agent has UAMI with appropriate permissions

## During Lab Checklist

- [ ] CP1: Concepts — can explain Stop vs PostToolUse, agent-level vs custom-agent-level, prompt vs command
- [ ] CP2: Hook A (Stop, prompt, completeness) created and tested — blocks incomplete response
- [ ] CP3: Hook B (PostToolUse, command, block) created and tested — blocks rm -rf, sudo, chmod 777, az group delete
- [ ] CP4: Hook C (PostToolUse, command, audit) created and tested — logs every tool call
- [ ] CP5: All three hooks wired at agent level; M3 P1 incident re-fired and verified
- [ ] CP6: Limits memorized (64KB, 1-300s timeout, shebangs, maxRejections)

## Post-Lab Verification

- [ ] Three hooks active at agent level in Builder → Hooks
- [ ] P1 incident routes through full chain with hooks active
- [ ] Dangerous commands are blocked (verified with test)
- [ ] Audit trail visible in hook execution logs
- [ ] Attendee can state the difference between agent-level and custom-agent-level hooks
- [ ] Attendee understands `failMode: allow` vs `failMode: block`
