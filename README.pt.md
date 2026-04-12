<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | **[Português](README.pt.md)** | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### a fundação bare-metal de ia para amd strix halo

**5 serviços principais · 128gb de memória unificada · compilado a partir do código-fonte · zero nuvem · blocos de lego**

*carimbado pelo arquiteto*

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

> **[wiki](docs/wiki/Home.md)** — 24 páginas de documentação · **[discord](https://discord.gg/dSyV646eBs)** — comunidade + suporte · **[tutoriais](https://www.youtube.com/@DirtyOldMan-1971)** — vídeos passo a passo

---

## o que é isto

a camada base para executar ia local no seu próprio hardware. um script instala tudo. cinco serviços principais. tudo systemd. tudo com reinício automático. apenas ssh. *"i know kung fu."* *(eu sei kung fu.)*

## instalação

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # veja o que acontece primeiro
./install.sh --yes-all    # instalar tudo
./install.sh --status     # verificar o que está a correr
```

## o que recebe

| | |
|---|---|
| **gpu** | rocm 7.2.1 — memória unificada completa de 128gb em gfx1151 |
| **inferência** | llama.cpp (Vulkan) — via Lemonade. *(h/t u/Look_0ver_There)* |
| **backend** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **agentes** | gaia sdk 0.17.x — construa agentes de ia que funcionam 100% localmente |
| **gateway** | caddy 2.x — proxy reverso, configuração drop-in, roteamento automático |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  Os seus  │
│  :8080   │  :13305  │  agentes  │  blocos   │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## filosofia

cada peça encaixa e desencaixa. sem dependências rígidas. sem aprisionamento a fornecedores. sem amarras à nuvem.

a indústria de ia quer que você alugue o computador de outra pessoa. nós achamos que você deveria ser dono de toda a pilha — o hardware, os modelos, os dados, o pipeline. quando você controla o seu próprio software, controla o seu próprio destino. sem chaves de api a expirar às 2 da manhã. sem termos de serviço a mudar sob os seus pés.

isto é o core. tudo o resto é um bloco de lego que você escolhe adicionar.

> *"they get the kingdom. they forge their own keys."* *(eles recebem o reino. forjam as suas próprias chaves.)*

## blocos de lego

o core é a fundação. encaixe o que precisar:

| bloco | o que faz | estado |
|-------|-----------|--------|
| **ssh mesh** | rede multi-máquinas | [guia →](docs/wiki/SSH-Mesh.md) |
| **pipeline de voz** | whisper + kokoro tts | [guia →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | frontend de chat | planeado |
| **comfyui** | geração de imagem/vídeo | planeado |
| **servidores de jogos** | gestão de arcade | planeado |
| **glusterfs** | armazenamento distribuído | planeado |
| **bots discord** | agentes ia no discord | planeado |

[como construir o seu próprio bloco →](docs/wiki/Adding-a-Service.md)

## recomendado: agentes principais

o core funciona sem agentes. mas estes cinco vigiam a sua pilha quando você não está por perto.

| agente | função |
|--------|--------|
| **sentinel** | segurança — analisa, monitoriza, não confia em nada |
| **meek** | auditor — auditoria diária de 17 verificações, cadeia de fornecimento |
| **shadow** | integridade — chaves ssh, hashes de ficheiros, saúde da mesh |
| **pulse** | monitor — temperaturas gpu, ram, disco, saúde dos serviços |
| **bounty** | bugs — captura erros, cria threads de correção automaticamente |

são uma recomendação, não um requisito. [guia dos agentes principais →](docs/wiki/Core-Agents.md)

## segurança

apenas chaves ssh. sem senhas. sem portas abertas. sem exceções. todos os serviços em 127.0.0.1. *"you shall not pass."* *(não passarás.)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[guia completo de segurança →](docs/SECURITY.md)

## privacidade

**zero telemetria. zero rastreamento. zero recolha de dados.** nada liga para casa. os seus dados ficam na sua máquina. *"there is no cloud. there is only zuul."* *(não há nuvem. só existe zuul.)*

## documentação

| guia | o que abrange |
|------|--------------|
| [primeiros passos](docs/wiki/Getting-Started.md) | instalação, verificação, primeiros passos |
| [componentes](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [arquitetura](docs/wiki/Architecture.md) | como as peças se encaixam |
| [adicionar um serviço](docs/wiki/Adding-a-Service.md) | encaixe o seu próprio bloco de lego |
| [gestão de modelos](docs/wiki/Model-Management.md) | carregar, trocar, testar modelos |
| [visão geral dos agentes](docs/wiki/Agents-Overview.md) | os 17 atores llm |
| [benchmarks](docs/wiki/Benchmarks.md) | números de desempenho |
| [resolução de problemas](docs/wiki/Troubleshooting.md) | correções comuns |
| [wiki completa — 24 páginas](docs/wiki/Home.md) | tudo |

## opções

```
./install.sh --dry-run        pré-visualizar sem instalar
./install.sh --yes-all        instalar tudo
./install.sh --status         verificar o que está a correr
./install.sh --skip-rocm      saltar qualquer componente
./install.sh --help           todas as opções
```

## requisitos

- arch linux (bare metal)
- hardware amd ryzen ai (strix halo / strix point)
- sudo sem senha

## créditos

este projeto existe por causa das pessoas que construíram as ferramentas sobre as quais nos apoiamos.

agradecimento especial a [Light-Heart-Labs](https://github.com/Light-Heart-Labs) e [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — o farol que mostrou o caminho. se não fosse por esse projeto, nada disto existiria.

construído sobre [llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv).

---

<div align="center">

*"i am inevitable."* *(eu sou inevitável.)* — *carimbado pelo arquiteto*

MIT

</div>
