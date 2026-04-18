<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | **Español** | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### el monstruo de 1 bit — inferencia IA local, bare metal, cero python en runtime

**rocm c++ · pesos ternarios (.h1b) · kernels HIP fusionados · wave32 wmma · 17 especialistas c++ · cero telemetría · cero nube**

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

## qué es esto

halo-ai core es el **script de instalación del monstruo de 1 bit** — una pila IA local completa que corre entera en C++ sobre hardware AMD Strix Halo. cero python en runtime. cero nube. cero telemetría. cero suscripciones.

un script, tres repositorios de ingeniería:

| repo | qué es |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | el motor de inferencia. HIP puro, kernels ternarios fusionados, servidor compatible con OpenAI con streaming SSE. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | el framework de agentes. 17 especialistas de un solo propósito sobre un bus de mensajes, registro de auditoría con cadena de hash, puerta de verificación de consentimiento. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | el formato de modelo (.h1b) + pipeline de entrenamiento. ternario absmean, QAT con estimador straight-through, destilación desde profesores bf16. |

halo-ai core los clona, los compila desde fuente, los conecta a systemd, y apunta un reverse proxy caddy al resultado. un comando, obtienes un LLM corriendo, un bucle de voz, un bot de discord, un runner de CI, y un rastro de auditoría. todo local.

*"I know kung fu."*

## instalación

dos caminos. el script detecta tu GPU y elige.

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # auto: strixhalo → rápido; resto → fuentes
```

| camino | para quién | tiempo | qué hace |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 min | descarga binarios pre-compilados, verifica SHA256 + GPG, conecta systemd |
| [`./install-source.sh`](install-source.sh) | cualquier otra GPU AMD | ~4 h | compila TheRock + rocm-cpp + agent-cpp + halo-1bit desde fuentes para tu arch |

**no es un Strix Halo?** ver [`release/KERNELS.md`](release/KERNELS.md).

## la pila

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
│  modelo ternario (.h1b v2) · tokenizer halo-1bit (.htok) │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## números que importan

| métrica | valor |
|---|---|
| velocidad de decodificación | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| tamaño del modelo | 1,1 GiB (TQ1_0) |
| KLD vs F16 | 0,0023 bits/token |
| acuerdo top-1 | 96,3% |
| binario agente | 1,3 MB |
| arranque en frío | < 2s |
| deps runtime | 0 python |

## filosofía

python llevó la era LLM. C++ posee la siguiente. python en entrenamiento está bien; python en runtime sobre hardware que posees es un lastre. **halo-ai core tiene cero python en runtime.**

la industria IA quiere que alquiles la computadora de otro. creemos que deberías poseer toda la pila — el hardware, los modelos, los pesos, el pipeline.

*"they get the kingdom. they forge their own keys."*

## privacidad

**cero telemetría. cero rastreo. cero recolección de datos.** nada llama a casa.

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
