<div align="center">

🌐 [English](README.md) | **Français** | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### la fondation ia bare-metal pour amd strix halo

**13 services essentiels · 128 go de mémoire unifiée · lemonade + llama.cpp + nexus · zéro cloud · blocs lego**

*estampillé par l'architecte*

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
[![YouTube](https://img.shields.io/badge/YouTube-tutoriels-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![Nexus VPN](https://img.shields.io/badge/Security-Nexus_Zero_Trust-red?style=flat)](docs/wiki/Nexus-VPN.md)
[![Self Hosted](https://img.shields.io/badge/Auto_hébergé-100%25_local-purple?style=flat)](https://github.com/stampby/halo-ai-core)
[![Bleeding Edge](https://img.shields.io/badge/⚠_Bleeding_Edge-kernel_7.0_+_NPU-ff4444?style=flat)](https://github.com/stampby/halo-ai-core-bleeding-edge)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24 pages de documentation · **[discord](https://discord.gg/dSyV646eBs)** — communauté + support · **[tutoriels](https://www.youtube.com/@DirtyOldMan-1971)** — guides vidéo

---

## c'est quoi

la couche fondation pour exécuter l'ia en local sur votre propre matériel. un seul script installe tout. huit étapes, tout en systemd, tout en redémarrage automatique, tout passe par lemonade server sur :13305. ssh uniquement. *"i know kung fu."* *(je connais le kung fu.)*

## installation

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # voir ce qui se passe d'abord
./install.sh --yes-all    # tout installer
./install.sh --status     # vérifier ce qui tourne
```

[![Install Demo](https://img.shields.io/badge/asciinema-regarder_la_démo-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *~3 min sur matériel strix halo*

## ce que vous obtenez

| | |
|---|---|
| **gpu** | rocm 7.12.0 — mémoire unifiée complète de 128 go sur gfx1151 |
| **inférence** | llama.cpp (Vulkan) — via le backend llamacpp de lemonade. sans compilation. *(merci u/Look_0ver_There)* |
| **backend** | lemonade server 10.2.0 — routeur unifié sur :13305. compatible openai + anthropic + ollama |
| **voix** | kokoro tts (cpu) + whisper.cpp (vulkan) — reconnaissance et synthèse vocale |
| **code** | claude code — agent de codage ia local, lancé via lemonade |
| **jeux** | Minecraft + LinuxGSM — gestion de serveurs de jeux |
| **interview** | interviewer — séances de pratique d'entrevue alimentées par l'ia |
| **benchmarks** | lemonade eval — benchmarking automatisé et analyse de précision |
| **mesh vpn** | lemonade nexus — mesh wireguard zero-trust avec gouvernance cryptographique |
| **gateway** | caddy 2.x — tableau de bord + proxy de services sur :80 |
| **vpn** | wireguard — scannez un code qr, accédez à votre stack depuis votre téléphone |
| **dashboard** | panneau de contrôle glass — chargement de modèles, stats en direct, gestion d'agents |
| **pkg manager** | gestionnaire de paquets — état des services, suivi de versions, déclencheurs de build sur :3010 |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     routeur unifié — toutes les apis, tous les backends      │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│ Claude Code │ Jeux  │ Interviewer │ Nexus VPN  │
│ Pkg Manager (:3010)                              │
├───────────────┴─────────────────────┴────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[regarder l'installation complète](halo-ai-core-install.cast)** — installation propre enregistrée sur strix halo. clonez le dépôt et lancez `asciinema play halo-ai-core-install.cast` pour la voir en temps réel.

## benchmarks — prêts à l'emploi

ces chiffres proviennent d'un `install.sh --yes-all` propre sur matériel strix halo. aucun réglage manuel. aucune astuce. le script d'installation applique toutes les optimisations automatiquement. benchmarks exécutés via l'api lemonade sdk par claude code.

| modèle | quant | test | prompt tok/s | gen tok/s | TTFT |
|--------|-------|------|-------------|----------|------|
| qwen3-30B-A3B | Q4_K_M | court (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | moyen (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | long (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | soutenu (54→2048) | **437.0** | **70.5** | 124ms |

*génération stable à 70-73 tok/s sans dégradation sur 2048 tokens. 18 go de vram sur 64 go utilisés. ttft sous 200ms. testé le 2026-04-08.*

### ce qui le rend rapide

- **lemonade server** — routeur unifié sur :13305. compatible openai, anthropic et ollama. un seul endpoint pour tout.
- **llama.cpp (Vulkan)** — backend Vulkan pré-compilé via Lemonade. sans compilation, sans patches. fonctionne sur tout GPU Vulkan. *(h/t u/Look_0ver_There)*
- **kokoro tts** — synthèse vocale rapide sur cpu. 9 langues.
- **whisper.cpp (Vulkan)** — reconnaissance vocale avec accélération gpu.
- **optimisé gfx1151** — chaque binaire cible votre silicium exact. pas de builds génériques.
- **128 go de mémoire unifiée** — pas de mur VRAM. chargez des modèles 35B sans sourciller.

vous n'avez pas à les chercher. vous n'avez pas à les configurer. `install.sh` le fait pour vous. c'est tout l'intérêt.

## accès mobile instantané — scannez et c'est parti

quand l'installation se termine, un qr code apparaît dans votre terminal. ouvrez l'application wireguard sur votre téléphone, scannez-le, et vous êtes connecté à toute votre pile ia. pas de redirection de ports. pas de relais cloud. pas de configuration. scannez et c'est parti.

```
  ┌──────────────────────────────────────────┐
  │  SCANNEZ AVEC VOTRE TÉLÉPHONE            │
  │  App WireGuard → + → Scanner un QR Code  │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (votre qr ici)

  IP VPN du téléphone: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

vpn wireguard. tunnel chiffré. votre téléphone communique directement avec votre pile via votre réseau local. fonctionne depuis n'importe où sur votre wifi — ou n'importe où dans le monde si vous redirigez udp 51820.

> *fonctionnalité suggérée par zach barrow. énorme victoire. bravo.*

## philosophie

chaque pièce s'emboîte et se détache. pas de dépendances rigides. pas d'enfermement propriétaire. pas d'attaches au cloud.

l'industrie de l'ia veut que vous louiez l'ordinateur de quelqu'un d'autre. nous pensons que vous devriez posséder toute la pile — le matériel, les modèles, les données, le pipeline. quand vous contrôlez votre propre logiciel, vous contrôlez votre propre destin. pas de clés api qui expirent à 2h du matin. pas de conditions d'utilisation qui changent sous vos pieds.

ceci est le noyau. tout le reste est un bloc lego que vous choisissez d'ajouter.

> *"they get the kingdom. they forge their own keys."* *(ils obtiennent le royaume. ils forgent leurs propres clés.)*

## intégration avec les services payants

local d'abord. cloud quand vous le souhaitez. un seul lien, tous les grands fournisseurs ia.

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — guides d'intégration, schémas de routage, gestion des clés api

</div>

> *"sometimes you gotta run before you can walk."* *(parfois il faut courir avant de savoir marcher.)* — halo-ai tourne en local. les services payants sont la porte de secours, pas la fondation.

## blocs lego

le noyau est la fondation. ajoutez ce dont vous avez besoin :

| bloc | à quoi ça sert | statut |
|------|----------------|--------|
| **nexus vpn** | mesh wireguard zero-trust avec gouvernance cryptographique (remplace ssh mesh) | [guide →](docs/wiki/Nexus-VPN.md) |
| **vlan tagging** | isolation réseau 802.1Q (nécessite un switch managé) | [guide →](docs/wiki/Network-Layout.md) |
| **pipeline vocal** | whisper + kokoro tts | [guide →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | interface de chat | planifié |
| **comfyui** | génération d'images/vidéos | planifié |
| **serveurs de jeux** | Minecraft + LinuxGSM | actif |
| **glusterfs** | stockage distribué | planifié |
| **bots discord** | agents ia dans discord | planifié |

[comment créer votre propre bloc →](docs/wiki/Adding-a-Service.md)

## prêt à l'emploi

installez core, ouvrez le navigateur, commencez à parler à votre ia. pas de cli nécessaire.

## recommandé : agents de base

le noyau fonctionne sans agents. mais ces cinq-là surveilleront votre pile quand vous n'êtes pas là.

| agent | mission |
|-------|---------|
| **sentinel** | sécurité — scanne, surveille, ne fait confiance à rien |
| **meek** | auditeur — audit quotidien en 17 points, chaîne d'approvisionnement |
| **shadow** | intégrité — clés nexus, hash de fichiers, santé du mesh |
| **pulse** | surveillance — températures gpu, ram, disque, santé des services |
| **bounty** | bugs — attrape les erreurs, crée automatiquement des fils de correction |

c'est une recommandation, pas une obligation. [guide des agents de base →](docs/wiki/Core-Agents.md)

## sécurité

**lemonade nexus** — vpn mesh wireguard zero-trust. ~~ssh mixer est déprécié et supprimé.~~ nexus est le remplacement.

| | ssh mesh (ancien) | nexus (maintenant) |
|---|---|---|
| gestion des clés | manuelle sur chaque machine | ed25519 auto-généré par serveur |
| chiffrement | ssh uniquement | tunnels wireguard chacha20-poly1305 |
| découverte des pairs | aucune | protocole gossip udp, automatique |
| rotation des clés | manuelle | automatique hebdomadaire avec shamir |
| gouvernance | confiance plate | démocratique — vote majoritaire tier 1 |
| traversée nat | aucune | stun hole-punching + relais |

tous les services écoutent sur 127.0.0.1. nexus fournit le tunnel chiffré. *"vous ne passerez pas."*

[guide nexus vpn →](docs/wiki/Nexus-VPN.md) · [durcissement sécurité →](docs/SECURITY.md)

## confidentialité

**zéro télémétrie. zéro pistage. zéro collecte de données.** rien ne communique vers l'extérieur. vos données restent sur votre machine. *"there is no cloud. there is only zuul."* *(il n'y a pas de cloud. il n'y a que zuul.)*

## documentation

| guide | contenu |
|-------|---------|
| [démarrage](docs/wiki/Getting-Started.md) | installation, vérification, premiers pas |
| [composants](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [architecture](docs/wiki/Architecture.md) | comment les pièces s'assemblent |
| [ajouter un service](docs/wiki/Adding-a-Service.md) | intégrer votre propre bloc lego |
| [gestion des modèles](docs/wiki/Model-Management.md) | charger, changer, benchmarker des modèles |
| [aperçu des agents](docs/wiki/Agents-Overview.md) | les 17 acteurs llm |
| [benchmarks](docs/wiki/Benchmarks.md) | chiffres de performance |
| [dépannage](docs/wiki/Troubleshooting.md) | corrections courantes |
| [wiki complet — 24 pages](docs/wiki/Home.md) | tout |

## options

```
./install.sh --dry-run        aperçu sans installer
./install.sh --yes-all        tout installer
./install.sh --status         vérifier ce qui tourne
./install.sh --skip-rocm      sauter un composant
./install.sh --help           toutes les options
```

## prérequis

- arch linux (bare metal)
- matériel amd ryzen ai (strix halo / strix point)
- sudo sans mot de passe

## remerciements

ce projet existe grâce aux personnes qui ont construit les outils sur lesquels nous nous appuyons.

remerciements particuliers à [Light-Heart-Labs](https://github.com/Light-Heart-Labs) et [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — le phare qui a montré le chemin. sans ce projet, rien de tout cela n'existerait.

construit sur [llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv).

---

<div align="center">

*"i am inevitable."* *(je suis inévitable.)* — *estampillé par l'architecte*

MIT

</div>
