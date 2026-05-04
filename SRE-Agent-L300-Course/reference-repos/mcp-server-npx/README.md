# npx-Based stdio MCP Server Reference (D8)

A minimal stdio MCP server that runs inside the Azure SRE Agent container via `npx`.

## Runtime Constraints

| Constraint | Value |
|-----------|-------|
| Runtime | Node 20 |
| Transport | stdio (stdin/stdout) |
| Docker | **Not available** |
| Container | Runs inside the agent container |

## Quick Start

```bash
# Install dependencies
npm install

# Run locally for testing
node index.js

# In the SRE Agent portal, configure as stdio connector:
#   Command: npx
#   Args: ["@workshop/sre-mcp-server"]
```

## MCP Protocol

This server implements the [Model Context Protocol](https://modelcontextprotocol.io/) over stdio:
- Reads JSON-RPC messages from stdin
- Writes JSON-RPC responses to stdout
- Logs to stderr (stdout is reserved for protocol messages)

## Tools Provided

| Tool | Description |
|------|-------------|
| `get_service_health` | Returns health status for a named service |
| `list_recent_deployments` | Lists deployments in the last N hours |
| `get_runbook_link` | Returns a direct link to the runbook for a service |

## Usage in M7

1. Build and publish the package (or use locally via `npx --prefix .`)
2. Add as an stdio connector in the SRE Agent portal
3. Select tools in the capacity bar exercise
4. Test health monitoring drill (disconnect → auto-recovery)

## References

- [MCP Connectors & Tools](https://sre.azure.com/docs/capabilities/mcp-connectors)
- [Setup MCP Connector](https://sre.azure.com/docs/tutorials/connectors/setup-mcp-connector)
- [M7 Lab Guide](../../labs/module-M7-mcp-integrations/README.md)
