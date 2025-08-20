FROM axolotlai/axolotl-cloud:main-latest

WORKDIR /workspace/fine-tuning

# Install uv for faster package management
RUN pip install uv

COPY requirements.txt .

# Install main requirements with uv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system -r requirements.txt

# Create separate venv for vLLM using uv to avoid flash-attn conflicts with Axolotl
RUN uv venv /opt/vllm-venv

# Install PyTorch 2.6.x with CUDA 12.6 to match flashinfer wheel availability
RUN uv pip install --python /opt/vllm-venv/bin/python "torch>=2.6.0,<2.7.0" --index-url https://download.pytorch.org/whl/cu126

# Install vLLM (will use existing PyTorch)
RUN uv pip install --python /opt/vllm-venv/bin/python vllm

# Install flashinfer for better performance (no-deps to avoid torch conflict)
RUN uv pip install --python /opt/vllm-venv/bin/python flashinfer-python --index-url https://flashinfer.ai/whl/cu126/torch2.6 --no-deps

# Install hf-transfer for faster downloads
RUN uv pip install --python /opt/vllm-venv/bin/python hf-transfer

# Expose vLLM port (not started automatically)
EXPOSE 8000

COPY scripts/WELCOME /etc/motd

COPY scripts .

RUN chmod +x autorun.sh start_vllm.sh
CMD ["/workspace/fine-tuning/autorun.sh"]
