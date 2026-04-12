<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | **中文** | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### 面向amd strix halo的裸机ai基础平台

**8个核心服务 · 128gb统一内存 · lemonade + llama.cpp + kokoro tts · 零云端 · 乐高积木**

*由架构师盖章*

[![CI](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml)
[![CodeQL](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.12.0-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![Lemonade](https://img.shields.io/badge/Lemonade_10.2.0-00d4ff?style=flat&logo=amd&logoColor=white)](https://github.com/lemonade-sdk/lemonade)
[![Kokoro TTS](https://img.shields.io/badge/Kokoro_TTS-ff6b35?style=flat)](https://github.com/remsky/Kokoro-FastAPI)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_pages-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-articles-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutorials-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Security-SSH_Only-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)
[![Bleeding Edge](https://img.shields.io/badge/⚠_Bleeding_Edge-kernel_7.0_+_NPU-ff4444?style=flat)](https://github.com/stampby/halo-ai-core-bleeding-edge)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24页文档 · **[discord](https://discord.gg/dSyV646eBs)** — 社区 + 技术支持 · **[教程](https://www.youtube.com/@DirtyOldMan-1971)** — 视频演示

---

## 这是什么

在自己的硬件上运行本地ai的基础层。一个脚本安装一切。八个步骤，全部systemd，全部自动重启，所有流量经由lemonade server :13305。仅限ssh。*"i know kung fu."* *(我会功夫。)*

## 安装

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # 先看看会发生什么
./install.sh --yes-all    # 安装所有内容
./install.sh --status     # 检查运行状态
```

[![Install Demo](https://img.shields.io/badge/asciinema-观看安装演示-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *在strix halo硬件上约3分钟*

## 你会得到什么

| | |
|---|---|
| **gpu** | rocm 7.12.0 — gfx1151上完整的128gb统一内存 |
| **推理** | llama.cpp (Vulkan) — 通过lemonade的llamacpp后端。无需编译。*(感谢 u/Look_0ver_There)* |
| **后端** | lemonade server 10.2.0 — :13305上的统一路由器。兼容openai + anthropic + ollama |
| **语音** | kokoro tts (cpu) + whisper.cpp (vulkan) — 语音识别和语音合成 |
| **编程** | claude code — 本地ai编程代理，通过lemonade启动 |
| **网关** | caddy 2.x — :80上的仪表板 |
| **vpn** | wireguard — 扫描二维码，从手机访问你的技术栈 |
| **仪表板** | :5090上的状态服务器 — gpu、内存、服务、开机自动加载 |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     统一路由器 — 所有api，所有后端                    │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│  Claude Code  │  仪表板 (:5090)  │ WireGuard     │
├───────────────┴──────────────────┴───────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[观看完整安装过程](halo-ai-core-install.cast)** — 在strix halo上录制的全新安装。克隆仓库并运行`asciinema play halo-ai-core-install.cast`实时观看。

## 基准测试 — 开箱即用

这些数据来自strix halo硬件上的全新`install.sh --yes-all`。无手动调优。无技巧。安装脚本自动应用所有优化。基准测试通过claude code经由lemonade sdk api执行。

| 模型 | 量化 | 测试 | 提示词 tok/s | 生成 tok/s | TTFT |
|------|------|------|-------------|-----------|------|
| qwen3-30B-A3B | Q4_K_M | 短 (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | 中 (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | 长 (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | 持续 (54→2048) | **437.0** | **70.5** | 124ms |

*2048个token上稳定的70-73 tok/s生成速度，零衰减。64gb显存中使用18gb。ttft低于200ms。测试于2026-04-08。*

### 为什么这么快

- **lemonade server** — :13305上的统一路由器。兼容openai、anthropic和ollama。一个端点搞定一切。
- **llama.cpp (Vulkan)** — 通过Lemonade提供的预编译Vulkan后端。无需编译，无需补丁。在任何Vulkan GPU上运行。*(h/t u/Look_0ver_There)*
- **kokoro tts** — 快速的cpu语音合成。支持9种语言。
- **whisper.cpp (Vulkan)** — gpu加速的语音识别。
- **gfx1151优化** — 每个二进制文件都精确针对你的芯片。没有通用构建。
- **128gb统一内存** — 没有显存限制。轻松加载35B模型。

你不需要去找它们。你不需要配置它们。`install.sh`替你完成。这就是重点。

## 即时移动访问 — 扫码即连

安装完成后，终端中会出现一个二维码。打开手机上的wireguard应用，扫描它，即可连接到你的整个ai技术栈。无需端口转发。无需云中继。无需配置。扫码即连。

```
  ┌──────────────────────────────────────────┐
  │  用手机扫描                                │
  │  WireGuard应用 → + → 扫描二维码            │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (你的二维码在这里)

  手机VPN IP: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

wireguard vpn。加密隧道。你的手机通过本地网络直接与技术栈通信。在wifi范围内任何地方都能使用 — 如果你转发udp 51820，则全球任何地方都可以。

> *功能由zach barrow建议。巨大的胜利。bravo。*

## 理念

每一块都能卡入和拔出。没有硬依赖。没有供应商锁定。没有云端束缚。

ai行业想让你租用别人的电脑。我们认为你应该拥有整个技术栈 — 硬件、模型、数据、流水线。当你掌控自己的软件时，你就掌控了自己的命运。不会有api密钥在凌晨2点过期。不会有服务条款在你脚下悄然改变。

这就是core。其他一切都是你选择添加的乐高积木。

> *"they get the kingdom. they forge their own keys."* *(他们得到王国。他们锻造自己的钥匙。)*

## 集成付费服务

本地优先。需要时再上云。一个链接，所有主流ai提供商。

<div align="center">

[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=flat-square&logo=openai&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Anthropic](https://img.shields.io/badge/Anthropic-191919?style=flat-square&logo=anthropic&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Gemini](https://img.shields.io/badge/Gemini-4285F4?style=flat-square&logo=googlegemini&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Azure](https://img.shields.io/badge/Azure_AI-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Mistral](https://img.shields.io/badge/Mistral-FF7000?style=flat-square&logo=mistral&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Groq](https://img.shields.io/badge/Groq-F55036?style=flat-square&logo=groq&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![OpenRouter](https://img.shields.io/badge/OpenRouter-6467F2?style=flat-square&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Perplexity](https://img.shields.io/badge/Perplexity-20808D?style=flat-square&logo=perplexity&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![ElevenLabs](https://img.shields.io/badge/ElevenLabs-000000?style=flat-square&logo=elevenlabs&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Replicate](https://img.shields.io/badge/Replicate-000000?style=flat-square&logo=replicate&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Cohere](https://img.shields.io/badge/Cohere-39594D?style=flat-square&logo=cohere&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Stability](https://img.shields.io/badge/Stability_AI-9B59B6?style=flat-square&logoColor=white)](https://github.com/stampby/halo-ai.services)

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — 集成指南、路由模式、api密钥管理

</div>

> *"sometimes you gotta run before you can walk."* *(有时你得先跑才能走。)* — halo-ai在本地运行。付费服务是逃生通道，不是基础。

## 乐高积木

core是基础。按需拼接：

| 积木 | 功能 | 状态 |
|------|------|------|
| **ssh mesh** | 多机网络（默认，任何地方都能用） | [指南 →](docs/wiki/SSH-Mesh.md) |
| **vlan tagging** | 802.1Q网络隔离（需要网管交换机） | [指南 →](docs/wiki/Network-Layout.md) |
| **语音流水线** | whisper + kokoro tts | [指南 →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | 聊天前端 | 计划中 |
| **comfyui** | 图像/视频生成 | 计划中 |
| **游戏服务器** | 游戏厅管理 | 计划中 |
| **glusterfs** | 分布式存储 | 计划中 |
| **discord 机器人** | discord中的ai智能体 | 计划中 |

[如何构建你自己的积木 →](docs/wiki/Adding-a-Service.md)

## 开箱即用

安装core，打开浏览器，开始和你的ai对话。无需命令行。

## 推荐：核心智能体

core无需智能体即可运行。但这五个会在你不在时守护你的技术栈。

| 智能体 | 职责 |
|--------|------|
| **sentinel** | 安全 — 扫描、监控、不信任任何事物 |
| **meek** | 审计员 — 17项日常审计、供应链检查 |
| **shadow** | 完整性 — ssh密钥、文件哈希、mesh健康 |
| **pulse** | 监控 — gpu温度、内存、磁盘、服务健康 |
| **bounty** | 缺陷 — 捕获错误、自动创建修复线程 |

这些是建议，不是必须的。[核心智能体指南 →](docs/wiki/Core-Agents.md)

## 安全

仅限ssh密钥。无密码。无开放端口。无例外。所有服务绑定127.0.0.1。*"you shall not pass."* *(你不能通过。)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[完整安全指南 →](docs/SECURITY.md)

## 隐私

**零遥测。零追踪。零数据收集。** 没有任何东西会回传数据。你的数据留在你的机器上。*"there is no cloud. there is only zuul."* *(没有云。只有祖尔。)*

## 文档

| 指南 | 内容 |
|------|------|
| [入门指南](docs/wiki/Getting-Started.md) | 安装、验证、第一步 |
| [组件](docs/wiki/Components.md) | rocm、caddy、llama.cpp、lemonade、gaia |
| [架构](docs/wiki/Architecture.md) | 各部分如何协同工作 |
| [添加服务](docs/wiki/Adding-a-Service.md) | 拼入你自己的乐高积木 |
| [模型管理](docs/wiki/Model-Management.md) | 加载、切换、测试模型 |
| [智能体概览](docs/wiki/Agents-Overview.md) | 17个llm演员 |
| [性能测试](docs/wiki/Benchmarks.md) | 性能数据 |
| [故障排除](docs/wiki/Troubleshooting.md) | 常见修复方法 |
| [完整wiki — 24页](docs/wiki/Home.md) | 所有内容 |

## 选项

```
./install.sh --dry-run        安装前预览
./install.sh --yes-all        安装所有内容
./install.sh --status         检查运行状态
./install.sh --skip-rocm      跳过任意组件
./install.sh --help           所有选项
```

## 系统要求

- arch linux（裸机）
- amd ryzen ai硬件（strix halo / strix point）
- 免密sudo

## 致谢

这个项目的存在归功于那些构建了我们所依赖的工具的人们。

特别感谢 [Light-Heart-Labs](https://github.com/Light-Heart-Labs) 和 [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — 指引方向的灯塔。没有那个项目，这一切都不会存在。

基于以下项目构建：[llama.cpp](https://github.com/ggml-org/llama.cpp)、[Lemonade SDK](https://github.com/lemonade-sdk/lemonade)、[AMD Gaia](https://github.com/amd/gaia)、[Caddy](https://caddyserver.com)、[ROCm](https://github.com/ROCm/TheRock)、[whisper.cpp](https://github.com/ggerganov/whisper.cpp)、[Kokoro](https://github.com/remsky/Kokoro-FastAPI)、[ComfyUI](https://github.com/comfyanonymous/ComfyUI)、[Open WebUI](https://github.com/open-webui/open-webui)、[SearXNG](https://github.com/searxng/searxng)、[Vane](https://github.com/ItzCrazyKns/Vane)、[pyenv](https://github.com/pyenv/pyenv)。

---

<div align="center">

*"i am inevitable."* *(我是不可避免的。)* — *由架构师盖章*

MIT

</div>
