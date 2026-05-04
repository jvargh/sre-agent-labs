#!/usr/bin/env python3
"""
Azure SRE Agent REST API v2 Client.

Wraps PUT /api/v2/extendedAgent/agents/{agentName} for managing
custom agents + hooks as YAML. Supports export, put, and diff operations.

Usage:
    python sre_agent_client.py export --agent-name incident_triager --output ./agent.yaml
    python sre_agent_client.py put --agent-name incident_triager --yaml-path ./agent.yaml
    python sre_agent_client.py diff --agent-name incident_triager --yaml-path ./agent.yaml

Reference: https://sre.azure.com/docs/tutorials/agent-config/agent-hooks
"""

import argparse
import json
import os
import sys
from difflib import unified_diff
from pathlib import Path

try:
    from azure.identity import DefaultAzureCredential
except ImportError:
    sys.exit("Install azure-identity: pip install azure-identity")

try:
    import requests
except ImportError:
    sys.exit("Install requests: pip install requests")

try:
    import yaml
except ImportError:
    yaml = None  # YAML normalization optional; raw text diff used if unavailable


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_URL = os.environ.get("SRE_AGENT_API_URL", "")
SCOPE = "https://management.azure.com/.default"


def get_token() -> str:
    """Acquire a bearer token using DefaultAzureCredential."""
    credential = DefaultAzureCredential()
    token = credential.get_token(SCOPE)
    return token.token


def agent_url(agent_name: str) -> str:
    """Build the full API URL for an agent."""
    if not BASE_URL:
        sys.exit("Set SRE_AGENT_API_URL environment variable.")
    return f"{BASE_URL.rstrip('/')}/api/v2/extendedAgent/agents/{agent_name}"


def headers() -> dict:
    """Build request headers with auth token."""
    return {
        "Authorization": f"Bearer {get_token()}",
        "Content-Type": "application/yaml",
        "Accept": "application/yaml",
    }


# ---------------------------------------------------------------------------
# Export
# ---------------------------------------------------------------------------

def cmd_export(args: argparse.Namespace) -> None:
    """GET the current agent config as YAML."""
    url = agent_url(args.agent_name)
    print(f"Exporting agent '{args.agent_name}' from {url} ...")
    resp = requests.get(url, headers=headers(), timeout=30)
    resp.raise_for_status()

    output_path = args.output or f"./{args.agent_name}.agent.yaml"
    Path(output_path).write_text(resp.text, encoding="utf-8")
    print(f"Exported to {output_path}")


# ---------------------------------------------------------------------------
# Put
# ---------------------------------------------------------------------------

def cmd_put(args: argparse.Namespace) -> None:
    """PUT the YAML config to create/update the agent."""
    yaml_path = Path(args.yaml_path)
    if not yaml_path.exists():
        sys.exit(f"File not found: {yaml_path}")

    url = agent_url(args.agent_name)
    body = yaml_path.read_text(encoding="utf-8")

    print(f"Pushing agent '{args.agent_name}' to {url} ...")
    resp = requests.put(url, headers=headers(), data=body, timeout=60)
    resp.raise_for_status()
    print(f"Push complete. Status: {resp.status_code}")
    if resp.text:
        print(resp.text)


# ---------------------------------------------------------------------------
# Diff
# ---------------------------------------------------------------------------

def cmd_diff(args: argparse.Namespace) -> None:
    """Compare local YAML against the running agent."""
    yaml_path = Path(args.yaml_path)
    if not yaml_path.exists():
        sys.exit(f"File not found: {yaml_path}")

    url = agent_url(args.agent_name)
    print(f"Fetching remote agent '{args.agent_name}' ...")
    resp = requests.get(url, headers=headers(), timeout=30)
    resp.raise_for_status()

    remote_text = resp.text
    local_text = yaml_path.read_text(encoding="utf-8")

    # Normalize if PyYAML is available for structural comparison
    if yaml:
        try:
            remote_normalized = yaml.dump(yaml.safe_load(remote_text), default_flow_style=False)
            local_normalized = yaml.dump(yaml.safe_load(local_text), default_flow_style=False)
        except yaml.YAMLError:
            remote_normalized = remote_text
            local_normalized = local_text
    else:
        remote_normalized = remote_text
        local_normalized = local_text

    if remote_normalized.strip() == local_normalized.strip():
        print("No drift detected.")
    else:
        print("Drift detected:")
        diff = unified_diff(
            remote_normalized.splitlines(keepends=True),
            local_normalized.splitlines(keepends=True),
            fromfile="remote",
            tofile="local",
        )
        sys.stdout.writelines(diff)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Azure SRE Agent REST API v2 Client"
    )
    sub = parser.add_subparsers(dest="command", required=True)

    # export
    p_export = sub.add_parser("export", help="Export agent config as YAML")
    p_export.add_argument("--agent-name", required=True)
    p_export.add_argument("--output", help="Output file path")

    # put
    p_put = sub.add_parser("put", help="Push YAML config to agent")
    p_put.add_argument("--agent-name", required=True)
    p_put.add_argument("--yaml-path", required=True)

    # diff
    p_diff = sub.add_parser("diff", help="Diff local YAML vs running agent")
    p_diff.add_argument("--agent-name", required=True)
    p_diff.add_argument("--yaml-path", required=True)

    args = parser.parse_args()

    dispatch = {"export": cmd_export, "put": cmd_put, "diff": cmd_diff}
    dispatch[args.command](args)


if __name__ == "__main__":
    main()
