# The Bleeding Edge Is Live — NPU, Nexus, and a Package Manager

*April 13, 2026 · stamped by the architect*

---

We just spent 24 hours rebuilding the stack from the ground up. Here's what changed and why it matters.

## NPU Is Alive

The AMD XDNA2 NPU on Strix Halo is running inference. Not "detected." Not "loaded but SVA bind failed." Running. Models. On silicon.

- **Llama 3.2 3B** — generating on the NPU
- **Qwen3 8B** — reasoning mode, turbo, on the NPU
- **Whisper v3 Turbo** — speech-to-text, on the NPU

The driver is `amdxdna`, the firmware is `1.1.2.65`, and it took three kernel builds to get here. The stock Arch kernel 6.19.11 detects the NPU fine — but the inference stack needs kernel 7.0+ for the right firmware path.

We built [CachyOS 7.0-rc3](https://github.com/stampby/halo-ai-core-bleeding-edge) with BORE scheduler, LTO, and native Zen 5 optimizations. The `modules_install` target in kernel 7.0-rc3 silently skips `drivers/accel/` — we patched the PKGBUILD to fix it.

**Full details:** [NPU Acceleration →](NPU-Acceleration.md)

## SSH Mixer Is Dead. Long Live Nexus.

We deprecated SSH Mixer. It was duct tape. Nexus is the replacement.

**Lemonade Nexus** is a self-hosted, cryptographically secure WireGuard mesh VPN with:

- Zero-trust two-tier security (TEE hardware attestation)
- Ed25519 identity for every server and client
- Shamir's Secret Sharing for root key distribution
- Democratic governance — protocol changes need Tier 1 majority vote
- UDP gossip protocol for state sync
- Automatic WireGuard tunnel establishment with STUN hole-punching
- No database — all state is signed JSON on disk

It built from source on Strix Halo in under 2 minutes. It's running right now on ports 9100 (public API) and 9101 (VPN-only private API). The WireGuard tunnel is up at `10.64.0.1`.

**Full details:** [Architecture →](Architecture.md)

## We Built Our Own Package Manager

The Arch rolling release model is great for a desktop. It's a liability for an AI stack. One `pacman -Syu` and your carefully tuned ROCm + llama.cpp + vLLM setup is toast.

So we built a package manager. It tracks 16 packages across 6 categories:

| Category | Packages |
|----------|----------|
| **LLM** | Lemonade Server, llama.cpp (Vulkan), llama.cpp (ROCm), reversellm, vLLM |
| **NPU** | FastFlowLM |
| **Media** | ComfyUI, stable-diffusion.cpp |
| **Agents** | Gaia, Gaia UI, Living Mind Cortex, Interviewer |
| **Network** | Lemonade Nexus, Caddy, SearXNG |
| **Data** | PostgreSQL |

Glass-themed web dashboard on `:3010`. Start, stop, restart any service. Trigger builds from source. Version tracking. Category filtering. All independent from pacman.

**Full details:** [Components →](Components.md)

## The LLM Inference Stack

No more confusion about what runs where. The stack is clean:

| Engine | Backend | Purpose |
|--------|---------|---------|
| **FLM** | NPU (XDNA2) | Small model inference (3B-8B), Whisper STT |
| **llama.cpp** | Vulkan | GPU inference, general purpose |
| **llama.cpp** | ROCm/HIP | GPU inference, ROCm-optimized |
| **vLLM** | ROCm | High-throughput serving |

All compiled separately from source. All sit side by side. No wrappers. No ONNX Runtime.

**Full details:** [Benchmarks →](Benchmarks.md)

## NPU Benchmarks — All Models

All Q4_1 quantized. XDNA2 NPU, 8 columns, firmware 1.1.2.65. CachyOS 7.0-rc3 kernel. Zero GPU usage during runs. Turbo power mode.

| Model | Params | ~tok/s | Time (100 words) | Footprint |
|-------|--------|--------|-------------------|-----------|
| **lfm2.5-it** | 1.2B | **~59** | 4.2s | 0.9 GB |
| **qwen3** | 0.6B | **~47** | 4.3s | 0.5 GB |
| **qwen3.5** | 0.8B | **~45** | 7.8s | 0.6 GB |
| **llama3.2** | 1B | **~43** | 4.5s | 0.8 GB |
| **gemma3** | 1B | **~31** | 6.3s | 0.8 GB |
| **llama3.2** | 3B | **~19** | 9.7s | 2.7 GB |
| **qwen3** | 8B | **~8** | 50.5s | 5.6 GB |

**Sweet spot:** sub-2B models at 40-60 tok/s. LFM2.5-IT at 1.2B is the NPU king — 59 tok/s with minimal footprint.

**Notes:**
- The 8B with reasoning mode is slow because the thinking chain generates hidden tokens before visible output
- The 0.6B and 0.8B models are fast enough for real-time assistant responses
- NPU runs alongside GPU — dedicated low-power inference while Radeon handles heavy models
- Whisper v3 Turbo (0.62 GB) runs on NPU for always-on speech-to-text

*tested 2026-04-13 on CachyOS 7.0.0-rc3-1-cachyos-rc-native*

## Changelog — Last 24 Hours

```
+ CachyOS 7.0-rc3 kernel built and booted (BORE + LTO + native Zen 5)
+ NPU inference confirmed (Llama 3.2 3B, Qwen3 8B, Whisper v3)
+ Lemonade Nexus built, installed, running as service
+ Package manager dashboard built and deployed (:3010)
+ Gaia venv rebuilt (Python 3.13→3.14 migration)
+ Caddy config fixed (missing Caddyfile)
+ All 10 README translations updated (8→13 services)
+ r8169 network driver baked into CachyOS initramfs
+ amdxdna module manually injected into CachyOS package
- SSH Mixer deprecated (replaced by Nexus)
- Bitwarden removed (no longer needed)
- linux-mainline kernel removed (replaced by CachyOS)
- Medium articles deprecated (wiki only from now on)
```

## Boot Menu

Strix Halo now has three boot options:

1. **Stock 6.19.11** — stable, NPU detected but FLM incompatible
2. **Claude Ready Snapshot** — known-good state, rollback target
3. **CachyOS 7.0-rc3 Bleeding Edge** — full NPU + FLM + everything

## What's Next

- Line-by-line security audit of the full stack
- RC release candidate for bleeding edge
- Clean room install test
- Benchmarks post with the new NPU numbers

---

> *"the future is not set. there is no fate but what we make for ourselves."*

**[← Back to Wiki Home](Home.md)** · **[Benchmarks →](Benchmarks.md)** · **[NPU Acceleration →](NPU-Acceleration.md)** · **[Discord →](https://discord.gg/dSyV646eBs)**
