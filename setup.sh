#!/usr/bin/env bash

set -euo pipefail

echo "==> Bootstrapping Arch setup..."

# -------------------------------------- #
# 🧱 Base Packages
# -------------------------------------- #
echo "==> Installing core packages (pacman)..."
sudo pacman -Syu --needed --noconfirm \
  base-devel \
  git \
  zsh \
  curl \
  wget \
  chezmoi

# -------------------------------------- #
# 🛠 Install yay (AUR helper)
# -------------------------------------- #
if ! command -v yay &>/dev/null; then
  echo "==> Installing yay..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir"
  (cd "$tmpdir" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

# -------------------------------------- #
# 📁 Dotfiles via chezmoi
# -------------------------------------- #
echo "==> Applying chezmoi config..."
chezmoi init --apply "git@github.com:Saharariel/dotfiles-arch.git"

# -------------------------------------- #
# 📦 Install system packages from packages.aur
# -------------------------------------- #
PKG_FILE="packages.aur"
if [[ -r "$PKG_FILE" ]]; then
  mapfile -t packages < <(grep -vE '^\s*#|^$' "$PKG_FILE")
  if [[ ${#packages[@]} -gt 0 ]]; then
    echo "==> Installing AUR packages with yay..."
    yay -S --needed --noconfirm "${packages[@]}"
  else
    echo "ℹ️ Package list is empty."
  fi
else
  echo "❌ packages.aur file not found!"
fi

# -------------------------------------- #
# 🐚 Set zsh as default shell
# -------------------------------------- #
echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "✅ Setup complete. Reboot recommended!"
