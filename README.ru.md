<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | **Русский** | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### фундамент ai на голом железе для amd strix halo

**5 базовых сервисов · 128гб унифицированной памяти · собрано из исходников · без облака · как лего**

*штамп архитектора*

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

> **[вики](docs/wiki/Home.md)** — 24 страницы документации · **[дискорд](https://discord.gg/dSyV646eBs)** — сообщество + поддержка · **[туториалы](https://www.youtube.com/@DirtyOldMan-1971)** — видеоинструкции

---

## что это такое

базовый слой для запуска локального ai на вашем собственном железе. один скрипт устанавливает всё. пять базовых сервисов. всё через systemd. всё с автоперезапуском. только ssh. *"i know kung fu." (я знаю кунг-фу.)*

## установка

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # сначала посмотрите, что произойдёт
./install.sh --yes-all    # установить всё
./install.sh --status     # проверить, что работает
```

## что вы получаете

| | |
|---|---|
| **gpu** | rocm 7.2.1 — полные 128гб унифицированной памяти на gfx1151 |
| **инференс** | llama.cpp (Vulkan) — via Lemonade. *(h/t u/Look_0ver_There)* |
| **бэкенд** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **агенты** | gaia sdk 0.17.x — создавайте ai-агентов, работающих 100% локально |
| **шлюз** | caddy 2.x — обратный прокси, подключаемая конфигурация, автомаршрутизация |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  Ваши     │
│  :8080   │  :13305  │  агенты   │  блоки    │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## философия

каждый элемент вставляется и вынимается. никаких жёстких зависимостей. никакой привязки к поставщику. никаких облачных привязок.

индустрия ai хочет, чтобы вы арендовали чужой компьютер. мы считаем, что вы должны владеть всем стеком — железом, моделями, данными, пайплайном. когда вы контролируете своё программное обеспечение, вы контролируете свою судьбу. никаких api-ключей, истекающих в 2 часа ночи. никаких условий обслуживания, меняющихся у вас под ногами.

это — ядро. всё остальное — лего-блок, который вы сами решаете добавить.

> *"they get the kingdom. they forge their own keys." (они получают королевство. они куют свои собственные ключи.)*

## лего-блоки

ядро — это фундамент. подключайте то, что нужно:

| блок | что делает | статус |
|------|-----------|--------|
| **ssh mesh** | многомашинная сеть | [руководство →](docs/wiki/SSH-Mesh.md) |
| **голосовой пайплайн** | whisper + kokoro tts | [руководство →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | чат-интерфейс | планируется |
| **comfyui** | генерация изображений/видео | планируется |
| **игровые серверы** | управление аркадой | планируется |
| **glusterfs** | распределённое хранилище | планируется |
| **дискорд-боты** | ai-агенты в дискорде | планируется |

[как создать свой собственный блок →](docs/wiki/Adding-a-Service.md)

## рекомендация: базовые агенты

ядро работает без агентов. но эти пятеро будут следить за вашим стеком, пока вас нет.

| агент | задача |
|-------|--------|
| **sentinel** | безопасность — сканирует, мониторит, не доверяет ничему |
| **meek** | аудитор — ежедневный аудит из 17 проверок, цепочка поставок |
| **shadow** | целостность — ssh-ключи, хеши файлов, здоровье меша |
| **pulse** | мониторинг — температура gpu, озу, диск, состояние сервисов |
| **bounty** | баги — ловит ошибки, автоматически создаёт потоки исправлений |

это рекомендация, а не требование. [руководство по базовым агентам →](docs/wiki/Core-Agents.md)

## безопасность

только ssh-ключи. никаких паролей. никаких открытых портов. никаких исключений. все сервисы на 127.0.0.1. *"you shall not pass." (ты не пройдёшь.)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[полное руководство по безопасности →](docs/SECURITY.md)

## конфиденциальность

**ноль телеметрии. ноль отслеживания. ноль сбора данных.** ничего не звонит домой. ваши данные остаются на вашей машине. *"there is no cloud. there is only zuul." (нет никакого облака. есть только зуул.)*

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

*"i am inevitable." (я неизбежен.)* — *штамп архитектора*

MIT

</div>
