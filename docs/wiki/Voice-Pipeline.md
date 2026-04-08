# Voice Pipeline

Full voice input/output: speak to your AI, hear it speak back. Everything runs locally.

## Components

```
Microphone → Whisper (STT) → LLM → Kokoro (TTS) → Speaker
```

| Component | What It Does | Backend |
|-----------|-------------|---------|
| Whisper.cpp | Speech-to-text | Lemonade `whispercpp` |
| llama.cpp | Language processing | Core service |
| Kokoro | Text-to-speech | Lemonade `kokoro` |

## Setup

### Whisper (Speech-to-Text)

Through Lemonade SDK:

```bash
source ~/lemonade-env/bin/activate
lemonade --tools whispercpp-load --model base.en
```

Or standalone:

```bash
cd ~/llama.cpp
./build/bin/whisper-cli -m models/ggml-base.en.bin -f audio.wav
```

### Kokoro (Text-to-Speech)

Through Lemonade SDK:

```bash
lemonade --tools kokoro-load --text "Hello from Halo AI Core"
```

## Audio Hardware

### Recording Chain

```
Shure SM7B → Focusrite Scarlett Solo → PipeWire → Whisper
```

- SM7B needs a preamp with lots of gain (Scarlett Solo works)
- PipeWire handles routing on Arch Linux
- Record on the Ryzen workstation (SM7B is connected there)
- Process on Strix Halo via SSH

### Gapless Audio Output

All audio output must be gapless — no clicks, pops, or gaps between chunks. This is non-negotiable for:

- TTS responses
- Music playback
- Audiobook generation

## Voice Cloning

Train a voice model from recordings:

1. Record 30+ minutes of clean audio (SM7B, quiet room)
2. Process through the spatial audio engine
3. Fine-tune a TTS model on the recordings
4. Deploy as a Kokoro-compatible voice

The model stays on your hardware. It never leaves.

## Field Recording

TASCAM DR-10L lavalier recorders capture ambient audio for:

- Foley sound libraries
- Voice training data
- Environmental recording

## SSH-Only Access

Whisper and Kokoro run on Strix Halo. Access them via SSH tunnel only:

```bash
# Run whisper on Strix Halo via SSH
cat audio.wav | ssh strix-halo "whisper-cli -m models/base.en.bin -f -"
```

No open ports. No web endpoints for audio.
