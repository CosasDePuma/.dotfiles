#! /bin/bash

tmp=/tmp/setup.sh.$$

aptp="apt-get purge -qq -y"
aptu="apt-get update -qq -y"
apti="apt-get install -qq -y"

nocolor="\e[0;0m"
colorinfo="\e[1;94m"
colorerror="\e[1;91m"
colorwarning="\e[1;33m"
colorsuccess="\e[1;92m"

dist=$(lsb_release -cs)

[ "$dist" = "loki" ] && dist="xenial"
[ "$SUDO_USER" = "" ] && sudo="sudo" || sudo=""

# -----------------------------------------------------------------

info() {
  echo -e "$colorinfo[INFO]\t\t$nocolor$1 $colorinfo$2 $nocolor$3"
}

error() {
  echo -e "$colorerror[ERROR]\t\t$nocolor$1 $colorerror$2 $nocolor$3"
  exit 1
}

warning() {
  echo -e "$colorwarning[WARNING]\t$nocolor$1 $colorwarning$2 $nocolor$3"
}

success() {
  echo -e "$colorsuccess[SUCCESS]\t$colorsuccess$1 $nocolor$2"
}

# -----------------------------------------------------------------

check() {
  case $1 in
    neovim)
      set -- nvim
      ;;
    *)
      ;;
  esac
  if ! dpkg -l $1 &>/dev/null; then
    error "The program" $1 "cannot be installed"
  else
    success $1 "installed"
  fi
}

init_sudo() {
  info "Checking" sudo
  $sudo echo &>/dev/null
}

purge() {
  warning "Removing" $1
  $sudo $aptp $1 &>/dev/null
}

update() {
  info "Updating the" repositories
  $sudo $aptu && success repositories "updated"
}

install() {
  info "Installing" $1
  $sudo $apti $1 &>/dev/null
  check $1
}

# -----------------------------------------------------------------

init_sudo

dependencies=( git curl wget dialog ca-certificates apt-transport-https software-properties-common )
for dependency in ${dependencies[@]}; do
  info "Checking" $dependency
  if ! dpkg -l $dependency &>/dev/null; then
    install $dependency
  fi
done

# -----------------------------------------------------------------

dialog --clear --help-button              \
  --backtitle "CosasDePuma Setup Script"  \
  --title "[ M A I N - M E N U ]"         \
  --checklist                             \
"\n
You can use the UP/DOWN arrow keys to move between the different options.
You can also press the first letter of the name to jump directly.
Press SPACE to mark/unmark an option.
"                                         \
  15 70 5                                 \
  Update  "Update your repositories" on   \
  Atom    "A hackable text editor for the 21st Century" on      \
  Docker  "Build, Ship and Deploy" on     \
  Neovim  "Vim-fork focused on extensibility and usability" on  \
  VSCode  "Code editing. Redefined" off   \
  2>"${tmp}"
options=$(<"${tmp}")

clear && echo

for option in ${options[@]}; do
  option=$(echo $option | tr [:upper:] [:lower:])
  case $option in
    update)
      update
      ;;
    atom)
      (curl -fsSL "https://packagecloud.io/AtomEditor/atom/gpgkey" | $sudo apt-key add -) &>/dev/null
      $sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
      update
      install $option
      ;;
    docker)
      purge docker
      purge docker.io
      purge docker-engine
      curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | $sudo apt-key add - &>/dev/null
      $sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $dist stable"
      update
      install $option-ce
      ;;
    neovim)
      $sudo add-apt-repository -y "ppa:neovim-ppa/stable" &>/dev/null
      update
      install $option
      ;;
    vscode)
      curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > microsoft.gpg
      $sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
      $sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
      update
      install code
      ;;
    *)
      install $option
      ;;
  esac
done

echo && exit 0

# FIXME:
# - Update & Atom can't update twice
# - Update & Docker can't update twice

# Bash colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
