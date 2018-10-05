#!/usr/bin/env bash

# >> COLORS
# --------------

if ! lsb_release -a 2>/dev/null | grep -sq elementary; then
  BOLD="\033[1m"
  NO_COLOR="\033[0m"
  COLOR_BLUE="\033[38;5;12m"
  COLOR_WHITE="\033[38;5;15m"
  COLOR_GREEN="\033[38;5;40m"
  COLOR_YELLOW="\033[38;5;228m"
  BACKGROUND_RED="\033[48;5;9m"
fi


# >> PRIVILEGES CHECKER
# --------------------------

if [ "$(id -u)" != "0" ]; then
 echo "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: You must be root${NO_COLOR}"
 exit
fi


# >> MAIN SCRIPT
# --------------------------

if ! which virtualbox; then
  apt install -y virtualbox-qt
fi

if ! which kubectl; then
  # Download the latest package of Kubectl
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  # Make the binary executable
  chmod +x kubectl
  # Add the binary to your PATH
  mv kubectl /usr/local/bin/kubectl
fi

if ! which minikube; then
  # Download the latest package of Kubectl
  curl -LO https://github.com/kubernetes/minikube/releases/download/v0.29.0/minikube-linux-amd64
  # Make the binary executable
  chmod +x minikube-linux-amd64
  # Add the binary to your PATH
  mv minikube-linux-amd64 /usr/local/bin/minikube
fi


# References: https://www.youtube.com/watch?v=gpmerrSpbHg
