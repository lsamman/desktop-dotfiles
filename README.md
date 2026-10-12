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

## Layout
- `packages/`: pacman and AUR package lists
- `config/`: files copied into `~/.config` (`@HOME@` is replaced with your home path)
- `local-share/`, `icons/`, `wallpapers/`: theme, cursor, wallpaper
- Not included: monitor layout, input devices, power settings, logins, per-app data.
