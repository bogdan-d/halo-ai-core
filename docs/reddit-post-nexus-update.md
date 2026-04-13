# Reddit Post — Kansas City Shuffle → Nexus Update

**Subreddit:** r/AMDStrixHalo

**Title:** Update: SSH Mixer deprecated — replaced by Lemonade Nexus. New benchmarks methodology. NPU is live.

---

**PASTE BELOW THIS LINE:**

---

~~the kansas city shuffle — ssh mixer was our multi-machine networking solution. manual key exchange, ~/.ssh/config on every box, full mesh.~~

~~it worked. but it didn't scale. every new machine meant touching every existing machine.~~

~~deprecated. if you set it up, it still runs. but there's something better now.~~

---

## what replaced it

**Lemonade Nexus** — zero-trust WireGuard mesh VPN with cryptographic governance. part of the Lemonade SDK.

- Ed25519 identity for every machine
- Shamir's Secret Sharing for root key distribution
- automatic WireGuard tunnel establishment with STUN hole-punching
- democratic governance — protocol changes need Tier 1 majority vote
- no database — signed JSON on disk
- 5-layer security model (Ed25519 → WireGuard → Zero-Trust → TEE Attestation → Democratic Governance)

built from source on Strix Halo in under 2 minutes. running right now.

**our guide (customized for halo-ai-core):**

→ https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Nexus-VPN.md

**original Lemonade Nexus documentation:**

→ https://github.com/lemonade-sdk/lemonade-nexus

---

## what else changed in 24 hours

based on community feedback we changed how we benchmark and how the stack works. credit where it's due — you made this better.

**1. NPU is live.** the XDNA2 on Strix Halo is running inference. Llama 3.2 3B, Qwen3 8B, Whisper v3 Turbo. all on the NPU. took three kernel builds to get there.

**2. new benchmarks methodology.** we now test across multiple context depths. previous numbers were valid but didn't tell the full story.

**3. clean inference stack.** FLM on NPU. llama.cpp Vulkan and ROCm on GPU. vLLM for serving. all separate. no wrappers.

**4. custom package manager.** 16 packages tracked. independent from Arch rolling updates. web dashboard.

full details on all of this:

→ https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Blog-2026-04-13-Bleeding-Edge-Is-Live.md

---

## benchmarks

**stable stack (halo-ai-core):**

```
Qwen3-Coder-30B-A3B    73.0 tok/s
Qwen3.5-35B-A3B        57.0 tok/s
Qwen3 8B               90.0 tok/s
Gemma 4 27B            52.4 tok/s
```

→ https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Benchmarks.md

**bleeding edge (NPU — CachyOS 7.0-rc3):**

```
Llama 3.2 3B     NPU    Q4_1
Qwen3 8B         NPU    Q4_1 (reasoning mode)
Whisper v3       NPU    Q4_1 (speech-to-text)
```

→ https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Blog-2026-04-13-Bleeding-Edge-Is-Live.md

---

repo: https://github.com/stampby/halo-ai-core

wiki: https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Home.md

discord: https://discord.gg/dSyV646eBs

---

*designed and built by the architect*
