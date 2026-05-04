#!/usr/bin/env python3
"""
Azure SRE Agent — stdio MCP Server (Python 3.12)

A minimal Model Context Protocol server that communicates over stdio.
Runs inside the SRE Agent container (Python 3.12, no Docker).

Protocol: JSON-RPC 2.0 over stdin/stdout
Logging: stderr only (stdout is reserved for protocol messages)
"""

import json
import sys
from datetime import datetime, timedelta, timezone

# ---------------------------------------------------------------------------
# Tool definitions
# ---------------------------------------------------------------------------

TOOLS = [
    {
        "name": "get_service_health",
        "description": "Returns health status for a named service.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "service_name": {
                    "type": "string",
                    "description": "Name of the service to check",
                }
            },
            "required": ["service_name"],
        },
    },
    {
        "name": "list_recent_deployments",
        "description": "Lists deployments in the last N hours.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "hours": {
                    "type": "number",
                    "description": "Lookback window in hours",
                    "default": 24,
                }
            },
        },
    },
    {
        "name": "get_runbook_link",
        "description": "Returns a direct link to the runbook for a service.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "service_name": {
                    "type": "string",
                    "description": "Name of the service",
                }
            },
            "required": ["service_name"],
        },
    },
]

# ---------------------------------------------------------------------------
# Tool implementations
# ---------------------------------------------------------------------------


def get_service_health(arguments: dict) -> dict:
    name = arguments.get("service_name", "unknown")
    return {
        "service": name,
        "status": "healthy",
        "uptime_percent": 99.95,
        "last_check": datetime.now(timezone.utc).isoformat(),
        "open_incidents": 0,
    }


def list_recent_deployments(arguments: dict) -> dict:
    hours = arguments.get("hours", 24)
    now = datetime.now(timezone.utc)
    return {
        "lookback_hours": hours,
        "deployments": [
            {
                "id": "deploy-001",
                "service": "api-gateway",
                "timestamp": (now - timedelta(hours=1)).isoformat(),
                "status": "succeeded",
                "version": "2.4.1",
            },
            {
                "id": "deploy-002",
                "service": "worker-service",
                "timestamp": (now - timedelta(hours=2)).isoformat(),
                "status": "succeeded",
                "version": "1.8.0",
            },
        ],
    }


def get_runbook_link(arguments: dict) -> dict:
    name = arguments.get("service_name", "unknown")
    slug = name.replace(" ", "-").lower()
    return {
        "service": name,
        "runbook_url": f"https://wiki.example.com/runbooks/{slug}",
        "last_updated": "2026-04-15T10:00:00Z",
    }


TOOL_HANDLERS = {
    "get_service_health": get_service_health,
    "list_recent_deployments": list_recent_deployments,
    "get_runbook_link": get_runbook_link,
}

# ---------------------------------------------------------------------------
# JSON-RPC handler
# ---------------------------------------------------------------------------


def handle_request(request: dict) -> dict | None:
    req_id = request.get("id")
    method = request.get("method", "")
    params = request.get("params", {})

    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {"listChanged": False}},
                "serverInfo": {"name": "sre-mcp-server-python", "version": "1.0.0"},
            },
        }

    if method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {"tools": TOOLS},
        }

    if method == "tools/call":
        tool_name = params.get("name", "")
        handler = TOOL_HANDLERS.get(tool_name)
        if not handler:
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32601, "message": f"Unknown tool: {tool_name}"},
            }
        try:
            result = handler(params.get("arguments", {}))
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "content": [
                        {"type": "text", "text": json.dumps(result, indent=2)}
                    ]
                },
            }
        except Exception as exc:
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32000, "message": str(exc)},
            }

    if method == "notifications/initialized":
        return None  # Notification — no response

    return {
        "jsonrpc": "2.0",
        "id": req_id,
        "error": {"code": -32601, "message": f"Method not found: {method}"},
    }


# ---------------------------------------------------------------------------
# stdio transport
# ---------------------------------------------------------------------------


def main() -> None:
    print("SRE MCP Server started (stdio transport, Python 3.12)", file=sys.stderr)
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            request = json.loads(line)
        except json.JSONDecodeError:
            print(f"Invalid JSON: {line}", file=sys.stderr)
            continue

        response = handle_request(request)
        if response is not None:
            sys.stdout.write(json.dumps(response) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
