#!/usr/bin/env bash
# halo-ai-core install-strixhalo.sh — fast path for gfx1151 Strix Halo.
# "If it ain't broke, don't fix it. If it is broke, we've got a tarball for that." — architect
#
# What this script does:
#   1. Verifies GPU is gfx1151 (bail otherwise — see install-source.sh).
#   2. Installs ROCm userspace (rocm-hip-sdk via pacman).
#   3. Downloads pre-built binaries from GitHub Releases (or a local mirror).
#   4. Verifies SHA256SUMS (and GPG sig if present).
#   5. Installs to /usr/local/ and wires systemd.
#
# Time: ~5 minutes. For non-Strix-Halo users, use ./install-source.sh (~4 hours).
set -euo pipefail
# Pin PATH against a malicious inherit. All tools we use live here.
PATH=/usr/bin:/bin

# Allow running this script directly (not only from install.sh). When
# install.sh is the entry point it passes ROOT_DIR via environment; when
# invoked standalone we default to the script's own directory so
# "$ROOT_DIR/man-cave" etc. resolve correctly.
ROOT_DIR="${ROOT_DIR:-$(cd "$(dirname "$(readlink -f "$0")")" && pwd)}"
export ROOT_DIR

# ── Configuration ───────────────────────────────────────────
REPO="${REPO:-stampby/halo-ai-core}"
RELEASE_TAG="${RELEASE_TAG:-latest}"
SOURCE="${SOURCE:-https://github.com/${REPO}/releases/${RELEASE_TAG}/download}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"
MODELS_DIR="${MODELS_DIR:-$HOME/halo-ai/models}"
SKIP_GPG="${SKIP_GPG:-0}"
DRY_RUN=0

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${CYAN}[halo-ai]${NC} $1"; }
ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
die()  { err "$1"; exit 1; }

# ── Parse args ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --from-local) SOURCE="$2"; shift 2 ;;
        --tag)        RELEASE_TAG="$2"; SOURCE="https://github.com/${REPO}/releases/download/${RELEASE_TAG}"; shift 2 ;;
        --dry-run)    DRY_RUN=1; shift ;;
        --skip-gpg)   SKIP_GPG=1; shift ;;
        --help|-h)
            cat <<EOF
Usage: ./install-strixhalo.sh [options]

Options:
  --from-local <url>   pull artifacts from a LAN mirror instead of GitHub
                       (e.g. http://strixhalo.lan:8000/releases)
  --tag <version>      install a specific release tag (default: latest)
  --dry-run            show what would happen, no changes
  --skip-gpg           skip GPG signature check (SHA256 still enforced)
  --help               this screen
EOF
            exit 0 ;;
        *) die "unknown arg: $1" ;;
    esac
done

# ── Source protocol check (after --from-local may have overridden SOURCE) ──
# HTTP has no transport integrity; we still fall back to SHA256 (+ GPG when
# available) for those, but warn loudly so the user knows what they're doing.
case "$SOURCE" in
    https://*|file://*) ;;
    http://*)  warn "HTTP source — transport unauthenticated; GPG-sign your mirror" ;;
    *)         die "unsupported source scheme in SOURCE=$SOURCE" ;;
esac

# ── Banner ──────────────────────────────────────────────────
echo
echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  halo-ai-core — strix halo fast install                  ║${NC}"
echo -e "${BOLD}║  pre-built binaries · gfx1151 wave32 · ~5 min            ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
echo

# ── Step 1: Verify GPU ──────────────────────────────────────
log "step 1/7: verifying gfx1151 (Strix Halo)"
if command -v rocminfo &>/dev/null; then
    GPU_ARCH=$(rocminfo 2>/dev/null | grep -oP 'gfx\d+' | head -1 || true)
else
    if lspci 2>/dev/null | grep -q "Strix Halo\|Radeon 8060S"; then
        GPU_ARCH="gfx1151"
    else
        GPU_ARCH=""
    fi
