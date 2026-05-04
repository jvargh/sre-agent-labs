# Sample Skills Reference Repo (D7)

Sample `SKILL.md` files for the SRE Agent with a grading rubric — good and intentionally bad examples.

## Purpose

Used in Lab 4 (Skills Authoring) as graded exercises. Attendees evaluate these examples to build intuition for effective skill descriptions.

## Grading Rubric

| Criterion | Weight | Good Example | Bad Example |
|-----------|--------|-------------|-------------|
| **Trigger phrases** in description | 40% | ✅ Multiple specific phrases | ❌ None — agent never loads it |
| **Clear procedural steps** | 25% | ✅ Step-by-step troubleshooting | ❌ Vague "look at stuff" |
| **Tool attachments specified** | 15% | ✅ Explicit read-only tools | ❌ No tools or write tools on a discovery skill |
| **Scoped to one domain** | 10% | ✅ Focused on Postgres | ❌ Covers "everything" |
| **Links to runbooks** | 10% | ✅ Direct links | ❌ No external references |

## File Structure

```
good-examples/
  postgres-troubleshooting.md   # tag: good — clear triggers, scoped, linked
bad-examples/
  vague-skill.md                # tag: bad — no triggers, vague, unscoped
```

## Usage in Lab 4

1. Attendees read both examples.
2. Apply the rubric to score each.
3. Identify the specific deficiencies in the bad example.
4. Author their own skill using the good example as a template.

> **Answer key:** Maintained in a separate file by the trainer — not distributed to attendees.

## References

- [Skills Concepts](https://sre.azure.com/docs/concepts/skills)
- [Skills Tutorials](https://sre.azure.com/docs/tutorials/skills/)
- [Lab 4 Guide](../../labs/lab-04-skills-authoring/README.md)
