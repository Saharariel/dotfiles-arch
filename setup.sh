#!/usr/bin/env bash

set -e

echo "==> Bootstrapping Arch setup..."

# -------------------------------------- #
# 🧱 Base Packages
# -------------------------------------- #
echo "==> Installing core packages..."

sudo pacman -Syu --needed --noconfirm \
  base-devel \
  git \
  chezmoi \
  zsh \
  curl \
  wget

# -------------------------------------- #
# 📁 Dotfiles via chezmoi
# -------------------------------------- #
echo "==> Applying dotfiles from repo..."

chezmoi init --apply "https://github.com/Saharariel/dotfiles-arch"

# -------------------------------------- #
# 📦 Install system packages from file
# -------------------------------------- #
echo "==> Installing additional system packages..."

PKG_FILE=packages.lst
if [[ -f "$PKG_FILE" ]]; then
  grep -vE '^\s*#' "$PKG_FILE" | grep -v '^$' | xargs sudo pacman -S --needed --noconfirm
else
  echo "Missing packages.lst file!"
fi

# -------------------------------------- #
# ✅ Post-install
# -------------------------------------- #
echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "✅ Done. Reboot recommended."
