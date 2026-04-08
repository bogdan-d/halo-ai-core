# Machine Fleet

The reference setup runs across 5 machines on a 10.0.0.0/24 network.

## Hardware

| Machine | IP | CPU | GPU/Accel | RAM | Storage | Role |
|---------|-----|-----|-----------|-----|---------|------|
| Strix Halo | 10.0.0.10 | Ryzen AI MAX+ 395 | Radeon 8060S (128GB unified) + NPU | 128GB | 2TB NVMe | AI inference, core services |
| Sliger | 10.0.0.20 | i7-8700K | GTX 1080Ti | — | 2x 1.9TB NVMe | Game servers, voice training |
| Ryzen | 10.0.0.25 | Ryzen 9800X3D | — (CPU only) | 32GB | 4TB NVMe | Primary desktop, recording |
| Minisforum | 10.0.0.30 | — | — | — | — | Windows 11, office |
| Pi 5 | 10.0.0.40 | ARM Cortex-A76 | — | 8GB | 5x 1TB SATA | Media vault, backup |

## Management

| Device | IP | Purpose |
|--------|-----|---------|
| JetKVM (Strix) | 10.0.0.101 | Remote KVM for Strix Halo |
| JetKVM (Sliger) | 10.0.0.102 | Remote KVM for Sliger |
| Router (ET12) | 10.0.0.1 | Gateway, DHCP reservations |

## Access Rules

- **All machines**: SSH key-only, ed25519
- **Strix Halo**: SSH ONLY — no tunnels, no HTTPS, no port forwarding
- **Full bidirectional SSH mesh** — every machine reaches every other
- **JetKVMs** for physical console access when SSH is unavailable

## Network

See [[Network Layout]] for the full three-tier network architecture.

## You Don't Need All This

Halo AI Core runs on a single machine. The mesh is for scaling. Start with one Strix Halo and add machines when you need them.
