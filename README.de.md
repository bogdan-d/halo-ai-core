<!--
Hinweis: Diese Übersetzung ist maschinell erstellt. Die englische README ist maßgeblich. PRs willkommen.
-->

> **Hinweis**: Diese Übersetzung ist maschinell erstellt. Die englische README ist maßgeblich. PRs willkommen.

<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | **Deutsch** | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### das 1-Bit-Monster — lokale KI-Inferenz, bare metal, kein Python zur Laufzeit

**rocm c++ · ternäre Gewichte (.h1b) · fusionierte HIP-Kernels · wave32 wmma · 17 c++-Spezialisten · null Telemetrie · null Cloud**

*stamped by the architect*

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![ROCm](https://img.shields.io/badge/ROCm_7.13-ED1C24?style=flat&logo=amd&logoColor=white)](https://github.com/ROCm/TheRock)
[![rocm-cpp](https://img.shields.io/badge/rocm--cpp-inference_engine-00d4ff?style=flat)](https://github.com/stampby/rocm-cpp)
[![agent-cpp](https://img.shields.io/badge/agent--cpp-17_specialists-00d4ff?style=flat)](https://github.com/stampby/agent-cpp)
[![halo-1bit](https://img.shields.io/badge/halo--1bit-.h1b_format-00d4ff?style=flat)](https://github.com/stampby/halo-1bit)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Reddit](https://img.shields.io/badge/Reddit-r/MidlifeCrisisAI-FF4500?style=flat&logo=reddit&logoColor=white)](https://www.reddit.com/r/MidlifeCrisisAI/)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

## was ist das

halo-ai core ist das **Installationsskript für das 1-Bit-Monster** — ein kompletter lokaler KI-Stack, der vollständig in C++ auf AMD-Strix-Halo-Hardware läuft. Kein Python zur Laufzeit. Keine Cloud. Keine Telemetrie. Keine Abos.

Ein Skript, drei Engineering-Repos:

| Repo | was es ist |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | die Inferenz-Engine. Reines HIP, fusionierte ternäre Kernels, OpenAI-kompatibler Server mit SSE-Streaming. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | das Agent-Framework. 17 Einzweck-Spezialisten auf einem Nachrichtenbus, Audit-Log mit Hash-Kette, Consent-Verification-Gate. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | das Modellformat (.h1b) + Trainings-Pipeline. absmean-ternär, QAT mit Straight-Through-Estimator, Distillation von bf16-Lehrern. |

halo-ai core klont sie, baut sie aus dem Quelltext, verdrahtet sie mit systemd und richtet einen caddy-Reverse-Proxy darauf. Ein Befehl, du bekommst ein laufendes LLM, eine Sprach-Schleife, einen Discord-Bot, einen CI-Runner und einen Audit-Trail. Alles lokal.

*"I know kung fu."*

## Installation

Zwei Pfade. Das Skript erkennt deine GPU automatisch und wählt.

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # auto: strixhalo → schnell; sonst → Quelltext
```

| Pfad | für wen | Zeit | was es tut |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 min | lädt vorgebaute Binaries von GH Releases, prüft SHA256 + GPG, verdrahtet systemd |
| [`./install-source.sh`](install-source.sh) | jede andere AMD-GPU | ~4 h | baut TheRock + rocm-cpp + agent-cpp + halo-1bit aus dem Quelltext für deine Arch |

**Kein Strix Halo?** Siehe [`release/KERNELS.md`](release/KERNELS.md).

## der Stack

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 C++-Spezialisten               │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP-Kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  ternäres Modell (.h1b v2) · halo-1bit Tokenizer (.htok) │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## Zahlen, die zählen

| Metrik | Wert |
|---|---|
| Decodier-Geschwindigkeit | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| Modellgröße | 1,1 GiB (TQ1_0) |
| KLD vs F16 | 0,0023 Bits/Token |
| Top-1-Übereinstimmung | 96,3% |
| Agent-Binary | 1,3 MB |
| Kaltstart | < 2s |
| Laufzeit-Deps | 0 Python |

## Philosophie

Python hat die LLM-Ära getragen. C++ besitzt die nächste. Python beim Training ist okay; Python zur Laufzeit auf eigener Hardware ist eine Last. **halo-ai core hat null Python zur Laufzeit.**

Die KI-Industrie will, dass du fremde Computer mietest. Wir denken, du solltest den ganzen Stack besitzen — die Hardware, die Modelle, die Gewichte, die Pipeline.

*"they get the kingdom. they forge their own keys."*

## Privatsphäre

**Null Telemetrie. Null Tracking. Null Datensammlung.** Nichts funkt nach Hause.

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
