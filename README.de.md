<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | **[Deutsch](README.de.md)** | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### das bare-metal-ki-fundament für amd strix halo

**5 Kerndienste · 128 GB vereinheitlichter Speicher · aus Quellcode kompiliert · null Cloud · Lego-Bausteine**

*gestempelt vom Architekten*

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.2.1-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_Seiten-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-Artikel-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-Tutorials-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Sicherheit-nur_SSH-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Selbst_gehostet-100%25_lokal-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

> **[Wiki](docs/wiki/Home.md)** — 24 Seiten Dokumentation · **[Discord](https://discord.gg/dSyV646eBs)** — Community + Support · **[Tutorials](https://www.youtube.com/@DirtyOldMan-1971)** — Video-Anleitungen

---

## was ist das

die Grundschicht, um lokale KI auf eigener Hardware zu betreiben. ein einziges Skript installiert alles. fünf Kerndienste. alles systemd. alles automatischer Neustart. nur SSH. *"i know kung fu."* *(ich kann Kung Fu.)*

## Installation

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # erst sehen, was passiert
./install.sh --yes-all    # alles installieren
./install.sh --status     # prüfen, was läuft
```

## was du bekommst

| | |
|---|---|
| **GPU** | rocm 7.2.1 — volle 128 GB vereinheitlichter Speicher auf gfx1151 |
| **Inferenz** | llama.cpp — aus Quellcode kompiliert, hip + vulkan |
| **Backend** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **Agenten** | gaia sdk 0.17.x — baue KI-Agenten, die 100% lokal laufen |
| **Gateway** | caddy 2.x — Reverse Proxy, Drop-in-Konfiguration, Auto-Routing |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  Deine    │
│  :8080   │  :13305  │  Agenten  │ Bausteine │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## Philosophie

jedes Teil rastet ein und rastet aus. keine harten Abhängigkeiten. kein Vendor Lock-in. keine Cloud-Fesseln.

die KI-Industrie will, dass du den Computer von jemand anderem mietest. wir denken, du solltest den gesamten Stack besitzen — die Hardware, die Modelle, die Daten, die Pipeline. wenn du deine eigene Software kontrollierst, kontrollierst du dein eigenes Schicksal. keine API-Schlüssel, die um 2 Uhr morgens ablaufen. keine Nutzungsbedingungen, die sich unter deinen Füßen ändern.

dies ist der Kern. alles andere ist ein Lego-Baustein, den du wählst hinzuzufügen.

> *"they get the kingdom. they forge their own keys."* *(sie bekommen das Königreich. sie schmieden ihre eigenen Schlüssel.)*

## Lego-Bausteine

der Kern ist das Fundament. steck an, was du brauchst:

| Baustein | was er tut | Status |
|----------|-----------|--------|
| **SSH Mesh** | Multi-Maschinen-Netzwerk | [Anleitung →](docs/wiki/SSH-Mesh.md) |
| **Sprach-Pipeline** | whisper + kokoro tts | [Anleitung →](docs/wiki/Voice-Pipeline.md) |
| **Open WebUI** | Chat-Oberfläche | geplant |
| **ComfyUI** | Bild-/Videogenerierung | geplant |
| **Spieleserver** | Arcade-Verwaltung | geplant |
| **GlusterFS** | verteilter Speicher | geplant |
| **Discord-Bots** | KI-Agenten in Discord | geplant |

[wie du deinen eigenen Baustein baust →](docs/wiki/Adding-a-Service.md)

## empfohlen: Kern-Agenten

der Kern läuft ohne Agenten. aber diese fünf überwachen deinen Stack, wenn du nicht da bist.

| Agent | Aufgabe |
|-------|---------|
| **sentinel** | Sicherheit — scannt, überwacht, vertraut nichts |
| **meek** | Prüfer — tägliche 17-Punkte-Prüfung, Lieferkette |
| **shadow** | Integrität — SSH-Schlüssel, Datei-Hashes, Mesh-Gesundheit |
| **pulse** | Überwachung — GPU-Temperaturen, RAM, Festplatte, Dienst-Gesundheit |
| **bounty** | Bugs — fängt Fehler, erstellt automatisch Fix-Threads |

sie sind eine Empfehlung, keine Voraussetzung. [Kern-Agenten-Anleitung →](docs/wiki/Core-Agents.md)

## Sicherheit

nur SSH-Schlüssel. keine Passwörter. keine offenen Ports. keine Ausnahmen. alle Dienste auf 127.0.0.1. *"you shall not pass."* *(du kommst hier nicht vorbei.)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[vollständige Sicherheitsanleitung →](docs/SECURITY.md)

## Datenschutz

**null Telemetrie. null Tracking. null Datenerfassung.** nichts telefoniert nach Hause. deine Daten bleiben auf deiner Maschine. *"there is no cloud. there is only zuul."* *(es gibt keine Cloud. es gibt nur Zuul.)*

## Dokumentation

| Anleitung | Inhalt |
|-----------|--------|
| [Erste Schritte](docs/wiki/Getting-Started.md) | Installation, Überprüfung, erste Schritte |
| [Komponenten](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [Architektur](docs/wiki/Architecture.md) | wie die Teile zusammenpassen |
| [Dienst hinzufügen](docs/wiki/Adding-a-Service.md) | eigenen Lego-Baustein integrieren |
| [Modellverwaltung](docs/wiki/Model-Management.md) | Modelle laden, wechseln, benchmarken |
| [Agenten-Überblick](docs/wiki/Agents-Overview.md) | die 17 LLM-Akteure |
| [Benchmarks](docs/wiki/Benchmarks.md) | Leistungszahlen |
| [Fehlerbehebung](docs/wiki/Troubleshooting.md) | häufige Lösungen |
| [Vollständiges Wiki — 24 Seiten](docs/wiki/Home.md) | alles |

## Optionen

```
./install.sh --dry-run        Vorschau ohne Installation
./install.sh --yes-all        alles installieren
./install.sh --status         prüfen, was läuft
./install.sh --skip-rocm      beliebige Komponente überspringen
./install.sh --help           alle Optionen
```

## Voraussetzungen

- Arch Linux (Bare Metal)
- AMD Ryzen AI Hardware (Strix Halo / Strix Point)
- passwortloses sudo

## Danksagungen

dieses Projekt existiert dank der Menschen, die die Werkzeuge gebaut haben, auf denen wir aufbauen.

besonderer Dank an [Light-Heart-Labs](https://github.com/Light-Heart-Labs) und [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — der Leuchtturm, der den Weg zeigte. ohne dieses Projekt würde nichts davon existieren.

gebaut auf [llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv).

---

<div align="center">

*"i am inevitable."* *(ich bin unvermeidlich.)* — *gestempelt vom Architekten*

MIT

</div>
