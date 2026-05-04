# Python stdio MCP Server Reference (D8)

A minimal stdio MCP server implemented in Python 3.12 for the Azure SRE Agent container.

## Runtime Constraints

| Constraint | Value |
|-----------|-------|
| Runtime | Python 3.12 |
| Transport | stdio (stdin/stdout) |
| Docker | **Not available** |
| Container | Runs inside the agent container |

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally for testing
python server.py

# In the SRE Agent portal, configure as stdio connector:
#   Command: python3
#   Args: ["/path/to/server.py"]
```

## MCP Protocol

This server implements the [Model Context Protocol](https://modelcontextprotocol.io/) over stdio:
- Reads JSON-RPC messages from stdin (one per line)
- Writes JSON-RPC responses to stdout
- Logs to stderr (stdout is reserved for protocol messages)

## Tools Provided

| Tool | Description |
|------|-------------|
| `get_service_health` | Returns health status for a named service |
| `list_recent_deployments` | Lists deployments in the last N hours |
| `get_runbook_link` | Returns a direct link to the runbook for a service |

## Usage in M7

1. Copy `server.py` and `requirements.txt` to the agent environment
2. Add as a stdio connector in the SRE Agent portal
3. Select tools in the capacity bar exercise
4. Test health monitoring drill (disconnect → auto-recovery)

## References

- [MCP Connectors & Tools](https://sre.azure.com/docs/capabilities/mcp-connectors)
- [Setup MCP Connector](https://sre.azure.com/docs/tutorials/connectors/setup-mcp-connector)
- [M7 Lab Guide](../../labs/module-M7-mcp-integrations/README.md)
