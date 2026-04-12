<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | **Português** | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### a fundação bare-metal de ia para amd strix halo

**8 serviços principais · 128gb de memória unificada · lemonade + llama.cpp + kokoro tts · zero nuvem · blocos de lego**

*carimbado pelo arquiteto*

[![CI](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml)
[![CodeQL](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.12.0-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![Lemonade](https://img.shields.io/badge/Lemonade_10.2.0-00d4ff?style=flat&logo=amd&logoColor=white)](https://github.com/lemonade-sdk/lemonade)
[![Kokoro TTS](https://img.shields.io/badge/Kokoro_TTS-ff6b35?style=flat)](https://github.com/remsky/Kokoro-FastAPI)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_páginas-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-artigos-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutoriais-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Segurança-apenas_SSH-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Auto_hospedado-100%25_local-purple?style=flat)](https://github.com/stampby/halo-ai-core)
[![Bleeding Edge](https://img.shields.io/badge/⚠_Bleeding_Edge-kernel_7.0_+_NPU-ff4444?style=flat)](https://github.com/stampby/halo-ai-core-bleeding-edge)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24 páginas de documentação · **[discord](https://discord.gg/dSyV646eBs)** — comunidade + suporte · **[tutoriais](https://www.youtube.com/@DirtyOldMan-1971)** — vídeos passo a passo

---

## o que é isto

a camada base para executar ia local no seu próprio hardware. um script instala tudo. oito passos, tudo systemd, tudo reinício automático, tudo passa pelo lemonade server em :13305. apenas ssh. *"i know kung fu."* *(eu sei kung fu.)*

## instalação

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # veja o que acontece primeiro
./install.sh --yes-all    # instalar tudo
./install.sh --status     # verificar o que está a correr
```

[![Install Demo](https://img.shields.io/badge/asciinema-ver_demo_de_instalação-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *~3 min em hardware strix halo*

## o que recebe

| | |
|---|---|
| **gpu** | rocm 7.12.0 — memória unificada completa de 128gb em gfx1151 |
| **inferência** | llama.cpp (Vulkan) — via backend llamacpp do lemonade. sem compilar. *(obrigado u/Look_0ver_There)* |
| **backend** | lemonade server 10.2.0 — router unificado em :13305. compatível com openai + anthropic + ollama |
| **voz** | kokoro tts (cpu) + whisper.cpp (vulkan) — fala-para-texto e texto-para-fala |
| **código** | claude code — agente de programação ia local, lançado via lemonade |
| **gateway** | caddy 2.x — painel de controlo em :80 |
| **vpn** | wireguard — leia um código qr, aceda à sua pilha a partir do telemóvel |
| **painel** | servidor de estatísticas em :5090 — gpu, ram, serviços, carregamento automático no arranque |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     router unificado — todas as apis, todos os backends      │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│  Claude Code  │  Painel (:5090)  │ WireGuard     │
├───────────────┴──────────────────┴───────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[ver a instalação completa](halo-ai-core-install.cast)** — instalação limpa gravada em strix halo. clone o repositório e execute `asciinema play halo-ai-core-install.cast` para ver em tempo real.

## benchmarks — pronto a usar

estes números vêm de um `install.sh --yes-all` limpo em hardware strix halo. sem ajustes manuais. sem truques. o script de instalação aplica todas as otimizações automaticamente. benchmarks executados via api do lemonade sdk pelo claude code.

| modelo | quant | teste | prompt tok/s | gen tok/s | TTFT |
|--------|-------|-------|-------------|----------|------|
| qwen3-30B-A3B | Q4_K_M | curto (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | médio (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | longo (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | sustentado (54→2048) | **437.0** | **70.5** | 124ms |

*geração sólida a 70-73 tok/s sem degradação ao longo de 2048 tokens. 18gb de 64gb de vram usados. ttft abaixo de 200ms. testado em 2026-04-08.*

### o que o torna rápido

- **lemonade server** — router unificado em :13305. compatível com openai, anthropic e ollama. um endpoint para tudo.
- **llama.cpp (Vulkan)** — backend Vulkan pré-compilado via Lemonade. sem compilar, sem patches. funciona em qualquer GPU Vulkan. *(h/t u/Look_0ver_There)*
- **kokoro tts** — síntese de voz rápida em cpu. 9 idiomas.
- **whisper.cpp (Vulkan)** — fala-para-texto com aceleração gpu.
- **otimizado para gfx1151** — cada binário visa o seu silício exato. sem builds genéricos.
- **128gb de memória unificada** — sem barreira de VRAM. carregue modelos 35B sem pestanejar.

não precisa de os procurar. não precisa de os configurar. `install.sh` faz isso por si. esse é o ponto.

## acesso móvel instantâneo — leia e pronto

quando a instalação termina, um código qr aparece no seu terminal. abra a app wireguard no telemóvel, leia-o, e está ligado a toda a sua pilha ia. sem redirecionamento de portas. sem relay na nuvem. sem configuração. leia e pronto.

```
  ┌──────────────────────────────────────────┐
  │  LEIA COM O SEU TELEMÓVEL                │
  │  App WireGuard → + → Ler Código QR       │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (o seu qr aqui)

  IP VPN do telemóvel: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

vpn wireguard. túnel encriptado. o seu telemóvel comunica diretamente com a sua pilha pela rede local. funciona em qualquer lugar do seu wifi — ou em qualquer lugar do mundo se redirecionar udp 51820.

> *funcionalidade sugerida por zach barrow. grande vitória. bravo.*

## filosofia

cada peça encaixa e desencaixa. sem dependências rígidas. sem aprisionamento a fornecedores. sem amarras à nuvem.

a indústria de ia quer que você alugue o computador de outra pessoa. nós achamos que você deveria ser dono de toda a pilha — o hardware, os modelos, os dados, o pipeline. quando você controla o seu próprio software, controla o seu próprio destino. sem chaves de api a expirar às 2 da manhã. sem termos de serviço a mudar sob os seus pés.

isto é o core. tudo o resto é um bloco de lego que você escolhe adicionar.

> *"they get the kingdom. they forge their own keys."* *(eles recebem o reino. forjam as suas próprias chaves.)*

## integração com serviços pagos

local primeiro. nuvem quando quiser. um link, todos os grandes fornecedores de ia.

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — guias de integração, padrões de routing, gestão de chaves api

</div>

> *"sometimes you gotta run before you can walk."* *(às vezes é preciso correr antes de saber andar.)* — halo-ai corre local. serviços pagos são a saída de emergência, não a fundação.

## blocos de lego

o core é a fundação. encaixe o que precisar:

| bloco | o que faz | estado |
|-------|-----------|--------|
| **ssh mesh** | rede multi-máquinas (padrão, funciona em qualquer lugar) | [guia →](docs/wiki/SSH-Mesh.md) |
| **vlan tagging** | isolamento de rede 802.1Q (requer switch gerido) | [guia →](docs/wiki/Network-Layout.md) |
| **pipeline de voz** | whisper + kokoro tts | [guia →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | frontend de chat | planeado |
| **comfyui** | geração de imagem/vídeo | planeado |
| **servidores de jogos** | gestão de arcade | planeado |
| **glusterfs** | armazenamento distribuído | planeado |
| **bots discord** | agentes ia no discord | planeado |

[como construir o seu próprio bloco →](docs/wiki/Adding-a-Service.md)

## pronto a usar

instale o core, abra o navegador, comece a falar com a sua ia. sem cli necessário.

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
