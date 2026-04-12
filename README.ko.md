<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | **한국어** | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### amd strix halo를 위한 베어메탈 ai 기반

**5개 핵심 서비스 · 128gb 통합 메모리 · 소스에서 컴파일 · 클라우드 제로 · 레고 블록**

*아키텍트가 찍은 도장*

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

> **[위키](docs/wiki/Home.md)** — 24페이지 문서 · **[디스코드](https://discord.gg/dSyV646eBs)** — 커뮤니티 + 지원 · **[튜토리얼](https://www.youtube.com/@DirtyOldMan-1971)** — 비디오 안내

---

## 이것은 무엇인가

자체 하드웨어에서 로컬 ai를 실행하기 위한 기반 레이어. 하나의 스크립트로 모든 것을 설치. 5개의 핵심 서비스. 모두 systemd. 모두 자동 재시작. ssh 전용. *"i know kung fu." (나는 쿵푸를 안다.)*

## 설치

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # 먼저 무엇이 일어나는지 확인
./install.sh --yes-all    # 모든 것을 설치
./install.sh --status     # 실행 중인 항목 확인
```

## 포함 내용

| | |
|---|---|
| **gpu** | rocm 7.2.1 — gfx1151에서 128gb 통합 메모리 전체 지원 |
| **추론** | llama.cpp (Vulkan) — via Lemonade. *(h/t u/Look_0ver_There)* |
| **백엔드** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **에이전트** | gaia sdk 0.17.x — 100% 로컬에서 실행되는 ai 에이전트 구축 |
| **게이트웨이** | caddy 2.x — 리버스 프록시, 드롭인 설정, 자동 라우팅 |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  사용자   │
│  :8080   │  :13305  │  에이전트 │  블록     │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## 철학

모든 조각은 끼우고 빼는 방식. 하드 의존성 없음. 벤더 종속 없음. 클라우드 연결 없음.

ai 산업은 당신이 다른 사람의 컴퓨터를 빌려 쓰길 원합니다. 우리는 당신이 전체 스택을 소유해야 한다고 생각합니다 — 하드웨어, 모델, 데이터, 파이프라인. 자신의 소프트웨어를 통제하면 자신의 운명을 통제하게 됩니다. 새벽 2시에 만료되는 api 키도 없고, 발밑에서 바뀌는 서비스 약관도 없습니다.

이것이 코어입니다. 나머지는 당신이 추가를 선택하는 레고 블록입니다.

> *"they get the kingdom. they forge their own keys." (그들은 왕국을 얻는다. 그들은 자신의 열쇠를 만든다.)*

## 레고 블록

코어가 기반입니다. 필요한 것을 끼우세요:

| 블록 | 기능 | 상태 |
|------|------|------|
| **ssh mesh** | 다중 머신 네트워킹 | [가이드 →](docs/wiki/SSH-Mesh.md) |
| **음성 파이프라인** | whisper + kokoro tts | [가이드 →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | 채팅 프론트엔드 | 계획됨 |
| **comfyui** | 이미지/비디오 생성 | 계획됨 |
| **게임 서버** | 아케이드 관리 | 계획됨 |
| **glusterfs** | 분산 스토리지 | 계획됨 |
| **디스코드 봇** | 디스코드 내 ai 에이전트 | 계획됨 |

[자신만의 블록 만드는 방법 →](docs/wiki/Adding-a-Service.md)

## 권장: 핵심 에이전트

코어는 에이전트 없이도 작동합니다. 하지만 이 다섯이 당신이 없을 때 스택을 감시합니다.

| 에이전트 | 역할 |
|----------|------|
| **sentinel** | 보안 — 스캔, 모니터링, 아무것도 신뢰하지 않음 |
| **meek** | 감사관 — 17항목 일일 감사, 공급망 |
| **shadow** | 무결성 — ssh 키, 파일 해시, 메시 상태 |
| **pulse** | 모니터 — gpu 온도, 램, 디스크, 서비스 상태 |
| **bounty** | 버그 — 오류 포착, 자동 수정 스레드 생성 |

이들은 권장 사항이지 필수가 아닙니다. [핵심 에이전트 가이드 →](docs/wiki/Core-Agents.md)

## 보안

ssh 키만. 비밀번호 없음. 열린 포트 없음. 예외 없음. 모든 서비스 127.0.0.1에서 실행. *"you shall not pass." (너는 지나갈 수 없다.)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[전체 보안 가이드 →](docs/SECURITY.md)

## 프라이버시

**텔레메트리 제로. 추적 제로. 데이터 수집 제로.** 아무것도 외부로 통신하지 않습니다. 당신의 데이터는 당신의 머신에 머뭅니다. *"there is no cloud. there is only zuul." (클라우드는 없다. 줄만 있을 뿐.)*

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

*"i am inevitable." (나는 필연이다.)* — *아키텍트가 찍은 도장*

MIT

</div>
