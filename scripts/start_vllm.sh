#!/bin/bash
set -e

# vLLM Server Startup Script
# Usage: ./start_vllm.sh [config.yaml|model_path] [additional_args...]

show_usage() {
    echo "Usage: $0 [config.yaml|model_path] [additional_args...]"
    echo ""
    echo "Examples:"
    echo "  # Using YAML config file:"
    echo "  $0 vllm_config.yaml"
    echo ""
    echo "  # Using model path with args:"
    echo "  $0 ./outputs/lora-out --lora-modules lora_name=./outputs/lora-out"
    echo "  $0 NousResearch/Llama-3.2-1B --max-model-len 4096"
    echo "  $0 ./outputs/merged-model --port 8000"
    echo ""
    echo "YAML config example:"
    echo "  model: ./outputs/my-model"
    echo "  max_model_len: 32768"
    echo "  gpu_memory_utilization: 0.95"
    echo "  port: 8000"
    echo "  host: 0.0.0.0"
}

if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

INPUT="$1"
shift  # Remove first arg, keep the rest

# Check if input is a YAML file
if [[ "$INPUT" == *.yaml ]] || [[ "$INPUT" == *.yml ]]; then
    if [ ! -f "$INPUT" ]; then
        echo "❌ Config file not found: $INPUT"
        exit 1
    fi
    
    echo "🚀 Starting vLLM server with config file..."
    echo "📄 Config: $INPUT"
    
    # Extract key info from YAML for display
    if command -v python3 >/dev/null 2>&1; then
        MODEL=$(python3 -c "
import yaml
try:
    with open('$INPUT', 'r') as f:
        config = yaml.safe_load(f)
    print(config.get('model', 'Not specified'))
except:
    print('Could not parse config')
" 2>/dev/null || echo "Could not parse config")
        
        PORT=$(python3 -c "
import yaml
try:
    with open('$INPUT', 'r') as f:
        config = yaml.safe_load(f)
    print(config.get('port', 8000))
except:
    print('8000')
" 2>/dev/null || echo "8000")
        
        HOST=$(python3 -c "
import yaml
try:
    with open('$INPUT', 'r') as f:
        config = yaml.safe_load(f)
    print(config.get('host', '0.0.0.0'))
except:
    print('0.0.0.0')
" 2>/dev/null || echo "0.0.0.0")
        
        echo "📁 Model: $MODEL"
        echo "🌐 Server will be available at: http://$HOST:$PORT"
    fi
    echo "🔧 Additional args: $*"
    echo ""
    
    # Start vLLM with config file
    python -m vllm.entrypoints.openai.api_server \
        --config "$INPUT" \
        "$@"
        
else
    # Treat as model path (legacy mode)
    MODEL_PATH="$INPUT"
    
    echo "🚀 Starting vLLM server..."
    echo "📁 Model: $MODEL_PATH"
    echo "🔧 Additional args: $*"
    echo "🌐 Server will be available at: http://0.0.0.0:8000"
    echo ""
    
    # Start vLLM with the provided model and any additional arguments
    python -m vllm.entrypoints.openai.api_server \
        --model "$MODEL_PATH" \
        --host 0.0.0.0 \
        --port 8000 \
        "$@"
fi
