<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | **हिन्दी** | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### amd strix halo के लिए बेयर-मेटल ai आधार

**13 कोर सेवाएं · 128GB यूनिफाइड मेमोरी · Lemonade + llama.cpp + Nexus · जीरो क्लाउड · लेगो ब्लॉक**

*आर्किटेक्ट की मुहर*

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

> **[विकी](docs/wiki/Home.md)** — 24 पृष्ठ दस्तावेज़ · **[डिस्कॉर्ड](https://discord.gg/dSyV646eBs)** — समुदाय + सहायता · **[ट्यूटोरियल](https://www.youtube.com/@DirtyOldMan-1971)** — वीडियो गाइड

---

## यह क्या है

अपने खुद के हार्डवेयर पर लोकल ai चलाने का आधार स्तर। एक स्क्रिप्ट सब कुछ इंस्टॉल करती है। आठ चरण, सब systemd पर, सब ऑटो-रिस्टार्ट, सब कुछ lemonade server :13305 के माध्यम से। केवल ssh। *"i know kung fu."* *(मुझे कुंग फू आता है।)*

## इंस्टॉल

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # पहले देखें क्या होगा
./install.sh --yes-all    # सब कुछ इंस्टॉल करें
./install.sh --status     # जाँचें क्या चल रहा है
```

[![Install Demo](https://img.shields.io/badge/asciinema-इंस्टॉल_डेमो_देखें-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *strix halo हार्डवेयर पर ~3 मिनट*

## आपको क्या मिलता है

| | |
|---|---|
| **gpu** | rocm 7.12.0 — gfx1151 पर पूर्ण 128gb एकीकृत मेमोरी |
| **इन्फरेंस** | llama.cpp (Vulkan) — lemonade के llamacpp बैकएंड के माध्यम से। कंपाइल नहीं करना होगा। *(u/Look_0ver_There को धन्यवाद)* |
| **बैकएंड** | lemonade server 10.2.0 — :13305 पर एकीकृत राउटर। openai + anthropic + ollama संगत |
| **आवाज़** | kokoro tts (cpu) + whisper.cpp (vulkan) — स्पीच-टू-टेक्स्ट और टेक्स्ट-टू-स्पीच |
| **कोडिंग** | claude code — लोकल ai कोडिंग एजेंट, lemonade के माध्यम से लॉन्च |
| **गेम** | Minecraft + LinuxGSM — गेम सर्वर प्रबंधन |
| **साक्षात्कार** | interviewer — AI-संचालित साक्षात्कार अभ्यास सत्र |
| **बेंचमार्क** | lemonade eval — स्वचालित बेंचमार्किंग और सटीकता विश्लेषण |
| **मेश VPN** | lemonade nexus — क्रिप्टोग्राफिक गवर्नेंस के साथ जीरो-ट्रस्ट WireGuard मेश |
| **गेटवे** | caddy 2.x — डैशबोर्ड + सर्विस प्रॉक्सी :80 पर |
| **VPN** | wireguard — QR कोड स्कैन करें, फोन से अपने स्टैक तक पहुंचें |
| **डैशबोर्ड** | glass कंट्रोल पैनल — मॉडल लोडिंग, लाइव स्टैट्स, एजेंट प्रबंधन |
| **पैकेज मैनेजर** | पैकेज मैनेजर — सर्विस स्टेटस, वर्शन ट्रैकिंग, बिल्ड ट्रिगर :3010 पर |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     एकीकृत राउटर — सभी api, सभी बैकएंड            │
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

> **[पूरा इंस्टॉल देखें](halo-ai-core-install.cast)** — strix halo पर रिकॉर्ड किया गया क्लीन इंस्टॉल। रिपो क्लोन करें और `asciinema play halo-ai-core-install.cast` चलाएँ रियल टाइम में देखने के लिए।

## बेंचमार्क — बॉक्स से बाहर तैयार

ये नंबर strix halo हार्डवेयर पर क्लीन `install.sh --yes-all` से आते हैं। कोई मैनुअल ट्यूनिंग नहीं। कोई ट्रिक नहीं। इंस्टॉल स्क्रिप्ट सभी ऑप्टिमाइज़ेशन स्वचालित रूप से लागू करती है। बेंचमार्क claude code द्वारा lemonade sdk api के माध्यम से चलाए गए।

| मॉडल | क्वांट | टेस्ट | प्रॉम्प्ट tok/s | जनरेशन tok/s | TTFT |
|------|--------|--------|-----------------|--------------|------|
| qwen3-30B-A3B | Q4_K_M | छोटा (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | मध्यम (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | लंबा (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | निरंतर (54→2048) | **437.0** | **70.5** | 124ms |

*2048 टोकन पर बिना किसी गिरावट के स्थिर 70-73 tok/s जनरेशन। 64gb में से 18gb vram उपयोग। 200ms से कम ttft। 2026-04-08 को परीक्षित।*

### इसे तेज़ क्या बनाता है

- **lemonade server** — :13305 पर एकीकृत राउटर। openai, anthropic और ollama संगत। सब कुछ के लिए एक एंडपॉइंट।
- **llama.cpp (Vulkan)** — Lemonade के माध्यम से प्री-बिल्ट Vulkan बैकएंड। कंपाइल नहीं, पैच नहीं। किसी भी Vulkan GPU पर चलता है। *(h/t u/Look_0ver_There)*
- **kokoro tts** — तेज़ cpu-आधारित टेक्स्ट-टू-स्पीच। 9 भाषाएँ।
- **whisper.cpp (Vulkan)** — gpu त्वरण के साथ स्पीच-टू-टेक्स्ट।
- **gfx1151 अनुकूलित** — हर बाइनरी आपके सटीक सिलिकॉन को लक्षित करती है। कोई जेनेरिक बिल्ड नहीं।
- **128gb एकीकृत मेमोरी** — कोई VRAM दीवार नहीं। 35B मॉडल बिना झिझक लोड करें।

आपको इन्हें खोजना नहीं है। आपको इन्हें कॉन्फ़िगर नहीं करना है। `install.sh` आपके लिए करता है। यही बात है।

## तुरंत मोबाइल एक्सेस — स्कैन करें और जुड़ें

जब इंस्टॉल पूरा होता है, आपके टर्मिनल में एक qr कोड दिखाई देता है। अपने फोन पर wireguard ऐप खोलें, स्कैन करें, और आप अपने पूरे ai स्टैक से जुड़ जाते हैं। कोई पोर्ट फॉरवर्डिंग नहीं। कोई क्लाउड रिले नहीं। कोई कॉन्फ़िगरेशन नहीं। बस स्कैन करें और जुड़ें।

```
  ┌──────────────────────────────────────────┐
  │  अपने फोन से स्कैन करें                   │
  │  WireGuard ऐप → + → QR कोड स्कैन करें    │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (आपका QR यहाँ)

  फोन VPN IP: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

wireguard vpn। एन्क्रिप्टेड टनल। आपका फोन आपके लोकल नेटवर्क पर सीधे आपके स्टैक से बात करता है। आपके wifi पर कहीं से भी काम करता है — या दुनिया में कहीं से भी अगर आप udp 51820 फॉरवर्ड करते हैं।

> *zach barrow द्वारा सुझाई गई सुविधा। बड़ी जीत। ब्रावो।*

## दर्शन

हर टुकड़ा जोड़ा और निकाला जा सकता है। कोई कठोर निर्भरता नहीं। कोई वेंडर लॉक-इन नहीं। कोई क्लाउड बंधन नहीं।

ai उद्योग चाहता है कि आप किसी और का कंप्यूटर किराए पर लें। हम मानते हैं कि आपको पूरे स्टैक का मालिक होना चाहिए — हार्डवेयर, मॉडल, डेटा, पाइपलाइन। जब आप अपने सॉफ्टवेयर को नियंत्रित करते हैं, तो आप अपनी नियति को नियंत्रित करते हैं। रात 2 बजे समाप्त होने वाली api कुंजी नहीं। आपके पैरों तले बदलती सेवा शर्तें नहीं।

यह कोर है। बाकी सब एक लेगो ब्लॉक है जिसे आप जोड़ना चुनते हैं।

> *"they get the kingdom. they forge their own keys."* *(वे राज्य पाते हैं। वे अपनी चाबियाँ गढ़ते हैं।)*

## सशुल्क सेवाओं के साथ एकीकरण

पहले लोकल। क्लाउड जब चाहें। एक लिंक, हर बड़ा ai प्रदाता।

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

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — एकीकरण गाइड, राउटिंग पैटर्न, api कुंजी प्रबंधन

</div>

> *"sometimes you gotta run before you can walk."* *(कभी-कभी चलने से पहले दौड़ना पड़ता है।)* — halo-ai लोकल चलता है। सशुल्क सेवाएँ आपातकालीन निकास हैं, आधार नहीं।

## लेगो ब्लॉक

कोर आधार है। जो चाहिए वो जोड़ें:

| ब्लॉक | क्या करता है | स्थिति |
|-------|-------------|--------|
| **nexus vpn** | जीरो-ट्रस्ट WireGuard मेश (SSH मेश का प्रतिस्थापन) | [गाइड →](docs/wiki/Nexus-VPN.md) |
| **vlan tagging** | 802.1Q नेटवर्क आइसोलेशन (मैनेज्ड स्विच आवश्यक) | [गाइड →](docs/wiki/Network-Layout.md) |
| **वॉइस पाइपलाइन** | whisper + kokoro tts | [गाइड →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | चैट फ्रंटएंड | योजनाबद्ध |
| **comfyui** | इमेज/वीडियो जनरेशन | योजनाबद्ध |
| **गेम सर्वर** | Minecraft + LinuxGSM | सक्रिय |
| **glusterfs** | वितरित स्टोरेज | योजनाबद्ध |
| **डिस्कॉर्ड बॉट** | डिस्कॉर्ड में ai एजेंट | योजनाबद्ध |

[अपना खुद का ब्लॉक कैसे बनाएँ →](docs/wiki/Adding-a-Service.md)

## तुरंत उपयोग के लिए तैयार

कोर इंस्टॉल करें, ब्राउज़र खोलें, अपने ai से बात शुरू करें। cli की ज़रूरत नहीं।

## अनुशंसित: मुख्य एजेंट

कोर एजेंट के बिना भी चलता है। लेकिन ये पाँच आपकी अनुपस्थिति में आपके स्टैक की निगरानी करेंगे।

| एजेंट | कार्य |
|--------|------|
| **sentinel** | सुरक्षा — स्कैन, निगरानी, किसी पर भरोसा नहीं |
| **meek** | ऑडिटर — 17-जाँच दैनिक ऑडिट, आपूर्ति श्रृंखला |
| **shadow** | अखंडता — nexus कुंजी, फ़ाइल हैश, मेश स्वास्थ्य |
| **pulse** | मॉनिटर — gpu तापमान, रैम, डिस्क, सेवा स्वास्थ्य |
| **bounty** | बग — त्रुटियाँ पकड़ता है, स्वचालित फिक्स थ्रेड बनाता है |

ये अनुशंसा हैं, आवश्यकता नहीं। [मुख्य एजेंट गाइड →](docs/wiki/Core-Agents.md)

## सुरक्षा

**Lemonade Nexus** — जीरो-ट्रस्ट WireGuard मेश VPN। ~~SSH मिक्सर अब बंद और हटा दिया गया है।~~ Nexus इसका प्रतिस्थापन है।

| | SSH मेश (पुराना) | Nexus (अभी) |
|---|---|---|
| कुंजी प्रबंधन | प्रत्येक मशीन पर मैन्युअल | Ed25519 प्रति सर्वर स्वत: उत्पन्न |
| एन्क्रिप्शन | केवल SSH | WireGuard ChaCha20-Poly1305 टनल |
| पीयर खोज | कोई नहीं | UDP गॉसिप प्रोटोकॉल, स्वचालित |
| कुंजी रोटेशन | मैन्युअल | Shamir के साथ स्वचालित साप्ताहिक |
| गवर्नेंस | सपाट विश्वास | लोकतांत्रिक — Tier 1 बहुमत मत |
| NAT ट्रैवर्सल | कोई नहीं | STUN होल पंचिंग + रिले |

सभी सेवाएं 127.0.0.1 पर बाइंड। Nexus एन्क्रिप्टेड टनल प्रदान करता है। *"तुम यहाँ से नहीं गुजरोगे।"*

[Nexus VPN गाइड →](docs/wiki/Nexus-VPN.md) · [सुरक्षा सख्त →](docs/SECURITY.md)

## गोपनीयता

**शून्य टेलीमेट्री। शून्य ट्रैकिंग। शून्य डेटा संग्रह।** कुछ भी बाहर कनेक्ट नहीं होता। आपका डेटा आपकी मशीन पर रहता है। *"there is no cloud. there is only zuul."* *(कोई क्लाउड नहीं है। केवल ज़ूल है।)*

## दस्तावेज़

| गाइड | विषय |
|------|------|
| [शुरुआत](docs/wiki/Getting-Started.md) | इंस्टॉल, सत्यापन, पहले कदम |
| [घटक](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [आर्किटेक्चर](docs/wiki/Architecture.md) | टुकड़े कैसे जुड़ते हैं |
| [सेवा जोड़ें](docs/wiki/Adding-a-Service.md) | अपना खुद का लेगो ब्लॉक जोड़ें |
| [मॉडल प्रबंधन](docs/wiki/Model-Management.md) | मॉडल लोड, स्विच, बेंचमार्क |
| [एजेंट अवलोकन](docs/wiki/Agents-Overview.md) | 17 llm एक्टर |
| [बेंचमार्क](docs/wiki/Benchmarks.md) | प्रदर्शन संख्याएँ |
| [समस्या निवारण](docs/wiki/Troubleshooting.md) | सामान्य समाधान |
| [पूर्ण विकी — 24 पृष्ठ](docs/wiki/Home.md) | सब कुछ |

## विकल्प

```
./install.sh --dry-run        बिना इंस्टॉल किए पूर्वावलोकन
./install.sh --yes-all        सब कुछ इंस्टॉल करें
./install.sh --status         जाँचें क्या चल रहा है
./install.sh --skip-rocm      कोई भी घटक छोड़ें
./install.sh --help           सभी विकल्प
```

## आवश्यकताएँ

- arch linux (बेयर मेटल)
- amd ryzen ai हार्डवेयर (strix halo / strix point)
- पासवर्ड रहित sudo

## श्रेय

यह प्रोजेक्ट उन लोगों की वजह से मौजूद है जिन्होंने वे उपकरण बनाए जिन पर हम खड़े हैं।

[Light-Heart-Labs](https://github.com/Light-Heart-Labs) और [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) को विशेष धन्यवाद — वह प्रकाशस्तंभ जिसने रास्ता दिखाया। अगर वह प्रोजेक्ट नहीं होता, तो इसमें से कुछ भी अस्तित्व में नहीं होता।

[llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv) पर निर्मित।

---

<div align="center">

*"i am inevitable."* *(मैं अनिवार्य हूँ।)* — *आर्किटेक्ट की मुहर*

MIT

</div>
