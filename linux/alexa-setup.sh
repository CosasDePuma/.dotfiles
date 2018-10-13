#!/usr/bin/env bash

# >> COLORS
# --------------

if which tput > /dev/null 2>&1 && [[ $(tput -T$TERM colors) -ge 8 ]]; then
  BOLD="\033[1m"
  NO_COLOR="\033[0m"
  COLOR_WHITE="\033[38;5;15m"
  BACKGROUND_RED="\033[48;5;9m"
fi


# >> PRIVILEGES CHECKER
# --------------------------

if [ "$(id -u)" != "0" ]; then
 echo -e "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: You must be root${NO_COLOR}"
 exit
else
  echo -n "Starting."
  sleep 0.5
  echo -n "."
  sleep 0.5
  echo -n "."
  sleep 0.5
fi


# >> ERROR
# -----------------

err() {
  clear
  echo -e "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: Bad return code in line $1${NO_COLOR}"
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
if ! which npm &>/dev/null; then
  if dialog --title "Alexa Setup" --yesno "\nWould you like to install NodeJS and NPM?" 7 45; then
    dialog --title "Alexa Setup" --infobox "\nInstalling NodeJS and NPM..." 5 32
    ( curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - ) &>/dev/null
    if ! sudo apt-get install -y nodejs &>/dev/null; then
      err 64
    fi
    ln -s /usr/bin/nodejs /usr/bin/node
    dialog --title "Alexa Setup" --msgbox "\nNodeJS and NPM successfully installed!" 7 42
  fi
fi

if ! which atom &>/dev/null; then
  if dialog --title "Alexa Setup" --yesno "\nWould you like to install Atom?" 7 35; then
    dialog --title "Alexa Setup" --infobox "\nInstalling Atom..." 5 22
    # Download the latest package of Atom
    if ! curl -LO https://atom.io/download/deb &>/dev/null; then
      err 76
    fi
    # Install the deb package
    if ! dpkg -i deb; then
      err 80
    fi
    # Install the dependencies
    if ! apt install -y -f; then
      err 84
    fi
    # Remove the deb package
    if ! rm -f deb &>/dev/null; then
      err 88
    fi
    dialog --title "Alexa Setup" --msgbox "\nAtom successfully installed!" 7 32
  fi
fi

if [ ! -d ${HOME}/.atom/packages/platformio-ide-terminal ]; then
  if dialog --title "Alexa Setup" --yesno "\nWould you like to install an Atom terminal?" 7 47; then
    dialog --title "Alexa Setup" --infobox "\nInstalling platformio-ide-terminal package..." 5 49
    if ! apm install platformio-ide-terminal &>/dev/null; then
      err 98
    fi
    dialog --title "Alexa Setup" --msgbox "\nPlatformio-IDE-Terminal successfully installed!" 7 51
  fi
fi

if ! which aws &>/dev/null; then
  if dialog --title "Alexa Setup" --yesno "\nWould you like to install AWS Cli?" 7 38; then
    dialog --title "Alexa Setup" --infobox "\nInstalling AWS Cli..." 5 25
    if ! apt install -y awscli &>/dev/null; then
      err 108
    fi
    dialog --title "Alexa Setup" --msgbox "\nAWS Cli successfully installed!" 7 35
  fi
fi

if ! which npm &>/dev/null; then
  err 115
fi

if ! which ask &>/dev/null; then
  if dialog --title "Alexa Setup" --yesno "\nWould you like to the Alexa Skill Kit?" 7 42; then
    dialog --title "Alexa Setup" --infobox "\nInstalling the Alexa Skill Kit..." 5 37
    if ! npm install --global ask-cli &>/dev/null; then
      err 122
    fi
    dialog --title "Alexa Setup" --msgbox "\nAlexa Skill Kit successfully installed!" 7 43
  fi
fi

dialog --title "Alexa Setup" --msgbox "\nAlexa Setup correctly done!" 7 31
clear

# References: https://www.youtube.com/watch?v=0LUY_VTGlkA
