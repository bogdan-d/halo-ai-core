# BitNet 1.58-bit on MLX ROCm — Prototype Specification

> *"Little bones, little bones, everywhere I go" — Gord Downie*

## What Exists

The MLX ROCm backend already supports 2-bit affine quantization:
- `qdequant.hpp`: pack/unpack 2-bit values from uint32 (16 values per word)
- `qmv_kernel.hip`: GEMV with 2-bit support
- `qmm.hip`: GEMM with 2-bit dispatch
- Warp reduction, coalesced loads, vectorized paths — all working

## What's Needed

### 1. Add `Ternary` to QuantizationMode

**File:** `mlx/primitives.h:155`

```cpp
// Before:
enum class QuantizationMode { Affine, Mxfp4, Mxfp8, Nvfp4 };

// After:
enum class QuantizationMode { Affine, Ternary, Mxfp4, Mxfp8, Nvfp4 };
```

### 2. Add ternary dequant kernel

**New file:** `mlx/backend/rocm/quantized/qdequant_ternary.hpp`

Core function — replaces affine `scale * q + bias` with direct mapping `q - 1`:

```cpp
template <int BITS>
__device__ __forceinline__ void dequant_and_dot_ternary(
    uint32_t packed,
    const float* __restrict__ x_local,
    float& acc)
{
  static_assert(BITS == 2, "Ternary requires 2-bit packing");
  constexpr int pf = pack_factor_u32<BITS>;  // 16 values per uint32
  constexpr uint32_t mask = 0x3u;

  #pragma unroll
  for (int i = 0; i < pf; i++) {
    uint32_t q = (packed >> (i * BITS)) & mask;
    // Map: 0 → -1, 1 → 0, 2 → +1
    float w = static_cast<float>(static_cast<int>(q) - 1);
    acc += x_local[i] * w;
  }
}
```

### 3. Add ternary GEMV kernel

**File:** `mlx/backend/rocm/quantized/qmv_ternary_kernel.hip`

Same structure as `qmv_fast_kernel` but:
- No per-group scale/bias loads
- Single global scale factor
- Ternary dequant instead of affine
- Simpler memory access pattern (no scales/biases arrays)

### 4. Dispatch in qmm.hip

Add ternary path to the quantized matmul dispatch:

```cpp
if (mode_ == QuantizationMode::Ternary) {
  // Ternary: 2-bit packed, global scale only, no bias
  // Launch qmv_ternary_kernel
}
```

### 5. Model loader

BitNet models store weights as packed 2-bit ternary in safetensors. The model loader needs to:
- Detect `model_type: "bitnet"` in config.json
- Set `QuantizationMode::Ternary` instead of `Affine`
- Read global scale from model config
- Skip per-group scale/bias loading

## Kernel Differences: Affine vs Ternary

| | Affine (current) | Ternary (new) |
|---|---|---|
| Bit width | 2/4/5/6/8 | 2 only |
| Scale | Per-group array | Single global scalar |
| Bias | Per-group array | None |
| Dequant | `scale * q + bias` | `q - 1` (→ {-1, 0, 1}) |
| Memory loads | weights + scales + biases | weights + 1 scalar |
| Bandwidth | ~2.5 bits/param effective | ~2 bits/param effective |

## Expected Performance Gain

Ternary weights reduce memory bandwidth by ~50% vs 4-bit:
- 4-bit: 0.5 bytes per weight + scale/bias overhead
- Ternary: 0.25 bytes per weight + 1 global scalar

On unified memory (128GB bandwidth-limited), this should roughly **double tok/s** for bandwidth-bound models. A 4-bit model at 46.9 tok/s could hit ~80-90 tok/s in 1-bit.

## Files to Modify

```
mlx/primitives.h                                    — Add Ternary to enum
mlx/backend/rocm/quantized/qdequant_ternary.hpp     — New: ternary dequant
mlx/backend/rocm/quantized/qmv_ternary_kernel.hip   — New: ternary GEMV
mlx/backend/rocm/quantized/qmm.hip                  — Add ternary dispatch
mlx/backend/rocm/quantized/quantized.cpp             — Add ternary entry point
```

Plus model loader changes in the lemon-mlx-engine layer (not in MLX core).

## Prototype Written

Full ternary dequant header: `/tmp/qdequant_ternary.hpp`

---

*Stamped by the architect.*
