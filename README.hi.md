<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | **हिन्दी** | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### amd strix halo के लिए बेयर-मेटल ai आधार

**5 मुख्य सेवाएँ · 128gb एकीकृत मेमोरी · सोर्स से कंपाइल · शून्य क्लाउड · लेगो ब्लॉक**

*आर्किटेक्ट की मुहर*

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

> **[विकी](docs/wiki/Home.md)** — 24 पृष्ठ दस्तावेज़ · **[डिस्कॉर्ड](https://discord.gg/dSyV646eBs)** — समुदाय + सहायता · **[ट्यूटोरियल](https://www.youtube.com/@DirtyOldMan-1971)** — वीडियो गाइड

---

## यह क्या है

अपने खुद के हार्डवेयर पर लोकल ai चलाने का आधार स्तर। एक स्क्रिप्ट सब कुछ इंस्टॉल करती है। पाँच मुख्य सेवाएँ। सब systemd पर। सब ऑटो-रिस्टार्ट। केवल ssh। *"i know kung fu." (मुझे कुंग फू आता है।)*

## इंस्टॉल

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # पहले देखें क्या होगा
./install.sh --yes-all    # सब कुछ इंस्टॉल करें
./install.sh --status     # जाँचें क्या चल रहा है
```

## आपको क्या मिलता है

| | |
|---|---|
| **gpu** | rocm 7.2.1 — gfx1151 पर पूर्ण 128gb एकीकृत मेमोरी |
| **इन्फरेंस** | llama.cpp (Vulkan) — via Lemonade. *(h/t u/Look_0ver_There)* |
| **बैकएंड** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **एजेंट** | gaia sdk 0.17.x — 100% लोकल ai एजेंट बनाएँ |
| **गेटवे** | caddy 2.x — रिवर्स प्रॉक्सी, ड्रॉप-इन कॉन्फिग, ऑटो-रूटिंग |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  आपके    │
│  :8080   │  :13305  │  एजेंट   │  ब्लॉक   │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## दर्शन

हर टुकड़ा जोड़ा और निकाला जा सकता है। कोई कठोर निर्भरता नहीं। कोई वेंडर लॉक-इन नहीं। कोई क्लाउड बंधन नहीं।

ai उद्योग चाहता है कि आप किसी और का कंप्यूटर किराए पर लें। हम मानते हैं कि आपको पूरे स्टैक का मालिक होना चाहिए — हार्डवेयर, मॉडल, डेटा, पाइपलाइन। जब आप अपने सॉफ्टवेयर को नियंत्रित करते हैं, तो आप अपनी नियति को नियंत्रित करते हैं। रात 2 बजे समाप्त होने वाली api कुंजी नहीं। आपके पैरों तले बदलती सेवा शर्तें नहीं।

यह कोर है। बाकी सब एक लेगो ब्लॉक है जिसे आप जोड़ना चुनते हैं।

> *"they get the kingdom. they forge their own keys." (वे राज्य पाते हैं। वे अपनी चाबियाँ गढ़ते हैं।)*

## लेगो ब्लॉक

कोर आधार है। जो चाहिए वो जोड़ें:

| ब्लॉक | क्या करता है | स्थिति |
|-------|-------------|--------|
| **ssh mesh** | बहु-मशीन नेटवर्किंग | [गाइड →](docs/wiki/SSH-Mesh.md) |
| **वॉइस पाइपलाइन** | whisper + kokoro tts | [गाइड →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | चैट फ्रंटएंड | योजनाबद्ध |
| **comfyui** | इमेज/वीडियो जनरेशन | योजनाबद्ध |
| **गेम सर्वर** | आर्केड प्रबंधन | योजनाबद्ध |
| **glusterfs** | वितरित स्टोरेज | योजनाबद्ध |
| **डिस्कॉर्ड बॉट** | डिस्कॉर्ड में ai एजेंट | योजनाबद्ध |

[अपना खुद का ब्लॉक कैसे बनाएँ →](docs/wiki/Adding-a-Service.md)

## अनुशंसित: मुख्य एजेंट

कोर एजेंट के बिना भी चलता है। लेकिन ये पाँच आपकी अनुपस्थिति में आपके स्टैक की निगरानी करेंगे।

| एजेंट | कार्य |
|--------|------|
| **sentinel** | सुरक्षा — स्कैन, निगरानी, किसी पर भरोसा नहीं |
| **meek** | ऑडिटर — 17-जाँच दैनिक ऑडिट, आपूर्ति श्रृंखला |
| **shadow** | अखंडता — ssh कुंजी, फ़ाइल हैश, मेश स्वास्थ्य |
| **pulse** | मॉनिटर — gpu तापमान, रैम, डिस्क, सेवा स्वास्थ्य |
| **bounty** | बग — त्रुटियाँ पकड़ता है, स्वचालित फिक्स थ्रेड बनाता है |

ये अनुशंसा हैं, आवश्यकता नहीं। [मुख्य एजेंट गाइड →](docs/wiki/Core-Agents.md)

## सुरक्षा

केवल ssh कुंजी। कोई पासवर्ड नहीं। कोई खुले पोर्ट नहीं। कोई अपवाद नहीं। सभी सेवाएँ 127.0.0.1 पर। *"you shall not pass." (तुम नहीं गुज़रोगे।)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[पूर्ण सुरक्षा गाइड →](docs/SECURITY.md)

## गोपनीयता

**शून्य टेलीमेट्री। शून्य ट्रैकिंग। शून्य डेटा संग्रह।** कुछ भी बाहर कनेक्ट नहीं होता। आपका डेटा आपकी मशीन पर रहता है। *"there is no cloud. there is only zuul." (कोई क्लाउड नहीं है। केवल ज़ूल है।)*

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

*"i am inevitable." (मैं अनिवार्य हूँ।)* — *आर्किटेक्ट की मुहर*

MIT

</div>
