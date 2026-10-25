# Oppo F9 (CPH1823): Unlock, GSI, and Documentation Site

**Date:** 2026-10-25  
**Status:** Approved design (pending implementation plan)  
**Device:** Oppo F9 / F9 Pro — model **CPH1823**, SoC **MediaTek Helio P60 (MT6771)**  
**GitHub:** `sakethramanujam/oppo-f9-cph1823` (GitHub Pages via Docusaurus)  
**Owner constraint:** Device is owned by the operator; wipe of all user data is acceptable.

## 1. Problem

The attached Oppo F9 (USB ID `22d9:2046`, CPH1823) has a forgotten screen lock. The desired end state is a more modern, privacy-oriented system than EOL ColorOS. GrapheneOS-class security is **not** available on this hardware.

## 2. Goals

1. Regain access by wiping the lock / userdata.
2. Unlock the bootloader using MediaTek BROM + auth bypass (test-point shorting allowed).
3. Install a custom recovery (OrangeFox primary).
4. Boot an Android 13 Treble GSI (ArrowOS first; Lineage/TrebleDroid fallback).
5. Optionally root with Magisk and apply a practical hardening checklist.
6. Publish a Docusaurus GitHub Pages runbook so the work is a reusable public project.

## 3. Non-goals

- GrapheneOS, CalyxOS, or any OS that requires Pixel-class verified-boot hardware.
- Preserving existing userdata.
- Guaranteeing fingerprint, VoLTE, camera feature parity, or Widevine L1.
- Hosting firmware blobs or partition dumps in git.
- Using cracked Miracle Box / UnlockTool binaries as the primary path.

## 4. Security reality (explicit)

Unlocked bootloader + unsigned GSI **weakens** the verified-boot trust chain relative to locked stock. The F9 (2018 MT6771) will not match Pixel + GrapheneOS. “Secure modern OS” here means: fewer ColorOS services, newer AOSP userland (~Android 13), optional Magisk hardening — not hardware-backed OS integrity at GrapheneOS level.

## 5. Architecture / phases

```text
Host prep → Wipe/access → BROM dump → Unlock → OrangeFox → A13 GSI → Magisk/harden
                ↑                                                      │
                └──────────── unbrick from dump / stock scatter ←───────┘
```

| Phase | Action | Success check |
| --- | --- | --- |
| 0 | Host: adb/fastboot, mtkclient, libusb, udev (`0e8d`, `22d9`) | `mtkclient` lists device in BROM/preloader |
| 1 | Wipe lock (stock recovery and/or mtkclient userdata/FRP clear) | Boots to ColorOS setup |
| 2 | Test-point BROM (document exact pads from CPH1823 community photos/schematics in the site); dump critical partitions + SHA256 | Dump directory complete |
| 3 | Unlock via mtkclient / CPH1823 LK path | `unlocked: yes` or seccfg unlocked |
| 4 | Flash OrangeFox (TWRP fallback) | Recovery boots |
| 5 | Flash matching arm64 Treble A13 GSI; disable vbmeta verify as required | Boots to Android setup; adb works |
| 6 | Optional Magisk; hardening checklist | Root/DenyList as configured |

**Stock baseline:** Prefer ColorOS **Android 10** before GSI work. If the device is stuck on Oreo after a bad flash, restore Android 10 stock first (many GSIs fail from Oreo on this device per community reports).

## 6. Host tooling

**Primary (Linux):**

