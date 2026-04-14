# USB Install — Full Stack on a Stick

*"I carry the fire." — The Road*

Build a bootable USB SSD with the entire halo-ai stack. Plug it into any AMD Strix Halo machine, boot, talk. Everything lives on the stick — nothing touches the host.

---

## What You Need

- **USB 3.2 SSD** — 256GB minimum (Samsung T7, SanDisk Extreme, etc.)
- **Arch Linux host** — any machine running Arch (to build the USB)
- **Internet connection** — downloads ~5GB of packages + models
- **10-20 minutes** — depending on internet speed

## What You Get

- Arch Linux with kernel 7.0 mainline
- Full halo-ai stack (Lemonade, llama.cpp Vulkan, Kokoro TTS, Whisper STT)
- Qwen3-Coder-30B model pre-loaded (if available on your machine)
- NPU support (XDNA2, accel module)
- Voice pipeline ready on boot
- Autologin, no desktop needed
- systemd services auto-start after first reboot

## Build the USB

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core

# See what would happen (no changes)
./build-usb.sh --dry-run

# Build it (replace /dev/sdX with your USB device)
./build-usb.sh /dev/sdX

# Non-interactive (skips confirmations)
./build-usb.sh /dev/sdX --yes-all

# Without the LLM model (saves ~18GB, download later)
./build-usb.sh /dev/sdX --no-model
```

The script will:
1. Partition the USB (512MB EFI + btrfs root)
2. Pacstrap a full Arch base system
3. Copy halo-ai-core repo to the USB
4. Copy your LLM model (if available)
5. Configure autologin + first-boot installer
6. Install GRUB bootloader

## Boot It

1. Plug the USB into any AMD Strix Halo machine
2. Boot from USB (F12/F2/DEL at BIOS to select boot device)
3. It auto-logs in as `bcloud`
4. **First boot:** install.sh runs automatically (needs internet)
5. **Reboot** after install completes
6. Open http://localhost:13305 — load a model, start talking

## Default Credentials

- **User:** bcloud
- **Password:** haloai
- **Change it:** `passwd`

## Safety

- The build script **only writes to USB devices** — it checks the transport type
- It asks you to type YES before erasing anything
- `--dry-run` shows exactly what would happen without touching the drive
- Nothing is written to the host machine

## FAQ

**Can I use a regular USB flash drive?**
Technically yes, but it will be painfully slow. USB 3.2 SSD is strongly recommended.

**Does it work on non-Strix Halo hardware?**
The base system boots on any x86_64 machine. ROCm/NPU features require AMD RDNA 3.5 + XDNA2 (Strix Halo).

**How do I update the stack?**
Boot the USB, `cd ~/halo-ai-core && git pull && ./install.sh --yes-all`

**Can I add more models later?**
Yes. Copy GGUF files to `~/models/` and load them through Lemonade.

---

*Designed and built by the architect.*
