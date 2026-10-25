# Oppo F9 CPH1823 Unlock, GSI, and Docs Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a Docusaurus GitHub Pages runbook at `sakethramanujam/oppo-f9-cph1823` and execute the mtkclient-first unlock → OrangeFox → Android 13 GSI path on the attached CPH1823.

**Architecture:** Repo root holds scripts, design/plans, and gitignore for dumps. `website/` is a Docusaurus 3 app deployed by GitHub Actions to project Pages. Device work follows dump-before-write; operator performs test-point shorts; agents drive host tooling and doc updates.

**Tech Stack:** Docusaurus 3, GitHub Actions Pages, Python 3 + mtkclient, android-tools (adb/fastboot), bash scripts, Linux udev.

**Spec:** `docs/superpowers/specs/2026-10-25-oppo-f9-cph1823-unlock-gsi-design.md`

## Global Constraints

- Device: CPH1823 / MT6771; USB seen as Oppo `22d9:2046`; wipe OK; test-point shorting OK.
- Tooling: mtkclient-first; no cracked Miracle/UnlockTool as primary path; no firmware/dumps in git.
- Security copy: every public page must state GrapheneOS is unavailable and unlocked GSI weakens verified boot.
- GitHub: repo name `oppo-f9-cph1823`, account `sakethramanujam`, `baseUrl` `/oppo-f9-cph1823/`.
- GSI order: ArrowOS A13 first; Lineage/TrebleDroid A13 fallback; variant from live device props.
- Recovery: OrangeFox primary; TWRP fallback.
- Never flash a foreign preloader except restore from our dump.

---

## File map

| Path | Responsibility |
| --- | --- |
| `README.md` | Danger summary + link to Pages site |
| `LICENSE` | MIT (code/docs); warranty disclaimer in README/site |
| `.gitignore` | `backups/`, images, stock ROMs, env |
| `scripts/setup-host.sh` | Install adb/fastboot deps hints + udev + venv mtkclient |
| `scripts/udev/99-mtk-oppo.rules` | MediaTek + Oppo USB access |
| `scripts/dump-partitions.sh` | Wrapper: mtkclient dump list + SHA256SUMS into `backups/` |
| `scripts/verify-checksums.sh` | Verify SHA256SUMS in a backup dir |
| `scripts/tests/test_verify_checksums.sh` | Shell test for checksum helper |
| `website/` | Docusaurus 3 app |
| `website/docs/*.md` | Runbook IA from spec §9 |
| `.github/workflows/deploy-docs.yml` | Build + deploy Pages |
| `backups/` | Local only (gitignored) |

---

### Task 1: GitHub repo remote and root project files

**Files:**
- Create: `README.md`
- Create: `LICENSE`
- Modify: `.gitignore`
- Create: `.github/workflows/deploy-docs.yml` (placeholder job OK until Task 2; prefer create in Task 2 with real build)

**Interfaces:**
- Consumes: none
- Produces: remote `git@github.com:sakethramanujam/oppo-f9-cph1823.git`; root README pointing at future Pages URL

- [ ] **Step 1: Create the empty GitHub repo**

```bash
gh repo create sakethramanujam/oppo-f9-cph1823 --public --description "Oppo F9 CPH1823 unlock, dump, OrangeFox, Android 13 GSI runbook" --source=. --remote=origin
```

If `--source=.` fails because remote exists, use:

```bash
gh repo create sakethramanujam/oppo-f9-cph1823 --public --description "Oppo F9 CPH1823 unlock, dump, OrangeFox, Android 13 GSI runbook"
git remote add origin git@github.com:sakethramanujam/oppo-f9-cph1823.git
```

- [ ] **Step 2: Write `LICENSE` (MIT)**

Use standard MIT text with copyright holder `sakethramanujam` and year `2026`.

- [ ] **Step 3: Write `README.md`**

```markdown
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
```

- [ ] **Step 4: Expand `.gitignore`**

