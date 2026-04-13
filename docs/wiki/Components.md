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

## Lemonade Services

Additional services from the Lemonade ecosystem, all installed by `install.sh`:

### Interviewer

AI-powered interview practice — practice technical and behavioral interviews with LLM feedback.

- Source: `~/.local/share/halo-services/interviewer/`
- Port: 8191
- Service: `interviewer.service` (user)
- Repo: [stampby/interviewer](https://github.com/stampby/interviewer)

### Lemonade Eval

Benchmarking and accuracy analysis client for Lemonade Server.

- Source: `~/.local/share/halo-services/lemonade-eval/`
- CLI: `lemonade-eval run`
- Repo: [stampby/lemonade-eval](https://github.com/stampby/lemonade-eval)

### Lemonade Nexus

Zero-trust WireGuard mesh VPN with cryptographic governance. Ed25519 identity, Shamir's Secret Sharing, gossip protocol, STUN hole-punching, federated relays.

- Binary: `/usr/local/bin/lemonade-nexus`
- Built from source (C++20 + Rust)
- Ports: 9100 (HTTP), 51940 (WireGuard), 9102 (gossip), 3478 (STUN)
- Repo: [stampby/lemonade-nexus](https://github.com/stampby/lemonade-nexus)
