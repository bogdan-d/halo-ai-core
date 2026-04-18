<div align="center">

🌐 [English](README.md) | **Français** | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### le monstre 1-bit — inférence IA locale, bare metal, zéro python à l'exécution

**rocm c++ · poids ternaires (.h1b) · kernels HIP fusionnés · wave32 wmma · 17 spécialistes c++ · zéro télémétrie · zéro cloud**

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

## c'est quoi

halo-ai core est le **script d'installation du monstre 1-bit** — une pile IA locale complète, entièrement en C++ sur matériel AMD Strix Halo. zéro python à l'exécution. zéro cloud. zéro télémétrie. zéro abonnement.

un seul script, trois dépôts d'ingénierie :

| dépôt | à quoi ça sert |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | le moteur d'inférence. HIP pur, kernels ternaires fusionnés, serveur OpenAI-compatible avec streaming SSE. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | le framework d'agents. 17 spécialistes à fonction unique sur un bus de messages, journal d'audit en chaîne de hash, porte de vérification de consentement. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | le format de modèle (.h1b) + pipeline d'entraînement. ternaire absmean, QAT avec estimateur straight-through, distillation depuis des professeurs bf16. |

halo-ai core les clone, les compile depuis les sources, les raccorde à systemd, et pointe un reverse proxy caddy sur le résultat. une seule commande, vous obtenez un LLM qui tourne, une boucle vocale, un bot discord, un runner CI, et un journal d'audit. tout en local.

*"I know kung fu."*

## installation

deux chemins. le script détecte automatiquement votre GPU et choisit.

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # auto: strixhalo → rapide ; sinon → depuis sources
```

| chemin | pour qui | temps | ce qu'il fait |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 min | télécharge les binaires pré-compilés depuis GH Releases, vérifie SHA256 + GPG, raccorde systemd |
| [`./install-source.sh`](install-source.sh) | tout autre GPU AMD | ~4 h | compile TheRock + rocm-cpp + agent-cpp + halo-1bit depuis les sources pour votre arch |

pourquoi deux scripts : chaque Strix Halo a le même silicium (gfx1151, wave32, 128 Go unifiés). une seule compilation produit un binaire qui tourne à l'identique sur chacune — inutile de tout recompiler à chaque fois. pour tout le reste (gfx1030, gfx1100, gfx1201, CDNA), les kernels WMMA wave32 ne se portent pas directement, donc compilation depuis les sources avec codegen spécifique à l'arch.

**vous tournez sur autre chose qu'un Strix Halo et vous voulez les kernels pour votre GPU ?** voir [`release/KERNELS.md`](release/KERNELS.md) pour la couverture, comment compiler vos propres binaires, et comment partager des builds communautaires.

## la pile

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 spécialistes C++               │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — kernels HIP · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  modèle ternaire (.h1b v2) · tokenizer halo-1bit (.htok) │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

> *chaque couche est une brique lego si quelqu'un la veut. prenez le monstre entier ou une pièce.*

## chiffres qui comptent

| métrique | valeur | note |
|---|---|---|
| **vitesse de décodage** | 85 tok/s | BitNet-b1.58-2B, greedy, Strix Halo |
| **taille du modèle** | 1,1 Gio | format TQ1_0, 4× plus petit que F16 |
| **KLD vs F16** | 0,0023 | bits/token moyen — indistinguable en pratique |
| **accord top-1** | 96,3% | vs référence F16, même token argmax |
| **binaire agent** | 1,3 Mo | agent_cpp, lié statiquement |
| **démarrage à froid** | < 2s | bitnet_decode --server |
| **dépendances runtime** | 0 python | libc, pthreads, httplib, nlohmann-json, OpenSSL |

détails et méthodologie : [docs/benchmark-comparison.md](docs/benchmark-comparison.md) · [docs/replicate.md](docs/replicate.md)

## philosophie

> chaque pièce s'emboîte et se retire. pas de dépendances dures. pas de verrouillage fournisseur. pas d'attache cloud.

python a porté l'ère LLM. le C++ possède la suivante. python à l'entraînement, d'accord ; python à l'exécution sur du matériel que vous possédez, c'est un passif. **halo-ai core a zéro python à l'exécution.**

l'industrie IA veut que vous louiez l'ordinateur de quelqu'un d'autre. nous pensons que vous devriez posséder toute la pile — le matériel, les modèles, les poids, le pipeline. quand vous contrôlez votre logiciel, vous contrôlez votre destin.

*"they get the kingdom. they forge their own keys."*

## vie privée

**zéro télémétrie. zéro tracking. zéro collecte de données.** rien ne phone home. vos données restent sur votre machine.

les fournisseurs d'API payants (OpenAI, Anthropic, Groq, DeepSeek, xAI, OpenRouter) sont supportés via sommelier avec vos propres clés — mais c'est votre choix, pas notre défaut. local d'abord veut dire local d'abord.

*"there is no cloud. there is only zuul."*

## prérequis

- Arch Linux (bare metal de préférence ; podman fonctionne pour le headless)
- matériel AMD Ryzen AI — Strix Halo (gfx1151) ou Strix Point (gfx1150)
- sudo sans mot de passe
- ~20 Gio d'espace libre (artefacts de build, kernels, modèles)

## crédits

ce projet se tient sur les épaules des gens qui livrent de l'open source.

construit sur [llama.cpp](https://github.com/ggml-org/llama.cpp), [TheRock](https://github.com/ROCm/TheRock), [httplib](https://github.com/yhirose/cpp-httplib), [nlohmann/json](https://github.com/nlohmann/json), [usearch](https://github.com/unum-cloud/usearch), [FTXUI](https://github.com/ArthurSonzogni/FTXUI), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro TTS](https://github.com/remsky/Kokoro-FastAPI), [microsoft/bitnet-b1.58-2B-4T](https://huggingface.co/microsoft/bitnet-b1.58-2B-4T).

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
