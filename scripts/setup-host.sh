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
pip install "git+https://github.com/bkerler/mtkclient.git"
echo "Host setup done. Activate with: source $VENV/bin/activate"
echo "If adb missing system-wide, use ~/.local/opt/platform-tools or install android-tools-adb via apt."
command -v adb >/dev/null && adb version || true
