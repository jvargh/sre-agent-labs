# Agent-as-Code Reference Repo (D5)

Infrastructure as Code for Azure SRE Agent — Bicep + Terraform variants producing identical resource sets.

## Overview

This reference repo provides two IaC implementations that deploy the same Azure SRE Agent resource set:

| Variant | File | Language |
|---------|------|----------|
| Bicep | `bicep/main.bicep` | Azure Bicep |
| Terraform | `terraform/main.tf` | Terraform (AzureRM + AzAPI) |

## Resource Set

Both variants create:

| Resource | Type |
|----------|------|
| SRE Agent | `Microsoft.AzureSREAgent/agents` |
| User-Assigned Managed Identity (UAMI) | `Microsoft.ManagedIdentity/userAssignedIdentities` |
| Application Insights | `Microsoft.Insights/components` |
| Log Analytics Workspace | `Microsoft.OperationalInsights/workspaces` |
| Role Assignments | Per the M1 promotion-playbook matrix |

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `agentName` | (required) | Name of the SRE Agent resource |
| `location` | `eastus` | Azure region |
| `modelProvider` | `Anthropic` | Model provider: `Anthropic` or `AzureOpenAI` (EUDB) |
| `environment` | `workshop` | Environment tag |

## Verification

Both variants produce identical Azure resource sets. Verify with:

```bash
# Deploy Bicep
az deployment group create --resource-group <rg> --template-file bicep/main.bicep --parameters agentName=<name>

# Deploy Terraform
cd terraform && terraform init && terraform apply -var="agent_name=<name>"

# Compare: what-if on Bicep against Terraform-deployed RG should show no changes
az deployment group what-if --resource-group <rg> --template-file bicep/main.bicep --parameters agentName=<name>
```

## Provider Note

The resource provider name `Microsoft.AzureSREAgent/agents` is current as of the build date. Check [sre.azure.com/docs](https://sre.azure.com/docs) for the latest GA RP name. If it has changed, file a `srea-doc-drift` issue.

The `modelProvider` parameter defaults to `Anthropic`. For EUDB compliance, set to `AzureOpenAI`.

## References

- [REST API v2](https://sre.azure.com/docs/tutorials/agent-config/agent-hooks)
- [Agent Identity](https://sre.azure.com/docs/concepts/agent-identity)
- [M12 Lab Guide](../../labs/module-M12-config-as-code/README.md)
