# Reddit Post Draft — r/LocalLLaMA + r/AMDStrixHalo

**Subreddits:** r/LocalLLaMA, r/AMDStrixHalo, r/SelfHosted

---

**Title:** Qwen3.5-35B on AMD Strix Halo — 57 tok/s gen, 1270 tok/s prompt, 128GB unified, zero cloud. Built a benchmark suite for it.

---

**Body:**

been running local LLMs on an AMD Ryzen AI MAX+ 395 (Strix Halo) with 128GB unified memory. no cloud, no API keys, no subscriptions. everything compiles from source on arch linux with one install script.

just built a proper benchmark suite and ran it against Qwen3.5-35B-A3B (MoE, 3B active params, Q4_K_XL quant). posting the numbers because i couldn't find real-world benchmarks for this chip anywhere when i was buying it.

## the hardware

    CPU:        AMD Ryzen AI MAX+ 395 (32 cores, Zen 5)
    GPU:        Radeon 8060S (RDNA 3.5, integrated, gfx1151)
    Memory:     128GB unified (shared CPU/GPU — no discrete VRAM limit)
    OS:         Arch Linux, kernel 6.19.11
    Stack:      Lemonade SDK 10.2.0 → llama.cpp (Vulkan) → ROCm 7.2.1

the key thing about strix halo is that 128GB unified memory. no "VRAM limit" — the GPU and CPU share the same pool. you can load models that would need a $2000 GPU on any other platform.

## benchmark results — Qwen3.5-35B-A3B

these are from `halo-bench.sh` — a benchmark script i wrote that tests prompt processing scaling, generation speed, context stress, reasoning, code gen, and concurrency. all tests hit the Lemonade API (OpenAI-compatible endpoint on localhost).

### prompt processing — scales beautifully

    Context Size    Prompt tok/s    TTFT
    ────────────    ────────────    ────
    16 tokens           269.5       111ms
    256 tokens          941.6       283ms
    1024 tokens       1,270.9       819ms
    4096 tokens       1,116.7     3,207ms
    8192 tokens       1,050.1     4,367ms

prompt processing peaks around 1K tokens and holds above 1000 tok/s even at 8K context. this is the HIPBLASLT + rocWMMA flash attention doing its thing.

### generation speed — rock solid

    Output Length    Gen tok/s
    ─────────────    ─────────
    50 tokens           58.0
    100 tokens          57.6
    250 tokens          57.2
    500 tokens          57.0
    1000 tokens         56.8

generation barely moves between 50 and 1000 tokens. 57 tok/s sustained is faster than most people read. for a 35B MoE model on integrated graphics, this is wild.

### context window stress

    Context Depth    Gen tok/s    Prompt tok/s
    ─────────────    ─────────    ────────────
    1K context          57.0       1,006.1
    4K context          55.6       1,116.7
    8K context          54.2       1,050.1

slight gen slowdown at 8K (54.2 vs 57.0) but prompt processing stays flat. unified memory means no PCIe bottleneck — the GPU is reading directly from the same DDR5.

### real tasks

    Task                    Gen tok/s    Prompt tok/s
    ────                    ─────────    ────────────
    Math reasoning             57.0         348.4
    Code reasoning             57.0         405.1
    Python async server        56.8         257.2
    Bash scripting             56.9         288.9

reasoning and code generation are the same speed as short responses. the model doesn't slow down when it has to think.

### memory

    llama-server RSS:     5.7 GB
    RAM delta during inference:  73 MB
    Total system RAM used:  44 GB / 128 GB

5.7GB RSS for a 35B model. 84GB still free. i could stack two or three of these.

## what makes it fast

the install script patches llama.cpp at build time:

- **MMQ kernel fix** — corrects register pressure on RDNA 3.5 (mmq_x=48, mmq_y=64, nwarps=4). without this patch, gfx1151 exceeds the 256 VGPR limit and loses ~20% perf
- **rocWMMA flash attention** — hardware-accelerated matrix multiply for attention layers
- **fast math intrinsics** — `__expf()` for MoE routing and SiLU activation
- **HIPBLASLT** — doubles prompt processing throughput
- **Vulkan backend** — Lemonade uses its own Vulkan-compiled llama.cpp, not ROCm

## the stack

everything is installed with one script:

```
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```

what it sets up:

- **Lemonade SDK** — AMD's LLM serving platform (native AUR package). manages models, serves OpenAI/Anthropic/Ollama-compatible APIs. has a web UI for chatting
- **llama.cpp** — compiled from source with HIP + Vulkan, patched for gfx1151
- **Gaia SDK** — AMD's agent framework. build AI agents that run 100% local
- **Caddy** — reverse proxy so everything is accessible on the network
- **WireGuard** — VPN with QR code for phone access
- **Claude Code** — launch directly with `lemonade launch claude -m <model>`

all systemd services, auto-start on boot, auto-restart on failure.

## the benchmark script

wrote `halo-bench.sh` specifically for this — it's in the repo. 8 test categories, multi-run with stddev, JSON + CSV + summary output:

```
./halo-bench.sh                          # full suite, all models
./halo-bench.sh -m Qwen3.5-35B-A3B -q   # quick, one model
./halo-bench.sh -r 5 --record           # 5 runs + asciinema
```

tests: prompt scaling, generation speed, context stress, reasoning, code gen, multi-turn conversation, instruction following, concurrency.

results: https://github.com/stampby/halo-ai-core/tree/main/bench-results

## other models tested

    Model                   Gen tok/s    Notes
    ─────                   ─────────    ─────
    Qwen3-Coder-30B-A3B       73.0       daily coding driver
    Qwen3.5-35B-A3B           57.0       general purpose
    Qwen3 8B                  90.0       fast, lightweight
    Gemma 4 27B               52.4       
    Bonsai 1.7B (1-bit)      260.0       vulkan, speed demon

## links

- repo: https://github.com/stampby/halo-ai-core
- benchmarks: https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Benchmarks.md
- benchmark script: https://github.com/stampby/halo-ai-core/blob/main/halo-bench.sh
- discord: https://discord.gg/dSyV646eBs

built this for myself but figured the numbers might help anyone looking at strix halo for local inference. AMA.

---

*designed and built by the architect*
