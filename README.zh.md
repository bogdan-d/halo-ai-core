<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | **[中文](README.zh.md)** | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### 面向amd strix halo的裸机ai基础平台

**5个核心服务 · 128gb统一内存 · 从源码编译 · 零云端 · 乐高积木**

*由架构师盖章*

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.2.1-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_pages-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-articles-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutorials-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Security-SSH_Only-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24页文档 · **[discord](https://discord.gg/dSyV646eBs)** — 社区 + 技术支持 · **[教程](https://www.youtube.com/@DirtyOldMan-1971)** — 视频演示

---

## 这是什么

在自己的硬件上运行本地ai的基础层。一个脚本安装一切。五个核心服务。全部systemd。全部自动重启。仅限ssh。*"i know kung fu."* *(我会功夫。)*

## 安装

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # 先看看会发生什么
./install.sh --yes-all    # 安装所有内容
./install.sh --status     # 检查运行状态
```

## 你会得到什么

| | |
|---|---|
| **gpu** | rocm 7.2.1 — gfx1151上完整的128gb统一内存 |
| **推理** | llama.cpp (Vulkan) — via Lemonade. *(h/t u/Look_0ver_There)* |
| **后端** | lemonade sdk 9.x — llm、whisper、kokoro、stable diffusion |
| **智能体** | gaia sdk 0.17.x — 构建100%本地运行的ai智能体 |
| **网关** | caddy 2.x — 反向代理，即插即用配置，自动路由 |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  你的     │
│  :8080   │  :13305  │  智能体   │  积木     │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## 理念

每一块都能卡入和拔出。没有硬依赖。没有供应商锁定。没有云端束缚。

ai行业想让你租用别人的电脑。我们认为你应该拥有整个技术栈 — 硬件、模型、数据、流水线。当你掌控自己的软件时，你就掌控了自己的命运。不会有api密钥在凌晨2点过期。不会有服务条款在你脚下悄然改变。

这就是core。其他一切都是你选择添加的乐高积木。

> *"they get the kingdom. they forge their own keys."* *(他们得到王国。他们锻造自己的钥匙。)*

## 乐高积木

core是基础。按需拼接：

| 积木 | 功能 | 状态 |
|------|------|------|
| **ssh mesh** | 多机网络 | [指南 →](docs/wiki/SSH-Mesh.md) |
| **语音流水线** | whisper + kokoro tts | [指南 →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | 聊天前端 | 计划中 |
| **comfyui** | 图像/视频生成 | 计划中 |
| **游戏服务器** | 游戏厅管理 | 计划中 |
| **glusterfs** | 分布式存储 | 计划中 |
| **discord 机器人** | discord中的ai智能体 | 计划中 |

[如何构建你自己的积木 →](docs/wiki/Adding-a-Service.md)

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
