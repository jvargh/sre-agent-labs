# M7 — MCP Integrations II: Troubleshooting

## Common Issues

### Streamable-HTTP Connector Shows "Connection Failed"

- **Cause:** Incorrect endpoint URL, expired API key, or network egress blocked.
- **Fix:** Verify URL has no trailing slash. Regenerate the API key from the partner platform. Check NSG rules on the agent's VNET.

### stdio Server Crashes on Startup

- **Cause:** Missing `bin` entry in the npx package, or incompatible Node version.
- **Fix:** Verify the package is published with a valid `bin` field. Confirm the agent runtime is Node 20 — other versions are not supported.

### Capacity Bar Does Not Appear

- **Cause:** You are viewing the connector overview, not the tool-selection pane.
- **Fix:** Click into the connector → **Select tools** step.

### YAML Wildcard Expansion Fails

- **Cause:** Connector name mismatch or missing `/` separator.
- **Fix:** Verify the connector name in YAML matches exactly (case-sensitive). Use the format `connector-name/*` or `connector-name/specific_tool`.

### Plugin Marketplace Shows "Coming Soon"

- **Cause:** Expected behavior for some tenants at v1.
- **Fix:** No action needed — this is a click-through-only exercise. File a doc-update issue if a public install button appears before workshop go-live.

### Auto-Recovery Does Not Trigger

- **Cause:** The agent may not auto-restart stdio servers in all failure modes.
- **Fix:** Manually toggle the connector off and on. If persistent, recreate the connector.

## Escalation

If issues persist after trying the above fixes, escalate to the trainer with:
1. Connector name and type (Streamable-HTTP or stdio)
2. Error message from the connector detail pane
3. Screenshot of the capacity bar state
