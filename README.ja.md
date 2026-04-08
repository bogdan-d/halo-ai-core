<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | **[日本語](README.ja.md)** | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### amd strix halo向けベアメタルai基盤

**5つのコアサービス · 128gbユニファイドメモリ · ソースからコンパイル · クラウドゼロ · レゴブロック**

*アーキテクトが刻印*

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

> **[wiki](docs/wiki/Home.md)** — 24ページのドキュメント · **[discord](https://discord.gg/dSyV646eBs)** — コミュニティ + サポート · **[チュートリアル](https://www.youtube.com/@DirtyOldMan-1971)** — ビデオウォークスルー

---

## これは何か

自分のハードウェアでローカルaiを実行するための基盤レイヤー。1つのスクリプトですべてをインストール。5つのコアサービス。すべてsystemd。すべて自動再起動。sshのみ。*"i know kung fu."* *(カンフーを知っている。)*

## インストール

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # まず何が起こるか確認
./install.sh --yes-all    # すべてをインストール
./install.sh --status     # 実行中のものを確認
```

## 何が手に入るか

| | |
|---|---|
| **gpu** | rocm 7.2.1 — gfx1151で128gbフルユニファイドメモリ |
| **推論** | llama.cpp — ソースからコンパイル、hip + vulkan |
| **バックエンド** | lemonade sdk 9.x — llm、whisper、kokoro、stable diffusion |
| **エージェント** | gaia sdk 0.17.x — 100%ローカルで動作するaiエージェントを構築 |
| **ゲートウェイ** | caddy 2.x — リバースプロキシ、ドロップイン設定、自動ルーティング |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │ あなたの  │
│  :8080   │  :13305  │ エージェント│  ブロック │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## 哲学

すべてのピースはスナップインしてスナップアウトする。ハードな依存関係なし。ベンダーロックインなし。クラウドへの束縛なし。

ai業界はあなたに他人のコンピュータを借りさせたがっている。私たちはスタック全体を所有すべきだと考える — ハードウェア、モデル、データ、パイプライン。自分のソフトウェアをコントロールすれば、自分の運命をコントロールできる。午前2時にapiキーが期限切れになることもない。足元で利用規約が変わることもない。

これがcoreだ。それ以外はすべて、あなたが選んで追加するレゴブロックだ。

> *"they get the kingdom. they forge their own keys."* *(彼らは王国を手に入れる。自分の鍵を自ら鍛える。)*

## レゴブロック

coreが基盤。必要なものをスナップオン：

| ブロック | 機能 | 状態 |
|---------|------|------|
| **ssh mesh** | マルチマシンネットワーキング | [ガイド →](docs/wiki/SSH-Mesh.md) |
| **音声パイプライン** | whisper + kokoro tts | [ガイド →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | チャットフロントエンド | 計画中 |
| **comfyui** | 画像/動画生成 | 計画中 |
| **ゲームサーバー** | アーケード管理 | 計画中 |
| **glusterfs** | 分散ストレージ | 計画中 |
| **discord ボット** | discordのaiエージェント | 計画中 |

[独自のブロックを構築する方法 →](docs/wiki/Adding-a-Service.md)

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
