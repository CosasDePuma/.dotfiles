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
    err 43
  fi
fi


# >> CURL
# --------------------------
if ! which curl &>/dev/null; then
  if ! apt install -y --no-install-recommends curl &>/dev/null; then
    err 52
  fi
fi


# >> MAIN SCRIPT
# --------------------------
if which docker docker-engine docker.io &>/dev/null; then
  if ! apt-get purge -y docker docker-engine docker.io &>/dev/null; then
    err 61
  fi
fi

if ! which docker &>/dev/null; then
  if dialog --title "Docker Setup" --yesno "\nWould you like to install Docker?" 7 37; then
    dialog --title "Docker Setup" --infobox "\nInstalling Docker..." 5 24
    # Download the latest package of Docker
    if ! curl -so docker.deb https://download.docker.com/linux/ubuntu/dists/$(cat /etc/lsb-release | grep CODENAME | cut -d "=" -f 2)/pool/stable/amd64/$(curl -s https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/ | grep docker-ce | sed 's/<\/*[^>]*>//g' | cut -d" " -f1 | tail -1); then
      err 68
    fi
    # Install the deb file
    if ! dpkg -i docker.deb &>/dev/null; then
      err 74
    fi
    # Remove the deb file
    if ! rm docker.deb &>/dev/null; then
      err 78
    fi
    dialog --title "Docker Setup" --msgbox "\nDocker successfully installed!" 7 34
  fi
fi

if [ "$SUDO_USER" != "" ]; then
  if dialog --title "Docker Setup" --yesno "\nWould you like to run Docker without sudo?" 8 25; then
    groupadd docker &>/dev/null
    usermod -aG docker $SUDO_USER &>/dev/null
  fi
fi

dialog --title "Docker Setup" --msgbox "\nDocker Setup correctly done!" 7 32
clear
