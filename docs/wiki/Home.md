# halo-ai-core Wiki — the 1-bit monster

Local AI on AMD Strix Halo. No Python at runtime. No cloud. No telemetry. No subscriptions. All C++.

## Start here

- **[Getting-Started](Getting-Started.md)** — install, verify, first chat completion
- **[Architecture](Architecture.md)** — how the three engineering repos fit together
- **[Agents](Agents.md)** — the 17 C++ specialists and what each one does
- **[Integrations](Integrations.md)** — point your apps at the stack (curl, Python, Node, C++, WebUI)
- **[Networking](../NETWORKING.md)** — private mesh (Caddy + Headscale + Tailscale); phone / laptop / multi-node onboarding

## Reference

- **[Benchmarks](Benchmarks.md)** — PPL, KLD, top-1 agreement, decode speed; how to reproduce
- **[Troubleshooting](Troubleshooting.md)** — common failures and their fixes
- **[Contributing](Contributing.md)** — how to add arch coverage, submit community builds, port kernels to non-Strix hardware

## Project shape

```
halo-ai-core         ← you are here. the installer + orchestrator.
├── rocm-cpp         ← the inference engine (HIP, ternary kernels, HTTP server)
├── agent-cpp        ← the agent runtime (17 specialists on a message bus)
└── halo-1bit        ← the model format (.h1b) + training pipeline
```

All four repos MIT-licensed. Everything reproducible from source (`install-source.sh`),
everything fast-installable for Strix Halo (`install-strixhalo.sh`).

## Movie quotes we live by

- *"I know kung fu."*
- *"they get the kingdom. they forge their own keys."*
- *"there is no cloud. there is only zuul."*
- *"the 1-bit monster is already here. it just had to learn to count."*

— *stamped by the architect*
