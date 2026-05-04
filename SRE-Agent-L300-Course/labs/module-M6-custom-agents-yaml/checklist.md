# M6 — Checkpoint Checklist

## ⏱ 15-min Checkpoint

- [ ] `p1-investigator` exported to YAML
- [ ] Can identify all key fields in agent YAML

## ⏱ 30-min Checkpoint

- [ ] All 4 specialist YAMLs authored (incident_triager, db_expert, api_expert, notifier)
- [ ] Each has unique `name` and `handoff_description`

## ⏱ 45-min Checkpoint

- [ ] All 4 agents deployed via REST API v2
- [ ] Response Plan B updated to dispatch to `incident_triager`
- [ ] Canvas shows handoff chain with edges

## ⏱ 60-min Checkpoint

- [ ] Playground: database incident routes to `db_expert`
- [ ] Playground: API incident routes to `api_expert`
- [ ] `notifier` produces summary in both branches

## ⏱ 75-min Checkpoint

- [ ] Shared context concept understood
- [ ] Per-agent 80-tool budget understood
- [ ] `allowed_skills` shorthand understood

## ⏱ 90-min (End) Checkpoint

- [ ] All 4 YAMLs checked in to repo as a PR
- [ ] Full handoff chain operational end-to-end
