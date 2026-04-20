<!--
Nota: esta tradução é gerada automaticamente. O README em inglês é a fonte autoritativa. PRs são bem-vindos.
-->

> **Nota**: esta tradução é gerada automaticamente. O README em inglês é a fonte autoritativa. PRs são bem-vindos.

<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | **Português** | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### o monstro de 1 bit — inferência IA local, bare metal, zero python em runtime

**rocm c++ · pesos ternários (.h1b) · kernels HIP fundidos · wave32 wmma · 17 especialistas c++ · zero telemetria · zero nuvem**

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

## o que é isso

halo-ai core é o **script de instalação do monstro de 1 bit** — uma stack IA local completa que roda inteiramente em C++ sobre hardware AMD Strix Halo. Zero python em runtime. Zero nuvem. Zero telemetria. Zero assinaturas.

Um script, três repos de engenharia:

| repo | o que é |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | o motor de inferência. HIP puro, kernels ternários fundidos, servidor compatível com OpenAI com streaming SSE. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | o framework de agentes. 17 especialistas de propósito único num bus de mensagens, log de auditoria com cadeia de hash, porta de verificação de consentimento. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | o formato de modelo (.h1b) + pipeline de treino. ternário absmean, QAT com estimador straight-through, destilação de professores bf16. |

halo-ai core clona, compila da fonte, liga ao systemd, e aponta um reverse proxy caddy para o resultado. Um comando, tens um LLM a correr, um loop de voz, um bot discord, um runner de CI, e um trilho de auditoria. Tudo local.

*"I know kung fu."*

## instalação

Dois caminhos. O script deteta a tua GPU e escolhe.

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # auto: strixhalo → rápido; resto → fonte
```

| caminho | para quem | tempo | o que faz |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 min | descarrega binários pré-compilados, verifica SHA256 + GPG, liga systemd |
| [`./install-source.sh`](install-source.sh) | qualquer outra GPU AMD | ~4 h | compila TheRock + rocm-cpp + agent-cpp + halo-1bit da fonte para a tua arch |

**Não é Strix Halo?** Ver [`release/KERNELS.md`](release/KERNELS.md).

## a stack

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 especialistas C++              │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — kernels HIP · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  modelo ternário (.h1b v2) · tokenizer halo-1bit (.htok) │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## números que importam

| métrica | valor |
|---|---|
| velocidade de descodificação | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| tamanho do modelo | 1,1 GiB (TQ1_0) |
| KLD vs F16 | 0,0023 bits/token |
| concordância top-1 | 96,3% |
| binário do agente | 1,3 MB |
| arranque a frio | < 2s |
| deps em runtime | 0 python |

## filosofia

Python carregou a era LLM. C++ é dono da próxima. Python em treino tudo bem; python em runtime em hardware teu é peso morto. **halo-ai core tem zero python em runtime.**

A indústria IA quer que alugues o computador de outra pessoa. Achamos que devias ter a stack toda — o hardware, os modelos, os pesos, o pipeline.

*"they get the kingdom. they forge their own keys."*

## privacidade

**Zero telemetria. Zero tracking. Zero recolha de dados.** Nada liga para casa.

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
