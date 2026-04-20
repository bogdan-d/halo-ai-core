<!--
注意：此翻译由机器生成。英文 README 为权威版本。欢迎提交 PR。
-->

> **注意**：此翻译由机器生成。英文 README 为权威版本。欢迎提交 PR。

<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | **中文** | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### 1-bit 怪兽 — 本地 AI 推理、裸机、运行时零 python

**rocm c++ · 三值权重 (.h1b) · 融合 HIP 内核 · wave32 wmma · 17 个 c++ 专家 · 零遥测 · 零云**

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

## 这是什么

halo-ai core 是 **1-bit 怪兽的安装脚本** — 一个完整的本地 AI 栈,完全用 C++ 运行在 AMD Strix Halo 硬件上。运行时零 python。零云。零遥测。零订阅。

一个脚本,三个工程仓库:

| 仓库 | 是什么 |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | 推理引擎。纯 HIP、融合的三值内核、带 SSE 流的 OpenAI 兼容服务器。 |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | 智能体框架。消息总线上的 17 个单职能专家、哈希链审计日志、同意验证门。 |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | 模型格式 (.h1b) + 训练流水线。absmean 三值化、带直通估计的 QAT、从 bf16 教师的蒸馏。 |

halo-ai core 克隆它们、从源码构建、接入 systemd、让 caddy 反向代理指向结果。一条命令,就有一个运行的 LLM、一个语音循环、一个 discord 机器人、一个 CI 运行器、一条审计轨迹。全部本地。

*"I know kung fu."*

## 安装

两条路径。脚本自动检测你的 GPU 并选择。

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # 自动:strixhalo → 快速;其他 → 源码
```

| 路径 | 给谁 | 时间 | 做什么 |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | 约 5 分钟 | 从 GH Releases 下载预构建二进制文件,验证 SHA256 + GPG,接入 systemd |
| [`./install-source.sh`](install-source.sh) | 任何其他 AMD GPU | 约 4 小时 | 为你的架构从源码构建 TheRock + rocm-cpp + agent-cpp + halo-1bit |

**不是 Strix Halo?** 参见 [`release/KERNELS.md`](release/KERNELS.md)。

## 栈

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 个 C++ 专家                    │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  三值模型 (.h1b v2) · halo-1bit 分词器 (.htok)            │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## 重要数字

| 指标 | 值 |
|---|---|
| 解码速度 | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| 模型大小 | 1.1 GiB (TQ1_0) |
| KLD vs F16 | 0.0023 bits/token |
| Top-1 一致 | 96.3% |
| 智能体二进制 | 1.3 MB |
| 冷启动 | < 2 秒 |
| 运行时依赖 | 0 python |

## 哲学

Python 承载了 LLM 时代。C++ 拥有下一个。训练时用 Python 没问题;在你自己的硬件上运行时用 Python 是负担。**halo-ai core 运行时零 python。**

AI 产业想让你租别人的电脑。我们认为你应该拥有整个栈 — 硬件、模型、权重、流水线。

*"they get the kingdom. they forge their own keys."*

## 隐私

**零遥测。零追踪。零数据收集。** 什么都不回家。

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
