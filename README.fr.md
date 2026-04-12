<div align="center">

🌐 [English](README.md) | **[Français](README.fr.md)** | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### la fondation ia bare-metal pour amd strix halo

**5 services essentiels · 128 go de mémoire unifiée · compilé depuis les sources · zéro cloud · blocs lego**

*estampillé par l'architecte*

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.2.1-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_pages-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-articles-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutoriels-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Sécurité-SSH_uniquement-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Auto_hébergé-100%25_local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24 pages de documentation · **[discord](https://discord.gg/dSyV646eBs)** — communauté + support · **[tutoriels](https://www.youtube.com/@DirtyOldMan-1971)** — guides vidéo

---

## c'est quoi

la couche fondation pour exécuter l'ia en local sur votre propre matériel. un seul script installe tout. cinq services essentiels. tout en systemd. tout en redémarrage automatique. ssh uniquement. *"i know kung fu."* *(je connais le kung fu.)*

## installation

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # voir ce qui se passe d'abord
./install.sh --yes-all    # tout installer
./install.sh --status     # vérifier ce qui tourne
```

## ce que vous obtenez

| | |
|---|---|
| **gpu** | rocm 7.2.1 — mémoire unifiée complète de 128 go sur gfx1151 |
| **inférence** | llama.cpp (Vulkan) — via Lemonade. *(h/t u/Look_0ver_There)* |
| **backend** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **agents** | gaia sdk 0.17.x — créez des agents ia 100% locaux |
| **passerelle** | caddy 2.x — reverse proxy, config drop-in, routage automatique |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │   Vos     │
│  :8080   │  :13305  │  agents   │  blocs    │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## philosophie

chaque pièce s'emboîte et se détache. pas de dépendances rigides. pas d'enfermement propriétaire. pas d'attaches au cloud.

l'industrie de l'ia veut que vous louiez l'ordinateur de quelqu'un d'autre. nous pensons que vous devriez posséder toute la pile — le matériel, les modèles, les données, le pipeline. quand vous contrôlez votre propre logiciel, vous contrôlez votre propre destin. pas de clés api qui expirent à 2h du matin. pas de conditions d'utilisation qui changent sous vos pieds.

ceci est le noyau. tout le reste est un bloc lego que vous choisissez d'ajouter.

> *"they get the kingdom. they forge their own keys."* *(ils obtiennent le royaume. ils forgent leurs propres clés.)*

## blocs lego

le noyau est la fondation. ajoutez ce dont vous avez besoin :

| bloc | à quoi ça sert | statut |
|------|----------------|--------|
| **ssh mesh** | réseau multi-machines | [guide →](docs/wiki/SSH-Mesh.md) |
| **pipeline vocal** | whisper + kokoro tts | [guide →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | interface de chat | planifié |
| **comfyui** | génération d'images/vidéos | planifié |
| **serveurs de jeux** | gestion arcade | planifié |
| **glusterfs** | stockage distribué | planifié |
| **bots discord** | agents ia dans discord | planifié |

[comment créer votre propre bloc →](docs/wiki/Adding-a-Service.md)

## recommandé : agents de base

le noyau fonctionne sans agents. mais ces cinq-là surveilleront votre pile quand vous n'êtes pas là.

| agent | mission |
|-------|---------|
| **sentinel** | sécurité — scanne, surveille, ne fait confiance à rien |
| **meek** | auditeur — audit quotidien en 17 points, chaîne d'approvisionnement |
| **shadow** | intégrité — clés ssh, hash de fichiers, santé du mesh |
| **pulse** | surveillance — températures gpu, ram, disque, santé des services |
| **bounty** | bugs — attrape les erreurs, crée automatiquement des fils de correction |

c'est une recommandation, pas une obligation. [guide des agents de base →](docs/wiki/Core-Agents.md)

## sécurité

clés ssh uniquement. pas de mots de passe. pas de ports ouverts. pas d'exceptions. tous les services sur 127.0.0.1. *"you shall not pass."* *(vous ne passerez pas.)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[guide de sécurité complet →](docs/SECURITY.md)

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
