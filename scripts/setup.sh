#!/usr/bin/env bash
set -euo pipefail

echo "==> Bootstrapping Arch setup..."

# -------------------------------------- #
# 💥 Add Chaotic-AUR repository
# -------------------------------------- #
echo "==> Adding Chaotic-AUR..."

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm https://cdn.aur.chaotic.cx/chaotic-keyring.pkg.tar.zst
sudo pacman -U --noconfirm https://cdn.aur.chaotic.cx/chaotic-mirrorlist.pkg.tar.zst

if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

sudo pacman -Sy

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
# 📁 Dotfiles via chezmoi
# -------------------------------------- #
echo "==> Applying chezmoi config..."
chezmoi init --apply "https://github.com/Saharariel/dotfiles-arch.git"

# -------------------------------------- #
# 📦 Install system packages from packages.lst
# -------------------------------------- #
echo "==> Installing additional system packages..."
./install_pkg.sh

# -------------------------------------- #
# 🐚 Set zsh as default shell
# -------------------------------------- #
echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "✅ Setup complete. Reboot recommended!"
