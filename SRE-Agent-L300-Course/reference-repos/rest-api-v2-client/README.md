# REST API v2 Client Reference (D6)

PowerShell + Python clients for the Azure SRE Agent REST API v2 endpoint.

## Overview

These clients wrap the `PUT /api/v2/extendedAgent/agents/{agentName}` endpoint, enabling:

- **Export** current custom agent + hooks configuration as YAML
- **Push** (PUT) a YAML bundle to create or update a custom agent with hooks
- **Diff** local YAML against the running agent to detect drift

## Endpoint

```
PUT /api/v2/extendedAgent/agents/{agentName}
```

## Clients

| Language | File | Usage |
|----------|------|-------|
| PowerShell | `powershell/Invoke-SREAgentApi.ps1` | `./Invoke-SREAgentApi.ps1 -Action Put -AgentName "my-agent" -YamlPath ./agent.yaml` |
| Python | `python/sre_agent_client.py` | `python sre_agent_client.py put --agent-name my-agent --yaml-path ./agent.yaml` |

## Authentication

Both clients support:
1. **Managed Identity** (default in CI/CD)
2. **Azure CLI token** (`az account get-access-token`)
3. **Service Principal** (client ID + secret or certificate)

## Round-Trip Test

Verify zero-drift after export → push:

```bash
# Export
python sre_agent_client.py export --agent-name incident_triager --output incident-triager.yaml

# Push (no changes)
python sre_agent_client.py put --agent-name incident_triager --yaml-path incident-triager.yaml

# Diff
python sre_agent_client.py diff --agent-name incident_triager --yaml-path incident-triager.yaml
# Expected output: No drift detected.
```

## Hook YAML Structure

The YAML bundle includes the hook structure (Stop + PostToolUse, prompt + command):

```yaml
name: incident_triager
system_prompt: |
  ...
hooks:
  Stop:
    - type: prompt
      model: ReasoningFast
      prompt: |
        ...
  PostToolUse:
    - type: command
      matcher: "Bash|ExecuteShellCommand|RunAzCliWriteCommands"
      timeout: 30
      failMode: block
      script: |
        ...
```

## References

- [Agent Hooks API](https://sre.azure.com/docs/tutorials/agent-config/agent-hooks)
- [Create/Manage Hooks (UI)](https://sre.azure.com/docs/tutorials/agent-config/create-manage-hooks-ui)
- [Lab 9 Guide](../../labs/lab-09-agent-hooks/README.md)
- [Lab 12 Guide](../../labs/lab-12-config-as-code/README.md)
