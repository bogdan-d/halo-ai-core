# Model Management

How to download, load, switch, and benchmark LLM models on your hardware.

## Downloading Models

Models come from HuggingFace in GGUF format:

```bash
# Using huggingface-cli
pip install huggingface-hub
huggingface-cli download TheBloke/Qwen2-7B-GGUF qwen2-7b-q4_k_m.gguf --local-dir ~/models/

# Or using wget
wget https://huggingface.co/TheBloke/model/resolve/main/model.gguf -P ~/models/
```

## Model Storage

Keep models in a consistent location:

```bash
mkdir -p ~/models
# Symlink from shared storage if using SSHFS
ln -s /shared/models ~/models
```

## Loading a Model in llama.cpp

### One-Time

```bash
llama-server --host 0.0.0.0 --port 8080 \
    -m ~/models/qwen3-8b-q4_k_m.gguf \
    --n-gpu-layers 999 \
    --ctx-size 8192
```

### As a Service

```bash
sudo systemctl edit llama-server
```

Add:

```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/llama-server --host 0.0.0.0 --port 8080 -m /home/bcloud/models/qwen3-8b-q4_k_m.gguf --n-gpu-layers 999 --ctx-size 8192
```

```bash
sudo systemctl restart llama-server
```

## Loading via Lemonade

```bash
source ~/lemonade-env/bin/activate
lemonade --tools llamacpp-load --model ~/models/qwen3-8b-q4_k_m.gguf
```

## Switching Models

Stop the current model and start a new one:

```bash
sudo systemctl stop llama-server
# Edit the model path
sudo systemctl edit llama-server
sudo systemctl start llama-server
```

## Quantization Formats

| Format | Size | Speed | Quality |
|--------|------|-------|---------|
| Q2_K | Tiny | Fastest | Lowest |
| Q4_K_M | Small | Fast | Good |
| Q5_K_M | Medium | Medium | Better |
| Q6_K | Large | Slower | Great |
| Q8_0 | Large | Slow | Excellent |
| F16 | Huge | Slowest | Perfect |

With 128GB unified memory, you can run Q8_0 or even F16 for most models.

## Benchmarks

Quick benchmark:

```bash
llama-cli -m ~/models/model.gguf -p "Hello" -n 128 --n-gpu-layers 999
```

Watch for `eval time` and `tokens per second` in the output.

See [[Benchmarks]] for full numbers.