Ensure these entries exist (merge with any existing):

```gitignore
backups/
stock-firmware/
*.bin
*.img
*.zip
*.apk
.env
website/node_modules/
website/build/
website/.docusaurus/
website/.cache/
```

- [ ] **Step 5: Commit and push**

```bash
git add README.md LICENSE .gitignore
git commit -m "chore: add README, LICENSE, and gitignore for CPH1823 project"
git push -u origin main
```

Expected: repo visible at `https://github.com/sakethramanujam/oppo-f9-cph1823`

---

### Task 2: Docusaurus site scaffold and Pages deploy

**Files:**
- Create: `website/` (Docusaurus 3 classic)
- Create: `website/docusaurus.config.js` (or `.ts`) with `baseUrl: '/oppo-f9-cph1823/'`
- Create: `website/docs/intro.md` (overview)
- Create: `.github/workflows/deploy-docs.yml`

**Interfaces:**
- Consumes: repo name and `baseUrl` from Global Constraints
- Produces: working `npm run build` in `website/`; Actions workflow deploying to GitHub Pages

- [ ] **Step 1: Scaffold Docusaurus in `website/`**

```bash
npx create-docusaurus@latest website classic --typescript
```

If the tool prompts, choose: no blog optional (keep blog folder empty or delete later), npm.

- [ ] **Step 2: Set site config**

In `website/docusaurus.config.ts` (or `.js`), set:

```ts
const config = {
  title: 'Oppo F9 CPH1823',
  tagline: 'Unlock, dump, OrangeFox, Android 13 GSI',
  favicon: 'img/favicon.ico',
  url: 'https://sakethramanujam.github.io',
  baseUrl: '/oppo-f9-cph1823/',
  organizationName: 'sakethramanujam',
  projectName: 'oppo-f9-cph1823',
  onBrokenLinks: 'throw',
  i18n: { defaultLocale: 'en', locales: ['en'] },
  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/sakethramanujam/oppo-f9-cph1823/tree/main/website/',
        },
        blog: false,
        theme: { customCss: './src/css/custom.css' },
      },
    ],
  ],
  themeConfig: {
    navbar: {
      title: 'CPH1823',
      items: [
        { type: 'docSidebar', sidebarId: 'tutorialSidebar', position: 'left', label: 'Runbook' },
        { href: 'https://github.com/sakethramanujam/oppo-f9-cph1823', label: 'GitHub', position: 'right' },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `No warranty. Brick risk. Built with Docusaurus.`,
    },
  },
};
export default config;
```

Adjust export style to match what `create-docusaurus` generated (keep their import pattern; only change the fields above).

- [ ] **Step 3: Replace `website/docs/intro.md` with overview + warranty**

Content must include: CPH1823 / MT6771; wipe OK; GrapheneOS unavailable; unlocked GSI weakens AVB; link to phases. Title frontmatter `slug: /`.

- [ ] **Step 4: Local build smoke test**

```bash
cd website && npm install && npm run build
```

Expected: exit 0; `website/build/index.html` exists.

- [ ] **Step 5: Add GitHub Actions workflow**

Create `.github/workflows/deploy-docs.yml`:

```yaml
name: Deploy docs
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: true
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: website/package-lock.json
      - run: npm ci
        working-directory: website
      - run: npm run build
        working-directory: website
      - uses: actions/upload-pages-artifact@v3
        with:
          path: website/build
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 6: Enable Pages (GitHub Actions source) and push**

```bash
gh api -X PUT repos/sakethramanujam/oppo-f9-cph1823/pages -f build_type=workflow || true
git add website .github/workflows/deploy-docs.yml
git commit -m "feat: scaffold Docusaurus site and Pages deploy workflow"
git push origin main
gh run watch --exit-status
```

Expected: workflow green; site loads at `https://sakethramanujam.github.io/oppo-f9-cph1823/` (may take a minute).

---

### Task 3: Runbook doc pages and sidebar

