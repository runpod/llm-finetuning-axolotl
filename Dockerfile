FROM axolotlai/axolotl-cloud:main-latest

WORKDIR /workspace/fine-tuning

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install -r requirements.txt

RUN rm -rf /root/.cache/pip

# Install uv for faster package management
RUN pip install uv

# Create separate venv for vLLM using uv to avoid flash-attn conflicts with Axolotl
# Match CUDA version with base image (CUDA 12.6)
RUN uv venv /opt/vllm-venv && \
    uv pip install --python /opt/vllm-venv/bin/python vllm --torch-backend=cu126

# Expose vLLM port (not started automatically)
EXPOSE 8000

COPY scripts/WELCOME /etc/motd

COPY scripts .

RUN chmod +x autorun.sh start_vllm.sh
CMD ["/workspace/fine-tuning/autorun.sh"]
