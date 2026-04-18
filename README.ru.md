<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | **Русский** | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### 1-битный монстр — локальный AI-инференс, bare metal, ноль python в рантайме

**rocm c++ · тернарные веса (.h1b) · fused HIP-ядра · wave32 wmma · 17 c++ специалистов · ноль телеметрии · ноль облака**

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

## что это

halo-ai core — это **скрипт установки 1-битного монстра** — полный локальный AI-стек, работающий целиком на C++ на железе AMD Strix Halo. Ноль python в рантайме. Ноль облака. Ноль телеметрии. Ноль подписок.

Один скрипт, три инженерных репозитория:

| репо | что это |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | движок инференса. Чистый HIP, fused тернарные ядра, OpenAI-совместимый сервер с SSE-стримингом. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | фреймворк агентов. 17 однозадачных специалистов на шине сообщений, audit log с хэш-цепочкой, врата проверки согласия. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | формат модели (.h1b) + пайплайн обучения. absmean-тернарная квантизация, QAT со straight-through оценщиком, дистилляция из bf16-учителей. |

halo-ai core клонирует их, собирает из исходников, подключает к systemd, направляет caddy-реверс-прокси на результат. Одна команда — и у вас работающий LLM, голосовой цикл, discord-бот, CI-раннер и аудит-трейл. Всё локально.

*"I know kung fu."*

## установка

Два пути. Скрипт автоматически определяет ваш GPU и выбирает.

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # авто: strixhalo → быстро; иначе → из исходников
```

| путь | для кого | время | что делает |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 мин | качает предсобранные бинарники из GH Releases, проверяет SHA256 + GPG, подключает systemd |
| [`./install-source.sh`](install-source.sh) | любой другой AMD GPU | ~4 ч | собирает TheRock + rocm-cpp + agent-cpp + halo-1bit из исходников под вашу архитектуру |

**Не Strix Halo?** см. [`release/KERNELS.md`](release/KERNELS.md).

## стек

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 C++ специалистов               │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  тернарная модель (.h1b v2) · токенайзер halo-1bit       │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## числа, которые важны

| метрика | значение |
|---|---|
| скорость декодирования | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| размер модели | 1,1 GiB (TQ1_0) |
| KLD vs F16 | 0,0023 бит/токен |
| согласие top-1 | 96,3% |
| бинарник агента | 1,3 MB |
| холодный старт | < 2 с |
| зависимости в рантайме | 0 python |

## философия

Python пронёс эру LLM. C++ владеет следующей. Python на обучении — нормально; python в рантайме на вашем железе — обуза. **halo-ai core: ноль python в рантайме.**

AI-индустрия хочет, чтобы вы арендовали чужой компьютер. Мы считаем, что вы должны владеть всем стеком — железом, моделями, весами, пайплайном.

*"they get the kingdom. they forge their own keys."*

## приватность

**Ноль телеметрии. Ноль трекинга. Ноль сбора данных.** Ничто не звонит домой.

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
