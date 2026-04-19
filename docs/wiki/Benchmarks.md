# Benchmarks

Honest numbers for the 1-bit monster on AMD Strix Halo (Radeon 8060S, gfx1151,
ROCm 7.13.0, wave32 WMMA).

## The headline table

| metric | value | note |
|---|---|---|
| **decode speed @ 64 ctx** | **83 tok/s** | BitNet-b1.58-2B, greedy, Strix Halo |
| **decode speed @ 1024 ctx** | **68.6 tok/s** | same model, long context (split-KV FD attn) |
| **prefill** | ~88 tok/s | steady across all context sizes |
| **PPL @ 1k wikitext-103** | **9.16** | matches Microsoft's BitNet-b1.58-2B paper baseline |
| **model size** | 1.1 GiB | TQ1_0-packed .h1b, 4× smaller than F16 |
| **KLD vs F16** | 0.0023 | mean bits/token — indistinguishable in practice |
| **top-1 agreement** | 96.3% | vs F16 reference, same argmax token |
| **agent binary** | 1.3 MB | `agent_cpp`, statically linked |
| **cold start** | < 2 s | `bitnet_decode --server` |
| **runtime deps** | 0 python | libc, pthreads, httplib, nlohmann-json, OpenSSL |

Full context-sweep (post-RoPE-fix + split-KV FD default, 2026-04-19):
`N=64 → 83.1 tok/s · N=256 → 73.5 · N=512 → 71.1 · N=1024 → 68.6`. That is a
**1.83× lift at 1024 context** vs the pre-session baseline (37.5 → 68.6).

## Recent improvements (2026-04-19)

| kernel / fix | effect | verified |
|---|---|---|
| **RoPE split-half convention** | PPL @ 1k wikitext-103: broken → **9.16** (paper baseline) | bit-exact vs HF reference |
| Sherry ternary GEMV (LDS bank-conflict fix) | **1.44–1.66× halo v2** microbench | `max \|halo − sherry\| = 0` |
| TQ1 ternary GEMV (`__builtin_amdgcn_perm` repack) | **1.45–1.66× halo, 197 GB/s** microbench | `max \|halo − tq1\| = 0` |
| Split-KV Flash-Decoding attention | up to **6.78× at L=2048** microbench | `max \|fp16 − fd\| < 2e-4` |
| `bitnet_decode --ppl <file>` | teacher-forced PPL harness + wikitext-103 on disk | new in this release |

The RoPE fix was the big one: our kernel paired `(x[2i], x[2i+1])` (GPT-NeoX
interleaved) instead of the Llama-family `(x[i], x[i + hd/2])` split-half. At
pos=0 both conventions are identity; drift accumulates past pos ~100 and was
catastrophic by 1k-context. Fix: one-line kernel swap in
`rocm-cpp/src/prim_kernels.hip`.

## PPL methodology

```bash
bitnet_decode <model.h1b> --ppl <text.txt> [max_tokens=4095] [tokenizer.htok]
# JSON line on stdout:
# {"scored":N,"mean_nll":F,"perplexity":F,"elapsed_s":F,"tok_per_s":F}
```

Single-window teacher-forced forward over tokens, accumulates `-log_softmax`
at the target token, reports `exp(mean_NLL)`. Progress to stderr every 64
tokens. No sliding stride yet (planned); pass `max_tokens ≤ 4095` for the
model's 4096 ctx.

**Dataset**: wikitext-103 test split at
`/home/bcloud/halo-ai/datasets/wikitext-103-test.txt` (~300K HF tokens,
downloaded via `datasets` from `Salesforce/wikitext`, `wikitext-103-v1`).

Expected outputs: `mean_nll ≈ 2.21`, `perplexity ≈ 9.16` on a 1k-token window.

## Decode speed

```
bitnet_decode /path/to/halo-1bit-2b.h1b --server 8080
# Steady-state greedy decode: ~83 tok/s @ 64 ctx (68.6 @ 1024) on Strix Halo
```

Measured via repeated 256-token completions against `/v1/chat/completions`
with KV cache warm. The ternary GEMV runs at ~92% of LPDDR5-8000 peak
bandwidth; the attention path is now split-KV Flash-Decoding (default since
2026-04-19), so long-context generation stays fast.

## KLD vs F16 (weight-quant fidelity)

Corpus: WikiText-2 test (raw), 288,769 tokens, 564 chunks of n_ctx=512.
Reference: `bitnet-2b-f16.gguf` from the Microsoft BitNet-b1.58-2B-4T release.
This table compares llama.cpp quants against F16 to establish that the
quantization is faithful — separate question from the absolute PPL number
above.

| Quant   | Size    | ΔPPL%    | KLD-mean  | KLD-99%  | Top-1 % |
|---------|--------:|---------:|----------:|---------:|--------:|
| Q8_0    | 2.4 GiB |  +0.13%  | 0.00188   | 0.00569  | 96.63   |
| Q4_K_M  | 1.5 GiB |  +0.07%  | 0.00419   | —        | 94.98   |
| **TQ1_0** | **1.1 GiB** | **+0.33%** | **0.00232** | **0.00715** | **96.27** |
| Q1_0    | 546 MiB |  BROKEN  | 16.64     | —        |  0.001  |

TQ1_0 (llama.cpp's native ternary packing — 5 ternaries per byte, base-3)
respects BitNet's {−1, 0, +1} structure. Generic Q1_0 assumes Gaussian
weights and destroys BitNet's information. If anyone ships BitNet as Q1_0,
they haven't measured. Use TQ1_0.

## How to reproduce

### PPL on wikitext-103 (halo-ai direct)

```bash
# 1. Grab the test split (one-time)
python3 -c "
from datasets import load_dataset
ds = load_dataset('Salesforce/wikitext', 'wikitext-103-v1', split='test')
open('/home/bcloud/halo-ai/datasets/wikitext-103-test.txt','w').write(
    '\n'.join(ds['text'])
)
"

# 2. Run the harness
./bitnet_decode /home/bcloud/halo-ai/models/halo-1bit-2b.h1b \
    --ppl /home/bcloud/halo-ai/datasets/wikitext-103-test.txt 1024

# Expected: {"scored":1024,"mean_nll":~2.21,"perplexity":~9.16,...}
```

### KLD + quant comparison (llama.cpp)

```bash
# F16 baseline
llama-perplexity -m bitnet-2b-f16.gguf -f wiki.test.raw -c 512 \
    --kl-divergence-base f16_logits.kld

# Each quant against it
llama-perplexity -m bitnet-2b-tq1_0.gguf -f wiki.test.raw -c 512 \
    --kl-divergence --kl-divergence-base f16_logits.kld
```

Four llama-perplexity runs, ~10-15 min each on Strix Halo. Numbers printed at
the end of each run.

### Decode throughput

```bash
# Warm the cache with a short completion, then time 256 tokens.
./bench.sh                       # from orchestrator/
```

## Related posts

- [Reddit r/MidlifeCrisisAI: "Speed Without Stupidity"](https://www.reddit.com/r/MidlifeCrisisAI/) — the KLD/PPL post with full percentile breakdowns
- [docs/benchmark-comparison.md](../benchmark-comparison.md) — wider cross-backend numbers
- [docs/replicate.md](../replicate.md) — step-by-step rebuild
