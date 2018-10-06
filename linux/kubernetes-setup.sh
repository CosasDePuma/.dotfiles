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
if ! which virtualbox &>/dev/null; then
  if dialog --title "Kubernetes Setup" --yesno "\nWould you like to install VirtualBox?" 7 41; then
    dialog --title "Kubernetes Setup" --infobox "\nInstalling VirtualBox..." 5 28
    if ! apt install -y virtualbox-qt &>/dev/null; then
      err 62
    fi
    dialog --title "Kubernetes Setup" --msgbox "\nVirtualBox successfully installed!" 7 38
  fi
fi

if ! which kubectl &>/dev/null; then
  if dialog --title "Kubernetes Setup" --yesno "\nWould you like to install Kubectl?" 7 38; then
    dialog --title "Kubernetes Setup" --infobox "\nInstalling Kubectl..." 5 25
    # Download the latest package of Kubectl
    if ! curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &>/dev/null; then
      err 73
    fi
    # Make the binary executable
    if ! chmod +x kubectl &>/dev/null; then
      err 77
    fi
    # Add the binary to your PATH
    if ! mv kubectl /usr/local/bin/kubectl &>/dev/null; then
      err 81
    fi
    dialog --title "Kubernetes Setup" --msgbox "\nKubectl successfully installed!" 7 35
  fi
fi

if ! which minikube &>/dev/null; then
  if dialog --title "Kubernetes Setup" --yesno "\nWould you like to install Minikube?" 7 39; then
    dialog --title "Kubernetes Setup" --infobox "\nInstalling Minikube..." 5 26
    # Download the latest package of Minikube
    if ! curl -LO https://github.com/kubernetes/minikube/releases/download/v0.29.0/minikube-linux-amd64 &>/dev/null; then
      err 92
    fi
    # Make the binary executable
    if ! chmod +x minikube-linux-amd64 &>/dev/null; then
      err 95
    fi
    # Add the binary to your PATH
    if ! mv minikube-linux-amd64 /usr/local/bin/minikube &>/dev/null; then
      err 100
    fi
    dialog --title "Kubernetes Setup" --msgbox "\nMinikube successfully installed!" 7 36
  fi
fi

dialog --title "Kubernetes Setup" --msgbox "\nKubernetes Setup correctly done!" 7 36
clear

# References: https://www.youtube.com/watch?v=gpmerrSpbHg
