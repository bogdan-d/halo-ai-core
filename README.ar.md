<div align="center">

🌐 [English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | **العربية**

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### الأساس المعدني للذكاء الاصطناعي لمعالج amd strix halo

**5 خدمات أساسية · 128 جيجابايت ذاكرة موحدة · مُجمَّع من المصدر · بدون سحابة · قطع ليغو**

*ختم المعماري*

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

> **[الويكي](docs/wiki/Home.md)** — 24 صفحة توثيق · **[ديسكورد](https://discord.gg/dSyV646eBs)** — مجتمع + دعم · **[الدروس](https://www.youtube.com/@DirtyOldMan-1971)** — شروحات فيديو

---

## ما هذا

الطبقة الأساسية لتشغيل الذكاء الاصطناعي المحلي على عتادك الخاص. سكريبت واحد يُثبّت كل شيء. خمس خدمات أساسية. كلها systemd. كلها إعادة تشغيل تلقائي. ssh فقط. *"i know kung fu." (أنا أعرف الكونغ فو.)*

## التثبيت

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # شاهد ما سيحدث أولاً
./install.sh --yes-all    # ثبّت كل شيء
./install.sh --status     # تحقق مما يعمل
```

## ماذا تحصل

| | |
|---|---|
| **gpu** | rocm 7.2.1 — ذاكرة موحدة كاملة 128 جيجابايت على gfx1151 |
| **الاستدلال** | llama.cpp — مُجمَّع من المصدر، hip + vulkan |
| **الواجهة الخلفية** | lemonade sdk 9.x — llm، whisper، kokoro، stable diffusion |
| **الوكلاء** | gaia sdk 0.17.x — ابنِ وكلاء ai يعملون 100% محلياً |
| **البوابة** | caddy 2.x — وكيل عكسي، تكوين جاهز، توجيه تلقائي |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  قطعك    │
│  :8080   │  :13305  │  الوكلاء  │  الخاصة  │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## الفلسفة

كل قطعة تُركّب وتُفكّ. لا تبعيات صلبة. لا ارتباط بمورّد. لا قيود سحابية.

صناعة الذكاء الاصطناعي تريدك أن تستأجر حاسوب شخص آخر. نحن نعتقد أنه يجب أن تملك كامل المكدس — العتاد، النماذج، البيانات، خط الأنابيب. عندما تتحكم في برمجياتك، تتحكم في مصيرك. لا مفاتيح api تنتهي صلاحيتها الساعة الثانية صباحاً. لا شروط خدمة تتغير تحت قدميك.

هذا هو النواة. كل شيء آخر قطعة ليغو تختار أن تضيفها.

> *"they get the kingdom. they forge their own keys." (يحصلون على المملكة. يصنعون مفاتيحهم بأنفسهم.)*

## قطع ليغو

النواة هي الأساس. ركّب ما تحتاجه:

| القطعة | ماذا تفعل | الحالة |
|--------|----------|--------|
| **ssh mesh** | شبكات متعددة الأجهزة | [الدليل →](docs/wiki/SSH-Mesh.md) |
| **خط الصوت** | whisper + kokoro tts | [الدليل →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | واجهة دردشة | مخطط |
| **comfyui** | توليد صور/فيديو | مخطط |
| **خوادم ألعاب** | إدارة الأركيد | مخطط |
| **glusterfs** | تخزين موزع | مخطط |
| **بوتات ديسكورد** | وكلاء ai في ديسكورد | مخطط |

[كيف تبني قطعتك الخاصة →](docs/wiki/Adding-a-Service.md)

## موصى به: الوكلاء الأساسيون

النواة تعمل بدون وكلاء. لكن هؤلاء الخمسة سيراقبون مكدسك عندما لا تكون موجوداً.

| الوكيل | المهمة |
|--------|--------|
| **sentinel** | الأمان — يفحص، يراقب، لا يثق بشيء |
| **meek** | المدقق — تدقيق يومي من 17 فحصاً، سلسلة التوريد |
| **shadow** | السلامة — مفاتيح ssh، تجزئات الملفات، صحة الشبكة |
| **pulse** | المراقب — حرارة gpu، الذاكرة، القرص، صحة الخدمات |
| **bounty** | الأخطاء — يلتقط الأخطاء، ينشئ سلاسل إصلاح تلقائياً |

هذه توصية وليست متطلباً. [دليل الوكلاء الأساسيين →](docs/wiki/Core-Agents.md)

## الأمان

مفاتيح ssh فقط. لا كلمات مرور. لا منافذ مفتوحة. لا استثناءات. جميع الخدمات على 127.0.0.1. *"you shall not pass." (لن تمر.)*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[دليل الأمان الكامل →](docs/SECURITY.md)

## الخصوصية

**صفر قياس عن بُعد. صفر تتبع. صفر جمع بيانات.** لا شيء يتصل بالخارج. بياناتك تبقى على جهازك. *"there is no cloud. there is only zuul." (لا توجد سحابة. يوجد فقط زوول.)*

## التوثيق

| الدليل | ما يغطيه |
|--------|----------|
| [البدء](docs/wiki/Getting-Started.md) | التثبيت، التحقق، الخطوات الأولى |
| [المكونات](docs/wiki/Components.md) | rocm، caddy، llama.cpp، lemonade، gaia |
| [الهندسة المعمارية](docs/wiki/Architecture.md) | كيف تتصل القطع ببعضها |
| [إضافة خدمة](docs/wiki/Adding-a-Service.md) | ركّب قطعة ليغو خاصة بك |
| [إدارة النماذج](docs/wiki/Model-Management.md) | تحميل، تبديل، قياس أداء النماذج |
| [نظرة عامة على الوكلاء](docs/wiki/Agents-Overview.md) | 17 ممثل llm |
| [قياسات الأداء](docs/wiki/Benchmarks.md) | أرقام الأداء |
| [استكشاف الأخطاء](docs/wiki/Troubleshooting.md) | إصلاحات شائعة |
| [الويكي الكامل — 24 صفحة](docs/wiki/Home.md) | كل شيء |

## الخيارات

```
./install.sh --dry-run        معاينة بدون تثبيت
./install.sh --yes-all        تثبيت كل شيء
./install.sh --status         التحقق مما يعمل
./install.sh --skip-rocm      تخطي أي مكون
./install.sh --help           جميع الخيارات
```

## المتطلبات

- arch linux (معدن مكشوف)
- عتاد amd ryzen ai (strix halo / strix point)
- sudo بدون كلمة مرور

## الشكر والتقدير

هذا المشروع موجود بفضل الأشخاص الذين بنوا الأدوات التي نقف عليها.

شكر خاص لـ [Light-Heart-Labs](https://github.com/Light-Heart-Labs) و [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — المنارة التي أنارت الطريق. لولا ذلك المشروع، لما وُجد شيء من هذا.

مبني على [llama.cpp](https://github.com/ggml-org/llama.cpp)، [Lemonade SDK](https://github.com/lemonade-sdk/lemonade)، [AMD Gaia](https://github.com/amd/gaia)، [Caddy](https://caddyserver.com)، [ROCm](https://github.com/ROCm/TheRock)، [whisper.cpp](https://github.com/ggerganov/whisper.cpp)، [Kokoro](https://github.com/remsky/Kokoro-FastAPI)، [ComfyUI](https://github.com/comfyanonymous/ComfyUI)، [Open WebUI](https://github.com/open-webui/open-webui)، [SearXNG](https://github.com/searxng/searxng)، [Vane](https://github.com/ItzCrazyKns/Vane)، [pyenv](https://github.com/pyenv/pyenv).

---

<div align="center">

*"i am inevitable." (أنا حتمي.)* — *ختم المعماري*

MIT

</div>
