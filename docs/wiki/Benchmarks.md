# Benchmarks

Honest numbers on BitNet-b1.58-2B-4T across five quants, measured on AMD
Strix Halo with the Radeon 8060S (gfx1151).

## PPL + KLD vs F16 reference

Corpus: WikiText-2 test (raw), 288,769 tokens, 564 chunks of n_ctx=512.
Reference: `bitnet-2b-f16.gguf` (4.6 GiB, the F16 from Microsoft's official
BitNet-b1.58-2B-4T release on HuggingFace).

| Quant   | Size    | PPL(Q)   | ΔPPL%    | KLD-mean  | KLD-99%  | Top-1 % |
|---------|--------:|---------:|---------:|----------:|---------:|--------:|
| F16     | 4.6 GiB | 82.20    | —        | —         | —        | 100.00  |
| Q8_0    | 2.4 GiB | 82.31    | +0.13%   | 0.00188   | 0.00569  | 96.63   |
| Q4_K_M  | 1.5 GiB | 82.26    | +0.07%   | 0.00419   | —        | 94.98   |
| **TQ1_0** | **1.1 GiB** | **82.47** | **+0.33%** | **0.00232** | **0.00715** | **96.27** |
| Q1_0    | 546 MiB | 7.7e+8   | BROKEN   | 16.64     | —        | 0.001   |

Numbers mean ± std. Full KLD percentile distributions and Δp histograms are in
the run logs at `/tmp/bitnet-eval/ppl_*_kld.log` on the measurement host.

## The honest reads

- **Q8_0 is effectively free.** Mean KLD 0.0019 bits/token — you're losing less
  than one thousandth of a bit per token vs F16. Top-1 agreement 96.6%. Half
  the model size.
- **Q4_K_M is clean for a 4-bit quant.** KLD 2.2× Q8 but still tiny in absolute
  terms (0.004 bits/token). Top-1 drops 1.65pp — expected.
- **TQ1_0 is the ship default.** llama.cpp's native ternary packing respects
  BitNet's {−1, 0, +1} structure. Size drops to 1.1 GiB (4× smaller than F16),
  KLD 0.0023 (better than Q4_K_M), top-1 96.3%. This is what we bundle in our
  release artifacts.
- **Q1_0 is a trap.** Generic llama.cpp q1_0 is a per-superblock 1-bit quant
  that assumes Gaussian-distributed weights. BitNet doesn't — it has three
  specific values. Applying q1_0 destroys the information. If anyone ships
  BitNet as q1_0, they haven't measured. Use TQ1_0.

## Decode speed

```
bitnet_decode /path/to/halo-1bit-2b.h1b --server 8080
# Steady-state greedy decode: ~85 tok/s on Strix Halo
```

Measured via repeated 256-token completions against the /v1/chat/completions
endpoint, with KV cache warm.

## The big PPL caveat

BitNet-b1.58-2B-4T on WikiText-2 scores PPL ~82 at F16. That's the honest
number. Llama-3.2-1B scores ~11 on the same corpus. Qwen2.5-1.5B scores ~10.

**Ternary training genuinely costs quality on out-of-distribution prose.**

The point of this table isn't "BitNet wins PPL." It's:

1. The relative gap between quants is what matters for the "is it stupid?"
   question. Q8 / Q4 / TQ1_0 all preserve whatever quality F16 has.
2. Ternary unlocks real deployment wins — 1.1 GiB model file, integer-only
   matmul paths, ~85 tok/s on consumer silicon. No other quant tier matches.
3. Distillation from a bf16 teacher is the next experiment to close the gap.
   See the [halo-1bit distillation spec](https://github.com/stampby/halo-1bit/blob/main/docs/16-distillation-spec.md).

## How to reproduce

```bash
# 1. Download BitNet-b1.58-2B-4T F16 from HuggingFace
huggingface-cli download microsoft/bitnet-b1.58-2B-4T-gguf ggml-model-i2_s.gguf
# Note: the official F16 is called bitnet-2b-f16.gguf in other mirrors

# 2. Quantize
llama.cpp/build/bin/llama-quantize bitnet-2b-f16.gguf bitnet-2b-q8_0.gguf Q8_0
llama.cpp/build/bin/llama-quantize bitnet-2b-f16.gguf bitnet-2b-q4_k_m.gguf Q4_K_M

# 3. Get WikiText-2 test corpus
curl -o wiki.test.parquet https://huggingface.co/datasets/Salesforce/wikitext/resolve/main/wikitext-2-raw-v1/test-00000-of-00001.parquet
python3 -c "
import pyarrow.parquet as pq
t = pq.read_table('wiki.test.parquet')
with open('wiki.test.raw','w') as f:
    for row in t.column('text').to_pylist():
        f.write(row)
"

# 4. First build the F16 logits baseline
llama.cpp/build/bin/llama-perplexity -m bitnet-2b-f16.gguf \
    -f wiki.test.raw -c 512 --kl-divergence-base f16_logits.kld

# 5. Run each quant against it
llama.cpp/build/bin/llama-perplexity -m bitnet-2b-q8_0.gguf \
    -f wiki.test.raw -c 512 --kl-divergence \
    --kl-divergence-base f16_logits.kld

# Same for q4_k_m, tq1_0, q1_0. Final numbers printed at the end.
```

Four llama-perplexity runs, ~10-15 min each on Strix Halo Vulkan backend.

## Related posts

- [Reddit r/MidlifeCrisisAI: "Speed Without Stupidity"](https://www.reddit.com/r/MidlifeCrisisAI/) — the KLD/PPL post with full percentile breakdowns
- [PrismML-Eng/Bonsai-demo #51](https://github.com/PrismML-Eng/Bonsai-demo/pull/51) — ROCm HIP Q1_0 benchmarks using the Prism llama.cpp fork
