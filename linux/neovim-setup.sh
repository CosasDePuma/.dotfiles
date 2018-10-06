#!/usr/bin/env bash

# >> COLORS
# --------------

if ! lsb_release -a 2>/dev/null | grep -sq elementary; then
  BOLD="\033[1m"
  NO_COLOR="\033[0m"
  COLOR_WHITE="\033[38;5;15m"
  BACKGROUND_RED="\033[48;5;9m"
fi


# >> PRIVILEGES CHECKER
# --------------------------

if [ "$(id -u)" != "0" ]; then
 echo "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: You must be root${NO_COLOR}"
 exit
else
  echo -ne "Starting.\r"
  sleep 0.5
  echo -ne "Starting..\r"
  sleep 0.5
  echo -ne "Starting...\r"
  sleep 0.5
  CHOWN_USER=$SUDO_USER || CHOWN_USER=$USER
fi


# >> ERROR
# -----------------

err() {
  clear
	echo "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: Bad return code in line $1${NO_COLOR}"
  exit
}


# >> DIALOG
# --------------------------
if ! which dialog &>/dev/null; then
  if ! apt install -y --no-install-recommends dialog &>/dev/null; then
    err 42
  fi
fi


# >> CURL
# --------------------------
if ! which curl &>/dev/null; then
  if ! apt install -y --no-install-recommends curl &>/dev/null; then
    err 51
  fi
fi


# >> MAIN SCRIPT
# --------------------------
if ! which nvim &>/dev/null; then
  if dialog --title "NeoVim Setup" --yesno "\nWould you like to install NeoVim?" 7 37; then
    dialog --title "NeoVim Setup" --infobox "\nInstalling NeoVim..." 5 24
    # Download the latest package of NeoVim
    if ! curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage &>/dev/null; then
      err 63
    fi
    # Make the binary executable
    if ! chmod +x nvim.appimage &>/dev/null; then
      err 67
    fi
    # Add the binary to your PATH
    if ! mv nvim.appimage /usr/local/bin/nvim &>/dev/null; then
      err 71
    fi
    dialog --title "NeoVim Setup" --msgbox "\nNeoVim successfully installed!" 7 35
  fi
fi

if [ ! -f $HOME/.vimrc ]; then
  if dialog --title "NeoVim Setup" --yesno "\nWould you like to download custom configuration files?" 7 31; then
    dialog --title "NeoVim Setup" --infobox "\nDownloading init.vim..." 5 27
    # Create the directory
    if ! mkdir -p $HOME/.config/nvim &>/dev/null; then
      err 83
    fi
    # Download custom init.vim
    if ! curl -fsLo $HOME/.config/nvim/init.vim https://raw.githubusercontent.com/CosasDePuma/Setup/master/linux/init.vim; then
      err 87
    fi
    # Load the plugins
    if ! nvim -c "PlugInstall" -c "q!" -c "q!"; then
      err 91
    fi
    # Load the plugins
    if ! sed -i -e 's/" colorscheme/colorscheme/g' $HOME/.config/nvim/init.vim; then
      err 95
    fi
    if ! chown $CHOWN_USER -R $HOME/.config/nvim $HOME/.local/share/nvim; then
      err 99
    fi
    dialog --title "NeoVim Setup" --msgbox "\nCustom configuration loaded!" 7 32
  fi
fi

dialog --title "NeoVim Setup" --msgbox "\nNeoVim Setup correctly done!" 7 32
clear
