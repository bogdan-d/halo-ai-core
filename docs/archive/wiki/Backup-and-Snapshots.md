# Backup and Snapshots

btrfs snapshots are instant, free, and save your ass. Use them.

## Taking a Snapshot

```bash
# Before any major change
sudo btrfs subvolume snapshot -r / /.snapshots/before-change-$(date +%Y%m%d)
sudo btrfs subvolume snapshot -r /home /.snapshots/before-change-home-$(date +%Y%m%d)
```

The `-r` flag makes it read-only. This prevents accidental modification.

## Listing Snapshots

```bash
sudo btrfs subvolume list / | grep snapshot
```

## Rolling Back

If something breaks after an update or install:

### From a Running System (partial rollback)

```bash
# Mount the btrfs root
sudo mount /dev/nvme0n1p2 /mnt -o subvol=/

# Replace broken subvolume
sudo mv /mnt/@ /mnt/@.broken
sudo btrfs subvolume snapshot /mnt/.snapshots/known-good /@

sudo reboot
```

### From Live USB (full rollback)

```bash
mount /dev/nvme0n1p2 /mnt -o subvol=/
mv /mnt/@ /mnt/@.broken
btrfs subvolume snapshot /mnt/.snapshots/known-good /mnt/@
reboot
```

## Recommended Snapshot Points

Take snapshots at these moments:

| When | Name Pattern |
|------|-------------|
| Fresh install | `fresh-install-YYYYMMDD` |
| After core install | `core-complete-YYYYMMDD` |
| Before adding a service | `before-SERVICE-YYYYMMDD` |
| After successful test | `SERVICE-tested-YYYYMMDD` |
| Before system updates | `before-update-YYYYMMDD` |

## Deleting Old Snapshots

```bash
sudo btrfs subvolume delete /.snapshots/old-snapshot-name
```

## Cross-Machine Backup

Use SSHFS or rsync to backup between machines:

```bash
# Sync models to Pi storage
rsync -avz ~/models/ pi:/mnt/backup/models/

# Sync configs
rsync -avz /etc/caddy/ pi:/mnt/backup/configs/caddy/
```

## The Rule

Snapshot before every change. Storage is cheap. Your time is not.
