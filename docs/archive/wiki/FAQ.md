# FAQ

## Why Arch Linux?

Rolling release means latest drivers, latest ROCm, latest everything. No waiting 6 months for a package update. AMD hardware needs the latest kernel and driver support.

## Why not Docker/Podman?

Core services run bare metal for maximum GPU performance. No container overhead for inference. Podman is available as a lego block for isolating experimental services.

## Why llama.cpp over vLLM?

llama.cpp is stable, single-binary, and just works on gfx1151. vLLM is a production server designed for data centers serving hundreds of users. If you're running your own hardware for yourself and your agents, llama.cpp gives you the same speed with 10% of the complexity. vLLM is available as an optional lego block.

## Why Caddy over Nginx?

Caddy has automatic HTTPS, simpler config syntax, and the import pattern lets you drop in service configs without editing a monolithic file. It just works.

## Why SSH only?

Attack surface. Every open port is a door. SSH is one door with a very good lock (ed25519 keys). Everything else routes through it. If someone doesn't have your key, they don't get in. Period.

## Can I use this on non-Strix Halo hardware?

The script is built for gfx1151 (Strix Halo) but most of it works on any AMD GPU with Vulkan support. llama.cpp uses Vulkan (not ROCm) so any GPU with Vulkan drivers will work. vLLM and whisper.cpp still use ROCm — change `HSA_OVERRIDE_GFX_VERSION` in the ROCm env to match your GPU.

## Can I use this without a GPU?

Yes. llama.cpp will fall back to CPU if no Vulkan GPU is detected. Slower, but works.

## How do I update llama.cpp?

```bash
cd /srv/ai/llama-cpp
git pull
cmake -B build -DGGML_VULKAN=ON -DCMAKE_BUILD_TYPE=Release -G Ninja .
cmake --build build -j$(nproc)
sudo systemctl restart halo-llama-server
```

## How do I update Lemonade/Gaia?

```bash
~/lemonade-env/bin/pip install --upgrade lemonade-sdk
~/gaia-env/bin/pip install --upgrade -e ~/gaia
```

## Where are the logs?

```bash
journalctl -u llama-server -f    # llama.cpp
journalctl -u caddy -f           # Caddy
journalctl -u lemonade -f        # Lemonade
journalctl -u gaia -f            # Gaia
```
