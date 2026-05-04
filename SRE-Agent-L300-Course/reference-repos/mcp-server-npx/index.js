#!/usr/bin/env node
/**
 * Azure SRE Agent — stdio MCP Server (Node.js)
 *
 * A minimal Model Context Protocol server that communicates over stdio.
 * Runs inside the SRE Agent container (Node 20, no Docker).
 *
 * Protocol: JSON-RPC 2.0 over stdin/stdout
 * Logging: stderr only (stdout is reserved for protocol messages)
 */

"use strict";

const readline = require("readline");

// ---------------------------------------------------------------------------
// Tool definitions
// ---------------------------------------------------------------------------

const TOOLS = {
  get_service_health: {
    description: "Returns health status for a named service.",
    inputSchema: {
      type: "object",
      properties: {
        service_name: { type: "string", description: "Name of the service to check" },
      },
      required: ["service_name"],
    },
  },
  list_recent_deployments: {
    description: "Lists deployments in the last N hours.",
    inputSchema: {
      type: "object",
      properties: {
        hours: { type: "number", description: "Lookback window in hours", default: 24 },
      },
    },
  },
  get_runbook_link: {
    description: "Returns a direct link to the runbook for a service.",
    inputSchema: {
      type: "object",
      properties: {
        service_name: { type: "string", description: "Name of the service" },
      },
      required: ["service_name"],
    },
  },
};

// ---------------------------------------------------------------------------
// Tool implementations
// ---------------------------------------------------------------------------

function getServiceHealth(params) {
  const name = params.service_name || "unknown";
  return {
    service: name,
    status: "healthy",
    uptime_percent: 99.95,
    last_check: new Date().toISOString(),
    open_incidents: 0,
  };
}

function listRecentDeployments(params) {
  const hours = params.hours || 24;
  return {
    lookback_hours: hours,
    deployments: [
      {
        id: "deploy-001",
        service: "api-gateway",
        timestamp: new Date(Date.now() - 3600000).toISOString(),
        status: "succeeded",
        version: "2.4.1",
      },
      {
        id: "deploy-002",
        service: "worker-service",
        timestamp: new Date(Date.now() - 7200000).toISOString(),
        status: "succeeded",
        version: "1.8.0",
      },
    ],
  };
}

function getRunbookLink(params) {
  const name = params.service_name || "unknown";
  return {
    service: name,
    runbook_url: `https://wiki.example.com/runbooks/${name.replace(/\s+/g, "-").toLowerCase()}`,
    last_updated: "2026-04-15T10:00:00Z",
  };
}

const TOOL_HANDLERS = {
  get_service_health: getServiceHealth,
  list_recent_deployments: listRecentDeployments,
  get_runbook_link: getRunbookLink,
};

// ---------------------------------------------------------------------------
// JSON-RPC handler
// ---------------------------------------------------------------------------

function handleRequest(request) {
  const { id, method, params } = request;

  switch (method) {
    case "initialize":
      return {
        jsonrpc: "2.0",
        id,
        result: {
          protocolVersion: "2024-11-05",
          capabilities: { tools: { listChanged: false } },
          serverInfo: { name: "sre-mcp-server", version: "1.0.0" },
        },
      };

    case "tools/list":
      return {
        jsonrpc: "2.0",
        id,
        result: {
          tools: Object.entries(TOOLS).map(([name, def]) => ({
            name,
            description: def.description,
            inputSchema: def.inputSchema,
          })),
        },
      };

    case "tools/call": {
      const toolName = params?.name;
      const handler = TOOL_HANDLERS[toolName];
      if (!handler) {
        return {
          jsonrpc: "2.0",
          id,
          error: { code: -32601, message: `Unknown tool: ${toolName}` },
        };
      }
      try {
        const result = handler(params?.arguments || {});
        return {
          jsonrpc: "2.0",
          id,
          result: {
            content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
          },
        };
      } catch (err) {
        return {
          jsonrpc: "2.0",
          id,
          error: { code: -32000, message: err.message },
        };
      }
    }

    case "notifications/initialized":
      // Notification — no response needed
      return null;

    default:
      return {
        jsonrpc: "2.0",
        id,
        error: { code: -32601, message: `Method not found: ${method}` },
      };
  }
}

// ---------------------------------------------------------------------------
// stdio transport
// ---------------------------------------------------------------------------

const rl = readline.createInterface({ input: process.stdin, terminal: false });
let buffer = "";

rl.on("line", (line) => {
  buffer += line;
  try {
    const request = JSON.parse(buffer);
    buffer = "";
    const response = handleRequest(request);
    if (response) {
      process.stdout.write(JSON.stringify(response) + "\n");
    }
  } catch {
    // Incomplete JSON — continue buffering
  }
});

process.stderr.write("SRE MCP Server started (stdio transport, Node 20)\n");
