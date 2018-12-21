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

available_programs=( update atom askcli awscli ionic docker golang
  haskell texmaker neovim vscode wxmaxima )

[ "$dist" = "loki" ] && dist="xenial"
if [ "$SUDO_USER" = "" ]; then
  user=$USER
  sudo="sudo"
else
  sudo=""
  user=$SUDO_USER
fi

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

init_sudo() {
  info "Checking" sudo
  $sudo echo &>/dev/null
}

check() {
  case $1 in
    ask-cli)  set -- ask $2;;
    awscli)   set -- aws $2;;
  esac
  if [ "$2" = "module" ]; then
    if ! which $1 &>/dev/null; then
      error "The program" $1 "cannot be installed"
    fi
  else
    if ! dpkg -l $1 &>/dev/null; then
      error "The program" $1 "cannot be installed."
    fi
  fi
  success $1 "installed"
}

# -----------------------------------------------------------------

purge() {
  warning "Removing" $1
  $sudo $aptp $1 &>/dev/null
}

update() {
  info "Updating the" repositories
  $sudo $aptu && success repositories "updated"
}

install_() {
  info "Installing" $1
  $sudo $apti $1 &>/dev/null
  check $1
}

check_deps() {
  if ! dpkg -l $1 &>/dev/null; then
    error "The program" $1 "is required to be installed"
  fi
}

install_deps() {
  for dependency in $@; do
    install $dependency
  done
}

# -----------------------------------------------------------------

setup() {
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
        install_ $option
        ;;
      askcli)
        option=ask-cli
        check_deps npm
        info "Installing" $option
        $sudo npm install --global $option &>/dev/null
        check $option "module"
        ;;
      awscli)
        install_deps python-pip
        info "Installing" $option
        $sudo pip install $option &>/dev/null
        check $option "module"
        ;;
      docker)
        purge docker
        purge docker.io
        purge docker-engine
        curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | $sudo apt-key add - &>/dev/null
        $sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $dist stable"
        update
        install_ $option-ce
        $sudo groupadd docker &>/dev/null
        $sudo usermod -aG docker $user
        ;;
      ionic)
        check_deps npm
        info "Installing" cordova
        $sudo npm install --global cordova &>/dev/null
        check cordova "module"
        info "Installing" $option
        $sudo npm install --global $option &>/dev/null
        check $option "module"
        ;;
      golang)
        $sudo add-apt-repository -y "ppa:longsleep/golang-backports" &>/dev/null
        update
        install_ $option-go
        ;;
      haskell)
        install_ $option-platform
        ;;
      neovim)
        $sudo add-apt-repository -y "ppa:neovim-ppa/stable" &>/dev/null
        update
        install_ $option
        ;;
      nodejs)
        info "Adding" $option "repository"
        curl -fsSL https://deb.nodesource.com/setup_11.x | $sudo bash - &>/dev/null
        install_ $option
        option=npm
        install_ $option
        info "Upgrading" $option
        $sudo $option install --global $option@latest &>/dev/null && success $option "updgraded"
        ;;
      vscode)
        curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > microsoft.gpg
        $sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
        $sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        update
        install_ code
        ;;
      *)
        install_ $option
        ;;
    esac
  done
}

# -----------------------------------------------------------------

check_args () {
  [ $# -eq 0 ] && return 1
  options=''
  while [ $# -gt 0 ]; do
    if [ "$1" = "-a" -o "$1" = "--all" ]; then
      options=$available_programs
      return 0
    else
      if [[ " ${available_programs[@]} " =~ " $1 " ]]; then
        options="$options $1"
      else
        error "The program" $1 "is not available"
      fi
    fi
    shift
  done
}

# -----------------------------------------------------------------

init_sudo

dependencies=( git curl wget dialog ca-certificates apt-transport-https software-properties-common )
for dependency in ${dependencies[@]}; do
  info "Checking" $dependency
  if ! dpkg -l $dependency &>/dev/null; then
    install $dependency
  fi
  [ $dependency = dialog -a ! -f $HOME/.dialogrc ] && curl -fsSL -o $HOME/.dialogrc "https://raw.githubusercontent.com/CosasDePuma/Setup/master/config/.dialogrc"
done

# -----------------------------------------------------------------

check_args $@ ||                                                      \
dialog --clear --help-button                                          \
  --backtitle "CosasDePuma Setup Script"                              \
  --title "[ M A I N - M E N U ]"                                     \
  --checklist                                                         \
"\n
You can use the UP/DOWN arrow keys to move between the different options.
You can also press the first letter of the name to jump directly.
Press SPACE to mark/unmark an option.
"                                                                     \
  20 70 10                                                            \
  Update    "Update your repositories" on                             \
  Atom      "A hackable text editor for the 21st Century" on          \
  ASKCli    "A tool for you to manage your Alexa skills" off          \
  AWSCli    "Universal Command Line Interface for AWS" off            \
  Ionic     "Build apps in one codebase, for any platform." off       \
  Docker    "Build, Ship and Deploy" on                               \
  Golang    "The Go programming language" off                         \
  Haskell   "An advanced, purely functional programming language" off \
  TeXMaker  "Cross-platform open-source LaTeX editor" off             \
  Neovim    "Vim-fork focused on extensibility and usability" on      \
  NodeJS    "Entorno de ejecución para JavaScript" on                 \
  VSCode    "Code  editing. Redefined" off                            \
  wxMaxima  "Document based interface for Maxima" off                 \
  2>"${tmp}"
[ "$options" = '' ] && options=$(<"${tmp}")

clear
echo
[ "$(echo ${options[0]} | cut -d " " -f1)" = "HELP" ] && exit 2

if setup; then
  clear
  success setup "completed!"
fi

# TODO:
# - Create "man" page
# - Run "man" page in help
# FIXME:
# - Update & Atom can't update twice
# - Update & Docker can't update twice

# Bash colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