fi
if [[ "$GPU_ARCH" != "gfx1151" ]]; then
    if [[ -n "$GPU_ARCH" ]]; then
        warn "detected $GPU_ARCH — this fast-install ships gfx1151 binaries only"
        warn "for your GPU, use ./install-source.sh (builds from source, ~4 hours)"
        exit 1
    else
        warn "could not detect GPU. if you're sure this is a Strix Halo, set GPU_ARCH=gfx1151 and re-run"
        exit 1
    fi
fi
ok "GPU: $GPU_ARCH"

# ── Step 2: ROCm userspace ──────────────────────────────────
log "step 2/7: ROCm userspace (pacman)"
if ! command -v hipconfig &>/dev/null || [[ ! -d /opt/rocm ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
        warn "dry-run: would install rocm-hip-sdk"
    else
        sudo pacman -S --noconfirm --needed rocm-hip-sdk rocm-opencl-sdk
    fi
    ok "rocm-hip-sdk installed"
else
    ok "ROCm already present ($(hipconfig --version 2>/dev/null || echo unknown))"
fi

# ── Step 3: Fetch release manifest ──────────────────────────
log "step 3/7: fetching release from $SOURCE"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

ASSETS=(
    bitnet_decode-rdna.tar.zst
    agent_cpp.tar.zst
    librocm_cpp-rdna.tar.zst
    halo-1bit-2b.tar.zst
    SHA256SUMS
)
OPTIONAL_ASSETS=(
    man-cave-rdna.tar.zst       # FTXUI TUI — not always shipped
)

for a in "${ASSETS[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
        log "dry-run: would fetch $SOURCE/$a"
        continue
    fi
    curl --fail-with-body -sLO "$SOURCE/$a" || die "fetch failed: $a"
done
for a in "${OPTIONAL_ASSETS[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
        log "dry-run: would try $SOURCE/$a (optional)"
        continue
    fi
    if curl -fsLO "$SOURCE/$a" 2>/dev/null; then
        ok "optional asset $a fetched"
    else
        rm -f "$a"
        log "optional asset $a not in release — skipping"
    fi
done

# GPG signature is optional (skipped if missing or --skip-gpg)
# Use -f so curl DOES NOT write a body on error (would otherwise leave a
# bogus SHA256SUMS.asc on disk that the verify block later chokes on).
if [[ $DRY_RUN -eq 0 && $SKIP_GPG -eq 0 ]]; then
    if curl -fsLO "$SOURCE/SHA256SUMS.asc" 2>/dev/null; then
        ok "GPG signature fetched"
    else
        rm -f SHA256SUMS.asc
        warn "no GPG signature at $SOURCE — skipping sig check"
    fi
fi
ok "assets downloaded"

# ── Step 4: Verify integrity ────────────────────────────────
if [[ $DRY_RUN -eq 0 ]]; then
    log "step 4/7: verifying SHA256SUMS"
    # No --ignore-missing: SHA256SUMS is authoritative, every listed file
    # must be on disk and match. A tampered SUMS that drops required rows
    # should not silently pass.
    sha256sum -c SHA256SUMS --quiet || die "checksum verification FAILED"
    ok "checksums match"

    if [[ -f SHA256SUMS.asc && $SKIP_GPG -eq 0 ]]; then
        if gpg --verify SHA256SUMS.asc SHA256SUMS 2>/dev/null; then
            ok "GPG signature verified"
        else
            warn "GPG signature invalid or architect's key not imported"
            warn "import via: curl https://github.com/stampby.gpg | gpg --import"
            # Refuse to proceed non-interactively — no prompt to answer.
            if [[ ! -t 0 ]]; then
                die "GPG signature invalid and stdin is not a tty — aborting"
            fi
            read -rp "continue anyway? (y/N): " cont
            [[ "$cont" =~ ^[Yy]$ ]] || die "aborted on unverified signature"
        fi
    fi
else
    warn "dry-run: skipping integrity check"
fi

# ── Step 5: Install ─────────────────────────────────────────
log "step 5/7: installing to $INSTALL_PREFIX and $MODELS_DIR"

# Canonicalize INSTALL_PREFIX — refuse paths outside the known-safe set
# (prevents path-traversal via INSTALL_PREFIX=../../etc tricks).
INSTALL_PREFIX_REAL="$(readlink -f "$INSTALL_PREFIX" 2>/dev/null || echo "$INSTALL_PREFIX")"
case "$INSTALL_PREFIX_REAL" in
    /usr/local|/usr/local/*|/opt|/opt/*|"$HOME"|"$HOME"/*) ;;
    *) die "INSTALL_PREFIX=$INSTALL_PREFIX_REAL is outside /usr/local, /opt, or \$HOME — refusing" ;;
esac

# Resolve the user the service should run as. If invoked via plain sudo,
# SUDO_USER is the real user. Fall back to $USER. Never allow root.
RUN_USER="${SUDO_USER:-$USER}"
if [[ "$RUN_USER" == "root" || -z "$RUN_USER" ]]; then
    die "refusing to install systemd unit as root — re-run this script without sudo login shell"
fi

if [[ $DRY_RUN -eq 0 ]]; then
    sudo mkdir -p "$INSTALL_PREFIX/bin" "$INSTALL_PREFIX/lib"
    mkdir -p "$MODELS_DIR"

    sudo tar --zstd -xf bitnet_decode-rdna.tar.zst -C "$INSTALL_PREFIX/"
    sudo tar --zstd -xf agent_cpp.tar.zst          -C "$INSTALL_PREFIX/"
    sudo tar --zstd -xf librocm_cpp-rdna.tar.zst   -C "$INSTALL_PREFIX/"
    [[ -f man-cave-rdna.tar.zst ]] && sudo tar --zstd -xf man-cave-rdna.tar.zst -C "$INSTALL_PREFIX/"
    tar --zstd -xf halo-1bit-2b.tar.zst            -C "$MODELS_DIR/" --strip-components=1

    # Arch/CachyOS does NOT include /usr/local/lib in ld.so.conf by default
    # (unlike Debian/Ubuntu). Without this, bitnet_decode fails with
    # "librocm_cpp.so: cannot open shared object file" even though the .so
    # is extracted. Register the path before running ldconfig.
    LIB_PATH="${INSTALL_PREFIX_REAL}/lib"
    CONF_FILE="/etc/ld.so.conf.d/halo-ai.conf"
    if [[ ! -f "$CONF_FILE" ]] || ! grep -qxF "$LIB_PATH" "$CONF_FILE" 2>/dev/null; then
        echo "$LIB_PATH" | sudo tee "$CONF_FILE" >/dev/null
        ok "registered $LIB_PATH with ld.so.conf.d"
    fi
    sudo ldconfig
else
    warn "dry-run: skipping install"
fi
ok "installed"

# ── Step 6: systemd units ───────────────────────────────────
log "step 6/7: systemd units"
if [[ $DRY_RUN -eq 0 ]]; then
    sudo tee /etc/systemd/system/halo-bitnet.service >/dev/null <<EOF
[Unit]
Description=halo-ai bitnet decode server
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_PREFIX/bin/bitnet_decode $MODELS_DIR/halo-1bit-2b.h1b --server 8080
Restart=on-failure
RestartSec=3
User=$RUN_USER

[Install]
WantedBy=multi-user.target
EOF
    sudo tee /etc/systemd/system/halo-agent.service >/dev/null <<EOF
[Unit]
Description=halo-ai agent runtime
After=halo-bitnet.service
Wants=halo-bitnet.service

[Service]
Type=simple
ExecStart=$INSTALL_PREFIX/bin/agent_cpp
Restart=on-failure
RestartSec=3
User=$RUN_USER

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable --now halo-bitnet.service
    sleep 2
    sudo systemctl enable --now halo-agent.service
    ok "systemd units enabled"
else
    warn "dry-run: skipping systemd"
fi

# ── Step 7: private mesh — Caddy + Headscale + Tailscale ────
# Sets up a private Tailscale-compatible mesh rooted on *this* box. No SaaS,
# no port forwarding, no cloud. Every device that wants to talk to halo-ai
# joins the mesh via a preauth key; the install prints a QR + one-liner.
# Docs: docs/NETWORKING.md
log "step 7/7: private mesh (Caddy + Headscale + Tailscale)"
if [[ $DRY_RUN -eq 0 ]]; then
    sudo pacman -S --needed --noconfirm \
        caddy headscale tailscale qrencode >/dev/null
    ok "network stack installed"

    # ── Identity + secrets ──────────────────────────────────
    HALO_HOSTNAME="$(cat /proc/sys/kernel/hostname)"
    LAN_IP="$(ip -4 -br addr show scope global 2>/dev/null \
              | awk 'NR==1{print $3}' | cut -d/ -f1)"
    LAN_SUBNET="$(echo "$LAN_IP" | cut -d. -f1-3).0/24"
    if [[ -f /etc/caddy/token.secret ]]; then
        BEARER_TOKEN="$(sudo cat /etc/caddy/token.secret)"
    else
        BEARER_TOKEN="sk-halo-$(head -c 32 /dev/urandom | base64 | tr -d '/+=' | head -c 40)"
        echo "$BEARER_TOKEN" | sudo tee /etc/caddy/token.secret >/dev/null
        sudo chown caddy:caddy /etc/caddy/token.secret
        sudo chmod 0600 /etc/caddy/token.secret
    fi

    # ── Caddy reverse proxy ─────────────────────────────────
    sudo tee /etc/caddy/Caddyfile >/dev/null <<CADDY_EOF
{
    admin off
}

# halo-ai inference — bearer-gated HTTPS, proxies bitnet_decode on :8080.
${HALO_HOSTNAME}.local, ${LAN_IP} {
    tls internal
    @authorized header_regexp Authorization ^Bearer\s+${BEARER_TOKEN}\$

    # man-cave — LAN-only launcher page (Lemonade + Gaia + user tiles).
    # No auth; exposure limited by Headscale hostname.
    handle_path /mancave/* {
        root * /srv/www/mancave
        file_server
    }

    handle @authorized {
        reverse_proxy 127.0.0.1:8080 {
            flush_interval -1
            transport http {
                read_timeout  10m
                write_timeout 10m
            }
        }
    }
    handle {
        respond "unauthorized — bearer token required" 401
    }
}

# Headscale coordination plane — clients connect here to join the mesh.
# No bearer gate (tailscale protocol has its own auth).
headscale.${HALO_HOSTNAME}.local {
    tls internal
    reverse_proxy 127.0.0.1:8380
}

# LAN-only bootstrap server — serves join.sh + CA cert + mobile page.
http://${LAN_IP}:8099 {
    root * /var/www/halo-bootstrap
    file_server browse
}
CADDY_EOF
    sudo mkdir -p /var/www/halo-bootstrap /var/log/caddy /srv/www/mancave
    sudo chown -R caddy:caddy /var/www/halo-bootstrap /var/log/caddy /srv/www/mancave

    # ── man-cave static page — copy from repo tree and lock down perms ──
    if [[ -d "$ROOT_DIR/man-cave" ]]; then
        sudo rsync -a --delete "$ROOT_DIR/man-cave/" /srv/www/mancave/
        sudo chown -R caddy:caddy /srv/www/mancave
        sudo chmod -R o+rX /srv/www/mancave
        log "man-cave served at https://${HALO_HOSTNAME}.local/mancave/"
    fi

    # ── Headscale config patch ──────────────────────────────
    sudo sed -i \
        -e "s|^server_url:.*|server_url: https://headscale.${HALO_HOSTNAME}.local|" \
        -e "s|^listen_addr: 127.0.0.1:8080|listen_addr: 127.0.0.1:8380|" \
        /etc/headscale/config.yaml

    # ── /etc/hosts + service enable ─────────────────────────
    grep -q "headscale.${HALO_HOSTNAME}.local" /etc/hosts || \
        echo "127.0.0.1 headscale.${HALO_HOSTNAME}.local ${HALO_HOSTNAME}.local" \
            | sudo tee -a /etc/hosts >/dev/null
    sudo systemctl enable --now caddy headscale tailscaled

    # ── Trust Caddy's local CA ──────────────────────────────
    CADDY_ROOT=/var/lib/caddy/pki/authorities/local/root.crt
    for _ in 1 2 3 4 5; do [[ -f $CADDY_ROOT ]] && break; sleep 1; done
    if [[ -f $CADDY_ROOT ]]; then
        sudo install -m 644 "$CADDY_ROOT" \
            /etc/ca-certificates/trust-source/anchors/halo-local.crt
        sudo trust extract-compat
        sudo update-ca-trust
        sudo systemctl restart tailscaled
        ok "local CA trusted system-wide"
    else
        warn "Caddy CA not yet generated — rerun 'sudo trust extract-compat' later"
    fi

    # ── Headscale user + 24h reusable preauth key ───────────
    sudo headscale users create "$RUN_USER" >/dev/null 2>&1 || true
    HS_UID=$(sudo headscale users list 2>&1 \
            | awk -v u="$RUN_USER" 'tolower($0) ~ u { for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+$/) { print $i; exit } }')
    HS_UID=${HS_UID:-1}
    PREAUTH_KEY=$(sudo headscale preauthkeys create -u "$HS_UID" --reusable --expiration 24h 2>&1 | tail -1)

    # ── Enrol this box as the first mesh node ───────────────
    sudo tailscale up --reset \
        --login-server="https://headscale.${HALO_HOSTNAME}.local" \
        --authkey="$PREAUTH_KEY" \
        --hostname="${HALO_HOSTNAME}-box" >/dev/null 2>&1 || true
    TAILNET_IP=$(tailscale ip -4 2>/dev/null | head -1)

    # ── Bootstrap artifacts for peer devices ────────────────
    HALO_PUBKEY_FILE="/home/${RUN_USER}/.ssh/id_ed25519.pub"
    HALO_PUBKEY=$([[ -f "$HALO_PUBKEY_FILE" ]] && cat "$HALO_PUBKEY_FILE" || echo '')
    sudo tee /var/www/halo-bootstrap/join.sh >/dev/null <<JOIN_EOF
#!/usr/bin/env bash
# Join the halo-ai mesh (Arch-family peers):
#   curl -fsSL http://${LAN_IP}:8099/join.sh | sudo bash
set -euo pipefail

AUTHKEY="${PREAUTH_KEY}"
HALO_PUBKEY="${HALO_PUBKEY}"

command -v tailscale >/dev/null 2>&1 || pacman -S --noconfirm tailscale
systemctl enable --now tailscaled
grep -q "headscale.${HALO_HOSTNAME}.local" /etc/hosts || \\
    echo "${LAN_IP} headscale.${HALO_HOSTNAME}.local" >> /etc/hosts
curl -fsSL http://${LAN_IP}:8099/halo-local.crt \\
    -o /etc/ca-certificates/trust-source/anchors/halo-local.crt
trust extract-compat
update-ca-trust
systemctl restart tailscaled
tailscale up --reset \\
    --login-server=https://headscale.${HALO_HOSTNAME}.local \\
    --authkey="\$AUTHKEY" \\
    --hostname="\$(hostname)"
if [[ -n "\$HALO_PUBKEY" ]]; then
    PEER_USER="\${SUDO_USER:-\$USER}"
    PEER_HOME=\$(getent passwd "\$PEER_USER" | cut -d: -f6)
    install -d -m 700 -o "\$PEER_USER" -g "\$PEER_USER" "\$PEER_HOME/.ssh"
    touch "\$PEER_HOME/.ssh/authorized_keys"
    chown "\$PEER_USER:\$PEER_USER" "\$PEER_HOME/.ssh/authorized_keys"
    chmod 600 "\$PEER_HOME/.ssh/authorized_keys"
    grep -qF "\$HALO_PUBKEY" "\$PEER_HOME/.ssh/authorized_keys" || \\
        echo "\$HALO_PUBKEY" >> "\$PEER_HOME/.ssh/authorized_keys"
fi
echo "joined — tailnet: \$(tailscale ip -4 | head -1)"
JOIN_EOF
    sudo chmod 755 /var/www/halo-bootstrap/join.sh
    [[ -f $CADDY_ROOT ]] && sudo install -m 644 "$CADDY_ROOT" \
        /var/www/halo-bootstrap/halo-local.crt

    # ── Mobile onboarding page (target of the QR) ───────────
    sudo tee /var/www/halo-bootstrap/m.html >/dev/null <<HTML_EOF
<!doctype html><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">
<title>halo-ai · join the mesh</title>
<style>body{font-family:system-ui;max-width:28rem;margin:2rem auto;padding:0 1rem;line-height:1.5}
code{background:#eee;padding:.1rem .3rem;border-radius:3px}
.k{word-break:break-all;display:block;padding:.6rem;background:#f4f4f4;border-radius:6px;margin:.5rem 0;user-select:all}
h1{font-size:1.3rem}</style>
<h1>🌐 halo-ai · join the mesh</h1>
<ol>
 <li>Install <a href="https://tailscale.com/download">Tailscale</a>.</li>
 <li>Settings → <em>Use alternate coordination server</em>:
   <code class=k>https://headscale.${HALO_HOSTNAME}.local</code></li>
 <li>Paste the auth key (reusable, 24h):
   <code class=k>${PREAUTH_KEY}</code></li>
 <li>Your LLM endpoint:
   <code class=k>https://${HALO_HOSTNAME}.local/v1</code>
   API key:
   <code class=k>${BEARER_TOKEN}</code></li>
</ol>
<p>Any OpenAI-compatible app works: Chatbox · LM Studio · SillyTavern · Continue · Jan.</p>
HTML_EOF
    sudo chown -R caddy:caddy /var/www/halo-bootstrap
    sudo systemctl restart caddy

    # ── Firewall open the mesh + reverse proxy to LAN ───────
    if systemctl is-active ufw >/dev/null 2>&1; then
        sudo ufw allow from "$LAN_SUBNET" to any port 8099 proto tcp >/dev/null
        sudo ufw allow from "$LAN_SUBNET" to any port 443   proto tcp >/dev/null
        sudo ufw allow from "$LAN_SUBNET" to any port 80    proto tcp >/dev/null
        sudo ufw reload >/dev/null 2>&1 || true
        ok "UFW allowed 80/443/8099 from $LAN_SUBNET"
    fi

    ok "mesh online"
else
    warn "dry-run: skipping network stack"
fi

# ── Final summary with QR + endpoints ───────────────────────
echo
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  done. the 1-bit monster is awake.                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo
if [[ $DRY_RUN -eq 0 ]] && [[ -n "${LAN_IP:-}" ]]; then
    echo -e "${BOLD}📱 scan to join from a phone${NC}"
    qrencode -t ansiutf8 -o - "http://${LAN_IP}:8099/m.html" 2>/dev/null || \
        echo "   (install 'qrencode' to render the QR; URL is http://${LAN_IP}:8099/m.html)"
    echo
    echo -e "${BOLD}🔗 endpoints${NC}"
    echo -e "   LAN:     ${CYAN}https://${HALO_HOSTNAME}.local/v1${NC}   (trust CA once)"
    [[ -n "${TAILNET_IP:-}" ]] && \
        echo -e "   Tailnet: ${CYAN}http://${TAILNET_IP}:8080/v1${NC}"
    echo
    echo -e "${BOLD}🔑 bearer token${NC} (OpenAI-compatible API key)"
    echo -e "   ${YELLOW}${BEARER_TOKEN}${NC}"
    echo
    echo -e "${BOLD}🌐 join a peer (Arch-family)${NC}"
    echo -e "   ${CYAN}curl -fsSL http://${LAN_IP}:8099/join.sh | sudo bash${NC}"
    echo -e "   phones / Windows / Mac: scan QR above → follow the page"
    echo
    echo -e "${BOLD}📖 docs${NC}   halo-ai-core/docs/NETWORKING.md"
    echo
fi
echo "  curl -H 'Authorization: Bearer \$TOKEN' http://localhost:8080/v1/models"
echo "  journalctl -fu halo-bitnet"
echo "  sudo headscale nodes list      # see peers"
echo "  man-cave                       # FTXUI dashboard"