**Files:**
- Create: `website/docs/hardware.md`
- Create: `website/docs/host-setup.md`
- Create: `website/docs/phase-1-wipe.md`
- Create: `website/docs/phase-2-brom-dump.md`
- Create: `website/docs/phase-3-unlock.md`
- Create: `website/docs/phase-4-orangefox.md`
- Create: `website/docs/phase-5-gsi.md`
- Create: `website/docs/hardening.md`
- Create: `website/docs/unbrick.md`
- Create: `website/docs/references.md`
- Create: `website/docs/changelog.md`
- Modify: `website/sidebars.ts`

**Interfaces:**
- Consumes: phase order and IA from spec §5 and §9
- Produces: complete sidebar; each page has warranty callout; changelog starts with “not yet verified on hardware”

- [ ] **Step 1: Write `sidebars.ts`**

```ts
import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    'intro',
    'hardware',
    'host-setup',
    'phase-1-wipe',
    'phase-2-brom-dump',
    'phase-3-unlock',
    'phase-4-orangefox',
    'phase-5-gsi',
    'hardening',
    'unbrick',
    'references',
    'changelog',
  ],
};

export default sidebars;
```

- [ ] **Step 2: Author each doc page**

Every page starts with:

```md
:::danger
No warranty. Brick risk. Only use on a device you own. Unlocked bootloader + GSI is not GrapheneOS-level security.
:::
```

Fill concrete content:

- `hardware.md` — CPH1823, MT6771, USB `22d9:2046` / MediaTek `0e8d`, note test-point pads will be filled with photo refs during Task 6.
- `host-setup.md` — documents `./scripts/setup-host.sh`, udev, mtkclient venv.
- `phase-1-wipe.md` — stock recovery Vol Down+Power wipe; mtkclient userdata/FRP clear fallback.
- `phase-2-brom-dump.md` — power off, short pads, `scripts/dump-partitions.sh`, list of partitions from spec §7.
- `phase-3-unlock.md` — mtkclient unlock / seccfg; verify unlocked; link XDA for LK notes.
- `phase-4-orangefox.md` — flash recovery image; TWRP fallback sentence.
- `phase-5-gsi.md` — detect A-only vs A/B; ArrowOS A13 first; vbmeta flags; Magisk optional.
- `hardening.md` — no Play if possible; Magisk DenyList; clear GrapheneOS gap again.
- `unbrick.md` — rollback ladder from spec §7.
- `references.md` — XDA CPH1823 GSI thread, mtkclient, stock firmware hash policy.
- `changelog.md` — table: date / phase / result / notes; initial row “docs scaffold only”.

- [ ] **Step 3: Build and commit**

```bash
cd website && npm run build
cd .. && git add website/docs website/sidebars.ts
git commit -m "docs: add full CPH1823 runbook pages and sidebar"
git push origin main
```

Expected: `npm run build` exit 0; Pages updates.

---

### Task 4: Host setup script, udev rules, checksum tools

**Files:**
- Create: `scripts/udev/99-mtk-oppo.rules`
- Create: `scripts/setup-host.sh`
- Create: `scripts/verify-checksums.sh`
- Create: `scripts/dump-partitions.sh`
- Create: `scripts/tests/test_verify_checksums.sh`

**Interfaces:**
- Consumes: partition list from spec §7
- Produces:
  - `setup-host.sh` exit 0 on this machine (or clear message if apt needs sudo)
  - `verify-checksums.sh <backup-dir>` exits 0 iff SHA256SUMS matches
  - `dump-partitions.sh <backup-dir>` invokes mtkclient for the partition list

- [ ] **Step 1: Write failing checksum test**

Create `scripts/tests/test_verify_checksums.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo hello >"$TMP/a.bin"
(cd "$TMP" && sha256sum a.bin >SHA256SUMS)
"$ROOT/scripts/verify-checksums.sh" "$TMP"
echo bye >"$TMP/a.bin"
if "$ROOT/scripts/verify-checksums.sh" "$TMP"; then
  echo "expected checksum failure" >&2
  exit 1
fi
echo "test_verify_checksums OK"
```

