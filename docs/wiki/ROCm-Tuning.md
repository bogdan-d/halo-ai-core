# ROCm Tuning for gfx1151

AMD Strix Halo uses the gfx1151 GPU architecture. Here's how to get the most out of it.

## Environment Variables

Set in `/etc/profile.d/rocm.sh` (the installer handles this):

```bash
export PATH=$PATH:/opt/rocm/bin
export ROCBLAS_USE_HIPBLASLT=1        # Better BLAS performance
export PYTORCH_ROCM_ARCH=gfx1151     # Target arch for source builds
export HSA_OVERRIDE_GFX_VERSION=11.5.1  # Version override for compatibility
export IOMMU=pt                       # Pass-through mode for GPU
```

## Verify GPU Access

```bash
rocminfo | grep "Marketing Name"
# Should show: Radeon 8060S Graphics

rocm-smi
# Shows temperature, utilization, VRAM usage
```

## VRAM

Strix Halo has **128GB unified memory**. The GPU can access up to ~64GB VRAM (half of unified). This means:

- You can load **70B+ parameter models** in full precision
- Multiple models can run simultaneously
- No need for quantization on most models (but GGUF quantized models run faster)

## Known gfx1151 Notes

- gfx1100 kernels are 2-6x faster than gfx1151 on some workloads
- AOTriton provides 19x attention speedup — install if doing training
- Wave Size is 32 (not 64 like older AMD GPUs)
- VMM (Virtual Memory Management) not supported — model must fit in VRAM

## Building Software for gfx1151

When compiling anything with ROCm support:

```bash
export HIP_PATH=/opt/rocm
export ROCM_PATH=/opt/rocm
cmake -DAMDGPU_TARGETS=gfx1151 \
      -DCMAKE_HIP_COMPILER=/opt/rocm/bin/amdclang++ \
      ...
```

## NPU Coexistence

Strix Halo also has an NPU (RyzenAI-npu5). GPU and NPU can run simultaneously:

- GPU: Large models, image generation, heavy inference
- NPU: Small models (0.6B-2B), always-on tasks, voice detection

See [[NPU Acceleration]] for setup.

## Benchmarks

See [[Benchmarks]] for full performance numbers.