- `android-tools` (adb, fastboot)
- Python 3 + [mtkclient](https://github.com/bkerler/mtkclient)
- `libusb`, udev rules for MediaTek / Oppo
- Scripts under `scripts/` wrapping dump, unlock, checksum

**Secondary:** SP Flash Tool + official/stock scatter **only** for unbrick when mtkclient cannot write a needed image. Prefer a Windows VM for that narrow case rather than installing opaque cracked tools on the host.

**Forbidden as default path:** Cracked Miracle Thunder, pirated UnlockTool, random “pattern unlock” packs from mirror sites.

## 7. Partition dump and rollback

**Before any unlock or flash**, dump at least:

`preloader`, `lk` / `lk2`, `boot`, `recovery`, `logo`, `nvram`, `nvdata`, `protect1`, `protect2`, `proinfo`, `seccfg`, `vbmeta` (if present), `dtbo` (if present).

Skip full `userdata` dump (wipe accepted).

Store under gitignored `backups/cph1823-<date>/` with `SHA256SUMS`. Keep a known-good CPH1823 ColorOS Android 10 stock package on disk (not in git).

**Rollback ladder:**

1. OrangeFox / fastboot: restore `boot` + `system` (or super) from dump / stock.
2. mtkclient: write partition images from dump.
3. SP Flash Tool + stock scatter + dump as last resort.
4. Never flash a foreign `preloader` except when restoring our own dump.

## 8. Recovery, GSI, Magisk

- **Recovery:** OrangeFox for CPH1823; TWRP fallback.
- **GSI:** Android 13 Treble; **ArrowOS** first; LineageOS / TrebleDroid A13 fallback. Variant (`arm64` + A-only / A/B) chosen from live `getvar` / mtkclient printout after unlock — not assumed.
- **vbmeta:** Disable verity/verification only after unlock, as required for unsigned GSI.
- **Magisk:** Optional after first good GSI boot; patch dumped/current `boot.img`. Zygisk + DenyList optional. Prefer no Play Services for privacy; microG only if consciously required.

**Known likely breaks:** fingerprint; some camera modes; Widevine L1 → L3.

## 9. Documentation site (Docusaurus + GitHub Pages)

| Item | Choice |
| --- | --- |
| GitHub repo | `sakethramanujam/oppo-f9-cph1823` |
| Docs framework | Docusaurus 3 (classic) |
| Layout | `website/` app; canonical docs in `website/docs/` |
| Pages URL | `https://sakethramanujam.github.io/oppo-f9-cph1823/` |
| `baseUrl` | `/oppo-f9-cph1823/` |
| Deploy | GitHub Actions → Pages (build on push to `main`) |
| Root README | Points to live site + short danger summary |

**Sidebar IA:**

1. Overview and goals  
2. Hardware and identifiers  
3. Host setup  
4. Phase 1 — Wipe / regain access  
5. Phase 2 — BROM, test points, dump  
6. Phase 3 — Unlock bootloader  
7. Phase 4 — OrangeFox  
8. Phase 5 — Android 13 GSI + Magisk  
9. Hardening checklist  
10. Unbrick / rollback  
11. References  
12. Changelog / verification status (what was proven on this unit)

Every page: **no warranty**, brick risk, educational use, operator-owned device.

**Not in git:** firmware ZIPs, partition dumps, proprietary DA blobs beyond what mtkclient already vendors legally.

## 10. Repository layout (target)

```text
README.md
LICENSE
.gitignore                 # backups/, *.bin, stock ROMs, secrets
docs/superpowers/specs/    # this design + later plans
scripts/                   # host setup, dump, checksum helpers
website/                   # Docusaurus app
  docs/                    # published runbook
  blog/                    # optional; skip unless needed
  static/                  # diagrams only (no firmware)
backups/                   # local only, gitignored
```

## 11. Risks

| Risk | Mitigation |
| --- | --- |
| Hard brick (bad preloader) | Dump first; avoid foreign preloaders |
| Soft brick / bootloop | Recovery + dump restore |
| BROM not detected | Cable, udev, test-point short timing |
| GSI boot failure | Alternate GSI; restore Android 10 stock then retry |
| FRP after wipe | Document FRP clear for owned device |
| Malware from shady tools | mtkclient-first policy |
| Overclaiming security | Site and README state GrapheneOS gap clearly |

## 12. Success criteria

- [ ] Phone boots past lock screen (wiped).  
- [ ] Bootloader unlocked; critical dump retained with checksums.  
- [ ] OrangeFox (or documented fallback) boots.  
- [ ] Android 13 GSI reaches setup; Wi‑Fi and adb smoke-tested.  
- [ ] Public repo `oppo-f9-cph1823` live with Docusaurus Pages runbook.  
- [ ] Changelog records what was verified on this CPH1823 unit.

## 13. PR / implementation plan (next)

After this spec is accepted, produce an implementation plan (writing-plans) covering: git remote + `.gitignore`, Docusaurus scaffold + Actions, host setup scripts, then phased device procedures with verification gates between unlock and GSI flash.

## 14. References (seed)

- XDA: OPPO F9 PRO (CPH1823) unlock bootloader, fastboot, root, install GSI (community test-point + GSI notes, 2024).  
- mtkclient (bkerler).  
- Oppo/MediaTek community notes for MT6771 unlock / dump workflows.  
- Stock CPH1823 ColorOS Android 10 firmware packages (obtain from reputable stock-ROM mirrors; verify hashes).
