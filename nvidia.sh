#!/bin/bash
set -e

echo "[*] Checking NVIDIA GPU..."
if ! lspci -nn | grep -q "10de:"; then
  echo "[*] No NVIDIA GPU found. Skipping."
  exit 0
fi

echo "[*] NVIDIA GPU detected"

# 2. Kill the conflicts
echo "[*] Removing conflicting open-driver packages..."
sudo pacman -Rdd --noconfirm \
  libxnvctrl \
  linux-cachyos-nvidia-open \
  linux-cachyos-lts-nvidia-open \
  nvidia-open-dkms \
  2>/dev/null || true

echo "[*] Removing nvidia-open profile (if installed)..."
sudo chwd -r nvidia-open-dkms || true

echo "[*] Installing proprietary 580xx driver..."
sudo chwd -i nvidia-dkms-580xx

echo "[*] Installing VA-API utils..."
sudo pacman -S --needed --noconfirm libva-utils

echo "[*] Writing NVIDIA env vars for UWSM..."
mkdir -p "$HOME/.config/uwsm"

cat >"$HOME/.config/uwsm/env" <<'EOF'
# NVIDIA
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export NVD_BACKEND=direct
export MOZ_DISABLE_RDD_SANDBOX=1
export CUDA_DISABLE_PERF_BOOST=1
EOF

echo "[*] Done. Reboot recommended."
