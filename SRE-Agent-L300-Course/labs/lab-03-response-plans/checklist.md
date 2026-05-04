# Lab 3 — Checkpoint Checklist

## ⏱ 15-min Checkpoint

- [ ] `low-sev-triager` custom agent exists (Review mode)
- [ ] `p1-investigator` custom agent exists (Autonomous mode)

## ⏱ 30-min Checkpoint

- [ ] Response Plan A saved: P3/P4 → `low-sev-triager`, Review, deep investigation off
- [ ] `[TEST]` pre-validation flow completed

## ⏱ 45-min Checkpoint

- [ ] Response Plan B saved: P1/P2 → `p1-investigator`, Autonomous, Mode 2 ON
- [ ] Plans A and B have non-overlapping severity filters

## ⏱ 60-min Checkpoint

- [ ] P3 test incident routed to `low-sev-triager`
- [ ] P1 test incident routed to `p1-investigator` with 4-phase investigation

## ⏱ 75-min Checkpoint

- [ ] Turn off / turn on lifecycle tested on Plan B
- [ ] Unified grid view reviewed

## ⏱ 90-min (End) Checkpoint

- [ ] Both plans operational with correct routing
- [ ] Failure modes (overlapping plans, missing PostToolUse hook) discussed
- [ ] Ready for Lab 4 (skills) and eventually Lab 9 (hooks)
