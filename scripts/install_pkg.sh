#!/usr/bin/env bash
set -euo pipefail

PKG_FILE="packages.lst"

if [[ ! -f "$PKG_FILE" ]]; then
  echo "❌ Error: '$PKG_FILE' not found!"
  exit 1
fi

SHELL_NAME=$(basename "$SHELL") # Detect current shell, e.g. zsh, fish
PACKAGES=()

echo "==> Parsing packages for shell: $SHELL_NAME"

while IFS= read -r line; do
  # Skip empty lines and comments
  [[ "$line" =~ ^\s*$ || "$line" =~ ^\s*# ]] && continue

  # Conditional: package|condition (e.g. eza|zsh)
  if [[ "$line" == *"|"* ]]; then
    pkg="${line%%|*}"
    condition="${line##*|}"

    if [[ "$condition" == "$SHELL_NAME" ]]; then
      PACKAGES+=("$pkg")
    fi
  else
    PACKAGES+=("$line")
  fi
done <"$PKG_FILE"

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  echo "⚠️ No matching packages found for shell '$SHELL_NAME'."
  exit 0
fi

echo "==> Installing packages:"
printf ' - %s\n' "${PACKAGES[@]}"

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
