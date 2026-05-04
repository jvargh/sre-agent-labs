# Postgres Troubleshooting Guide

<!-- tag: good -->
<!-- Why good: Clear trigger phrases in description, scoped to one domain, step-by-step procedure, read-only tools, linked runbooks. -->

## Description

Use this skill when the user reports **Postgres connection failures**, **high Postgres CPU**, **Azure Database for PostgreSQL slow queries**, **Postgres replication lag**, or **pg_stat errors**. This guide walks through diagnosis of common Azure Database for PostgreSQL Flexible Server issues.

## Steps

### 1. Check connection health

Run `az postgres flexible-server show` to verify the server is in `Ready` state. If the state is `Updating` or `Stopped`, report this as the root cause.

### 2. Review active connections

Query `pg_stat_activity` via the Kusto tool or az CLI to count active connections. Compare against `max_connections` server parameter. If utilization > 80%, recommend connection pooling.

### 3. Identify slow queries

Check the `pg_stat_statements` view for queries with high `mean_exec_time`. Focus on queries exceeding 1 second average. Report the top 3 slow queries.

### 4. Check replication lag

For read replicas, query `pg_stat_replication` on the primary. Lag > 10 seconds indicates a problem. Check write throughput and network latency between primary and replica.

### 5. Review recent changes

Check the Azure Activity Log for recent configuration changes (parameter updates, firewall rule changes, SKU changes) in the last 24 hours that may correlate with the issue.

## Tools

- `RunAzCliReadCommands` — for server status and configuration checks
- `GetRecentDbErrors` (Kusto tool) — for querying error telemetry

## Runbooks

- [Azure Database for PostgreSQL troubleshooting](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-troubleshooting-guides)
- [Connection issues](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-troubleshoot-common-connection-issues)
