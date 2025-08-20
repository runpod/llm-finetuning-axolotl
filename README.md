# LLM Fine-Tuning with Axolotl - Pod Deployment

Pod-based LLM fine-tuning using [Axolotl](https://github.com/axolotl-ai-cloud/axolotl) on RunPod.

> **Serverless Version**: See [llm-fine-tuning](https://github.com/runpod-workers/llm-fine-tuning) for API-based deployments.

## 🚀 Quick Start

**Image**: `runpod/llm-finetuning:latest`

### Required Environment Variables

```bash
HF_TOKEN=your-huggingface-token
WANDB_API_KEY=your-wandb-key

# Training config (examples)
AXOLOTL_BASE_MODEL=TinyLlama/TinyLlama_v1.1
AXOLOTL_DATASETS=[{"path":"mhenrichsen/alpaca_2k_test","type":"alpaca"}]
AXOLOTL_ADAPTER=lora
```

### ⚠️ Critical: Volume Mounting

```bash
# ❌ NEVER mount to /workspace - overwrites everything!
# ✅ Mount to /workspace/data only
```

### Training

```bash
# Training starts automatically, or manually:
axolotl train config.yaml
```

### Inference (after training)

```bash
# Create vLLM config from example
cp vllm_config_example.yaml my_config.yaml
# Edit with your model path
./start_vllm.sh my_config.yaml
```

## 🏗️ Local Development

```bash
# Build and test
docker build -t llm-finetuning-pod .
docker-compose up
```

## 📚 Documentation

- **[Development Conventions](docs/conventions.md)** - Development guide and best practices
- **[Axolotl Documentation](https://axolotl-ai-cloud.github.io/axolotl/docs/config.html)** - Complete configuration reference

## 🔧 Troubleshooting

### Volume Mount Issues

```bash
# Symptoms: "No such file or directory" errors, infinite loops
# Cause: Mounting to /workspace overwrites container structure
# Solution: Mount to /workspace/data/ subdirectories only
```

### Environment Variables Not Loading

```bash
# Variables must be set before container starts
env | grep AXOLOTL_
```

### Authentication Issues

```bash
echo $HF_TOKEN
echo $WANDB_API_KEY
```

## 🏷️ Available Images

| Tag                            | Description           | Use Case             |
| ------------------------------ | --------------------- | -------------------- |
| `runpod/llm-finetuning:latest` | Latest stable release | Production pods      |
| `runpod/llm-finetuning:dev`    | Development build     | Testing new features |

---

> 💡 **Tip**: For API-driven serverless deployments, check out the main [llm-fine-tuning](https://github.com/runpod-workers/llm-fine-tuning) repository.
