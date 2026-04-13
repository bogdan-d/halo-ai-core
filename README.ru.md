<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | **Русский** | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### фундамент ai на голом железе для amd strix halo

**13 базовых сервисов · 128 ГБ единой памяти · Lemonade + llama.cpp + Nexus · без облака · блоки Lego**

*штамп архитектора*

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
[![Nexus VPN](https://img.shields.io/badge/Security-Nexus_Zero_Trust-red?style=flat)](docs/wiki/Nexus-VPN.md)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)
[![Bleeding Edge](https://img.shields.io/badge/⚠_Bleeding_Edge-kernel_7.0_+_NPU-ff4444?style=flat)](https://github.com/stampby/halo-ai-core-bleeding-edge)

</div>

---

> **[вики](docs/wiki/Home.md)** — 24 страницы документации · **[дискорд](https://discord.gg/dSyV646eBs)** — сообщество + поддержка · **[туториалы](https://www.youtube.com/@DirtyOldMan-1971)** — видеоинструкции

---

## что это такое

базовый слой для запуска локального ai на вашем собственном железе. один скрипт устанавливает всё. восемь шагов, всё через systemd, всё с автоперезапуском, всё идёт через lemonade server на :13305. только ssh. *"i know kung fu."* *(я знаю кунг-фу.)*

## установка

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # сначала посмотрите, что произойдёт
./install.sh --yes-all    # установить всё
./install.sh --status     # проверить, что работает
```

[![Install Demo](https://img.shields.io/badge/asciinema-смотреть_демо_установки-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *~3 мин на железе strix halo*

## что вы получаете

| | |
|---|---|
| **gpu** | rocm 7.12.0 — полные 128гб унифицированной памяти на gfx1151 |
| **инференс** | llama.cpp (Vulkan) — через llamacpp-бэкенд lemonade. без компиляции. *(спасибо u/Look_0ver_There)* |
| **бэкенд** | lemonade server 10.2.0 — единый маршрутизатор на :13305. совместим с openai + anthropic + ollama |
| **голос** | kokoro tts (cpu) + whisper.cpp (vulkan) — распознавание и синтез речи |
| **кодинг** | claude code — локальный ai-агент для кодирования, запускается через lemonade |
| **игры** | Minecraft + LinuxGSM — управление игровыми серверами |
| **интервью** | interviewer — сеансы практики собеседований на базе ИИ |
| **бенчмарки** | lemonade eval — автоматическое тестирование и анализ точности |
| **mesh vpn** | lemonade nexus — zero-trust WireGuard mesh с криптографическим управлением |
| **шлюз** | caddy 2.x — панель управления + прокси сервисов на :80 |
| **vpn** | wireguard — отсканируйте qr-код, доступ к стеку с телефона |
| **панель** | glass панель управления — загрузка моделей, live-статистика, управление агентами |
| **менеджер пакетов** | менеджер пакетов — статус сервисов, отслеживание версий, триггеры сборки на :3010 |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     единый маршрутизатор — все api, все бэкенды          │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│ Claude Code │ Games  │ Interviewer │ Nexus VPN  │
│ Pkg Manager (:3010)                              │
├───────────────┴─────────────────────┴────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[смотреть полную установку](halo-ai-core-install.cast)** — чистая установка, записанная на strix halo. клонируйте репо и запустите `asciinema play halo-ai-core-install.cast` для просмотра в реальном времени.

## бенчмарки — из коробки

эти цифры получены из чистого `install.sh --yes-all` на железе strix halo. без ручной настройки. без трюков. скрипт установки применяет все оптимизации автоматически. бенчмарки запущены через lemonade sdk api с помощью claude code.

| модель | квант | тест | промпт ток/с | генерация ток/с | TTFT |
|--------|-------|------|-------------|----------------|------|
| qwen3-30B-A3B | Q4_K_M | короткий (13→256) | **251.7** | **73.0** | 52мс |
| qwen3-30B-A3B | Q4_K_M | средний (75→512) | **494.3** | **72.5** | 152мс |
| qwen3-30B-A3B | Q4_K_M | длинный (39→1024) | **385.9** | **71.9** | 101мс |
| qwen3-30B-A3B | Q4_K_M | продолжительный (54→2048) | **437.0** | **70.5** | 124мс |

*стабильная генерация 70-73 ток/с без деградации на 2048 токенов. 18гб из 64гб vram использовано. ttft менее 200мс. тестировано 2026-04-08.*

### что делает его быстрым

- **lemonade server** — единый маршрутизатор на :13305. совместим с openai, anthropic и ollama. один эндпоинт для всего.
- **llama.cpp (Vulkan)** — предварительно собранный Vulkan-бэкенд через Lemonade. без компиляции, без патчей. работает на любом Vulkan GPU. *(h/t u/Look_0ver_There)*
- **kokoro tts** — быстрый синтез речи на cpu. 9 языков.
- **whisper.cpp (Vulkan)** — распознавание речи с gpu-ускорением.
- **оптимизирован для gfx1151** — каждый бинарник нацелен на ваш точный кремний. никаких универсальных сборок.
- **128гб унифицированной памяти** — нет стены VRAM. загружайте модели 35B не задумываясь.

вам не нужно их искать. не нужно их настраивать. `install.sh` делает это за вас. в этом и смысл.

## мгновенный мобильный доступ — сканируй и подключайся

когда установка завершается, в терминале появляется qr-код. откройте приложение wireguard на телефоне, отсканируйте его, и вы подключены ко всему ai-стеку. без проброса портов. без облачного реле. без конфигурации. просто сканируй и подключайся.

```
  ┌──────────────────────────────────────────┐
  │  ОТСКАНИРУЙТЕ ТЕЛЕФОНОМ                   │
  │  WireGuard → + → Сканировать QR-код       │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (ваш QR здесь)

  IP телефона VPN: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

vpn wireguard. зашифрованный туннель. ваш телефон общается напрямую с вашим стеком через локальную сеть. работает из любой точки вашего wifi — или из любой точки мира, если пробросить udp 51820.

> *фича предложена зак барроу. огромная победа. браво.*

## философия

каждый элемент вставляется и вынимается. никаких жёстких зависимостей. никакой привязки к поставщику. никаких облачных привязок.

индустрия ai хочет, чтобы вы арендовали чужой компьютер. мы считаем, что вы должны владеть всем стеком — железом, моделями, данными, пайплайном. когда вы контролируете своё программное обеспечение, вы контролируете свою судьбу. никаких api-ключей, истекающих в 2 часа ночи. никаких условий обслуживания, меняющихся у вас под ногами.

это — ядро. всё остальное — лего-блок, который вы сами решаете добавить.

> *"they get the kingdom. they forge their own keys."* *(они получают королевство. они куют свои собственные ключи.)*

## интеграция с платными сервисами

сначала локально. облако — когда захотите. одна ссылка, все крупные ai-провайдеры.

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — руководства по интеграции, паттерны маршрутизации, управление api-ключами

</div>

> *"sometimes you gotta run before you can walk."* *(иногда нужно бежать, прежде чем научишься ходить.)* — halo-ai работает локально. платные сервисы — это аварийный выход, а не фундамент.

## лего-блоки

ядро — это фундамент. подключайте то, что нужно:

| блок | что делает | статус |
|------|-----------|--------|
| **nexus vpn** | zero-trust WireGuard mesh (замена SSH mesh) | [руководство →](docs/wiki/Nexus-VPN.md) |
| **vlan tagging** | изоляция сети 802.1Q (требуется управляемый коммутатор) | [руководство →](docs/wiki/Network-Layout.md) |
| **голосовой пайплайн** | whisper + kokoro tts | [руководство →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | чат-интерфейс | планируется |
| **comfyui** | генерация изображений/видео | планируется |
| **игровые серверы** | Minecraft + LinuxGSM | активно |
| **glusterfs** | распределённое хранилище | планируется |
| **дискорд-боты** | ai-агенты в дискорде | планируется |

[как создать свой собственный блок →](docs/wiki/Adding-a-Service.md)

## готово к использованию

установите core, откройте браузер, начните общаться с вашим ai. cli не нужен.

## рекомендация: базовые агенты

ядро работает без агентов. но эти пятеро будут следить за вашим стеком, пока вас нет.

| агент | задача |
|-------|--------|
| **sentinel** | безопасность — сканирует, мониторит, не доверяет ничему |
| **meek** | аудитор — ежедневный аудит из 17 проверок, цепочка поставок |
| **shadow** | целостность — nexus-ключи, хеши файлов, здоровье меша |
| **pulse** | мониторинг — температура gpu, озу, диск, состояние сервисов |
| **bounty** | баги — ловит ошибки, автоматически создаёт потоки исправлений |

это рекомендация, а не требование. [руководство по базовым агентам →](docs/wiki/Core-Agents.md)

## безопасность

**Lemonade Nexus** — zero-trust WireGuard mesh VPN. ~~SSH mixer устарел и удалён.~~ Nexus — замена.

| | SSH mesh (старый) | Nexus (сейчас) |
|---|---|---|
| управление ключами | вручную на каждой машине | Ed25519 авто-генерация для каждого сервера |
| шифрование | только SSH | WireGuard ChaCha20-Poly1305 туннели |
| обнаружение пиров | нет | UDP gossip протокол, автоматически |
| ротация ключей | вручную | автоматическая еженедельная с Shamir |
| управление | плоское доверие | демократическое — голосование большинства Tier 1 |
| NAT traversal | нет | STUN hole-punching + relay |

все сервисы привязаны к 127.0.0.1. Nexus обеспечивает зашифрованный туннель. *"ты не пройдёшь."*

[руководство Nexus VPN →](docs/wiki/Nexus-VPN.md) · [усиление безопасности →](docs/SECURITY.md)

## конфиденциальность

**ноль телеметрии. ноль отслеживания. ноль сбора данных.** ничто не звонит домой. ваши данные остаются на вашей машине. *"there is no cloud. there is only zuul."* *(нет никакого облака. есть только зуул.)*

## документация

| руководство | что охватывает |
|-------------|---------------|
| [начало работы](docs/wiki/Getting-Started.md) | установка, проверка, первые шаги |
| [компоненты](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [архитектура](docs/wiki/Architecture.md) | как части соединяются |
| [добавление сервиса](docs/wiki/Adding-a-Service.md) | подключите свой собственный лего-блок |
| [управление моделями](docs/wiki/Model-Management.md) | загрузка, переключение, бенчмарк моделей |
| [обзор агентов](docs/wiki/Agents-Overview.md) | 17 llm-актёров |
| [бенчмарки](docs/wiki/Benchmarks.md) | показатели производительности |
| [устранение неполадок](docs/wiki/Troubleshooting.md) | типичные исправления |
| [полная вики — 24 страницы](docs/wiki/Home.md) | всё |

## параметры

```
./install.sh --dry-run        предпросмотр без установки
./install.sh --yes-all        установить всё
./install.sh --status         проверить, что работает
./install.sh --skip-rocm      пропустить любой компонент
./install.sh --help           все параметры
```

## требования

- arch linux (голое железо)
- аппаратура amd ryzen ai (strix halo / strix point)
- sudo без пароля

## благодарности

этот проект существует благодаря людям, которые создали инструменты, на которых мы стоим.

особая благодарность [Light-Heart-Labs](https://github.com/Light-Heart-Labs) и [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — маяку, который указал путь. без того проекта ничего этого не существовало бы.

построено на [llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv).

---

<div align="center">

*"i am inevitable."* *(я неизбежен.)* — *штамп архитектора*

MIT

</div>
