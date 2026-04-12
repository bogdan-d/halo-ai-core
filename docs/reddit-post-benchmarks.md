# Reddit Post — Ready to Paste

**Subreddits:** r/LocalLLaMA, r/AMDStrixHalo, r/SelfHosted

**Title:** Qwen3.5-35B on Strix Halo — 57 tok/s, 128GB unified, one install script. Benchmark suite included.

---

**PASTE BELOW THIS LINE:**

---

been running local LLMs on AMD Strix Halo (Ryzen AI MAX+ 395, 128GB unified). no cloud. everything from source. one install script.

built a benchmark suite and ran it. posting the numbers because nobody had real benchmarks for this chip when i was buying it.

# hardware

```
CPU:      Ryzen AI MAX+ 395 (32c Zen 5)
GPU:      Radeon 8060S (RDNA 3.5, gfx1151)
Memory:   128GB unified DDR5
OS:       Arch Linux 6.19.11
Stack:    Lemonade 10.2.0 → llama.cpp (Vulkan)
```

128GB unified = CPU and GPU share the same pool. no "VRAM limit." load models that would need a $2000 discrete GPU.

# Qwen3.5-35B-A3B — generation

MoE, 3B active params, Q4_K_XL quant.

```
Output       Gen tok/s
─────────    ─────────
50 tok          58.0
100 tok         57.6
250 tok         57.2
500 tok         57.0
1000 tok        56.8
```

rock solid ~57 tok/s. barely moves between 50 and 1000 tokens.

# prompt processing

```
Input        Prompt tok/s    TTFT
─────────    ────────────    ─────
16 tok           269.5       111ms
256 tok          941.6       283ms
1024 tok       1,270.9       819ms
4096 tok       1,116.7     3,207ms
8192 tok       1,050.1     4,367ms
```

peaks at **1,270 tok/s** around 1K. holds above 1,000 tok/s even at 8K context.

# context stress

```
Depth      Gen tok/s    Prompt tok/s
─────      ─────────    ────────────
1K            57.0        1,006
4K            55.6        1,117
8K            54.2        1,050
```

slight gen slowdown at 8K. unified memory = no PCIe bottleneck.

# real tasks

```
Task               Gen tok/s
────               ─────────
Math reasoning        57.0
Code reasoning        57.0
Python async          56.8
Bash scripting        56.9
```

doesn't slow down when it has to think.

# memory

```
llama-server RSS:     5.7 GB
RAM used total:      44 GB / 128 GB
RAM free:            84 GB
```

84GB free. could stack 2-3 models.

# other models

```
Model                   tok/s
─────                   ─────
Qwen3-Coder-30B-A3B     73.0
Qwen3.5-35B-A3B         57.0
Qwen3 8B                90.0
Gemma 4 27B             52.4
Bonsai 1.7B (1-bit)    260.0
```

# what makes it fast

install script patches llama.cpp at build time:

- **MMQ kernel fix** — register pressure fix for RDNA 3.5. without it you lose ~20%
- **rocWMMA flash attention** — hardware matrix multiply
- **fast math intrinsics** — `__expf()` for MoE routing
- **HIPBLASLT** — doubles prompt throughput
- **Vulkan backend** — Lemonade's own compiled llama.cpp

# the stack

```
git clone https://github.com/stampby/halo-ai-core
cd halo-ai-core
./install.sh --yes-all
```

one script installs:

- **Lemonade SDK** — model management + OpenAI API
- **llama.cpp** — from source, Vulkan only
- **Gaia SDK** — local AI agents
- **Caddy** — reverse proxy
- **WireGuard** — phone VPN with QR code
- **Claude Code** — `lemonade launch claude`

all systemd. auto-start. auto-restart.

# benchmark script

wrote `halo-bench.sh` for this. 8 categories, multi-run, JSON + CSV output:

```
./halo-bench.sh                  # full suite
./halo-bench.sh -q               # quick
./halo-bench.sh -r 5 --record   # 5 runs
```

repo: https://github.com/stampby/halo-ai-core

benchmarks: https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Benchmarks.md

benchmark script: https://github.com/stampby/halo-ai-core/blob/main/halo-bench.sh

discord: https://discord.gg/dSyV646eBs

AMA.

---

*designed and built by the architect*
