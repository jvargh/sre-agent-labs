# Lab 5 — Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| ADX connector fails to connect | Cluster URL format incorrect | Use format `https://<cluster>.<region>.kusto.windows.net/<database>` |
| `.add cluster AllDatabasesViewer` returns Forbidden | Missing Cluster Admin rights on the ADX cluster | Contact the ADX cluster owner; they must run the grant |
| Re-running the AllDatabasesViewer grant errors | Should not error — the command is idempotent | If it does error, check for typos in the UAMI client ID or tenant ID |
| Kusto tool test returns 0 rows | Seed data missing, table/column name mismatch, or data older than 24h | Verify D9 seed loaded correctly; check `AppEvents` schema matches the query |
| Agent doesn't call the Kusto tool | Tool description too vague for model matching | Edit the tool description to include specific trigger phrases like "errors", "exceptions", "failures" |
| Agent substitutes wrong parameter values | Prompt not specific enough | Use explicit time and pattern: "last 24 hours" and "NullPointerException" |
| Link tool URL doesn't resolve | Tenant ID placeholder incorrect | Replace `<tenant>` with your actual tenant ID or domain |
| Kusto query times out | Query unbounded or table too large | Ensure `take 100` and time filter are in the query |
