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
#!/usr/bin/env bash

set -euo pipefail
echo "==> Installing additional system packages..."

PKG_FILE="packages.lst"

# Check if the file exists and is readable
if [[ ! -r "$PKG_FILE" ]]; then
  echo "❌ Error: '$PKG_FILE' not found or not readable!"
  exit 1
fi

# Read packages (ignoring comments and empty lines)
mapfile -t packages < <(grep -vE '^\s*#' "$PKG_FILE" | grep -vE '^\s*$')

# Check if we have any packages to install
if [[ ${#packages[@]} -eq 0 ]]; then
  echo "ℹ️ No packages to install."
  exit 0
fi

# Install packages
echo "📦 Installing: ${packages[*]}"
sudo pacman -S --needed --noconfirm "${packages[@]}"

# ✅ Post-install
# -------------------------------------- #
echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "✅ Done. Reboot recommended."