- [ ] **Step 2: Run test — expect fail (script missing)**

```bash
chmod +x scripts/tests/test_verify_checksums.sh
bash scripts/tests/test_verify_checksums.sh
```

Expected: fail with “No such file” for `verify-checksums.sh`.

- [ ] **Step 3: Implement `scripts/verify-checksums.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
DIR="${1:?usage: verify-checksums.sh <backup-dir>}"
cd "$DIR"
sha256sum -c SHA256SUMS
```

- [ ] **Step 4: Re-run test — expect pass**

```bash
chmod +x scripts/verify-checksums.sh
bash scripts/tests/test_verify_checksums.sh
```

Expected: `test_verify_checksums OK`

- [ ] **Step 5: Add udev rules and `setup-host.sh`**

`scripts/udev/99-mtk-oppo.rules`:

```
# MediaTek
SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", MODE="0666", GROUP="plugdev"
# Oppo
SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="plugdev"
```

`scripts/setup-host.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Installing android-tools / libusb if missing (needs sudo)..."
sudo apt-get update
sudo apt-get install -y android-tools-adb android-tools-fastboot libusb-1.0-0 python3-venv python3-pip
sudo cp "$ROOT/scripts/udev/99-mtk-oppo.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
VENV="$ROOT/.venv"
python3 -m venv "$VENV"
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -U pip
pip install mtkclient
echo "Host setup done. Activate with: source $VENV/bin/activate"
adb version
```

- [ ] **Step 6: Implement `scripts/dump-partitions.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:?usage: dump-partitions.sh <backup-dir>}"
mkdir -p "$OUT"
# shellcheck disable=SC1091
source "$ROOT/.venv/bin/activate"
PARTS=(preloader lk lk2 boot recovery logo nvram nvdata protect1 protect2 proinfo seccfg vbmeta dtbo)
cd "$OUT"
for p in "${PARTS[@]}"; do
  echo "Dumping $p (skip if missing on device)..."
  mtk r "$p" "${p}.bin" || echo "WARN: skip $p" >&2
done
sha256sum ./*.bin >SHA256SUMS 2>/dev/null || true
echo "Dump complete under $OUT"
```

Note: operator must have phone in BROM (test points) before running. Script documents that in stderr banner — add at top:

```bash
echo "Power off phone, short BROM test points, then connect USB." >&2
```

- [ ] **Step 7: Run setup on this host**

```bash
chmod +x scripts/*.sh scripts/tests/*.sh
./scripts/setup-host.sh
source .venv/bin/activate
mtk --help | head
```

Expected: venv works; `mtk` / `mtkclient` CLI available. If `apt-get` cannot run non-interactively, stop and ask the operator for sudo.

- [ ] **Step 8: Commit**

```bash
git add scripts
echo '.venv/' >> .gitignore
git add .gitignore
git commit -m "feat: add host setup, udev, dump and checksum scripts"
git push origin main
```

---

### Task 5: Phase 1 — regain access (wipe)

**Files:**
- Modify: `website/docs/changelog.md` (record result)
- Modify: `website/docs/phase-1-wipe.md` if commands differ from reality

**Interfaces:**
- Consumes: working adb/udev from Task 4
- Produces: device boots to ColorOS setup (lock cleared)

- [ ] **Step 1: Try stock recovery wipe**

Operator:

1. Power off.
2. Hold **Volume Down + Power** until recovery.
3. Wipe data / factory reset.
4. Reboot.

- [ ] **Step 2: If recovery wipe fails, mtkclient userdata/FRP clear**

With phone powered off, BROM via test points if needed:

```bash
source .venv/bin/activate
# Example — confirm exact mtkclient subcommands against `mtk --help` on installed version:
mtk e userdata
mtk e frp
```

