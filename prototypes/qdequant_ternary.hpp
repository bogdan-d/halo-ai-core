// Ternary (1.58-bit) dequantization for BitNet models.
// Extends qdequant.hpp with ternary weight support.
// Weights packed as 2-bit values: 0 → -1, 1 → 0, 2 → +1
//
// "Little bones, little bones, everywhere I go" — Gord Downie

#pragma once

#include "mlx/backend/rocm/quantized/qdequant.hpp"

namespace mlx::core::rocm {

// --- Ternary dequant-and-dot ---
//
// BitNet 1.58-bit uses ternary weights {-1, 0, 1} packed as 2-bit values.
// Mapping: 0b00 (0) → -1, 0b01 (1) → 0, 0b10 (2) → +1
//
// Unlike affine quantization, ternary has:
//   - No per-group scale/bias
//   - Global scale factor only
//   - Integer accumulation then single scale multiply
//
// The dot product simplifies to:
//   result = global_scale * sum(x[i] * ternary_weight[i])
// where ternary_weight is {-1, 0, 1}

template <int BITS>
__device__ __forceinline__ void dequant_and_dot_ternary(
    uint32_t packed,
    const float* __restrict__ x_local,
    float& acc)
{
  static_assert(BITS == 2, "Ternary dequant requires 2-bit packing");
  constexpr int pf = pack_factor_u32<BITS>;  // 16 values per uint32
  constexpr uint32_t mask = 0x3u;             // 2-bit mask

  #pragma unroll
  for (int i = 0; i < pf; i++) {
    // Extract 2-bit value: 0, 1, or 2
    uint32_t q = (packed >> (i * BITS)) & mask;
    // Map: 0 → -1, 1 → 0, 2 → +1
    // Equivalent to: (int)q - 1
    float w = static_cast<float>(static_cast<int>(q) - 1);
    acc += x_local[i] * w;
  }
}

// Vectorized ternary dequant for 4 packed uint32 values (64 weights)
__device__ __forceinline__ void dequant_and_dot_ternary_vec4(
    const uint32_t (&packed)[4],
    const float* __restrict__ x_local,
    float& acc)
{
  constexpr uint32_t mask = 0x3u;

  #pragma unroll
  for (int p = 0; p < 4; p++) {
    #pragma unroll
    for (int i = 0; i < 16; i++) {
      uint32_t q = (packed[p] >> (i * 2)) & mask;
      float w = static_cast<float>(static_cast<int>(q) - 1);
      acc += x_local[p * 16 + i] * w;
    }
  }
}

// Optimized ternary dequant using integer arithmetic
// Avoids float conversion until final accumulation
__device__ __forceinline__ void dequant_and_dot_ternary_int(
    uint32_t packed,
    const float* __restrict__ x_local,
    float& acc)
{
  constexpr uint32_t mask = 0x3u;

  // Process 4 values at a time using integer tricks
  #pragma unroll
  for (int i = 0; i < 16; i++) {
    uint32_t q = (packed >> (i * 2)) & mask;
    // Branch-free ternary: multiply by (q-1)
    // q=0: w=-1, q=1: w=0, q=2: w=1
    // When w=0, the multiply is free (0 * anything = 0)
    // When w=±1, it's just add/subtract
    int w = static_cast<int>(q) - 1;
    if (w != 0) {
      acc += (w == 1) ? x_local[i] : -x_local[i];
    }
  }
}

// --- Ternary GEMV kernel ---
//
// Specialized kernel for ternary matrix-vector multiply.
// Similar structure to qmv_fast_kernel but:
//   - No scale/bias per group
//   - Single global scale factor
//   - Ternary dequant instead of affine

template <typename T, int GROUP_SIZE>
__global__ __launch_bounds__(256)
void qmv_ternary_kernel(
    const T* __restrict__ x,           // [M, K]
    const uint32_t* __restrict__ w,    // [N, K/16] packed ternary
    const T* __restrict__ global_scale, // scalar or [1]
    T* __restrict__ out,               // [M, N]
    int M,
    int N,
    int K)
{
  constexpr int BITS = 2;
  constexpr int PF = pack_factor_u32<BITS>;      // 16 values per uint32
  constexpr int VPT = values_per_thread<BITS>;    // 16 values per thread per step

  int row = blockIdx.x;  // M dimension
  int col = blockIdx.y * ROWS_PER_BLOCK + threadIdx.y;  // N dimension

  if (col >= N) return;

  float acc = 0.0f;

  // Each thread in the warp processes a stripe of K
  int k_start = threadIdx.x * VPT;
  int k_stride = WARP_SIZE * VPT;  // 32 * 16 = 512

  for (int k = k_start; k < K; k += k_stride) {
    // Load x values into registers
    float x_local[VPT];
    #pragma unroll
    for (int v = 0; v < VPT; v++) {
      int idx = row * K + k + v;
      x_local[v] = (k + v < K) ? to_float(x[idx]) : 0.0f;
    }

    // Load packed ternary weights
    int w_idx = col * (K / PF) + k / PF;
    uint32_t packed = w[w_idx];

    // Ternary dot product
    dequant_and_dot_ternary<BITS>(packed, x_local, acc);
  }

  // Warp reduction
  acc = warp_reduce_sum(acc);

  // Thread 0 writes the result with global scale
  if (threadIdx.x == 0) {
    float scale = to_float(global_scale[0]);
    out[row * N + col] = from_float<T>(acc * scale);
  }
}

} // namespace mlx::core::rocm
