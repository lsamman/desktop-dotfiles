#!/usr/bin/env bash
# Installs my KDE Plasma desktop setup on Arch (alongside Hyprland, nothing is removed).
# Usage: ./install.sh [--apps] [--no-packages]
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS=0; PKGS=1
for a in "$@"; do
  case "$a" in
    --apps) APPS=1 ;;
    --no-packages) PKGS=0 ;;
    -h|--help) sed -n '2,3p' "$0"; exit 0 ;;
    *) echo "Unknown option: $a"; exit 1 ;;
  esac
done

[[ $EUID -eq 0 ]] && { echo "Run as your normal user, not root (sudo is used when needed)."; exit 1; }
ARCH="$(uname -m)"
list() { grep -vE '^\s*(#|$)' "$1"; }
# Print only packages that exist in the enabled repos; warn about the rest (e.g. x86-only apps on Apple Silicon)
available() {
  local p
  while read -r p; do
    if pacman -Si "$p" >/dev/null 2>&1; then echo "$p"; else echo "skipping $p (not available for $ARCH)" >&2; fi
  done < <(list "$1")
}
say()  { printf '\n\033[1;35m==>\033[0m %s\n' "$*"; }

if (( PKGS )); then
  say "Installing core packages"
  sudo pacman -Sy
  sudo pacman -Su --needed --noconfirm - < <(available "$REPO/packages/pacman-core.txt")

  if [[ "$ARCH" == aarch64 ]]; then
    say "Apple Silicon detected: installing Asahi hardware packages"
    if ! grep -q '^\[asahi' /etc/pacman.conf; then
      echo "Warning: no [asahi-alarm] repo in /etc/pacman.conf. Is this Asahi ALARM? Skipping Asahi packages."
    else
      sudo pacman -S --needed --noconfirm - < <(available "$REPO/packages/asahi.txt") || echo "Some Asahi packages failed, continuing."
    fi
  fi

  if (( APPS )); then
    say "Enabling multilib (needed for Steam)"
    if [[ "$ARCH" == x86_64 ]] && ! grep -q '^\[multilib\]' /etc/pacman.conf; then
      sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
      sudo pacman -Sy
    fi
    say "Installing optional apps"
    sudo pacman -S --needed --noconfirm - < <(available "$REPO/packages/pacman-apps.txt") || echo "Some apps failed, continuing."
    if ! command -v yay >/dev/null; then
      say "Installing yay"
      tmp="$(mktemp -d)"; git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
      (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    fi
    if [[ "$ARCH" == x86_64 ]]; then
      yay -S --needed --noconfirm - < <(list "$REPO/packages/aur.txt") || echo "Some AUR packages failed, continuing."
    else
      echo "Skipping AUR list on $ARCH (sidra-bin and xenia-edge-bin are x86-only)."
    fi
  fi

  say "Enabling services"
  sudo systemctl enable --now NetworkManager bluetooth cups.socket || true
  systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
fi

say "Backing up existing configs"
BK="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BK"
for f in "$REPO"/config/*; do
  t="$HOME/.config/$(basename "$f")"
  [[ -e "$t" ]] && { mkdir -p "$BK/config"; cp -a "$t" "$BK/config/"; }
done
[[ -d "$HOME/.local/share/plasma" ]] && cp -a "$HOME/.local/share/plasma" "$BK/plasma" || true
echo "Backup in $BK"

say "Installing themes, cursor, wallpaper"
mkdir -p "$HOME/.local/share/plasma/desktoptheme" "$HOME/.icons" "$HOME/.local/share/wallpapers" "$HOME/.config"
cp -r "$REPO"/local-share/plasma/desktoptheme/. "$HOME/.local/share/plasma/desktoptheme/"
cp -r "$REPO"/icons/. "$HOME/.icons/"
cp -r "$REPO"/wallpapers/. "$HOME/.local/share/wallpapers/"

say "Installing config files"
cp -r "$REPO"/config/. "$HOME/.config/"
# fix up absolute paths
grep -rlI '@HOME@' "$HOME/.config" 2>/dev/null | xargs -r sed -i "s#@HOME@#$HOME#g"

say "Applying cursor theme"
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Susie-Deltarune
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 48
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nInherits=Susie-Deltarune\n' > "$HOME/.icons/default/index.theme"

say "Done"
cat <<MSG
Log out, then pick "Plasma (Wayland)" at your login screen (Hyprland stays available).
On a laptop, check Display settings and the panel (layout was made for a desktop).
Old configs: $BK
MSG
