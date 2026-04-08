# NPU Acceleration

AMD Strix Halo includes an NPU (Neural Processing Unit) — the RyzenAI-npu5. It runs small models at high speed with minimal power.

## What the NPU Is Good For

- Small models (0.6B - 2B parameters)
- Always-on background tasks
- Voice activity detection
- Classification tasks
- Running alongside the GPU without competing for VRAM

## What the NPU Is NOT Good For

- Large language models (7B+)
- Image generation
- Anything requiring lots of VRAM

## Requirements

- Linux kernel 7.0+ (XDNA driver support)
- `xdna-driver` kernel module
- FastFlowLM for inference

## Verification

```bash
rocminfo | grep -A2 "aie2p"
# Should show: RyzenAI-npu5
```

## FastFlowLM

FastFlowLM is the inference engine for the NPU:

```bash
# Through Lemonade
lemonade --tools flm-load --model tiny-model
```

## GPU + NPU Simultaneous

Both can run at the same time:

- GPU: Qwen3-30B for main chat
- NPU: Qwen3-0.6B for voice detection

## Performance

| Model | NPU tok/s | GPU tok/s | Notes |
|-------|-----------|-----------|-------|
| Qwen3 0.6B | 95.9 | 200+ | NPU wins on power efficiency |

## Kernel Setup

The NPU requires kernel 7.0+ with XDNA driver. On Arch:

```bash
# Check kernel version
uname -r
# Needs 7.0+

# Verify XDNA module
lsmod | grep xdna
```

If your kernel doesn't support it, you may need to build `linux-mainline` from source.
