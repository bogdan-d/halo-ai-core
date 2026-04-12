# Components

## ROCm 7.2.1

AMD's GPU compute stack. Used by vLLM and whisper.cpp for HIP-accelerated inference. llama.cpp uses Vulkan instead (13-21% faster generation — see [VULKAN-PERFORMANCE.md](../VULKAN-PERFORMANCE.md)).

- Package: `rocm-hip-sdk`, `rocm-opencl-sdk`
- Path: `/opt/rocm/bin/`
- Verify: `rocminfo | grep "Marketing Name"`
- Tuning vars set in `/etc/profile.d/rocm.sh`

### Environment Variables

```bash
ROCBLAS_USE_HIPBLASLT=1        # Better BLAS performance
PYTORCH_ROCM_ARCH=gfx1151     # Target architecture
HSA_OVERRIDE_GFX_VERSION=11.5.1  # Version override
IOMMU=pt                       # Pass-through mode
```

## Caddy 2.x

Reverse proxy that auto-discovers services. Drop a config file, reload, done.

- Config: `/etc/caddy/Caddyfile`
- Drop-ins: `/etc/caddy/conf.d/*.caddy`
- Service: `systemctl status caddy`

### Adding a New Service Route

```bash
sudo tee /etc/caddy/conf.d/myservice.caddy > /dev/null << 'EOF'
:9090 {
    reverse_proxy localhost:9000
}
EOF
sudo systemctl reload caddy
```

## llama.cpp

LLM inference engine built from source with **Vulkan only**. Benchmarks show 13-21% faster generation vs ROCm/HIP on Strix Halo.

- Binary: `/srv/ai/llama-cpp/build/bin/llama-server`
- Source: `/srv/ai/llama-cpp/`
- Service: `halo-llama-server.service`
- API: OpenAI-compatible at `localhost:8080`
- Build flags: `GGML_VULKAN=ON`, `-DCMAKE_BUILD_TYPE=Release`

### Loading a Model

Edit the service to add a model path:
```bash
sudo systemctl edit llama-server
```

Add:
```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/llama-server --host 0.0.0.0 --port 8080 --n-gpu-layers 999 -m /path/to/model.gguf
```

## Lemonade Server 10.2.0

AMD's unified AI backend. Wraps llama.cpp, whisper, kokoro TTS, and stable diffusion under one API.

- Package: `lemonade-server` (AUR)
- CLI: `lemonade`
- Daemon: `lemond`
- Service: `lemonade.service`
- Port: 13305

### Backends Available

- `llamacpp` — LLM inference (Vulkan)
- `whispercpp` — Speech to text
- `sd-cpp` — Image generation
- `kokoro` — Text to speech
- `oga-load` — ONNX GenAI
- `flm-load` — FastFlowLM (NPU)

## Gaia SDK 0.17.x

AMD's agent framework. Build AI agents that run 100% locally.

- Venv: `~/gaia-env/`
- CLI: `~/gaia-env/bin/gaia`
- Source: `~/gaia/`
- Service: `gaia.service`

Gaia includes its own web UI for agent management.
