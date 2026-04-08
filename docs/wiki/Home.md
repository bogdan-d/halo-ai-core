# Halo AI Core Wiki

> Your hardware. Your data. Your rules.

Welcome to the Halo AI Core knowledge base. Everything you need to run a local AI platform on AMD hardware and build on top of it.

## Getting Started

- [Getting Started](Getting-Started.md) — Clone, install, verify in 5 minutes
- [Architecture](Architecture.md) — How the pieces fit together
- [Components](Components.md) — ROCm, Caddy, llama.cpp, Lemonade, Gaia in detail

## Core Guides

- [Security](Security.md) — SSH keys only, no exceptions
- [Security Hardening](Security-Hardening.md) — 7-layer lockdown: firewall, fail2ban, integrity, auto-updates
- [Systemd Services](Systemd-Services.md) — Managing your services
- [Caddy Routing](Caddy-Routing.md) — Adding and managing reverse proxy routes
- [ROCm Tuning](ROCm-Tuning.md) — GPU optimization for gfx1151

## Core Agents (Recommended)

- [Core Agents](Core-Agents.md) — 5 caretaker agents that watch your stack
- [Agent Deployment](Agent-Deployment.md) — How each agent introduces itself and deploys
- [Echo Deployment](Echo-Deployment.md) — The voice of Halo AI, personality sliders, platform config
- [Landing Page](Landing-Page.md) — The dashboard spec — hardware, services, agents, blocks
- [Discord](Discord.md) — Channel structure, agent rules, digest format

## Building On Core

- [Lego Blocks](Lego-Blocks.md) — Philosophy and how to add services
- [Adding a Service](Adding-a-Service.md) — Step-by-step template for new blocks
- [SSH Mesh](SSH-Mesh.md) — Multi-machine networking
- [Voice Pipeline](Voice-Pipeline.md) — Whisper + Kokoro + voice cloning
- [Network Layout](Network-Layout.md) — Three-tier network architecture

## AI & Models

- [Model Management](Model-Management.md) — Loading, switching, and benchmarking models
- [NPU Acceleration](NPU-Acceleration.md) — XDNA driver and FastFlowLM
- [Benchmarks](Benchmarks.md) — Performance numbers on Strix Halo
- [Agents Overview](Agents-Overview.md) — The 17 LLM actors and what they do

## Platform

- [Machine Fleet](Machine-Fleet.md) — Hardware specs and access
- [Build From Source](Build-From-Source.md) — The philosophy and how-to
- [Backup and Snapshots](Backup-and-Snapshots.md) — btrfs snapshots and recovery

## Reference

- [FAQ](FAQ.md) — Frequently asked questions
- [Troubleshooting](Troubleshooting.md) — Common issues and fixes
- [Roadmap](Roadmap.md) — What's coming next
- [Glossary](Glossary.md) — Terms and concepts

---

*Designed and built by the architect*

*"There is no spoon." — The Matrix*
