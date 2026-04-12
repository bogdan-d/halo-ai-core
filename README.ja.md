<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | **日本語** | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### amd strix halo向けベアメタルai基盤

**8つのコアサービス · 128gbユニファイドメモリ · lemonade + llama.cpp + kokoro tts · クラウドゼロ · レゴブロック**

*アーキテクトが刻印*

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

> **[wiki](docs/wiki/Home.md)** — 24ページのドキュメント · **[discord](https://discord.gg/dSyV646eBs)** — コミュニティ + サポート · **[チュートリアル](https://www.youtube.com/@DirtyOldMan-1971)** — ビデオウォークスルー

---

## これは何か

自分のハードウェアでローカルaiを実行するための基盤レイヤー。1つのスクリプトですべてをインストール。8つのステップ、すべてsystemd、すべて自動再起動、すべてlemonade server :13305経由。sshのみ。*"i know kung fu."* *(カンフーを知っている。)*

## インストール

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # まず何が起こるか確認
./install.sh --yes-all    # すべてをインストール
./install.sh --status     # 実行中のものを確認
```

[![Install Demo](https://img.shields.io/badge/asciinema-インストールデモを見る-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *strix haloハードウェアで約3分*

## 何が手に入るか

| | |
|---|---|
| **gpu** | rocm 7.12.0 — gfx1151で128gbフルユニファイドメモリ |
| **推論** | llama.cpp (Vulkan) — lemonadeのllamacppバックエンド経由。コンパイル不要。*(u/Look_0ver_Thereに感謝)* |
| **バックエンド** | lemonade server 10.2.0 — :13305の統合ルーター。openai + anthropic + ollama互換 |
| **音声** | kokoro tts (cpu) + whisper.cpp (vulkan) — 音声認識とテキスト読み上げ |
| **コーディング** | claude code — ローカルaiコーディングエージェント、lemonade経由で起動 |
| **ゲートウェイ** | caddy 2.x — :80のダッシュボード |
| **vpn** | wireguard — qrコードをスキャンして、スマホからスタックにアクセス |
| **ダッシュボード** | :5090のステータスサーバー — gpu、ram、サービス、起動時自動読み込み |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     統合ルーター — すべてのapi、すべてのバックエンド      │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│  Claude Code  │  ダッシュボード (:5090)  │ WireGuard  │
├───────────────┴─────────────────────┴────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[フルインストールを視聴](halo-ai-core-install.cast)** — strix haloでのクリーンインストール録画。リポジトリをクローンして`asciinema play halo-ai-core-install.cast`を実行するとリアルタイムで視聴可能。

## ベンチマーク — そのまま使える

これらの数値はstrix haloハードウェアでのクリーンな`install.sh --yes-all`から取得。手動チューニングなし。トリックなし。インストールスクリプトがすべての最適化を自動適用。ベンチマークはclaude codeによりlemonade sdk api経由で実行。

| モデル | 量子化 | テスト | プロンプト tok/s | 生成 tok/s | TTFT |
|--------|--------|--------|-----------------|-----------|------|
| qwen3-30B-A3B | Q4_K_M | 短 (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | 中 (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | 長 (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | 持続 (54→2048) | **437.0** | **70.5** | 124ms |

*2048トークンにわたって劣化なしの安定した70-73 tok/s生成。64gbのうち18gb vram使用。200ms以下のttft。2026-04-08テスト。*

### 高速な理由

- **lemonade server** — :13305の統合ルーター。openai、anthropic、ollama互換。すべてに1つのエンドポイント。
- **llama.cpp (Vulkan)** — Lemonade経由の事前ビルドVulkanバックエンド。コンパイル不要、パッチ不要。任意のVulkan GPUで動作。*(h/t u/Look_0ver_There)*
- **kokoro tts** — 高速CPU音声合成。9言語対応。
- **whisper.cpp (Vulkan)** — GPU加速による音声認識。
- **gfx1151最適化** — すべてのバイナリがお使いのシリコンを正確にターゲット。汎用ビルドなし。
- **128gbユニファイドメモリ** — VRAMの壁なし。35Bモデルを余裕でロード。

探す必要はない。設定する必要もない。`install.sh`がすべてやる。それがポイント。

## インスタントモバイルアクセス — スキャンして接続

インストールが完了すると、ターミナルにqrコードが表示される。スマホでwireguardアプリを開き、スキャンすれば、aiスタック全体に接続完了。ポートフォワーディング不要。クラウドリレー不要。設定不要。スキャンして接続。

```
  ┌──────────────────────────────────────────┐
  │  スマホでスキャンしてください              │
  │  WireGuardアプリ → + → QRコードをスキャン │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (あなたのQRはここ)

  スマホVPN IP: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

wireguard vpn。暗号化トンネル。スマホがローカルネットワーク経由でスタックと直接通信。wifi内のどこからでも動作 — udp 51820をフォワードすれば世界中どこからでも。

> *zach barrowの提案による機能。大きな成果。ブラボー。*

## 哲学

すべてのピースはスナップインしてスナップアウトする。ハードな依存関係なし。ベンダーロックインなし。クラウドへの束縛なし。

ai業界はあなたに他人のコンピュータを借りさせたがっている。私たちはスタック全体を所有すべきだと考える — ハードウェア、モデル、データ、パイプライン。自分のソフトウェアをコントロールすれば、自分の運命をコントロールできる。午前2時にapiキーが期限切れになることもない。足元で利用規約が変わることもない。

これがcoreだ。それ以外はすべて、あなたが選んで追加するレゴブロックだ。

> *"they get the kingdom. they forge their own keys."* *(彼らは王国を手に入れる。自分の鍵を自ら鍛える。)*

## 有料サービスとの統合

ローカルファースト。クラウドは必要な時だけ。ワンリンクで全主要aiプロバイダー。

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — 統合ガイド、ルーティングパターン、apiキー管理

</div>

> *"sometimes you gotta run before you can walk."* *(歩く前に走らなければならない時もある。)* — halo-aiはローカルで動く。有料サービスは非常口であり、基盤ではない。

## レゴブロック

coreが基盤。必要なものをスナップオン：

| ブロック | 機能 | 状態 |
|---------|------|------|
| **ssh mesh** | マルチマシンネットワーキング（デフォルト、どこでも動作） | [ガイド →](docs/wiki/SSH-Mesh.md) |
| **vlan tagging** | 802.1Qネットワーク分離（マネージドスイッチ必要） | [ガイド →](docs/wiki/Network-Layout.md) |
| **音声パイプライン** | whisper + kokoro tts | [ガイド →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | チャットフロントエンド | 計画中 |
| **comfyui** | 画像/動画生成 | 計画中 |
| **ゲームサーバー** | アーケード管理 | 計画中 |
| **glusterfs** | 分散ストレージ | 計画中 |
| **discord ボット** | discordのaiエージェント | 計画中 |

[独自のブロックを構築する方法 →](docs/wiki/Adding-a-Service.md)

## すぐに使える

coreをインストールし、ブラウザを開き、aiと会話を始める。cliは不要。

## 推奨：コアエージェント

coreはエージェントなしでも動作する。しかしこの5つは、あなたがいない間にスタックを監視する。

| エージェント | 役割 |
|-------------|------|
| **sentinel** | セキュリティ — スキャン、監視、何も信頼しない |
| **meek** | 監査人 — 17項目の日次監査、サプライチェーン |
| **shadow** | 整合性 — sshキー、ファイルハッシュ、メッシュの健全性 |
| **pulse** | モニター — gpu温度、ram、ディスク、サービスの健全性 |
| **bounty** | バグ — エラーを捕捉、修正スレッドを自動作成 |

これらは推奨であり、必須ではない。[コアエージェントガイド →](docs/wiki/Core-Agents.md)

## セキュリティ

sshキーのみ。パスワードなし。開放ポートなし。例外なし。すべてのサービスは127.0.0.1上。*"you shall not pass."* *(ここは通さぬ。)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[完全なセキュリティガイド →](docs/SECURITY.md)

## プライバシー

**テレメトリゼロ。トラッキングゼロ。データ収集ゼロ。** 何も外部に通信しない。あなたのデータはあなたのマシンに留まる。*"there is no cloud. there is only zuul."* *(クラウドは存在しない。ズールだけが存在する。)*

## ドキュメント

| ガイド | 内容 |
|-------|------|
| [はじめに](docs/wiki/Getting-Started.md) | インストール、検証、最初のステップ |
| [コンポーネント](docs/wiki/Components.md) | rocm、caddy、llama.cpp、lemonade、gaia |
| [アーキテクチャ](docs/wiki/Architecture.md) | パーツがどのように組み合わさるか |
| [サービスの追加](docs/wiki/Adding-a-Service.md) | 独自のレゴブロックをスナップイン |
| [モデル管理](docs/wiki/Model-Management.md) | モデルの読み込み、切り替え、ベンチマーク |
| [エージェント概要](docs/wiki/Agents-Overview.md) | 17のllmアクター |
| [ベンチマーク](docs/wiki/Benchmarks.md) | パフォーマンス数値 |
| [トラブルシューティング](docs/wiki/Troubleshooting.md) | よくある修正方法 |
| [完全なwiki — 24ページ](docs/wiki/Home.md) | すべて |

## オプション

```
./install.sh --dry-run        インストールせずにプレビュー
./install.sh --yes-all        すべてをインストール
./install.sh --status         実行中のものを確認
./install.sh --skip-rocm      任意のコンポーネントをスキップ
./install.sh --help           すべてのオプション
```

## 要件

- arch linux（ベアメタル）
- amd ryzen aiハードウェア（strix halo / strix point）
- パスワードなしsudo

## クレジット

このプロジェクトは、私たちが立つ基盤となるツールを構築した人々のおかげで存在する。

[Light-Heart-Labs](https://github.com/Light-Heart-Labs) と [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) に特別な感謝を — 道を示した灯台。あのプロジェクトがなければ、これは何も存在しなかった。

以下の上に構築：[llama.cpp](https://github.com/ggml-org/llama.cpp)、[Lemonade SDK](https://github.com/lemonade-sdk/lemonade)、[AMD Gaia](https://github.com/amd/gaia)、[Caddy](https://caddyserver.com)、[ROCm](https://github.com/ROCm/TheRock)、[whisper.cpp](https://github.com/ggerganov/whisper.cpp)、[Kokoro](https://github.com/remsky/Kokoro-FastAPI)、[ComfyUI](https://github.com/comfyanonymous/ComfyUI)、[Open WebUI](https://github.com/open-webui/open-webui)、[SearXNG](https://github.com/searxng/searxng)、[Vane](https://github.com/ItzCrazyKns/Vane)、[pyenv](https://github.com/pyenv/pyenv)。

---

<div align="center">

*"i am inevitable."* *(私は不可避だ。)* — *アーキテクトが刻印*

MIT

</div>
