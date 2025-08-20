# LLM Fine-Tuning Pod Conventions

## 🎯 Project Overview

This repository provides an interactive Pod-based deployment for LLM fine-tuning using [Axolotl](https://github.com/axolotl-ai-cloud/axolotl) on RunPod. It's designed for development, experimentation, and debugging workflows where you need direct access to the training environment.

### Key Features

- Interactive pod-based deployment
- Environment variable-driven configuration
- Full fine-tuning, LoRA, and QLoRA support
- Support for LLaMA, Mistral, Gemma, and other popular model families
- Integration with Weights & Biases for experiment tracking
- HuggingFace Hub integration for model and dataset management

## 🏗️ Architecture

### Core Components

```
llm-finetuning-axolotl/
├── Dockerfile              # Pod container definition
├── requirements.txt        # Python dependencies
├── scripts/                # Pod initialization and configuration
│   ├── autorun.sh          # Main startup script
│   ├── configure.py        # Environment-to-YAML converter
│   ├── config_template.yaml # Base Axolotl configuration template
│   ├── start_vllm.sh       # vLLM server startup script
│   ├── vllm_config_example.yaml # vLLM configuration example
│   └── WELCOME             # User welcome message
├── docs/                   # Documentation
└── .github/workflows/      # CI/CD for pod image builds
```

### Deployment Pattern

**Pod Server Deployment**:

- **Purpose**: Persistent environments for development and experimentation
- **Container**: Built from root `Dockerfile`
- **Entry Point**: `scripts/autorun.sh`
- **Configuration**: Environment variables prefixed with `AXOLOTL_`
- **Use Cases**: Development, debugging, manual experimentation, interactive training

## 🛠️ Development Environment

### Prerequisites

- Docker with BuildKit support
- CUDA-compatible GPU (recommended: RTX 3090/4090 or higher)
- RunPod account (for deployment)

### Local Development Setup

1. **Build the pod image**:

```bash
docker build -t llm-finetuning-pod .
```

2. **Set up development environment**:

```bash
make setup  # Creates venv and installs dependencies
```

3. **Test locally**:

```bash
make test   # Runs autorun.sh with environment variables
```

### Environment Variables

#### Required for All Deployments

- `HF_TOKEN`: HuggingFace access token
- `WANDB_API_KEY`: Weights & Biases API key

#### Configuration Variables

- `AXOLOTL_*`: Any Axolotl configuration parameter prefixed with `AXOLOTL_`

## 🚀 Configuration Management

### Configuration System

1. **Environment Variables**: Set `AXOLOTL_*` prefixed variables
2. **Template Processing**: `configure.py` converts env vars to YAML
3. **Generated Config**: Creates `config.yaml` from `config_template.yaml`
4. **Training Execution**: `axolotl train config.yaml`

### Configuration Best Practices

#### 1. **Use Descriptive Environment Variable Names**

```bash
# Good - Clear and specific
export AXOLOTL_BASE_MODEL="NousResearch/Llama-3.2-1B"
export AXOLOTL_DATASETS='[{"path":"teknium/GPT4-LLM-Cleaned","type":"alpaca"}]'

# Avoid - Unclear or generic
export AXOLOTL_MODEL="model1"
export AXOLOTL_DATA="data"
```

#### 2. **Model-Specific Configurations**

```bash
# For LLaMA models
export AXOLOTL_IS_LLAMA_DERIVED_MODEL="true"
export AXOLOTL_LORA_TARGET_MODULES='["q_proj","v_proj","k_proj","o_proj","gate_proj","down_proj","up_proj"]'

# For Mistral models
export AXOLOTL_IS_MISTRAL_DERIVED_MODEL="true"
export AXOLOTL_LORA_TARGET_MODULES='["q_proj","v_proj"]'
```

#### 3. **Memory-Efficient Settings**

```bash
# For limited GPU memory
export AXOLOTL_LOAD_IN_8BIT="true"
export AXOLOTL_GRADIENT_CHECKPOINTING="true"
export AXOLOTL_MICRO_BATCH_SIZE="1"
export AXOLOTL_GRADIENT_ACCUMULATION_STEPS="8"
```

## 📁 Code Structure

### File Organization Rules

#### 1. **Scripts Directory** (`scripts/`)

- `autorun.sh`: Main startup script - handles pod initialization and training start
- `configure.py`: Environment-to-YAML configuration converter with validation
- `config_template.yaml`: Base Axolotl configuration template
- `WELCOME`: User-facing welcome message displayed on startup

#### 2. **Build Configuration**

- `Dockerfile`: Pod container definition
- `requirements.txt`: Python dependencies

### Code Style Guidelines

#### 1. **Shell Script Standards** (`autorun.sh`)

- Use `set -e` for error handling
- Provide clear echo messages for user feedback
- Check for required environment variables
- Handle both pod and local development scenarios

```bash
# Good
if [ -n "$HF_TOKEN" ]; then
    echo "🔑 Logging in to Hugging Face..."
    huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential
else
    echo "⚠️ Warning: HF_TOKEN is not set. Skipping Hugging Face login."
fi
```

#### 2. **Python Configuration Scripts** (`configure.py`)

- Use type hints and docstrings
- Validate environment variables before processing
- Provide clear error messages
- Handle JSON parsing for complex configurations

```python
# Good
def parse_env_value(value: str) -> Any:
    """Parse a string value that could be JSON into appropriate Python type."""
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return value
```

#### 3. **Configuration Templates** (`config_template.yaml`)

- Use descriptive base configurations
- Provide sensible defaults for development
- Include comments explaining complex options

## 🔄 Development Workflow

### 1. **Experiment Development**

```bash
# 1. Set up environment variables for experiment
export AXOLOTL_BASE_MODEL="TinyLlama/TinyLlama_v1.1"
export AXOLOTL_DATASETS='[{"path":"mhenrichsen/alpaca_2k_test","type":"alpaca"}]'
export AXOLOTL_ADAPTER="lora"

# 2. Test locally
make test

# 3. Deploy to pod
# 4. Monitor via W&B
# 5. Iterate by updating environment variables
```

### 2. **Testing Changes**

#### Local Testing

```bash
# Build and test locally
docker build -t test-pod .
docker run -it --gpus all \
  -e HF_TOKEN="$HF_TOKEN" \
  -e WANDB_API_KEY="$WANDB_API_KEY" \
  -e AXOLOTL_BASE_MODEL="TinyLlama/TinyLlama_v1.1" \
  test-pod
```

#### Pod Testing

```bash
# Deploy with environment variables set in pod configuration
# Monitor startup logs for configuration validation
# Check W&B for training progress
```

### 3. **Configuration Updates**

When adding new Axolotl configuration options:

1. **Update template**: Add to `scripts/config_template.yaml`
2. **Test locally**: Verify environment variable processing works
3. **Update documentation**: Add examples to README.md and this document
4. **Test deployment**: Verify in actual pod environment

## 🧪 Testing and Validation

### Pre-Deployment Checklist

#### 1. **Configuration Validation**

- [ ] Environment variables are properly prefixed with `AXOLOTL_`
- [ ] JSON configurations parse correctly
- [ ] Required variables have validation
- [ ] Template generates valid YAML

#### 2. **Container Testing**

- [ ] Dockerfile builds successfully
- [ ] All dependencies are installed
- [ ] Startup script executes without errors
- [ ] GPU access works correctly

#### 3. **Integration Testing**

- [ ] HuggingFace authentication works
- [ ] Weights & Biases logging functions
- [ ] Configuration generation works
- [ ] Training initiates successfully

### Common Test Scenarios

#### 1. **Minimal Configuration Test**

```bash
# Fastest possible training for validation
export AXOLOTL_BASE_MODEL="TinyLlama/TinyLlama_v1.1"
export AXOLOTL_DATASETS='[{"path":"mhenrichsen/alpaca_2k_test","type":"alpaca"}]'
export AXOLOTL_MICRO_BATCH_SIZE="1"
export AXOLOTL_NUM_EPOCHS="1"
export AXOLOTL_MAX_STEPS="5"
```

#### 2. **Memory Constraint Test**

```bash
# Test memory optimization features
export AXOLOTL_LOAD_IN_8BIT="true"
export AXOLOTL_GRADIENT_CHECKPOINTING="true"
export AXOLOTL_MICRO_BATCH_SIZE="1"
export AXOLOTL_GRADIENT_ACCUMULATION_STEPS="16"
```

## 🤝 Contribution Guidelines

### When to Update This Document

**Always update conventions.md when you**:

- Add new configuration options or environment variables
- Change the startup process or scripts
- Modify the container build process
- Add new dependencies
- Update the configuration template
- Change testing procedures

### Pull Request Requirements

1. **Code Changes**:

   - Test both local and pod deployments
   - Ensure environment variable processing works
   - Validate configuration generation

2. **Configuration Changes**:

   - Update `config_template.yaml`
   - Update README.md examples
   - Update this conventions document

3. **Documentation**:
   - Include examples for new features
   - Update troubleshooting section if applicable

## 🔧 Troubleshooting

### Critical RunPod Issue

#### ⚠️ **NEVER Mount Volumes to `/workspace`**

```bash
# ❌ WRONG - This will overwrite the entire Docker image structure
volumes:
  - ./data:/workspace

# ✅ CORRECT - Mount to subdirectories only
volumes:
  - ./data:/workspace/data/axolotl-artifacts
```

**Why**: RunPod volume mounts to `/workspace` will completely overwrite:

- `/workspace/axolotl/` (Axolotl installation)
- `/workspace/fine-tuning/` (Your scripts)
- All symlinks and directory structure

**Symptoms**:

- `ln: failed to create symbolic link '/workspace/axolotl/outputs': No such file or directory`
- `/root/cloud-entrypoint.sh: line 93: /workspace/fine-tuning/autorun.sh: No such file or directory`
- Infinite restart loop

**Solution**: Always mount to `/workspace/data/` or other subdirectories, never `/workspace` directly.

### Common Issues

#### 1. **Environment Variables Not Applied**

```bash
# Check if variables are set
env | grep AXOLOTL_

# Restart container if variables were added after startup
# Variables must be set before container starts
```

#### 2. **Configuration Generation Errors**

```bash
# Check configuration generation manually
python3 scripts/configure.py --template scripts/config_template.yaml --output debug_config.yaml

# Validate generated YAML
cat debug_config.yaml
```

#### 3. **Memory Issues**

```bash
# Enable memory optimizations
export AXOLOTL_LOAD_IN_8BIT="true"
export AXOLOTL_GRADIENT_CHECKPOINTING="true"
export AXOLOTL_MICRO_BATCH_SIZE="1"
export AXOLOTL_GRADIENT_ACCUMULATION_STEPS="8"
```

#### 4. **Authentication Failures**

```bash
# Verify environment variables
echo $HF_TOKEN
echo $WANDB_API_KEY

# Check HuggingFace login
huggingface-cli whoami
```

### Debug Mode

#### Container Debugging

```bash
# Enter running container
docker exec -it <container-id> /bin/bash

# Check startup logs
docker logs <container-id>

# Test configuration generation
cd scripts && python3 configure.py --template config_template.yaml --output debug_config.yaml
```

### Performance Optimization

#### GPU Utilization

- Monitor GPU memory usage during training
- Adjust `AXOLOTL_MICRO_BATCH_SIZE` and `AXOLOTL_GRADIENT_ACCUMULATION_STEPS`
- Enable `AXOLOTL_FLASH_ATTENTION="true"` for supported models

#### Training Speed

- Use `AXOLOTL_SAMPLE_PACKING="true"` for efficient sequence packing
- Enable `AXOLOTL_GRADIENT_CHECKPOINTING="true"` only if memory-constrained
- Consider `AXOLOTL_TORCH_COMPILE="true"` for PyTorch 2.0+ optimization

---

## 📞 Getting Help

- **Documentation**: [Axolotl Docs](https://axolotl-ai-cloud.github.io/axolotl/docs/config.html)
- **Issues**: Create GitHub issues for bugs or feature requests
- **Main Repository**: [llm-fine-tuning](https://github.com/runpod-workers/llm-fine-tuning) for serverless deployments

---

**Last Updated**: $(date)  
**Version**: 1.0.0  
**Maintainers**: Development Team

> 💡 **Remember**: This document focuses on Pod deployments. For serverless/API deployments, see the main repository conventions.
