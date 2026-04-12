<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | **[Español](README.es.md)** | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### la base de ia bare-metal para amd strix halo

**5 servicios esenciales · 128 gb de memoria unificada · compilado desde el código fuente · cero nube · bloques lego**

*sellado por el arquitecto*

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.2.1-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_páginas-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-artículos-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutoriales-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Seguridad-solo_SSH-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Auto_alojado-100%25_local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24 páginas de documentación · **[discord](https://discord.gg/dSyV646eBs)** — comunidad + soporte · **[tutoriales](https://www.youtube.com/@DirtyOldMan-1971)** — guías en vídeo

---

## qué es esto

la capa base para ejecutar ia local en tu propio hardware. un solo script lo instala todo. cinco servicios esenciales. todo systemd. todo reinicio automático. solo ssh. *"i know kung fu."* *(conozco el kung fu.)*

## instalación

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # ver qué pasará primero
./install.sh --yes-all    # instalar todo
./install.sh --status     # comprobar qué está corriendo
```

## qué obtienes

| | |
|---|---|
| **gpu** | rocm 7.2.1 — memoria unificada completa de 128 gb en gfx1151 |
| **inferencia** | llama.cpp (Vulkan) — via Lemonade. *(h/t u/Look_0ver_There)* |
| **backend** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **agentes** | gaia sdk 0.17.x — construye agentes de ia 100% locales |
| **pasarela** | caddy 2.x — reverse proxy, config drop-in, enrutamiento automático |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │   Tus     │
│  :8080   │  :13305  │  agentes  │  bloques  │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## filosofía

cada pieza encaja y se desencaja. sin dependencias rígidas. sin ataduras a proveedores. sin cadenas a la nube.

la industria de la ia quiere que alquiles el ordenador de otro. nosotros creemos que deberías ser dueño de toda la pila — el hardware, los modelos, los datos, el pipeline. cuando controlas tu propio software, controlas tu propio destino. sin claves api que caducan a las 2 de la mañana. sin términos de servicio que cambian bajo tus pies.

esto es el núcleo. todo lo demás es un bloque lego que tú eliges añadir.

> *"they get the kingdom. they forge their own keys."* *(obtienen el reino. forjan sus propias llaves.)*

## bloques lego

el núcleo es la base. añade lo que necesites:

| bloque | para qué sirve | estado |
|--------|----------------|--------|
| **ssh mesh** | red multi-máquinas | [guía →](docs/wiki/SSH-Mesh.md) |
| **pipeline de voz** | whisper + kokoro tts | [guía →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | interfaz de chat | planificado |
| **comfyui** | generación de imágenes/vídeo | planificado |
| **servidores de juegos** | gestión arcade | planificado |
| **glusterfs** | almacenamiento distribuido | planificado |
| **bots discord** | agentes ia en discord | planificado |

[cómo construir tu propio bloque →](docs/wiki/Adding-a-Service.md)

## recomendado: agentes principales

el núcleo funciona sin agentes. pero estos cinco vigilarán tu pila cuando no estés.

| agente | tarea |
|--------|-------|
| **sentinel** | seguridad — escanea, monitoriza, no confía en nada |
| **meek** | auditor — auditoría diaria de 17 puntos, cadena de suministro |
| **shadow** | integridad — claves ssh, hashes de archivos, salud del mesh |
| **pulse** | monitorización — temperaturas gpu, ram, disco, salud de servicios |
| **bounty** | bugs — atrapa errores, crea hilos de corrección automáticamente |

son una recomendación, no un requisito. [guía de agentes principales →](docs/wiki/Core-Agents.md)

## seguridad

solo claves ssh. sin contraseñas. sin puertos abiertos. sin excepciones. todos los servicios en 127.0.0.1. *"you shall not pass."* *(no pasarás.)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[guía de seguridad completa →](docs/SECURITY.md)

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
