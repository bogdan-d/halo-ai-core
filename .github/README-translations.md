# README translations

This repo ships ten non-English READMEs alongside the canonical English `README.md`. They exist so visitors coming in from non-English channels (r/MidlifeCrisisAI mirrors, Discord announcements, demo-video captions) see *something* in their own language instead of bouncing off.

## Source of truth

**The English `README.md` is authoritative.** Every translation is machine-generated and should be treated as a courtesy gloss, not an official document. If the translation disagrees with the English, the English wins.

## Files

The ten translated READMEs below were all generated from `README.md` at commit:

```
f46bb797ae502040a671a84e7e560b48b0149b38
```

(run `git log -1 --format=%H -- README.md` to verify against current tip)

| file | language | locale code |
|------|----------|------|
| [README.ar.md](../README.ar.md) | Arabic | ar |
| [README.de.md](../README.de.md) | German | de |
| [README.es.md](../README.es.md) | Spanish | es |
| [README.fr.md](../README.fr.md) | French | fr |
| [README.hi.md](../README.hi.md) | Hindi | hi |
| [README.ja.md](../README.ja.md) | Japanese | ja |
| [README.ko.md](../README.ko.md) | Korean | ko |
| [README.pt.md](../README.pt.md) | Portuguese | pt |
| [README.ru.md](../README.ru.md) | Russian | ru |
| [README.zh.md](../README.zh.md) | Chinese (Simplified) | zh |

## Disclaimer policy

Every translated file carries a two-line disclaimer at the top, in the target language where possible, English otherwise. Example (English):

> **Note**: this translation is machine-generated. The English README is authoritative. PRs welcome.

The disclaimer is **non-negotiable** — if a translation ships without it, it should not ship. This is how we stay honest with non-English readers: they know up front they're reading a courtesy translation, not an authoritative one.

## Known drift (2026-04-19)

At the time of this initial ship, the ten translations were generated from an earlier snapshot of `README.md` and carry stale headline metrics:

- Decode speed reads `85 tok/s` (pre-RoPE-fix baseline); English currently reads `83 tok/s @ 64 tokens · 68.6 tok/s @ 1024 tokens`.
- None of the translations carry the `PPL 9.16 on wikitext-103` number introduced post-RoPE-fix.
- The "recent improvements (2026-04-19)" table is English-only.

This drift is exactly what the disclaimer exists for. It will be corrected at the next translation refresh.

## How to update

**Rule of thumb: rerun translation when the English `README.md` diff since the last refresh exceeds 20 lines.**

Concretely:

1. Note the SHA recorded in this doc (currently `f46bb797ae502040a671a84e7e560b48b0149b38`).
2. Check the diff since that SHA:
   ```bash
   git diff f46bb797ae502040a671a84e7e560b48b0149b38..HEAD -- README.md | wc -l
   ```
3. If the diff is > 20 lines, rerun the translation for all ten files. Do not translate incrementally — full regenerate keeps the files internally consistent.
4. Re-apply the disclaimer prepend (the two-line quote block) to each file after regeneration.
5. Update the SHA above in this file to the new source commit.
6. Commit as `docs: refresh translated READMEs from <new-sha>`.

## Do not hand-edit for correctness

Hand-editing a machine translation in a language you don't speak is worse than leaving the machine translation alone. The failure mode isn't "slightly wrong"; it's "grammatically plausible sentence that means the opposite of what you intended." If a native speaker wants to improve a translation, they open a PR and we trust their judgment. Otherwise: regenerate, don't patch.

## Gates we check before shipping

When adding or refreshing a translation, verify:

1. File exists and has meaningful content (> 20 lines).
2. Headline metric numbers are not mangled (garbled numbers, not just stale — stale is covered by disclaimer).
3. URLs are byte-identical to the English (GitHub links, discord invite, reddit).
4. Code blocks are byte-identical (shell commands must run).
5. No bearer tokens or secrets leaked (`sk-halo-*`, `GH_TOKEN=...`).
6. No AI-assistant self-references (Claude, Anthropic, ChatGPT — common MT tells).

If any gate fails, skip that file and note why in the commit message.
