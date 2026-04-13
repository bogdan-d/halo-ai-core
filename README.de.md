<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | **Deutsch** | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### das bare-metal-ki-fundament für amd strix halo

**8 Kerndienste · 128 GB vereinheitlichter Speicher · lemonade + llama.cpp + kokoro tts · null Cloud · Lego-Bausteine**

*gestempelt vom Architekten*

[![CI](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml)
[![CodeQL](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.12.0-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![Lemonade](https://img.shields.io/badge/Lemonade_10.2.0-00d4ff?style=flat&logo=amd&logoColor=white)](https://github.com/lemonade-sdk/lemonade)
[![Kokoro TTS](https://img.shields.io/badge/Kokoro_TTS-ff6b35?style=flat)](https://github.com/remsky/Kokoro-FastAPI)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_Seiten-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-Artikel-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-Tutorials-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Sicherheit-nur_SSH-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Selbst_gehostet-100%25_lokal-purple?style=flat)](https://github.com/stampby/halo-ai-core)
[![Bleeding Edge](https://img.shields.io/badge/⚠_Bleeding_Edge-kernel_7.0_+_NPU-ff4444?style=flat)](https://github.com/stampby/halo-ai-core-bleeding-edge)

</div>

---

> **[Wiki](docs/wiki/Home.md)** — 24 Seiten Dokumentation · **[Discord](https://discord.gg/dSyV646eBs)** — Community + Support · **[Tutorials](https://www.youtube.com/@DirtyOldMan-1971)** — Video-Anleitungen

---

## was ist das

die Grundschicht, um lokale KI auf eigener Hardware zu betreiben. ein einziges Skript installiert alles. acht Schritte, alles systemd, alles automatischer Neustart, alles läuft über Lemonade Server auf :13305. nur SSH. *"i know kung fu."* *(ich kann Kung Fu.)*

## Installation

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # erst sehen, was passiert
./install.sh --yes-all    # alles installieren
./install.sh --status     # prüfen, was läuft
```

[![Install Demo](https://img.shields.io/badge/asciinema-Install_Demo_ansehen-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *~3 Min auf Strix Halo Hardware*

## was du bekommst

| | |
|---|---|
| **GPU** | rocm 7.12.0 — volle 128 GB vereinheitlichter Speicher auf gfx1151 |
| **Inferenz** | llama.cpp (Vulkan) — über Lemonades llamacpp-Backend. ohne Kompilieren. *(danke u/Look_0ver_There)* |
| **Backend** | lemonade server 10.2.0 — einheitlicher Router auf :13305. openai + anthropic + ollama kompatibel |
| **Sprache** | kokoro tts (cpu) + whisper.cpp (vulkan) — Sprache-zu-Text und Text-zu-Sprache |
| **Coding** | claude code — lokaler KI-Coding-Agent, gestartet über lemonade |
| **Gateway** | caddy 2.x — Dashboard auf :80 |
| **VPN** | wireguard — QR-Code scannen, auf deinen Stack vom Handy zugreifen |
| **Dashboard** | Stats-Server auf :5090 — GPU, RAM, Dienste, automatisches Laden beim Start |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     einheitlicher Router — alle APIs, alle Backends      │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│  Claude Code  │  Dashboard (:5090)  │ WireGuard  │
├───────────────┴─────────────────────┴────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[vollständige Installation ansehen](halo-ai-core-install.cast)** — saubere Installation aufgezeichnet auf Strix Halo. Repo klonen und `asciinema play halo-ai-core-install.cast` ausführen, um es in Echtzeit zu sehen.

## Benchmarks — sofort einsatzbereit

diese Zahlen stammen von einem sauberen `install.sh --yes-all` auf Strix Halo Hardware. kein manuelles Tuning. keine Tricks. das Installationsskript wendet alle Optimierungen automatisch an. Benchmarks über die Lemonade SDK API von Claude Code durchgeführt.

| Modell | Quant | Test | Prompt tok/s | Gen tok/s | TTFT |
|--------|-------|------|-------------|----------|------|
| qwen3-30B-A3B | Q4_K_M | kurz (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | mittel (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | lang (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | dauerhaft (54→2048) | **437.0** | **70.5** | 124ms |

*stabile 70-73 tok/s Generierung ohne Degradation über 2048 Tokens. 18 GB von 64 GB VRAM genutzt. TTFT unter 200ms. getestet am 2026-04-08.*

### was es schnell macht

- **lemonade server** — einheitlicher Router auf :13305. openai-, anthropic- und ollama-kompatibel. ein Endpoint für alles.
- **llama.cpp (Vulkan)** — vorkompiliertes Vulkan-Backend via Lemonade. ohne Kompilieren, ohne Patches. läuft auf jeder Vulkan-GPU. *(h/t u/Look_0ver_There)*
- **kokoro tts** — schnelle CPU-basierte Text-zu-Sprache. 9 Sprachen.
- **whisper.cpp (Vulkan)** — Sprache-zu-Text mit GPU-Beschleunigung.
- **gfx1151 optimiert** — jedes Binary zielt auf dein exaktes Silizium. keine generischen Builds.
- **128 GB vereinheitlichter Speicher** — keine VRAM-Grenze. 35B-Modelle laden ohne zu zögern.

du musst sie nicht suchen. du musst sie nicht konfigurieren. `install.sh` macht es für dich. das ist der Punkt.

## sofortiger mobiler Zugang — scannen und los

wenn die Installation fertig ist, erscheint ein QR-Code in deinem Terminal. öffne die WireGuard-App auf deinem Handy, scanne ihn, und du bist mit deinem gesamten KI-Stack verbunden. keine Portweiterleitung. kein Cloud-Relay. keine Konfiguration. einfach scannen und los.

```
  ┌──────────────────────────────────────────┐
  │  MIT DEINEM HANDY SCANNEN                │
  │  WireGuard App → + → QR-Code scannen     │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (dein QR hier)

  Handy VPN IP: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

WireGuard VPN. verschlüsselter Tunnel. dein Handy kommuniziert direkt mit deinem Stack über dein lokales Netzwerk. funktioniert überall in deinem WLAN — oder überall auf der Welt, wenn du UDP 51820 weiterleitest.

> *Feature vorgeschlagen von Zach Barrow. riesiger Gewinn. bravo.*

## Philosophie

jedes Teil rastet ein und rastet aus. keine harten Abhängigkeiten. kein Vendor Lock-in. keine Cloud-Fesseln.

die KI-Industrie will, dass du den Computer von jemand anderem mietest. wir denken, du solltest den gesamten Stack besitzen — die Hardware, die Modelle, die Daten, die Pipeline. wenn du deine eigene Software kontrollierst, kontrollierst du dein eigenes Schicksal. keine API-Schlüssel, die um 2 Uhr morgens ablaufen. keine Nutzungsbedingungen, die sich unter deinen Füßen ändern.

dies ist der Kern. alles andere ist ein Lego-Baustein, den du wählst hinzuzufügen.

> *"they get the kingdom. they forge their own keys."* *(sie bekommen das Königreich. sie schmieden ihre eigenen Schlüssel.)*

## Integration mit kostenpflichtigen Diensten

lokal zuerst. Cloud, wenn du willst. ein Link, alle großen KI-Anbieter.

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — Integrations-Guides, Routing-Muster, API-Key-Verwaltung

</div>

> *"sometimes you gotta run before you can walk."* *(manchmal muss man rennen, bevor man gehen kann.)* — halo-ai läuft lokal. kostenpflichtige Dienste sind der Notausgang, nicht das Fundament.

## Lego-Bausteine

der Kern ist das Fundament. steck an, was du brauchst:

| Baustein | was er tut | Status |
|----------|-----------|--------|
| **SSH Mesh** | Multi-Maschinen-Netzwerk (Standard, funktioniert überall) | [Anleitung →](docs/wiki/SSH-Mesh.md) |
| **VLAN Tagging** | 802.1Q Netzwerk-Isolation (erfordert Managed Switch) | [Anleitung →](docs/wiki/Network-Layout.md) |
| **Sprach-Pipeline** | whisper + kokoro tts | [Anleitung →](docs/wiki/Voice-Pipeline.md) |
| **Open WebUI** | Chat-Oberfläche | geplant |
| **ComfyUI** | Bild-/Videogenerierung | geplant |
| **Spieleserver** | Minecraft + LinuxGSM | aktiv |
| **GlusterFS** | verteilter Speicher | geplant |
| **Discord-Bots** | KI-Agenten in Discord | geplant |

[wie du deinen eigenen Baustein baust →](docs/wiki/Adding-a-Service.md)

## sofort einsatzbereit

Core installieren, Browser öffnen, mit deiner KI reden. kein CLI nötig.

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
