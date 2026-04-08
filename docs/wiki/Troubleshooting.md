# Troubleshooting

## ROCm Not Detecting GPU

```bash
# Check if user is in video/render groups
groups
# Should show: video render

# If not:
sudo usermod -aG video,render $USER
# Log out and back in

# Check ROCm
/opt/rocm/bin/rocminfo | grep "Marketing Name"
```

## Pacman Lock File

```
error: failed to synchronize all databases (unable to lock database)
```

```bash
sudo rm -f /var/lib/pacman/db.lck
```

## Python Version Mismatch

Arch ships Python 3.14. Lemonade and Gaia need 3.13. The install script handles this with pyenv, but if you need to fix manually:

```bash
~/.pyenv/versions/3.13.4/bin/python3 -m venv ~/my-env
```

## llama.cpp Build Fails — HIP Not Found

```bash
export PATH=$PATH:/opt/rocm/bin
export HIP_PATH=/opt/rocm
export ROCM_PATH=/opt/rocm
```

Then rebuild with `-DCMAKE_HIP_COMPILER=/opt/rocm/bin/amdclang++`

## Caddy Config Error

```bash
# Test config without restarting
caddy validate --config /etc/caddy/Caddyfile

# Check logs
journalctl -u caddy -f
```

## Service Won't Start

```bash
# Check the logs
journalctl -u servicename -f

# Check the unit file
systemctl cat servicename
```

## btrfs Snapshot Rollback

```bash
# List snapshots
sudo btrfs subvolume list / | grep snapshot

# To rollback (from live USB):
sudo mount /dev/nvme0n1p2 /mnt -o subvol=/
sudo mv /mnt/@ /mnt/@.broken
sudo btrfs subvolume snapshot /mnt/@.snapshots/snapshot-name /mnt/@
sudo reboot
```

## Windows SSH — Permission Denied

Admin users on Windows need keys in a different file:
```
C:\ProgramData\ssh\administrators_authorized_keys
```

NOT `~/.ssh/authorized_keys`. See [Security](Security) for details.
