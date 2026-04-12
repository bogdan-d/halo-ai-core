# Changelog

All notable changes to Halo AI Core.

---

## [0.9.0] — 2026-04-08

### Core Services
- ROCm 7.2.1 from Arch repos (gfx1151 + NPU detected)
- Caddy 2.11.2 reverse proxy with drop-in config pattern
- llama.cpp Vulkan only (h/t u/Look_0ver_There)
- Lemonade SDK 9.1.4 with web UI
- Gaia SDK 0.17.1 with Agent UI
- Python 3.13.4 via pyenv (Arch ships 3.14, SDKs need 3.13)
- WireGuard VPN with QR code — install finishes, QR appears, scan with phone, connected. Zero config remote access to your entire stack. *(Feature credit: Zach Barrow)*

### Web UIs
- Lemonade Server UI on :13305 — chat with LLMs out of the box
- Gaia Agent UI on :4200 — agent management and deployment

### Install Script
- `./install.sh --yes-all` — one command full install
- `./install.sh --dry-run` — preview without installing
- `./install.sh --status` — check what's running
- Skip flags for every component
- Works on fresh Arch install with NetworkManager
- Progress bars, spinners, and step indicators for real-time feedback
- Stops running services before overwriting binaries (no Text file busy)

### Performance — gfx1151 Optimizations (baked into install.sh)

The install script patches llama.cpp at build time. No manual tuning required.

**Benchmarks (Qwen3-30B-A3B Q4_K_M, AMD Ryzen AI MAX+ 395, kernel 6.19.11):**
- Prompt processing: **1,113 tok/s** (pp512)
- Token generation: **66.5 tok/s** (tg128)

**How we got here:**
- **MMQ kernel fix** ([ggml-org/llama.cpp#21284](https://github.com/ggml-org/llama.cpp/issues/21284)) — stock llama.cpp has suboptimal MMQ launch parameters that exceed the 256 VGPR register limit on RDNA 3.5. We patch `mmq_x=48`, `mmq_y=64`, `nwarps=4` at build time. This alone gives ~20% prefill improvement.
- **rocWMMA flash attention** — used for HIP-based workloads (vLLM, PyTorch), not llama.cpp which runs on Vulkan.
- **Fast math intrinsics** — replaced `expf()` with `__expf()` in MoE routing and SiLU activation for measurable speedup with negligible quality loss.
- **HIPBLASLT** — `ROCBLAS_USE_HIPBLASLT=1` environment variable doubles prompt processing throughput. Set in `/etc/profile.d/rocm.sh` and all systemd services.
- **AOTriton** — `TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1` enables a 19x attention speedup on AMD that was never documented in official ROCm docs. Found via [ROCm/ROCm#6034](https://github.com/ROCm/ROCm/issues/6034).
- **Anti-fragmentation** — `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` prevents VRAM fragmentation OOM on the shared unified memory.

These fixes were discovered through community research, GitHub issue tracking, and repeated benchmark testing on real Strix Halo hardware. Every new install gets all of them automatically.

### Infrastructure
- All services as systemd units with auto-restart
- Caddy routes via `/etc/caddy/conf.d/*.caddy` drop-ins
- ROCm environment vars in `/etc/profile.d/rocm.sh`
- SSHD hardened: key-only, no passwords, no root

### Documentation
- 29 wiki pages covering full platform
- README in 11 languages
- Security guide, SSH mesh guide, agent deployment specs
- Discord server spec with 18 channels

### GitHub
- CI: syntax check + dry-run + ShellCheck
- CodeQL: weekly security scan
- Dependabot: automated action updates
- Vulnerability alerts enabled
- Issue templates: bug report + feature request
- PR template with checklist
- SECURITY.md, CONTRIBUTING.md

### Assets
- halo-ai logo (circuit halo, server rack, LEDs)
- 7 SVG/PNG logo variants
- Install recording (asciinema cast)

---

*Designed and built by the architect.*
