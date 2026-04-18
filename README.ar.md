<div align="center" dir="rtl">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | **العربية**

# halo-ai core

### وحش الـ 1-بت — استدلال ذكاء اصطناعي محلي، bare metal، صفر بايثون أثناء التشغيل

**rocm c++ · أوزان ثلاثية (.h1b) · نوى HIP مدمجة · wave32 wmma · 17 متخصص c++ · صفر تتبع · صفر سحابة**

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

<div dir="rtl">

## ما هذا

halo-ai core هو **سكريبت التثبيت لوحش الـ 1-بت** — مجموعة ذكاء اصطناعي محلية كاملة، تعمل بالكامل بـ C++ على أجهزة AMD Strix Halo. صفر بايثون أثناء التشغيل. صفر سحابة. صفر تتبع. صفر اشتراكات.

سكريبت واحد، ثلاثة مستودعات هندسية:

| المستودع | ما هو |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | محرك الاستدلال. HIP نقي، نوى ثلاثية مدمجة، خادم متوافق مع OpenAI مع بث SSE. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | إطار عمل الوكلاء. 17 متخصصًا أحادي الغرض على ناقل الرسائل، سجل تدقيق بسلسلة hash، بوابة تحقق الموافقة. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | صيغة النموذج (.h1b) + خط أنابيب التدريب. تكميم ثلاثي absmean، QAT بمُقدِّر straight-through، تقطير من معلمي bf16. |

halo-ai core يستنسخها، يبنيها من المصدر، يربطها بـ systemd، ويوجه reverse proxy من caddy إلى النتيجة. أمر واحد، تحصل على LLM يعمل، حلقة صوتية، بوت discord، مشغل CI، ومسار تدقيق. كل شيء محلي.

</div>

*"I know kung fu."*

<div dir="rtl">

## التثبيت

مساران. السكريبت يكتشف GPU الخاص بك ويختار.

</div>

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # تلقائي: strixhalo → سريع; غير ذلك → من المصدر
```

<div dir="rtl">

| المسار | لمن | الوقت | ماذا يفعل |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 دقائق | تحميل بايناري مبنية مسبقًا من GH Releases، التحقق من SHA256 + GPG، ربط systemd |
| [`./install-source.sh`](install-source.sh) | أي GPU AMD آخر | ~4 ساعات | بناء TheRock + rocm-cpp + agent-cpp + halo-1bit من المصدر لمعماريتك |

**ليس Strix Halo؟** انظر [`release/KERNELS.md`](release/KERNELS.md).

## المجموعة

</div>

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 متخصص C++                      │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  نموذج ثلاثي (.h1b v2) · محلل halo-1bit (.htok)          │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

<div dir="rtl">

## أرقام مهمة

| المقياس | القيمة |
|---|---|
| سرعة فك التشفير | 85 tok/s (BitNet-b1.58-2B, Strix Halo) |
| حجم النموذج | 1.1 GiB (TQ1_0) |
| KLD مقابل F16 | 0.0023 بت/رمز |
| توافق Top-1 | 96.3% |
| بايناري الوكيل | 1.3 MB |
| بدء بارد | < 2 ث |
| تبعيات وقت التشغيل | 0 بايثون |

## فلسفة

بايثون حمل عصر LLM. C++ يملك التالي. بايثون عند التدريب لا بأس، بايثون في وقت التشغيل على جهازك الخاص هو عبء. **halo-ai core خال تمامًا من بايثون أثناء التشغيل.**

صناعة الذكاء الاصطناعي تريدك أن تستأجر كمبيوتر شخص آخر. نعتقد أنه يجب أن تمتلك كامل المجموعة — الأجهزة، النماذج، الأوزان، خط الأنابيب.

</div>

*"they get the kingdom. they forge their own keys."*

<div dir="rtl">

## الخصوصية

**صفر تتبع. صفر مراقبة. صفر جمع بيانات.** لا شيء يتصل بالمنزل.

</div>

*"there is no cloud. there is only zuul."*

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
