<!--
नोट: यह अनुवाद मशीन से उत्पन्न किया गया है। अंग्रेज़ी README आधिकारिक है। PRs का स्वागत है।
-->

> **नोट**: यह अनुवाद मशीन से उत्पन्न किया गया है। अंग्रेज़ी README आधिकारिक है। PRs का स्वागत है।

<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | **हिन्दी** | [العربية](README.ar.md)

# halo-ai core

### 1-बिट मॉन्स्टर — लोकल AI इनफेरेंस, बेयर मेटल, रनटाइम पर zero python

**rocm c++ · तृतीय वज़न (.h1b) · फ्यूज्ड HIP कर्नल · wave32 wmma · 17 c++ स्पेशलिस्ट · शून्य टेलीमेट्री · शून्य क्लाउड**

*stamped by the architect*

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![ROCm](https://img.shields.io/badge/ROCm_7.13-ED1C24?style=flat&logo=amd&logoColor=white)](https://github.com/ROCm/TheRock)
[![rocm-cpp](https://img.shields.io/badge/rocm--cpp-inference_engine-00d4ff?style=flat)](https://github.com/stampby/rocm-cpp)
[![agent-cpp](https://img.shields.io/badge/agent--cpp-17_specialists-00d4ff?style=flat)](https://github.com/stampby/agent-cpp)
[![halo-1bit](https://img.shields.io/badge/halo--1bit-.h1b_format-00d4ff?style=flat)](https://github.com/stampby/halo-1bit)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Reddit](https://img.shields.io/badge/Reddit-r/MidlifeCrisisAI-FF4500?style=flat&logo=reddit&logoColor=white)](https://www.reddit.com/r/MidlifeCrisisAI/)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

## यह क्या है

halo-ai core **1-बिट मॉन्स्टर का इंस्टॉल स्क्रिप्ट** है — AMD Strix Halo हार्डवेयर पर पूरी तरह C++ में चलने वाला पूरा लोकल AI स्टैक। रनटाइम पर कोई python नहीं। कोई क्लाउड नहीं। कोई टेलीमेट्री नहीं। कोई सब्सक्रिप्शन नहीं।

एक स्क्रिप्ट, तीन इंजीनियरिंग रिपॉज़िटरी:

| रिपो | क्या है |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | इनफेरेंस इंजन। शुद्ध HIP, फ्यूज्ड तृतीय कर्नल, SSE स्ट्रीमिंग के साथ OpenAI-संगत सर्वर। |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | एजेंट फ्रेमवर्क। मैसेज बस पर 17 एकल-उद्देश्य स्पेशलिस्ट, हैश-चेन ऑडिट लॉग, कॉन्सेंट-वेरिफिकेशन गेट। |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | मॉडल फॉर्मैट (.h1b) + ट्रेनिंग पाइपलाइन। absmean तृतीय क्वांटाइज़ेशन, straight-through एस्टिमेटर के साथ QAT, bf16 टीचर से डिस्टिलेशन। |

halo-ai core इन्हें क्लोन करता है, सोर्स से बिल्ड करता है, systemd से जोड़ता है, और एक caddy रिवर्स प्रॉक्सी को परिणाम पर पॉइंट करता है। एक कमांड से आपको मिलता है — चलता हुआ LLM, वॉइस लूप, discord बॉट, CI रनर, और ऑडिट ट्रेल। सब कुछ लोकल।

*"I know kung fu."*

## इंस्टॉलेशन

दो रास्ते। स्क्रिप्ट आपका GPU ऑटो-डिटेक्ट करती है और चुनती है।

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # ऑटो: strixhalo → तेज़; वरना → सोर्स
```

| रास्ता | किसके लिए | समय | क्या करता है |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 मिनट | GH Releases से प्री-बिल्ट बाइनरी डाउनलोड, SHA256 + GPG सत्यापन, systemd जोड़ना |
| [`./install-source.sh`](install-source.sh) | कोई भी अन्य AMD GPU | ~4 घंटे | आपकी arch के लिए TheRock + rocm-cpp + agent-cpp + halo-1bit सोर्स से बिल्ड |

**Strix Halo नहीं है?** [`release/KERNELS.md`](release/KERNELS.md) देखें।

## स्टैक

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 C++ स्पेशलिस्ट                  │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  तृतीय मॉडल (.h1b v2) · halo-1bit टोकनाइज़र (.htok)      │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

## महत्त्वपूर्ण संख्याएँ

| मेट्रिक | मान |
|---|---|
| डिकोड स्पीड | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| मॉडल आकार | 1.1 GiB (TQ1_0) |
| KLD vs F16 | 0.0023 बिट्स/टोकन |
| Top-1 सहमति | 96.3% |
| एजेंट बाइनरी | 1.3 MB |
| कोल्ड स्टार्ट | < 2 सेकंड |
| रनटाइम डिपेंडेंसी | 0 python |

## दर्शन

Python ने LLM युग उठाया। C++ अगले का मालिक है। ट्रेनिंग में python ठीक है; अपने हार्डवेयर के रनटाइम में python एक बोझ है। **halo-ai core में रनटाइम python zero है।**

AI उद्योग चाहता है कि आप किसी और का कंप्यूटर किराए पर लें। हमारा मानना है कि आपको पूरा स्टैक रखना चाहिए — हार्डवेयर, मॉडल, वज़न, पाइपलाइन।

*"they get the kingdom. they forge their own keys."*

## गोपनीयता

**शून्य टेलीमेट्री। शून्य ट्रैकिंग। शून्य डेटा संग्रह।** कुछ भी घर वापस कॉल नहीं करता।

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
