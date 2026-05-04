# M8 — Python Tools: Troubleshooting

## Common Issues

### AI Generation Produces Incorrect Code

- **Cause:** Ambiguous description.
- **Fix:** Be specific in the description. Edit the generated code manually if needed. The function must be named `main` and return a `dict`.

### Tool Test Fails with Timeout

- **Cause:** Default timeout is 120 s; complex operations may exceed this.
- **Fix:** Increase timeout in the tool settings (max 900 s). If the function is genuinely slow, optimize the code.

### ImportError for a Package

- **Cause:** The package is not in the 700+ preinstalled set.
- **Fix:** Check the preinstalled package list in the docs. Use only available packages. Common packages: `pandas`, `requests`, `azure-identity`, `reportlab`, `numpy`, `scipy`.

### ManagedIdentityCredential Raises CredentialUnavailableError

- **Cause:** Managed-identity scope not enabled on the tool's Identity tab.
- **Fix:** Open the tool → Identity tab → enable managed-identity scope. Verify the agent's UAMI has the required role assignments.

### Tool Does Not Appear in Custom Agent Tool Picker

- **Cause:** Tool is not in `Active` state.
- **Fix:** Check the tool's status in Builder → Tools. If it shows `Draft` or `Error`, fix and re-activate.

### HTTP Wrapper Returns ConnectionError

- **Cause:** Endpoint unreachable from the agent container.
- **Fix:** Verify the URL. If the API is behind a VNET/private endpoint, ensure the agent's egress rules allow it. Outbound network is enabled by default.

### Function Returns Non-Serializable Type

- **Cause:** The `main()` function returns an object that cannot be JSON-serialized (e.g., datetime, custom class).
- **Fix:** Convert all return values to JSON-serializable types (str, int, float, bool, list, dict, None).

## Escalation

If issues persist, escalate to the trainer with:
1. Tool name and authoring path (AI-generated / BYO / HTTP wrapper)
2. Error message from the test pane
3. The Python code (sanitize any secrets)
