<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | **Español** | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### la base de ia bare-metal para amd strix halo

**13 servicios principales · 128 gb de memoria unificada · lemonade + llama.cpp + nexus · cero cloud · bloques lego**

*sellado por el arquitecto*

[![CI](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml)
[![CodeQL](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.12.0-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![Lemonade](https://img.shields.io/badge/Lemonade_10.2.0-00d4ff?style=flat&logo=amd&logoColor=white)](https://github.com/lemonade-sdk/lemonade)
[![Kokoro TTS](https://img.shields.io/badge/Kokoro_TTS-ff6b35?style=flat)](https://github.com/remsky/Kokoro-FastAPI)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_páginas-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-artículos-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutoriales-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![Nexus VPN](https://img.shields.io/badge/Security-Nexus_Zero_Trust-red?style=flat)](docs/wiki/Nexus-VPN.md)
[![Self Hosted](https://img.shields.io/badge/Auto_alojado-100%25_local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24 páginas de documentación · **[discord](https://discord.gg/dSyV646eBs)** — comunidad + soporte · **[tutoriales](https://www.youtube.com/@DirtyOldMan-1971)** — guías en vídeo

---

## qué es esto

la capa base para ejecutar ia local en tu propio hardware. un solo script lo instala todo. ocho pasos, todo systemd, todo reinicio automático, todo pasa por lemonade server en :13305. solo ssh. *"i know kung fu."* *(conozco el kung fu.)*

## instalación

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # ver qué pasará primero
./install.sh --yes-all    # instalar todo
./install.sh --status     # comprobar qué está corriendo
```

[![Install Demo](https://img.shields.io/badge/asciinema-ver_demo_de_instalación-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *~3 min en hardware strix halo*

## qué obtienes

| | |
|---|---|
| **gpu** | rocm 7.12.0 — memoria unificada completa de 128 gb en gfx1151 |
| **inferencia** | llama.cpp (Vulkan) — via el backend llamacpp de lemonade. sin compilar. *(gracias u/Look_0ver_There)* |
| **backend** | lemonade server 10.2.0 — router unificado en :13305. compatible con openai + anthropic + ollama |
| **voz** | kokoro tts (cpu) + whisper.cpp (vulkan) — reconocimiento y síntesis de voz |
| **código** | claude code — agente de codificación ia local, lanzado a través de lemonade |
| **juegos** | Minecraft + LinuxGSM — gestión de servidores de juegos |
| **interview** | interviewer — sesiones de práctica de entrevistas impulsadas por ia |
| **benchmarks** | lemonade eval — benchmarking automatizado y análisis de precisión |
| **mesh vpn** | lemonade nexus — mesh wireguard de confianza cero con gobernanza criptográfica |
| **gateway** | caddy 2.x — panel de control + proxy de servicios en :80 |
| **vpn** | wireguard — escanea un código qr, accede a tu stack desde tu teléfono |
| **dashboard** | panel de control glass — carga de modelos, estadísticas en vivo, gestión de agentes |
| **pkg manager** | gestor de paquetes — estado de servicios, seguimiento de versiones, disparadores de compilación en :3010 |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     router unificado — todas las apis, todos los backends      │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│ Claude Code │ Juegos  │ Interviewer │ Nexus VPN  │
│ Pkg Manager (:3010)                              │
├───────────────┴─────────────────────┴────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> **[ver la instalación completa](halo-ai-core-install.cast)** — instalación limpia grabada en strix halo. clona el repo y ejecuta `asciinema play halo-ai-core-install.cast` para verla en tiempo real.

## benchmarks — listo para usar

estos números provienen de un `install.sh --yes-all` limpio en hardware strix halo. sin ajustes manuales. sin trucos. el script de instalación aplica todas las optimizaciones automáticamente. benchmarks ejecutados a través de la api de lemonade sdk por claude code.

| modelo | quant | test | prompt tok/s | gen tok/s | TTFT |
|--------|-------|------|-------------|----------|------|
| qwen3-30B-A3B | Q4_K_M | corto (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | medio (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | largo (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | sostenido (54→2048) | **437.0** | **70.5** | 124ms |

*generación sólida a 70-73 tok/s sin degradación en 2048 tokens. 18 gb de 64 gb de vram usados. ttft inferior a 200ms. probado 2026-04-08.*

### qué lo hace rápido

- **lemonade server** — router unificado en :13305. compatible con openai, anthropic y ollama. un solo endpoint para todo.
- **llama.cpp (Vulkan)** — backend Vulkan pre-compilado via Lemonade. sin compilar, sin parches. funciona en cualquier GPU Vulkan. *(h/t u/Look_0ver_There)*
- **kokoro tts** — síntesis de voz rápida por cpu. 9 idiomas.
- **whisper.cpp (Vulkan)** — reconocimiento de voz con aceleración gpu.
- **optimizado para gfx1151** — cada binario apunta a tu silicio exacto. sin builds genéricos.
- **128 gb de memoria unificada** — sin muro de VRAM. carga modelos de 35B sin pestañear.

no tienes que buscarlos. no tienes que configurarlos. `install.sh` lo hace por ti. ese es el punto.

## acceso móvil instantáneo — escanea y listo

cuando la instalación termina, aparece un código qr en tu terminal. abre la app wireguard en tu teléfono, escanéalo, y estás conectado a toda tu pila ia. sin redirección de puertos. sin relay en la nube. sin configuración. escanea y listo.

```
  ┌──────────────────────────────────────────┐
  │  ESCANEA CON TU TELÉFONO                 │
  │  App WireGuard → + → Escanear QR         │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (tu qr aquí)

  IP VPN del teléfono: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

vpn wireguard. túnel cifrado. tu teléfono habla directamente con tu pila a través de tu red local. funciona desde cualquier lugar en tu wifi — o desde cualquier lugar del mundo si rediriges udp 51820.

> *funcionalidad sugerida por zach barrow. gran acierto. bravo.*

## filosofía

cada pieza encaja y se desencaja. sin dependencias rígidas. sin ataduras a proveedores. sin cadenas a la nube.

la industria de la ia quiere que alquiles el ordenador de otro. nosotros creemos que deberías ser dueño de toda la pila — el hardware, los modelos, los datos, el pipeline. cuando controlas tu propio software, controlas tu propio destino. sin claves api que caducan a las 2 de la mañana. sin términos de servicio que cambian bajo tus pies.

esto es el núcleo. todo lo demás es un bloque lego que tú eliges añadir.

> *"they get the kingdom. they forge their own keys."* *(obtienen el reino. forjan sus propias llaves.)*

## integración con servicios de pago

local primero. nube cuando quieras. un enlace, todos los grandes proveedores de ia.

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — guías de integración, patrones de enrutamiento, gestión de claves api

</div>

> *"sometimes you gotta run before you can walk."* *(a veces hay que correr antes de poder caminar.)* — halo-ai corre en local. los servicios de pago son la salida de emergencia, no la base.

## bloques lego

el núcleo es la base. añade lo que necesites:

| bloque | para qué sirve | estado |
|--------|----------------|--------|
| **nexus vpn** | mesh wireguard de confianza cero con gobernanza criptográfica (reemplaza ssh mesh) | [guide →](docs/wiki/Nexus-VPN.md) |
| **vlan tagging** | aislamiento de red 802.1Q (requiere switch gestionado) | [guía →](docs/wiki/Network-Layout.md) |
| **pipeline de voz** | whisper + kokoro tts | [guía →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | interfaz de chat | planificado |
| **comfyui** | generación de imágenes/vídeo | planificado |
| **servidores de juegos** | Minecraft + LinuxGSM | activo |
| **glusterfs** | almacenamiento distribuido | planificado |
| **bots discord** | agentes ia en discord | planificado |

[cómo construir tu propio bloque →](docs/wiki/Adding-a-Service.md)

## listo para usar

instala core, abre el navegador, empieza a hablar con tu ia. sin cli necesario.

## recomendado: agentes principales

el núcleo funciona sin agentes. pero estos cinco vigilarán tu pila cuando no estés.

| agente | tarea |
|--------|-------|
| **sentinel** | seguridad — escanea, monitoriza, no confía en nada |
| **meek** | auditor — auditoría diaria de 17 puntos, cadena de suministro |
| **shadow** | integridad — claves nexus, hashes de archivos, salud del mesh |
| **pulse** | monitorización — temperaturas gpu, ram, disco, salud de servicios |
| **bounty** | bugs — atrapa errores, crea hilos de corrección automáticamente |

son una recomendación, no un requisito. [guía de agentes principales →](docs/wiki/Core-Agents.md)

## seguridad

**lemonade nexus** — vpn mesh wireguard de confianza cero. ~~ssh mixer está obsoleto y eliminado.~~ nexus es el reemplazo.

| | ssh mesh (antiguo) | nexus (ahora) |
|---|---|---|
| gestión de claves | manual en cada máquina | ed25519 auto-generado por servidor |
| cifrado | solo ssh | túneles wireguard chacha20-poly1305 |
| descubrimiento de pares | ninguno | protocolo gossip udp, automático |
| rotación de claves | manual | automática semanal con shamir |
| gobernanza | confianza plana | democrática — voto mayoritario tier 1 |
| traversal nat | ninguno | stun hole-punching + relay |

todos los servicios escuchan en 127.0.0.1. nexus proporciona el túnel cifrado. *"no pasarás."*

[guía nexus vpn →](docs/wiki/Nexus-VPN.md) · [endurecimiento de seguridad →](docs/SECURITY.md)

## privacidad

**cero telemetría. cero rastreo. cero recolección de datos.** nada llama a casa. tus datos se quedan en tu máquina. *"there is no cloud. there is only zuul."* *(no hay nube. solo hay zuul.)*

## documentación

| guía | contenido |
|------|-----------|
| [primeros pasos](docs/wiki/Getting-Started.md) | instalación, verificación, primeros pasos |
| [componentes](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [arquitectura](docs/wiki/Architecture.md) | cómo encajan las piezas |
| [añadir un servicio](docs/wiki/Adding-a-Service.md) | integrar tu propio bloque lego |
| [gestión de modelos](docs/wiki/Model-Management.md) | cargar, cambiar, benchmarkear modelos |
| [resumen de agentes](docs/wiki/Agents-Overview.md) | los 17 actores llm |
| [benchmarks](docs/wiki/Benchmarks.md) | cifras de rendimiento |
| [solución de problemas](docs/wiki/Troubleshooting.md) | correcciones comunes |
| [wiki completa — 24 páginas](docs/wiki/Home.md) | todo |

## opciones

```
./install.sh --dry-run        vista previa sin instalar
./install.sh --yes-all        instalar todo
./install.sh --status         comprobar qué está corriendo
./install.sh --skip-rocm      saltar cualquier componente
./install.sh --help           todas las opciones
```

## requisitos

- arch linux (bare metal)
- hardware amd ryzen ai (strix halo / strix point)
- sudo sin contraseña

## créditos

este proyecto existe gracias a las personas que construyeron las herramientas sobre las que nos apoyamos.

agradecimiento especial a [Light-Heart-Labs](https://github.com/Light-Heart-Labs) y [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — el faro que mostró el camino. si no fuera por ese proyecto, nada de esto existiría.

construido sobre [llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv).

---

<div align="center">

*"i am inevitable."* *(soy inevitable.)* — *sellado por el arquitecto*

MIT

</div>
