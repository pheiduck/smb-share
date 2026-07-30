# CIFS Mount via systemd Service + Timer

This folder provides a `mount.cifs`-based alternative to the gvfs approach in the [root README](../README.md), using a systemd **service** unit to perform the mount and a systemd **timer** unit to trigger it (e.g. on a schedule, or periodically retry until the share is reachable).

## Prerequisites

Install the CIFS utilities package:

```
sudo apt-get update && sudo apt-get install -y cifs-utils
```

On Arch/Manjaro:

```
sudo pacman -Syu cifs-utils --needed
```

## Files

- `cifs-share.service` – runs `mount.cifs` against the configured server/share.
- `cifs-share.timer` – schedules the service (e.g. on boot plus a recurring interval), so the mount is retried automatically if the server wasn't reachable at boot time.

## Installation

Copy both unit files into the user (or system) systemd directory:

```
mkdir -p ~/.config/systemd/user
cp cifs-share.service cifs-share.timer ~/.config/systemd/user/
```

Edit `cifs-share.service` to set your server, share name, mount point, and credentials file path.

Reload systemd and enable the timer:

```
systemctl --user daemon-reload
systemctl --user enable --now cifs-share.timer
```

## Checking status

```
systemctl --user status cifs-share.timer
systemctl --user status cifs-share.service
systemctl --user list-timers
```

## Notes

- The timer approach avoids the classic fstab problem where a share that isn't reachable at boot causes the mount (and sometimes the boot itself) to hang or fail silently.
- Older shares using the deprecated SMB1/NT1 dialect may fail to mount; specify `vers=` explicitly in the service's mount options (e.g. `vers=2.0` or `vers=3.0`) to match what the server supports.
- Keep credentials in a separate file referenced via `credentials=/path/to/file` (with `chmod 600`) rather than inline in the unit file.
- For a user-mode alternative that doesn't require root or systemd units at all, see the gvfs-based script in the repository root.
