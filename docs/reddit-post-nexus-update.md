# Reddit Post — Nexus Update + Methodology Changes + Benchmarks

**Subreddit:** r/AMDStrixHalo

**Title:** 24 hours of community feedback — NPU is live, SSH Mixer is dead, new benchmarks methodology. Full changelog.

---

**PASTE BELOW THIS LINE:**

---

~~the kansas city shuffle — ssh mixer was our multi-machine networking solution. manual key exchange, ~/.ssh/config on every box, full mesh. it worked but it didn't scale.~~

~~deprecated. gone. replaced.~~

~~if you set it up from our old guide, it still works. but there's something better now.~~

---

## what replaced it

**Lemonade Nexus** — zero-trust WireGuard mesh VPN with cryptographic governance. built from source on Strix Halo in under 2 minutes.

- Ed25519 identity for every machine
- Shamir's Secret Sharing for root key distribution
- automatic WireGuard tunnel establishment
- no database — signed JSON on disk
- democratic governance for protocol changes

it's running right now. full details on how to set it up:

**→ [Nexus VPN Wiki Page](https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Nexus-VPN.md)**

---

## methodology changes — thank you

the last 24 hours changed how we do things. some of you called us out and you were right. credit where it's due.

**what changed:**

1. **benchmarking context** — we now test across multiple context depths (1K, 4K, 8K) instead of just short prompts. shows real-world degradation. previous numbers were valid but didn't tell the full story.

2. **LLM stack clarity** — no more confusion about what runs where. the stack is now cleanly separated:

```
FLM (NPU)         → small models, whisper STT
llama.cpp Vulkan   → GPU inference
llama.cpp ROCm     → GPU inference, ROCm-optimized
vLLM               → high-throughput serving
```

all compiled separately. all sit side by side. no wrappers.

3. **package management** — we built our own package manager. 16 packages tracked. independent from Arch's rolling updates. one `pacman -Syu` can't break our stack anymore.

4. **wiki-first** — no more long reddit posts with every detail. this is the teaser. full details are on the wiki. always.

---

## NPU is live

the XDNA2 NPU on Strix Halo is running inference. not "detected." running models.

- Llama 3.2 3B on NPU
- Qwen3 8B on NPU (with reasoning)
- Whisper v3 Turbo on NPU

firmware 1.1.2.65, CachyOS 7.0-rc3 kernel with BORE + LTO + native Zen 5.

took three kernel builds to get there. the stock 6.19 kernel detects the NPU fine but the inference stack needs 7.0+ for the right firmware path. we documented everything.

**→ [NPU Acceleration Wiki Page](https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/NPU-Acceleration.md)**

---

## halo-ai-core benchmarks

the numbers from the stable stack. `install.sh --yes-all` on Strix Halo hardware. no manual tuning.

```
Model                   Backend    Gen tok/s
─────                   ───────    ─────────
Qwen3-Coder-30B-A3B    Vulkan        73.0
Qwen3.5-35B-A3B        Vulkan        57.0
Qwen3 8B               Vulkan        90.0
Gemma 4 27B            Vulkan        52.4
Bonsai 1.7B (1-bit)    Vulkan       260.0
```

full benchmark tables with context depth, prompt processing, TTFT, memory usage:

**→ [Benchmarks Wiki Page](https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Benchmarks.md)**

---

## bleeding edge benchmarks (NPU)

these are from the CachyOS 7.0-rc3 kernel with FastFlowLM on the XDNA2 NPU. separate from the stable benchmarks above.

```
Model              Backend    Notes
─────              ───────    ─────
Llama 3.2 3B       NPU        Q4_1, 2.7GB footprint
Qwen3 8B           NPU        Q4_1, 5.6GB, reasoning mode
Whisper v3 Turbo   NPU        Q4_1, 0.62GB, speech-to-text
```

NPU runs alongside GPU. dedicated low-power inference while the GPU handles the heavy models. 8 compute columns. firmware 1.1.2.65.

full NPU numbers and the kernel build process:

**→ [Bleeding Edge Wiki Page](https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Blog-2026-04-13-Bleeding-Edge-Is-Live.md)**

---

## changelog — last 24 hours

```
+ CachyOS 7.0-rc3 kernel (BORE + LTO + native Zen 5)
+ NPU inference live (3 models confirmed)
+ Lemonade Nexus replaces SSH Mixer
+ Custom package manager (16 packages, web dashboard)
+ Gaia agent framework rebuilt
+ 10 README translations updated (11 languages total)
- SSH Mixer deprecated
- Medium articles deprecated (wiki only)
```

---

repo: https://github.com/stampby/halo-ai-core

wiki: https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Home.md

bleeding edge: https://github.com/stampby/halo-ai-core-bleeding-edge

discord: https://discord.gg/dSyV646eBs

---

*designed and built by the architect*
