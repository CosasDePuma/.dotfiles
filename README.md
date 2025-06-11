<div align="center">

# 🌈 A collection of my personal dotfiles 🦄

<img src=".github/logo.png" alt=".dotfiles" />
<br/><br/>
</div>

This repository contains my personal configuration files for various tools and applications. Feel free to explore and use anything you find useful!

## 📦 Installation

The dotfiles are managed using [GNU Stow](https://www.gnu.org/software/stow/), a symlink farm manager.

```sh
# --- clone the repository
git clone --depth=1 https://github.com/cosasdepuma/.dotfiles.git
cd .dotfiles

# --- use stow to symlink everything at once...
stow --adopt .
# ... or selectively install specific configs
stow --adopt .config/git
```

## 📄 .Files

| Tool                                       | Config                                               | Description                             |
|--------------------------------------------|------------------------------------------------------|-----------------------------------------|
| [Bat](https://github.com/sharkdp/bat)      | [.config/bat/](.config/bat/)                         | Modern `cat` replacement                |
| [Curl](https://curl.se/)                   | [.curlrc](.curlrc)                                   | Command line tool for transferring data |
| [Direnv](https://direnv.net/)              | [.config/direnv/](.config/direnv/)                   | Environment switcher for the shell      |
| [Fish](https://www.fishshell.com/)         | [.config/fish/config.fish](.config/fish/config.fish) | Smart and user-friendly command line    |
| [Git](https://git-scm.com/)                | [.config/git/](.config/git/)                         | Version control system                  |
| HushLogin                                  | [.hushlogin](.hushlogin)                             | MOTD disabler                           |
| [LSD](https://github.com/lsd-rs/lsd)       | [.config/lsd/](.config/lsd/)                         | Modern `ls` replacement                 |
| [Nix](https://nixos.org/)                  | [.config/nix/](.config/nix/)                         | Package manager (Nix ecosystem)         |
| [SSH](https://www.openssh.com)             | [.ssh/](.ssh/)                                       | Secure remote login and file transfer   |
| [Starship](https://starship.rs/)           | [.config/starship.toml](.config/starship.toml)       | Cross-shell prompt                      |
| [Nerd Fonts](https://www.nerdfonts.com/)   | [.local/share/fonts/](.local/share/fonts/)           | Iconic font aggregator and collection   |
| Wallpapers                                 | [.local/share/wallpapers/](.local/share/wallpapers/) | My personal wallpaper collection        |
| [Wget](https://www.gnu.org/software/wget/) | [.wgetrc](.wgetrc)                                   | File download utility                   |

## 🎨 Theme

By default, I'm using the [Catppuccin](https://github.com/catppuccin/catppuccin) color scheme (Macchiato variant) for my terminal and tools. It provides a soothing pastel theme that's easy on the eyes.

## 📝 License

This project is licensed under the [WTFPL License](LICENSE). Do what the f*ck you want with these dotfiles!

---

<p align="center">
  Made with 💜 by <a href="https://github.com/CosasDePuma">Kike Fontán</a>
</p>