If those partition names differ, use `mtk printgpt` / `mtk partitions` and erase the FRP + userdata entries only.

- [ ] **Step 3: Verify**

Phone reaches first-time ColorOS setup. USB may show as `22d9:*` again.

- [ ] **Step 4: Update changelog and commit**

Add a changelog row with date, “Phase 1 wipe”, success/fail, method used. Push.

**Stop if wipe failed** — do not proceed to unlock.

---

### Task 6: Phase 2 — BROM dump with test points

**Files:**
- Create: `backups/cph1823-<YYYYMMDD>/` (local only)
- Modify: `website/docs/phase-2-brom-dump.md` (exact pad description + photo credits/links)
- Modify: `website/docs/changelog.md`

**Interfaces:**
- Consumes: `scripts/dump-partitions.sh`
- Produces: backup dir with `.bin` files + `SHA256SUMS` that `verify-checksums.sh` accepts

- [ ] **Step 1: Identify test points**

From XDA CPH1823 thread / board photos: document which pads to short (near SoC). Update `phase-2-brom-dump.md` with description and outbound photo links (do not commit large photos unless small diagrams in `website/static/img/`).

- [ ] **Step 2: Run dump**

```bash
source .venv/bin/activate
OUT="backups/cph1823-$(date +%Y%m%d)"
./scripts/dump-partitions.sh "$OUT"
./scripts/verify-checksums.sh "$OUT"
ls -lh "$OUT"
```

Expected: at least `preloader`, `lk` or `lk2`, `boot`, `recovery`, `seccfg` present; checksums OK. Missing optional partitions (`dtbo`, `vbmeta`) are WARN-only.

- [ ] **Step 3: Changelog + commit docs only**

Commit doc updates (not `backups/`). Push.

**Stop if dump incomplete for preloader/boot/lk/seccfg.**

---

### Task 7: Phase 3 — unlock bootloader

**Files:**
- Modify: `website/docs/phase-3-unlock.md`, `website/docs/changelog.md`

**Interfaces:**
- Consumes: valid dump from Task 6
- Produces: unlocked bootloader evidence (`fastboot getvar unlocked` or mtkclient seccfg state)

- [ ] **Step 1: Unlock via mtkclient**

```bash
source .venv/bin/activate
# Confirm against installed CLI help; typical:
mtk da seccfg unlock
```

If the installed mtkclient version uses a different verb, follow its unlock docs and record the exact command in `phase-3-unlock.md`.

- [ ] **Step 2: Boot to fastboot and verify**

```bash
adb reboot bootloader || true
fastboot getvar unlocked
fastboot getvar product
```

Expected: `unlocked: yes` (wording may vary). If fastboot unavailable until LK flash, follow XDA CPH1823 LK/`ik.bin` path **only after** comparing hashes to community files and documenting source in references — prefer mtkclient-native unlock first.

- [ ] **Step 3: Re-dump `seccfg` (and `lk` if changed) into same or new backup folder; verify checksums**

- [ ] **Step 4: Changelog + commit docs; push**

**Stop if still locked.**

---

### Task 8: Phase 4 — OrangeFox recovery

**Files:**
- Modify: `website/docs/phase-4-orangefox.md`, `website/docs/changelog.md`, `website/docs/references.md` (download URL + hash)

**Interfaces:**
- Consumes: unlocked fastboot/mtk write
- Produces: OrangeFox (or TWRP) boots

- [ ] **Step 1: Obtain OrangeFox image for CPH1823**

Download from the URL documented in the XDA thread / release page. Record SHA256 in `references.md`. Store the image under `stock-firmware/` or `/tmp` (gitignored), not in git.

- [ ] **Step 2: Flash recovery**

```bash
fastboot flash recovery OrangeFox-*.img
fastboot reboot recovery
```

If device uses `boot` for recovery, flash per device tree notes and document the deviation.

- [ ] **Step 3: Verify OrangeFox UI; changelog + commit; push**

