# halo-ai networking — Caddy + Headscale

The halo-ai install ships **private-mesh-by-default**. Your closet-server is
reachable from *your* devices only. No port forwarding on your router. No
cloud SaaS. No bearer token rotation drama.

Two moving parts:

| Component  | Role                                              | Where it runs        |
|------------|---------------------------------------------------|----------------------|
| **Headscale** | Self-hosted control plane (Tailscale-compatible) | On the halo box (:8380, proxied) |
| **Caddy**    | Reverse proxy — HTTPS + bearer auth for the LLM | On the halo box (:443) |
| **Tailscale client** | Device-side — runs on every phone / laptop / game-PC that wants to talk to halo-ai | Each device |

Your halo box is both the coordination server *and* the first node in its own
mesh. Add devices as needed; nothing leaves your LAN unless you explicitly
expose a DERP relay.

---

## 1. Bringing up halo-ai on a new box

The install script does everything automatically:

```bash
./install-strixhalo.sh
```

At the end you get a box-drawing summary with:

- The **LAN IP** (e.g. `10.0.0.10`) — for LAN-only use before devices join the
  mesh
- The **tailnet IP** (e.g. `100.64.0.1`) and **tailnet hostname**
  (`strixhalo.tail-<your-net>.ts.net` equivalent) — for devices on the mesh
- A **QR code** linking to a mobile-friendly onboarding page
- A **24-hour reusable preauth key** so new devices can join without manual
  approval
- The **bearer token** for your OpenAI-compatible endpoint

## 2. Adding a device — laptop, desktop, game PC, other Linux box

**Arch / CachyOS / Manjaro / EndeavourOS:** run the one-liner the installer
prints at the end (same script you'll see in the summary panel):

```bash
curl -fsSL http://<halo-lan-ip>:8099/join.sh | sudo bash
```

**Ubuntu / Debian / Fedora / macOS:** install the Tailscale app
(`https://tailscale.com/download`), then:

```bash
sudo tailscale up \
  --login-server=https://headscale.<halo-hostname>.local \
  --authkey=<preauth-key-from-installer>
```

Note: clients on non-Arch distros need to trust halo's local CA once —
import `http://<halo-lan-ip>:8099/caddy-root.crt` into the system trust
store. The bootstrap script handles this automatically on Arch-family distros.

## 3. Adding a phone — iOS / Android

The install summary includes a QR code that opens a mobile onboarding page on
the halo box. That page walks the phone through three taps:

1. **Install Tailscale** from the App Store / Play Store (link provided)
2. **Tap to copy** the login server URL: `https://headscale.<halo-hostname>.local`
3. **Tap to copy** the preauth key

Paste those into Tailscale → *Account* → *Use alternate coordination server*.
You're on the mesh. Your inference endpoint is `https://<halo-hostname>/v1`
with bearer `sk-halo-...`.

## 4. Using halo-ai from your app

Any OpenAI-compatible client works. Point it at:

- **URL:**  `https://<halo-hostname>/v1`  (or `http://<tailnet-ip>:8080/v1`
  if you skip the reverse proxy and trust the mesh)
- **API key:**  `sk-halo-<token>`  (printed in the install summary, stored at
  `/etc/caddy/token.secret` on the halo box)
- **Model:**  `halo` or `bitnet-b1.58-2b-4t`

Tested clients: Chatbox · LM Studio · SillyTavern · Continue (VS Code) ·
Cursor · Open WebUI · Jan · Raycast AI · curl.

## 5. Adding more halo boxes (multi-node)

Every halo box you install registers itself as a new node in the same
mesh — just run the installer on the second box with the same headscale
preauth key. The `halo-nexus` service (when enabled) discovers peer nodes
over the mesh and load-balances requests across them.

## 6. Revoking a device

```bash
sudo headscale nodes expire --identifier <id>
# or permanently:
sudo headscale nodes delete --identifier <id>
```

List devices: `sudo headscale nodes list`.

## 7. Troubleshooting

**`x509: certificate signed by unknown authority`** — the client hasn't
trusted halo's local CA. On Arch: bootstrap script handles it. Manual:

```bash
sudo curl -fsSL http://<halo-lan-ip>:8099/caddy-root.crt \
  -o /etc/ca-certificates/trust-source/anchors/halo-local.crt
sudo trust extract-compat && sudo update-ca-trust
sudo systemctl restart tailscaled
```

**Preauth key expired** — keys are 24h reusable by default. Regenerate:

```bash
sudo headscale preauthkeys create -u 1 --reusable --expiration 24h
```

**Can't reach `:8099`** — UFW blocks inbound by default; the installer adds
an allow rule for your local `/24`. If you moved subnets, add it manually:

```bash
sudo ufw allow from <your-subnet>/24 to any port 8099 proto tcp
```

**MagicDNS warnings on Arch** — benign. systemd-resolved + NetworkManager
wiring quirk; ignore unless `.tail-<net>.ts.net` names actually fail to
resolve.

---

## Why this stack?

- **Headscale over Tailscale SaaS**: zero vendor lock-in, no outbound
  dependency, runs entirely on your halo box. Same clients work — the
  open-source Tailscale apps on every platform talk to our server
  transparently.
- **Caddy over nginx**: one-line config, auto-cert (internal CA or real LE
  if you add a domain later), SSE streaming works out of the box.
- **Bearer token over mTLS**: OpenAI-compatible clients all speak
  `Authorization: Bearer ...`; matches every app on earth already.

You own every byte of keying material. No one else sees your device list.
