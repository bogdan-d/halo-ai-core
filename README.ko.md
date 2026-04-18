<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | **한국어** | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### 1비트 몬스터 — 로컬 AI 추론, 베어 메탈, 런타임 python 제로

**rocm c++ · 3값 가중치 (.h1b) · 융합된 HIP 커널 · wave32 wmma · 17개의 c++ 스페셜리스트 · 제로 텔레메트리 · 제로 클라우드**

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

## 이게 뭔가

halo-ai core는 **1비트 몬스터의 설치 스크립트**입니다 — AMD Strix Halo 하드웨어 위에서 완전히 C++로 실행되는 전체 로컬 AI 스택. 런타임 python 제로. 클라우드 제로. 텔레메트리 제로. 구독 제로.

스크립트 하나, 엔지니어링 레포 셋:

| 레포 | 뭐인가 |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | 추론 엔진. 순수 HIP, 융합된 3값 커널, SSE 스트리밍을 지원하는 OpenAI 호환 서버. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | 에이전트 프레임워크. 메시지 버스 위 17명의 단일 목적 스페셜리스트, 해시 체인 감사 로그, 동의 검증 게이트. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | 모델 포맷 (.h1b) + 학습 파이프라인. absmean 3값화, 스트레이트 스루 추정기를 사용한 QAT, bf16 교사 모델로부터의 증류. |

halo-ai core는 이들을 클론하고 소스에서 빌드하고 systemd에 연결하고 caddy 리버스 프록시를 결과에 맞춥니다. 한 번의 명령으로, 실행 중인 LLM, 음성 루프, discord 봇, CI 러너, 감사 트레일을 얻습니다. 전부 로컬.

*"I know kung fu."*

## 설치

두 가지 경로. 스크립트가 GPU를 자동 감지하고 선택합니다.

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # 자동: strixhalo → 빠름; 아니면 → 소스
```

| 경로 | 대상 | 시간 | 무엇을 하는지 |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | 약 5분 | GH Releases에서 사전 빌드된 바이너리 다운로드, SHA256 + GPG 검증, systemd 연결 |
| [`./install-source.sh`](install-source.sh) | 다른 모든 AMD GPU | 약 4시간 | 당신의 아키를 위해 TheRock + rocm-cpp + agent-cpp + halo-1bit를 소스로부터 빌드 |

**Strix Halo가 아니신가요?** [`release/KERNELS.md`](release/KERNELS.md) 참조.

## 스택

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17명의 C++ 스페셜리스트              │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  3값 모델 (.h1b v2) · halo-1bit 토크나이저 (.htok)         │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## 중요한 숫자

| 지표 | 값 |
|---|---|
| 디코딩 속도 | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| 모델 크기 | 1.1 GiB (TQ1_0) |
| KLD vs F16 | 0.0023 bits/token |
| Top-1 일치 | 96.3% |
| 에이전트 바이너리 | 1.3 MB |
| 콜드 스타트 | < 2초 |
| 런타임 의존성 | 0 python |

## 철학

Python은 LLM 시대를 이끌었습니다. C++는 다음을 소유합니다. 학습 시 Python은 괜찮습니다; 당신 소유의 하드웨어 런타임에서의 Python은 부채입니다. **halo-ai core는 런타임 python 제로.**

AI 산업은 당신이 남의 컴퓨터를 빌리기를 원합니다. 우리는 스택 전체를 소유해야 한다고 생각합니다 — 하드웨어, 모델, 가중치, 파이프라인.

*"they get the kingdom. they forge their own keys."*

## 프라이버시

**제로 텔레메트리. 제로 추적. 제로 데이터 수집.** 집으로 전화하지 않습니다.

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
