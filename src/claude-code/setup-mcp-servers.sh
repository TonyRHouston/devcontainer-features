#!/bin/sh
# Setup MCP servers for Claude Code
# This script runs on container start to configure MCP servers

set -e

# Only run if claude CLI is available
if ! command -v claude >/dev/null 2>&1; then
    echo "Claude CLI not found, skipping MCP server setup"
    exit 0
fi

# Setup Splunk MCP server (requires kubectl for cluster context)
if command -v kubectl >/dev/null 2>&1; then
    CLUSTER_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "")
    if [ -n "$CLUSTER_CONTEXT" ]; then
        SPLUNK_URL="http://internal-mcp-splunk.default.svc.${CLUSTER_CONTEXT}.local:3000/mcp"
        echo "Adding Splunk MCP server for cluster: $CLUSTER_CONTEXT"
        claude mcp add --transport http splunk "$SPLUNK_URL" 2>/dev/null || true
    else
        echo "No kubectl context found, skipping Splunk MCP server setup"
    fi
else
    echo "kubectl not found, skipping Splunk MCP server setup"
fi

echo "MCP server setup complete"
