<!--
注記: この翻訳は機械生成です。英語版 README が正本です。PR を歓迎します。
-->

> **注記**: この翻訳は機械生成です。英語版 README が正本です。PR を歓迎します。

<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | **日本語** | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### 1ビットモンスター — ローカルAI推論、ベアメタル、ランタイムPythonなし

**rocm c++ · 三値重み (.h1b) · 融合HIPカーネル · wave32 wmma · 17のC++スペシャリスト · テレメトリーゼロ · クラウドゼロ**

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

## これは何か

halo-ai core は **1ビットモンスターのインストールスクリプト** — AMD Strix Halo ハードウェア上で完全に C++ で動く、ローカル AI スタック一式です。ランタイム Python なし。クラウドなし。テレメトリーなし。サブスクなし。

スクリプト一つ、エンジニアリングリポジトリ三つ:

| repo | これは何か |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | 推論エンジン。純粋な HIP、融合された三値カーネル、SSE ストリーミング対応の OpenAI 互換サーバー。 |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | エージェントフレームワーク。メッセージバス上の単機能スペシャリスト 17 体、ハッシュチェーン監査ログ、同意検証ゲート。 |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | モデルフォーマット (.h1b) + 学習パイプライン。absmean 三値化、straight-through 推定器による QAT、bf16 教師モデルからの蒸留。 |

halo-ai core はそれらをクローンし、ソースからビルドし、systemd に繋ぎ、結果に向けて caddy リバースプロキシを立てます。一つのコマンドで、動作する LLM、音声ループ、Discord ボット、CI ランナー、監査トレイルが手に入ります。すべてローカル。

*"I know kung fu."*

## インストール

二つの道。スクリプトが GPU を自動検出して選びます。

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # 自動: strixhalo → 高速; それ以外 → ソース
```

| 道 | 対象 | 時間 | 内容 |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | 約 5 分 | GH Releases から事前ビルド済みバイナリをダウンロード、SHA256 + GPG 検証、systemd 接続 |
| [`./install-source.sh`](install-source.sh) | その他の AMD GPU | 約 4 時間 | TheRock + rocm-cpp + agent-cpp + halo-1bit をあなたのアーキ向けにソースからビルド |

**Strix Halo 以外?** [`release/KERNELS.md`](release/KERNELS.md) を参照。

## スタック

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 の C++ スペシャリスト            │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  三値モデル (.h1b v2) · halo-1bit トークナイザー (.htok)    │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## 重要な数字

| 指標 | 値 |
|---|---|
| デコード速度 | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| モデルサイズ | 1.1 GiB (TQ1_0) |
| KLD vs F16 | 0.0023 bits/token |
| Top-1 一致 | 96.3% |
| エージェントバイナリ | 1.3 MB |
| コールドスタート | < 2 秒 |
| ランタイム依存 | 0 python |

## 哲学

Python は LLM 時代を運びました。C++ が次を所有します。学習時の Python は構わない、ランタイムで自分のハードの上の Python は負債です。**halo-ai core はランタイム Python ゼロ。**

AI 産業はあなたに他人のコンピューターを借りさせたい。私たちはスタック全体を所有すべきだと考える — ハードウェア、モデル、重み、パイプライン。

*"they get the kingdom. they forge their own keys."*

## プライバシー

**ゼロテレメトリー。ゼロトラッキング。ゼロデータ収集。** 何もホームに発信しません。

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
