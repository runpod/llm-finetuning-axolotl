FROM axolotlai/axolotl-cloud:main-latest

WORKDIR /workspace/fine-tuning

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install -r requirements.txt

RUN rm -rf /root/.cache/pip

# Expose vLLM port (not started automatically)
EXPOSE 8000

COPY scripts/WELCOME /etc/motd

COPY scripts .

RUN chmod +x autorun.sh start_vllm.sh
CMD ["/workspace/fine-tuning/autorun.sh"]