**Fallback:** TWRP image for CPH1823 with the same flash/verify steps; document which was used.

---

### Task 9: Phase 5 — Android 13 GSI (+ optional Magisk)

**Files:**
- Modify: `website/docs/phase-5-gsi.md`, `website/docs/changelog.md`, `website/docs/references.md`

**Interfaces:**
- Consumes: working custom recovery; unlock
- Produces: Android 13 GSI at setup wizard; adb + Wi‑Fi smoke test

- [ ] **Step 1: Detect partition style**

```bash
fastboot getvar all 2>&1 | tee /tmp/cph1823-fastboot.txt
```

Determine A-only vs A/B and whether `system` or `super` exists. Write the chosen GSI filename pattern into `phase-5-gsi.md`.

- [ ] **Step 2: Flash vbmeta flags if required**

```bash
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
```

Use the device’s `vbmeta.img` from dump or empty vbmeta per Treble guide; document which.

- [ ] **Step 3: Flash ArrowOS (or chosen) A13 GSI**

In OrangeFox or fastbootd as appropriate for this device:

- Wipe data/cache.
- Flash system image.
- Reboot.

- [ ] **Step 4: Smoke test**

```bash
adb wait-for-device
adb shell getprop ro.build.version.release
adb shell getprop ro.product.system.device
```

Expected: Android 13 (or GSI-reported version); Wi‑Fi connects; note fingerprint/camera status in changelog.

- [ ] **Step 5: If ArrowOS fails, try Lineage/TrebleDroid A13 GSI once; else restore boot+system from dump (Task 10 path)**

- [ ] **Step 6: Optional Magisk**

Patch current `boot.img` with Magisk app; flash; verify `adb shell su -c id`. Document skip if operator declines root.

- [ ] **Step 7: Changelog + commit docs; push**

---

### Task 10: Hardening page verification + unbrick dry documentation

**Files:**
- Modify: `website/docs/hardening.md`, `website/docs/unbrick.md`, `website/docs/changelog.md`

**Interfaces:**
- Consumes: running GSI from Task 9 (or stock if GSI abandoned)
- Produces: hardening checklist marked done/skipped; unbrick page matches commands that actually worked

- [ ] **Step 1: Walk hardening checklist on device** (no Play / microG decision, DenyList if Magisk, remove unused accounts, full-disk encryption status note)

- [ ] **Step 2: Ensure unbrick page lists exact restore commands used in practice**

Example:

```bash
source .venv/bin/activate
mtk w boot backups/cph1823-YYYYMMDD/boot.bin
mtk w recovery backups/cph1823-YYYYMMDD/recovery.bin
# etc.
```

- [ ] **Step 3: Final site build and Pages check**

```bash
cd website && npm run build && cd ..
git add website/docs
git commit -m "docs: record hardening status and verified unbrick commands"
git push origin main
gh run watch --exit-status
```

Open `https://sakethramanujam.github.io/oppo-f9-cph1823/` and confirm changelog shows Phases 1–5 results.

---

## Plan self-review

**Spec coverage:**

| Spec section | Task(s) |
| --- | --- |
| Goals 1–6 | Tasks 5–9, 2–3 |
| Non-goals / security reality | README + every doc danger callout |
| Phases 0–6 | Tasks 4–9 |
| Host tooling | Task 4 |
| Dump + rollback | Tasks 6, 10 |
| Recovery / GSI / Magisk | Tasks 8–9 |
| Docusaurus Pages | Tasks 1–3 |
| Repo layout | Tasks 1–4 |
| Success criteria | Task 9–10 changelog |

**Placeholders:** none intentional; mtkclient exact subcommands verified at execution against `--help` (called out in Steps).

**Type/name consistency:** `verify-checksums.sh`, `dump-partitions.sh`, `setup-host.sh`, backup dir `backups/cph1823-<date>`, Pages `baseUrl` `/oppo-f9-cph1823/` used consistently.
