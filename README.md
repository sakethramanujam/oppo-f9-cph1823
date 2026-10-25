# Oppo F9 (CPH1823) unlock & GSI runbook

**No warranty. High brick risk. For a device you own.**

This project documents unlocking an Oppo F9 / F9 Pro (**CPH1823**, MediaTek MT6771), dumping partitions, installing OrangeFox, and booting an Android 13 Treble GSI.

**GrapheneOS is not available on this device.** An unlocked bootloader plus unsigned GSI weakens verified boot versus locked stock.

## Docs

Published site: https://sakethramanujam.github.io/oppo-f9-cph1823/

Design spec: `docs/superpowers/specs/2026-10-25-oppo-f9-cph1823-unlock-gsi-design.md`

## Quick host prep

See the site Host setup page, or:

```bash
./scripts/setup-host.sh
```

## Backups

Partition dumps belong in `backups/` (gitignored). Never commit firmware blobs.
