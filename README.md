# LLM Fine-Tuning with Axolotl - Pod Deployment

**Interactive LLM fine-tuning environment using Axolotl on RunPod Pods**

This repository provides a Pod-based deployment for LLM fine-tuning using [Axolotl](https://github.com/axolotl-ai-cloud/axolotl). It's designed for interactive development, experimentation, and debugging.

## 🎯 Purpose

This is the **Pod deployment** version of the LLM fine-tuning infrastructure. For serverless/API-based deployments, see the main [llm-fine-tuning](https://github.com/runpod-workers/llm-fine-tuning) repository.

## 🚀 Quick Start

### Deploy as RunPod Pod

1. **Use the pre-built image**: `runpod/llm-finetuning:latest`
2. **Set environment variables** for your training configuration:

```bash
# Required
export HF_TOKEN="your-huggingface-token"
export WANDB_API_KEY="your-wandb-key"

# Training Configuration (examples)
export AXOLOTL_BASE_MODEL="TinyLlama/TinyLlama_v1.1"
export AXOLOTL_DATASETS='[{"path":"mhenrichsen/alpaca_2k_test","type":"alpaca"}]'
export AXOLOTL_OUTPUT_DIR="./outputs/my_training"
export AXOLOTL_ADAPTER="lora"
export AXOLOTL_LORA_R="8"
export AXOLOTL_LORA_ALPHA="16"
export AXOLOTL_NUM_EPOCHS="1"
```

3. **Start training**:

```bash
# The autorun.sh script will automatically configure and start training
# Or manually run:
axolotl train config.yaml
```

4. **Optional - Start vLLM server** (after training):

```bash
# Create your vLLM config based on the example
cp vllm_config_example.yaml my_vllm_config.yaml
# Edit my_vllm_config.yaml with your trained model path and settings
./start_vllm.sh my_vllm_config.yaml
```

## 🏗️ Local Development

### Build and Test Locally

```bash
# Build the container
docker build -t llm-finetuning-pod .

# Run with test configuration
docker run -it --gpus all \
  -e HF_TOKEN="your-token" \
  -e WANDB_API_KEY="your-key" \
  -e AXOLOTL_BASE_MODEL="TinyLlama/TinyLlama_v1.1" \
  -e AXOLOTL_DATASETS='[{"path":"mhenrichsen/alpaca_2k_test","type":"alpaca"}]' \
  llm-finetuning-pod
```

### Using the Makefile

```bash
# Set up local development environment
make setup

# Install dependencies
make install

# Test the autorun script
make test
```

## ⚙️ Configuration

Configuration is done entirely through environment variables prefixed with `AXOLOTL_`:

### Required Variables

- `HF_TOKEN`: HuggingFace access token
- `WANDB_API_KEY`: Weights & Biases API key

### Common Configuration Examples

#### Basic LoRA Training

```bash
export AXOLOTL_BASE_MODEL="NousResearch/Llama-3.2-1B"
export AXOLOTL_DATASETS='[{"path":"teknium/GPT4-LLM-Cleaned","type":"alpaca"}]'
export AXOLOTL_ADAPTER="lora"
export AXOLOTL_LORA_R="16"
export AXOLOTL_LORA_ALPHA="32"
export AXOLOTL_NUM_EPOCHS="1"
export AXOLOTL_MICRO_BATCH_SIZE="2"
export AXOLOTL_GRADIENT_ACCUMULATION_STEPS="2"
```

#### Memory-Optimized Settings

```bash
export AXOLOTL_LOAD_IN_8BIT="true"
export AXOLOTL_GRADIENT_CHECKPOINTING="true"
export AXOLOTL_MICRO_BATCH_SIZE="1"
export AXOLOTL_GRADIENT_ACCUMULATION_STEPS="8"
```

#### Full Fine-Tuning

```bash
export AXOLOTL_BASE_MODEL="microsoft/DialoGPT-small"
# Don't set AXOLOTL_ADAPTER for full fine-tuning
export AXOLOTL_LEARNING_RATE="0.00001"
export AXOLOTL_WARMUP_STEPS="100"
```

## 📁 Repository Structure

```
llm-finetuning-axolotl/
├── Dockerfile              # Container definition
├── requirements.txt        # Python dependencies
└── scripts/                # Initialization scripts
    ├── autorun.sh          # Main startup script
    ├── configure.py        # Environment-to-YAML converter
    ├── config_template.yaml # Base configuration template
    ├── start_vllm.sh       # vLLM server startup script
    ├── vllm_config_example.yaml # vLLM configuration example
    └── WELCOME             # Welcome message
```

## 🔄 How It Works

1. **Container starts** → `autorun.sh` is executed
2. **Environment check** → Validates required tokens
3. **Configuration generation** → `configure.py` converts env vars to `config.yaml`
4. **Training starts** → `axolotl train config.yaml`

## 🚀 vLLM Inference Server

After training, you can serve your model using the built-in vLLM server:

### Quick Start vLLM

```bash
# 1. Copy and customize the example config
cp vllm_config_example.yaml my_vllm_config.yaml
# 2. Edit my_vllm_config.yaml with your trained model path and settings
# 3. Start vLLM with your config
./start_vllm.sh my_vllm_config.yaml
```

### vLLM Features

- **OpenAI-compatible API** at `http://localhost:8000`
- **Automatic LoRA support** for trained adapters
- **Optimized inference** with Flash Attention ≤ 2.8.0
- **GPU memory management** with configurable utilization
- **Not started automatically** - run when needed

### YAML Configuration

The `vllm_config_example.yaml` provides a template with common settings:

```yaml
# Model and performance
model: ./outputs/my-model
max_model_len: 32768
gpu_memory_utilization: 0.95

# Server settings
port: 8000
host: 0.0.0.0
served_model_name: my-model
# LoRA support (if needed)
# lora_modules:
#   - name: lora_adapter
#     path: ./outputs/lora-out
```

### API Usage

```bash
# Test the server
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "your-model",
    "prompt": "Hello, how are you?",
    "max_tokens": 100
  }'
```

## 🤝 Development Workflow

1. **Set environment variables** for your experiment
2. **Deploy pod** or run locally
3. **Monitor training** via Weights & Biases
4. **Iterate** by updating environment variables and restarting

## 📚 Documentation

- **[Development Conventions](docs/conventions.md)** - Development guide and best practices
- **[Axolotl Documentation](https://axolotl-ai-cloud.github.io/axolotl/docs/config.html)** - Complete configuration reference

## 🔧 Troubleshooting

### Common Issues

#### Environment Variables Not Loading

```bash
# Check if variables are set
env | grep AXOLOTL_

# Restart the container if variables were added after startup
```

#### Memory Issues

```bash
export AXOLOTL_LOAD_IN_8BIT="true"
export AXOLOTL_GRADIENT_CHECKPOINTING="true"
export AXOLOTL_MICRO_BATCH_SIZE="1"
```

#### Authentication Issues

```bash
# Verify tokens
echo $HF_TOKEN
echo $WANDB_API_KEY

# Test HuggingFace login
huggingface-cli whoami
```

## 🏷️ Available Images

| Tag                             | Description           | Use Case             |
| ------------------------------- | --------------------- | -------------------- |
| `runpod/llm-finetuning:latest`  | Latest stable release | Production pods      |
| `runpod/llm-finetuning:dev`     | Development build     | Testing new features |
| `runpod/llm-finetuning:preview` | Preview release       | Early access         |

---

> 💡 **Tip**: For API-driven serverless deployments, check out the main [llm-fine-tuning](https://github.com/runpod-workers/llm-fine-tuning) repository.
