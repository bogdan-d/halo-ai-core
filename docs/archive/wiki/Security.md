# Security

> "You take the red pill, you stay in Wonderland, and I show you how deep the rabbit hole goes." — Morpheus

## The Rule

**SSH keys only. No passwords. No open ports. No exceptions.**

All services bind to `localhost`. The only port open to the network is 22 (SSH). You access everything through SSH tunnels or by running commands remotely.

## Full Guide

See [docs/SECURITY.md](https://github.com/stampby/halo-ai-core/blob/main/docs/SECURITY.md) in the repo for:

- Key generation tutorial
- SSH config setup
- Multi-machine mesh
- Windows SSH quirks
- Hardening checklist
