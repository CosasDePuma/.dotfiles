#! /bin/bash

# -----------------------------------------------------------------
#                         V A R I A B L E S
# -----------------------------------------------------------------

dependencies=( git curl lsb-release wget dialog ca-certificates
  apt-transport-https software-properties-common gnupg2 )
available_programs=( nodejs atom askcli awscli docker golang
  haskell ionic neovim texmaker vscode wxmaxima )

# -----------------------------------------------------------------
#                            C O L O R S
# -----------------------------------------------------------------

nocolor="\e[0;0m"
colorinfo="\e[1;94m"
colorerror="\e[1;91m"
colorwarning="\e[1;33m"
colorsuccess="\e[1;92m"

# -----------------------------------------------------------------
#                          M E S S A G E S
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
#                         F U N C T I O N S
# -----------------------------------------------------------------

init_sudo() {
  info "Checking" sudo
  $sudo echo &>/dev/null
}

init_apt() {
  # (Un)install & Update
  # commands using apt-get
  aptp="apt-get purge -qq -y"
  aptu="apt-get update -qq -y"
  apti="apt-get install -qq -y"
}

init_variables() {
  # Temp file to save the choices
  tmp=/tmp/setup.sh.$$
  # Distro variables
  os=$(lsb_release -is)
  dist=$(lsb_release -cs)
  os=$(echo $os | tr [:upper:] [:lower:])
  dist=$(echo $dist | tr [:upper:] [:lower:])
  [ "$os" = "elementary" -o "$os" = "" ]  && os="ubuntu"
  [ "$dist" = "loki" -o "$dist" = "" ]    && dist="xenial"
  # Context: sudo & user
  if [ $EUID -eq 0 ]; then
    sudo=""
    [ "$SUDO_USER" = "" ] && user=$(whoami) || user=$SUDO_USER
  else
    user=$(whoami)
    sudo="sudo"
  fi
}

# -----------------------------------------------------------------

update() {
  info "Updating the" repositories
  $sudo $aptu && success repositories "updated"
}

inst() {
  info "Installing" $1
  $sudo $apti $1 &>/dev/null
  check $1
}

purge() {
  warning "Removing" $1
  $sudo $aptp $1 &>/dev/null
}

# -----------------------------------------------------------------

install_deps() {
  for dependency in $@; do
    inst $dependency
  done
}

install_dependencies() {
  update
  for dependency in ${dependencies[@]}; do
    inst $dependency
    # Check if the dialog theme has been set
    [ $dependency = dialog -a ! -f $HOME/.dialogrc ] && curl -fsSL -o $HOME/.dialogrc "https://raw.githubusercontent.com/CosasDePuma/Setup/master/config/.dialogrc"
  done
}

# -----------------------------------------------------------------

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

check_args () {
  options=''
  [ $# -lt 1 ] && return 1
  if [[ " $@ " =~ " -a " ]]; then
    options=${available_programs[@]}
  elif [[ " $@ " =~ " --all " ]]; then
    options=${available_programs[@]}
  else
    for program in $@; do
      [[ " ${available_programs[@]} " =~ " $program " ]] || error "The program" $program "is not available"
      options="$options $program"
    done
  fi
}

check_deps() {
  if ! dpkg -l $1 &>/dev/null; then
    error "The program" $1 "is required to be installed"
  fi
}

# -----------------------------------------------------------------

show_dialog() {
  dialog --clear                                                        \
    --backtitle "CosasDePuma Setup Script"                              \
    --title "[ M A I N - M E N U ]"                                     \
    --checklist                                                         \
  "\n
  You can use the UP/DOWN arrow keys to move between the different options.
  You can also press the first letter of the name to jump directly.
  Press SPACE to mark/unmark an option.
  "                                                                     \
    20 70 10                                                            \
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
        inst $option
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
        curl -fsSL "https://download.docker.com/linux/$os/gpg" | $sudo apt-key add - &>/dev/null
        $sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/$os $dist stable"
        update
        inst $option-ce
        $sudo groupadd docker &>/dev/null
        $sudo usermod -aG docker $user
        ;;
      golang)
        if [ "$os" = "ubuntu" ]; then
          $sudo add-apt-repository -y "ppa:longsleep/golang-backports" &>/dev/null
          update
        fi
        inst $option-go
        ;;
      haskell)
        inst $option-platform
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
      neovim)
        if [ "$os" = "ubuntu" ]; then
          $sudo add-apt-repository -y "ppa:neovim-ppa/stable" &>/dev/null
          update
        fi
        inst $option
        ;;
      nodejs)
        info "Adding" $option "repository"
        curl -fsSL https://deb.nodesource.com/setup_11.x | $sudo bash - &>/dev/null
        update
        inst $option
        option=npm
        inst $option
        info "Upgrading" $option
        $sudo $option install --global $option@latest &>/dev/null && success $option "updgraded"
        ;;
      vscode)
        curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > microsoft.gpg
        $sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
        $sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        update
        inst code
        [ -f microsoft.gpg ] && rm -f microsoft.gpg
        ;;
      *)
        inst $option
        ;;
    esac
  done
}

# -----------------------------------------------------------------

correct() {
  clear
  success setup "completed!"
  exit 0
}

# -----------------------------------------------------------------
#                             M A I N
# -----------------------------------------------------------------

init_apt
init_sudo
install_dependencies
init_variables
check_args $@           || \
show_dialog
clear
setup                   && \
correct

# TODO:
# - Create "man" page
# FIXME:
# - Update & Atom can't update twice (low priority)
# - Update & Docker can't update twice (low priority)
# - Better dependency check

# Bash colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
