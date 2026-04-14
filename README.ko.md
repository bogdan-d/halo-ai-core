<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | **한국어** | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### amd strix halo를 위한 베어메탈 ai 기반

**13 코어 서비스 · 128GB 통합 메모리 · Lemonade + llama.cpp + Nexus · 제로 클라우드 · 레고 블록**

*아키텍트가 찍은 도장*

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
[![Nexus VPN](https://img.shields.io/badge/Security-Nexus_Zero_Trust-red?style=flat)](docs/wiki/Nexus-VPN.md)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

> **[위키](docs/wiki/Home.md)** — 24페이지 문서 · **[디스코드](https://discord.gg/dSyV646eBs)** — 커뮤니티 + 지원 · **[튜토리얼](https://www.youtube.com/@DirtyOldMan-1971)** — 비디오 안내

---

## 이것은 무엇인가

자체 하드웨어에서 로컬 ai를 실행하기 위한 기반 레이어. 하나의 스크립트로 모든 것을 설치. 8단계, 모두 systemd, 모두 자동 재시작, 모든 것이 lemonade server :13305를 경유. ssh 전용. *"i know kung fu."* *(나는 쿵푸를 안다.)*

## 설치

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # 먼저 무엇이 일어나는지 확인
./install.sh --yes-all    # 모든 것을 설치
./install.sh --status     # 실행 중인 항목 확인
```

[![Install Demo](https://img.shields.io/badge/asciinema-설치_데모_보기-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *strix halo 하드웨어에서 약 3분*

## 포함 내용

| | |
|---|---|
| **gpu** | rocm 7.12.0 — gfx1151에서 128gb 통합 메모리 전체 지원 |
| **추론** | llama.cpp (Vulkan) — lemonade의 llamacpp 백엔드 경유. 컴파일 불필요. *(u/Look_0ver_There에게 감사)* |
| **백엔드** | lemonade server 10.2.0 — :13305의 통합 라우터. openai + anthropic + ollama 호환 |
| **음성** | kokoro tts (cpu) + whisper.cpp (vulkan) — 음성 인식 및 음성 합성 |
| **코딩** | claude code — 로컬 ai 코딩 에이전트, lemonade를 통해 실행 |
| **게임** | Minecraft + LinuxGSM — 게임 서버 관리 |
| **면접** | interviewer — AI 기반 면접 연습 세션 |
| **벤치마크** | lemonade eval — 자동화된 벤치마킹 및 정확도 분석 |
| **메시 VPN** | lemonade nexus — 암호화 거버넌스를 갖춘 제로 트러스트 WireGuard 메시 |
| **게이트웨이** | caddy 2.x — 대시보드 + 서비스 프록시 :80 |
| **VPN** | wireguard — QR 코드 스캔, 폰에서 스택 접속 |
| **대시보드** | glass 제어 패널 — 모델 관리, 실시간 통계, 에이전트 관리 |
| **패키지 관리** | 패키지 매니저 — 서비스 상태, 버전 추적, 빌드 트리거 :3010 |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     통합 라우터 — 모든 api, 모든 백엔드               │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│ Claude Code │ Games  │ Interviewer │ Nexus VPN  │
│ Pkg Manager (:3010)                              │
├───────────────┴─────────────────────┴────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[전체 설치 과정 보기](halo-ai-core-install.cast)** — strix halo에서 녹화된 클린 설치. 리포지토리를 클론하고 `asciinema play halo-ai-core-install.cast`를 실행하여 실시간으로 시청.

## 벤치마크 — 바로 사용 가능

이 수치들은 strix halo 하드웨어에서 클린 `install.sh --yes-all`로 얻은 결과. 수동 튜닝 없음. 트릭 없음. 설치 스크립트가 모든 최적화를 자동 적용. 벤치마크는 claude code가 lemonade sdk api를 통해 실행.

| 모델 | 양자화 | 테스트 | 프롬프트 tok/s | 생성 tok/s | TTFT |
|------|--------|--------|---------------|-----------|------|
| qwen3-30B-A3B | Q4_K_M | 짧음 (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | 중간 (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | 긴 (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | 지속 (54→2048) | **437.0** | **70.5** | 124ms |

*2048 토큰에 걸쳐 성능 저하 없이 안정적인 70-73 tok/s 생성. 64gb 중 18gb vram 사용. 200ms 미만 ttft. 2026-04-08 테스트.*

### 빠른 이유

- **lemonade server** — :13305의 통합 라우터. openai, anthropic, ollama 호환. 하나의 엔드포인트로 모든 것을.
- **llama.cpp (Vulkan)** — Lemonade를 통한 사전 빌드된 Vulkan 백엔드. 컴파일 불필요, 패치 불필요. 모든 Vulkan GPU에서 작동. *(h/t u/Look_0ver_There)*
- **kokoro tts** — 빠른 cpu 기반 음성 합성. 9개 언어 지원.
- **whisper.cpp (Vulkan)** — gpu 가속 음성 인식.
- **gfx1151 최적화** — 모든 바이너리가 정확한 실리콘을 타겟. 범용 빌드 없음.
- **128gb 통합 메모리** — VRAM 벽 없음. 35B 모델을 거뜬히 로드.

찾을 필요 없습니다. 설정할 필요도 없습니다. `install.sh`가 대신 해줍니다. 그게 핵심입니다.

## 즉시 모바일 접근 — 스캔하고 연결

설치가 끝나면 터미널에 qr 코드가 나타납니다. 휴대폰에서 wireguard 앱을 열고 스캔하면 전체 ai 스택에 연결됩니다. 포트 포워딩 불필요. 클라우드 릴레이 불필요. 설정 불필요. 스캔하고 바로 연결.

```
  ┌──────────────────────────────────────────┐
  │  휴대폰으로 스캔하세요                      │
  │  WireGuard 앱 → + → QR 코드 스캔          │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (여기에 QR 코드)

  휴대폰 VPN IP: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

wireguard vpn. 암호화 터널. 휴대폰이 로컬 네트워크를 통해 스택과 직접 통신. wifi 범위 내 어디서나 작동 — udp 51820을 포워딩하면 전 세계 어디서나.

> *zach barrow가 제안한 기능. 큰 성과. 브라보.*

## 철학

모든 조각은 끼우고 빼는 방식. 하드 의존성 없음. 벤더 종속 없음. 클라우드 연결 없음.

ai 산업은 당신이 다른 사람의 컴퓨터를 빌려 쓰길 원합니다. 우리는 당신이 전체 스택을 소유해야 한다고 생각합니다 — 하드웨어, 모델, 데이터, 파이프라인. 자신의 소프트웨어를 통제하면 자신의 운명을 통제하게 됩니다. 새벽 2시에 만료되는 api 키도 없고, 발밑에서 바뀌는 서비스 약관도 없습니다.

이것이 코어입니다. 나머지는 당신이 추가를 선택하는 레고 블록입니다.

> *"they get the kingdom. they forge their own keys."* *(그들은 왕국을 얻는다. 그들은 자신의 열쇠를 만든다.)*

## 유료 서비스 통합

로컬 우선. 원할 때 클라우드. 하나의 링크로 모든 주요 ai 제공업체.

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — 통합 가이드, 라우팅 패턴, api 키 관리

</div>

> *"sometimes you gotta run before you can walk."* *(때론 걷기 전에 뛰어야 한다.)* — halo-ai는 로컬에서 실행됩니다. 유료 서비스는 비상구이지 기반이 아닙니다.

## 레고 블록

코어가 기반입니다. 필요한 것을 끼우세요:

| 블록 | 기능 | 상태 |
|------|------|------|
| **nexus vpn** | 제로 트러스트 WireGuard 메시 (SSH 메시 대체) | [가이드 →](docs/wiki/Nexus-VPN.md) |
| **vlan tagging** | 802.1Q 네트워크 격리 (관리형 스위치 필요) | [가이드 →](docs/wiki/Network-Layout.md) |
| **음성 파이프라인** | whisper + kokoro tts | [가이드 →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | 채팅 프론트엔드 | 계획됨 |
| **comfyui** | 이미지/비디오 생성 | 계획됨 |
| **게임 서버** | Minecraft + LinuxGSM | 활성 |
| **glusterfs** | 분산 스토리지 | 계획됨 |
| **디스코드 봇** | 디스코드 내 ai 에이전트 | 계획됨 |

[자신만의 블록 만드는 방법 →](docs/wiki/Adding-a-Service.md)

## 바로 사용 가능

코어를 설치하고, 브라우저를 열고, ai와 대화를 시작하세요. cli 불필요.

## 권장: 핵심 에이전트

코어는 에이전트 없이도 작동합니다. 하지만 이 다섯이 당신이 없을 때 스택을 감시합니다.

| 에이전트 | 역할 |
|----------|------|
| **sentinel** | 보안 — 스캔, 모니터링, 아무것도 신뢰하지 않음 |
| **meek** | 감사관 — 17항목 일일 감사, 공급망 |
| **shadow** | 무결성 — nexus 키, 파일 해시, 메시 상태 |
| **pulse** | 모니터 — gpu 온도, 램, 디스크, 서비스 상태 |
| **bounty** | 버그 — 오류 포착, 자동 수정 스레드 생성 |

이들은 권장 사항이지 필수가 아닙니다. [핵심 에이전트 가이드 →](docs/wiki/Core-Agents.md)

## 보안

**Lemonade Nexus** — 제로 트러스트 WireGuard 메시 VPN. ~~SSH 믹서는 더 이상 사용되지 않으며 제거되었습니다.~~ Nexus가 대체합니다.

| | SSH 메시 (이전) | Nexus (현재) |
|---|---|---|
| 키 관리 | 각 머신에서 수동 | Ed25519 서버별 자동 생성 |
| 암호화 | SSH만 | WireGuard ChaCha20-Poly1305 터널 |
| 피어 발견 | 없음 | UDP 가십 프로토콜, 자동 |
| 키 순환 | 수동 | Shamir로 자동 주간 순환 |
| 거버넌스 | 플랫 신뢰 | 민주적 — Tier 1 과반수 투표 |
| NAT 통과 | 없음 | STUN 홀 펀칭 + 릴레이 |

모든 서비스는 127.0.0.1에 바인딩. Nexus가 암호화된 터널을 제공합니다. *"여기는 지나갈 수 없다."*

[Nexus VPN 가이드 →](docs/wiki/Nexus-VPN.md) · [보안 강화 →](docs/SECURITY.md)

## 프라이버시

**텔레메트리 제로. 추적 제로. 데이터 수집 제로.** 아무것도 외부로 통신하지 않습니다. 당신의 데이터는 당신의 머신에 머뭅니다. *"there is no cloud. there is only zuul."* *(클라우드는 없다. 줄만 있을 뿐.)*

## 문서

| 가이드 | 내용 |
|--------|------|
| [시작하기](docs/wiki/Getting-Started.md) | 설치, 검증, 첫 단계 |
| [구성 요소](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [아키텍처](docs/wiki/Architecture.md) | 조각들이 어떻게 맞물리는지 |
| [서비스 추가](docs/wiki/Adding-a-Service.md) | 자신만의 레고 블록 끼우기 |
| [모델 관리](docs/wiki/Model-Management.md) | 모델 로드, 전환, 벤치마크 |
| [에이전트 개요](docs/wiki/Agents-Overview.md) | 17개의 llm 액터 |
| [벤치마크](docs/wiki/Benchmarks.md) | 성능 수치 |
| [문제 해결](docs/wiki/Troubleshooting.md) | 일반적인 수정 사항 |
| [전체 위키 — 24페이지](docs/wiki/Home.md) | 모든 것 |

## 옵션

```
./install.sh --dry-run        설치 없이 미리보기
./install.sh --yes-all        모든 것을 설치
./install.sh --status         실행 중인 항목 확인
./install.sh --skip-rocm      특정 구성 요소 건너뛰기
./install.sh --help           모든 옵션
```

## 요구 사항

- arch linux (베어 메탈)
- amd ryzen ai 하드웨어 (strix halo / strix point)
- 비밀번호 없는 sudo

## 크레딧

이 프로젝트는 우리가 기반으로 삼는 도구를 만든 사람들 덕분에 존재합니다.

[Light-Heart-Labs](https://github.com/Light-Heart-Labs)와 [DreamServer](https://github.com/Light-Heart-Labs/DreamServer)에 특별한 감사를 — 길을 비춰준 등대. 그 프로젝트가 없었다면 이것 중 아무것도 존재하지 않았을 것입니다.

[llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv)를 기반으로 제작되었습니다.

---

<div align="center">

*"i am inevitable."* *(나는 필연이다.)* — *아키텍트가 찍은 도장*

MIT

</div>
