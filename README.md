# desktop-dotfiles

My KDE Plasma 6 (Wayland) desktop: Breeze Dark, Susie-Deltarune cursor, the
`sumac-night-molten-glass-plasma` Plasma theme, my panel and shortcuts, GTK settings, and the wallpaper.
Meant for an Arch install that already has Hyprland. Plasma installs alongside it.

## Install (Konsole)

```bash
sudo pacman -S --needed git
git clone https://github.com/lsamman/desktop-dotfiles.git
cd desktop-dotfiles
./install.sh            # core desktop + config
./install.sh --apps     # also Discord, Steam, OBS, qBittorrent, AUR apps...
```

Existing configs are backed up to `~/.dotfiles-backup/<timestamp>`. Then log out and choose **Plasma (Wayland)**.

## Apple Silicon (Asahi ALARM)
Detected automatically (`aarch64`). The script also installs the Asahi packages in `packages/asahi.txt`
(GPU Mesa, audio + speaker safety, firmware, m1n1/U-Boot, FEX/muvm for x86 apps) and skips x86-only apps
(Steam, Discord, Xenia, Sidra) and multilib. Packages missing from your repos are skipped with a warning.
Kernel and Mesa on a stock Asahi install are already correct, so nothing is replaced if they're present.
Retina screens may need scaling set in Display settings.

## Layout
- `packages/`: pacman and AUR package lists
- `config/`: files copied into `~/.config` (`@HOME@` is replaced with your home path)
- `local-share/`, `icons/`, `wallpapers/`: theme, cursor, wallpaper
- Not included: monitor layout, input devices, power settings, logins, per-app data.
