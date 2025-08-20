#!/bin/bash
set -e

# vLLM Server Startup Script
# Usage: ./start_vllm.sh config.yaml [additional_args...]

if [ $# -eq 0 ]; then
    echo "Usage: $0 config.yaml [additional_args...]"
    echo ""
    echo "Example:"
    echo "  $0 vllm_config.yaml"
    exit 1
fi

CONFIG_FILE="$1"
shift  # Remove config file from args, keep additional args

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

echo "🚀 Starting vLLM server..."
echo "📄 Config: $CONFIG_FILE"
echo "🔧 Additional args: $*"
echo ""

# Start vLLM with config file (using dedicated venv)
/opt/vllm-venv/bin/vllm serve --config "$CONFIG_FILE" "$@"
