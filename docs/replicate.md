# How to replicate the 1-bit monster

> *Don't take our word for it. Build it yourself.*

Step-by-step reproduction of the halo-ai stack on Strix Halo — and, as
context, the other backends the `sommelier` specialist routes against.
Glass walls — nothing hidden.

---

## What you need

### Hardware
- AMD Strix Halo (gfx1151) — any Ryzen AI MAX+ PRO 300 series
  - Bosgame M5, ASUS NUC 14 Pro AI, Sliger FPGA-DAC rack, etc.
  - 64 GB or 128 GB unified memory
  - NPU: RyzenAI aie2p (50 TOPS) — for FLM backend on the side
- Also works end-to-end on: gfx1150 (Strix Point). Other AMD archs go
  through `install-source.sh`.

### Software
- **[CachyOS](https://cachyos.org/) — required for NPU.** Stock Arch and
  other distros silently fall back to iGPU on the NPU path; see the
  warning block in the main [README](../README.md). The GPU-only path
  (`rocm-cpp`) technically works on stock Arch, but you lose the NPU
  specialists (`echo_ear`, lemond-FLM backends) and several benchmarks.
- Kernel `7.0.0-cachyos` or newer (has the `amdxdna` driver bound)
- ROCm 7.13.0 (from `rocm-hip-sdk` in `extra` — already wired up on CachyOS)
- `curl`, `git`, `github-cli`, `cmake`, `ninja`, `python3` (tooling only
  — **not** at runtime), `bc`
- ~20 GiB free disk space for halo-ai itself; ~80 GiB if you're also
  rebuilding the cross-backend comparison stack.

### Time
- halo-ai via `install-strixhalo.sh` (pre-built): **~5 min**
- halo-ai via `install-source.sh` (from-source, any AMD arch): **~4 hr**
- Full cross-backend benchmark (MLX + vLLM + Prism + FLM alongside):
  ~1 hr setup + ~45 min bench

---

## Step 0 — verify hardware

```bash
# GPU
rocminfo | grep "Marketing Name"
# → Radeon 8060S Graphics (gfx1151)

# NPU (optional — needed for echo_ear / FLM)
lspci -k | grep -A3 amdxdna
# → driver in use: amdxdna

# Kernel
uname -r
# → 7.0.0-cachyos or similar

# ROCm
cat /opt/rocm/.info/version
# → 7.13.0

# Memory
free -g | awk '/^Mem:/{print $2 "GB"}'
# → 64 or 128 (unified)
```

---

## Step 1 — install halo-ai

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                    # auto: gfx1151 → fast; else → source
```

Or force:
```bash
./install.sh --strixhalo        # pre-built binaries, ~5 min
./install.sh --source           # rebuild for your arch, ~4 hr
```

What this does:
- Verifies CachyOS / `amdxdna` driver bound
- Installs `rocm-hip-sdk` if missing
- Clones `rocm-cpp`, `agent-cpp`, `halo-1bit` (or downloads pre-built
  gfx1151 tarballs for the fast path)
- Wires `halo-bitnet.service` + `halo-agent.service` under systemd
- Stands up Caddy + Headscale for the private mesh
- Symlinks the TQ1_0 `.h1b` model into `/home/bcloud/halo-ai/models/`

After:

```bash
systemctl status halo-bitnet halo-agent
curl http://127.0.0.1:8080/v1/models
# → {"data":[{"id":"bitnet-b1.58-2b-4t",...}], ...}
```

## Step 2 — verify end-to-end decode

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{
    "model": "bitnet-b1.58-2b-4t",
    "messages": [{"role":"user","content":"say hi in 5 words"}],
    "max_tokens": 32
  }'
```

Expected: < 2 s cold start, ~83 tok/s @ 64 ctx (68.6 @ 1024) steady-state.

## Step 3 — verify PPL

```bash
# Fetch the wikitext-103 test split (one-time, via HF tooling — training
# time, not runtime, so python is fine here).
python3 -c "
from datasets import load_dataset
ds = load_dataset('Salesforce/wikitext', 'wikitext-103-v1', split='test')
open('/home/bcloud/halo-ai/datasets/wikitext-103-test.txt','w').write(
    '\n'.join(ds['text'])
)
"

./bitnet_decode /home/bcloud/halo-ai/models/halo-1bit-2b.h1b \
    --ppl /home/bcloud/halo-ai/datasets/wikitext-103-test.txt 1024

# Expected: {"scored":1024,"mean_nll":~2.21,"perplexity":~9.16,...}
```

PPL ≈ 9.16 matches Microsoft's BitNet-b1.58-2B-4T paper baseline. That's
the RoPE-fix bar — if you see numbers in the 500s, the fix didn't land
(check `rocm-cpp` is at `main` or newer than `8f764d7`).

## Step 4 — decode throughput bench

```bash
./bench.sh
# or directly:
bitnet_decode /home/bcloud/halo-ai/models/halo-1bit-2b.h1b \
    --text "Explain the concept of nuclear fusion" \
    --max-tokens 256 --temperature 0.0
```

Expected steady-state: **~83 tok/s @ 64 ctx (68.6 @ 1024)**. If you see < 50 tok/s, the FD
attention path didn't land — check `tools/bitnet_decode.cpp:503` calls
`rcpp_kv_cache_attn_decode_fd`.

---

## (Optional) Cross-backend comparison

Only needed if you want to run the wider-context benchmark against MLX,
vLLM, Prism llama.cpp, and FLM alongside halo-ai.

### Backend 2 — MLX ROCm (dense fp16 / int4)

MLX ROCm handles dense fp16/int4 Qwen3, Phi, etc. — the dense path we
explicitly *don't* cover. See [docs/mlx-setup-guide.md](mlx-setup-guide.md)
for why MLX is the optional-second-backend, not the default.

```bash
mkdir -p ~/mlx-engine && cd ~/mlx-engine
GPU_TARGET=gfx1151

gh release download b1004-tech-preview \
  -R lemonade-sdk/lemon-mlx-engine \
  -p "mlx-engine-b1004-tech-preview-ubuntu-rocm-tech-preview-${GPU_TARGET}-x64.zip"

unzip mlx-engine-*-${GPU_TARGET}-x64.zip -d .
chmod +x chat server diagnose

LD_LIBRARY_PATH=.:/opt/rocm/lib ./diagnose mlx-community/Qwen3-1.7B-4bit
LD_LIBRARY_PATH=.:/opt/rocm/lib ./server --host 0.0.0.0 --port 8081
```

Available models (auto-download on first use):
- `mlx-community/Qwen3-0.6B-4bit`, `Qwen3-1.7B-4bit`, `Qwen3-4B-4bit`,
  `Qwen3-8B-4bit`, `Phi-4-mini-instruct-4bit`

Route through `sommelier` by adding to its TOML config (see
[docs/mlx-setup-guide.md](mlx-setup-guide.md)).

### Backend 3 — vLLM ROCm via lemond

Production LLM server with PagedAttention and continuous batching.
Runs through `lemond` (Lemonade SDK daemon).

```bash
git clone https://github.com/lemonade-sdk/lemonade.git
cd lemonade
git fetch origin test-vllm && git checkout test-vllm

mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc) --target lemond
cd ..

./build/lemond --host 0.0.0.0 --port 13399
curl -s http://localhost:13399/v1/models | python3 -m json.tool | grep vllm
```

Available vLLM models (14 total):
`Qwen3-0.6B-vllm`, `Qwen3-1.7B-vllm`, `Qwen3-4B-AWQ-vllm`, `Qwen3-8B-AWQ-vllm`,
`Phi-4-mini-instruct-vllm`, `Llama-3.2-1B-Instruct-vllm`, `Llama-3.2-3B-Instruct-vllm`,
`Qwen3.5-0.8B-vllm`, `Qwen3.5-2B-vllm`, `Qwen3.5-4B-vllm`, `Qwen3.5-9B-vllm`,
`Gemma-3-4b-it-vllm`, `Qwen3-4B-vllm`, `Qwen3-8B-vllm`.

`lemond` also serves FLM (NPU) models on the same port — see Backend 5.

### Backend 4 — Prism llama.cpp (Vulkan 1-bit)

Prism is a llama.cpp fork that supports TQ1_0 (ternary) through Vulkan.
Useful for the Bonsai comparison models; halo-ai handles our BitNet
ternary directly through native HIP.

```bash
mkdir -p ~/prism-llamacpp && cd ~/prism-llamacpp

gh release download prism-b8796-e2d6742 \
  -R PrismML-Eng/llama.cpp -p '*ubuntu-vulkan*'
tar xzf llama-prism-*-vulkan-x64.tar.gz

pip install huggingface-hub
huggingface-cli download Qwen/Qwen3-Coder-Next-UD --include "*.gguf" \
  --local-dir ~/models/Qwen3-Coder-Next-TQ1_0

cd llama-prism-*/
./llama-server \
  --host 0.0.0.0 --port 8082 \
  --model ~/models/Qwen3-Coder-Next-TQ1_0/*.gguf \
  --ctx-size 4096 --n-gpu-layers 999
```

### Backend 5 — FastFlowLM on the NPU

Zero GPU memory used. Requires CachyOS + kernel `7.0.0-cachyos` (XDNA2
driver). Install:

```bash
sudo pacman -S lemonade xrt-plugin-amdxdna fastflowlm

# Memlock limits (REQUIRED for NPU):
echo "$(whoami) soft memlock unlimited" | sudo tee -a /etc/security/limits.d/99-npu.conf
echo "$(whoami) hard memlock unlimited" | sudo tee -a /etc/security/limits.d/99-npu.conf
# Log out + back in

flm validate
# → NPU 8 cols, firmware 1.1.0.0+, memlock unlimited
```

Models: `qwen3-0.6b-FLM`, `llama3.2-1b-FLM`, `gemma3-1b-FLM`,
`llama3.2-3b-FLM`, `qwen3-8b-FLM`, `whisper-v3-turbo-FLM`.

---

## Step 5 — run the standardized cross-backend bench

```bash
git clone https://github.com/stampby/bleeding-edge.git
cd bleeding-edge
./bench.sh
```

Auto-detects which backends are running, warms up each model, runs 3
rounds of 256-token generation, reports mean ± stddev, saves to
`results/` as CSV + JSON.

---

## Methodology

| Parameter | Value |
|-----------|-------|
| Generation length | 256 tokens |
| Rounds | 3 per model |
| Warmup | 1 round discarded |
| Temperature | 0.0 (deterministic) |
| Prompt | "Explain the concept of nuclear fusion..." |
| Measurement | Wall-clock, `tokens / elapsed_seconds` |
| Reported | Mean ± sample standard deviation |

---

## Expected results (Strix Halo gfx1151, 128GB, ROCm 7.13.0)

```
BACKEND    MODEL                       HARDWARE     TOK/S   ±STDDEV
──────────────────────────────────────────────────────────────────
halo-ai    bitnet-b1.58-2b-4t (TQ1_0)  GPU-HIP       85.0   ±0.4
mlx        Qwen3-0.6B-4bit             GPU-ROCm     149.3   ±0.3
mlx        Qwen3-1.7B-4bit             GPU-ROCm      65.2   ±0.2
mlx        Qwen3-4B-4bit               GPU-ROCm      44.5   ±0.1
mlx        Phi-4-mini-4bit             GPU-ROCm      37.0   ±0.2
mlx        Qwen3-8B-4bit               GPU-ROCm      20.8   ±0.1
vllm       Qwen3-0.6B                  GPU-ROCm     130.6   ±0.6
vllm       Qwen3-1.7B                  GPU-ROCm      47.1   ±0.2
vllm       Qwen3-4B-AWQ                GPU-ROCm      41.5   ±0.1
vllm       Phi-4-mini                  GPU-ROCm      24.9   ±0.0
vllm       Qwen3-8B-AWQ                GPU-ROCm      22.3   ±0.1
prism      Qwen3-Coder-Next-TQ1_0      GPU-Vulkan    65.6   ±0.8
lemond     Qwen3-0.6B-FLM              NPU-FLM       94.4   ±0.2
lemond     Llama-3.2-1B-FLM            NPU-FLM       61.7   ±0.2
lemond     Gemma3-1B-FLM               NPU-FLM       38.9   ±0.0
lemond     Llama-3.2-3B-FLM            NPU-FLM       24.9   ±0.0
lemond     Qwen3-8B-FLM                NPU-FLM       10.8   ±0.0
```

Your numbers may vary ±5% depending on thermal state and memory config.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| NPU not detected | Confirm CachyOS + `lspci -k \| grep amdxdna` — see Troubleshooting wiki |
| MLX `diagnose` fails | Check kernel 7.0.0-cachyos+ and ROCm 7.13.0 |
| vLLM first load slow | Normal — Triton JIT compiles HIP kernels on first run |
| `flm validate` fails | Check `ulimit -l` is unlimited, reboot after setting limits |
| MLX crashes on model switch | `curl -X POST http://localhost:8081/unload` |
| Prism no Vulkan | `sudo pacman -S vulkan-radeon` |
| PPL >> 10 on wikitext-103 | RoPE fix didn't land — update rocm-cpp |

---

## Reporting your results

Run these on different hardware? Open an issue with:

1. GPU model + arch (`gfx1151`, `gfx1150`, ...)
2. Memory (64 / 128 GB)
3. Kernel version (`uname -r`)
4. `bench.sh` output

We'll add it to the comparison table.

---

*Designed and built by the architect.*
