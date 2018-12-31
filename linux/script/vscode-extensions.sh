#! /bin/bash

# -----------------------------------------------------------------
#                         V A R I A B L E S
# -----------------------------------------------------------------

dependencies=( dialog )
available_extensions=( cpptools docker githistory gitlens go material-icon-theme
  python vscode-theme-onedark vscode-great-icons vscode-icons yaml )

# -----------------------------------------------------------------
#                            C O L O R S
# -----------------------------------------------------------------

nocolor="\e[0;0m"
colorinfo="\e[1;94m"
colorerror="\e[1;91m"
colorsuccess="\e[1;92m"

# -----------------------------------------------------------------
#                          M E S S A G E S
# -----------------------------------------------------------------

info() {
  echo -e "$colorinfo[INFO] $nocolor$1 $colorinfo$2 $nocolor$3"
}

error() {
  echo -e "$colorerror[ERROR] $nocolor$1 $colorerror$2 $nocolor$3"
  exit 1
}

success() {
  echo -e "$colorsuccess[SUCCESS] $colorsuccess$1 $nocolor$2"
}

# -----------------------------------------------------------------
#                         F U N C T I O N S
# -----------------------------------------------------------------

init_variables() {
  # Temp file to save the choices
  tmp=/tmp/setup.sh.$$
  update_="apt-get update -y -qq"
  install_="apt-get install -y -qq"
  [ $EUID -eq 0 ] && sudo="" || sudo="sudo"
}

# -----------------------------------------------------------------

install_dependencies() {
  info "updating the" "repositories"
  $sudo $update_
  for dependency in ${dependencies[@]}; do
    $sudo $install_ $dependency
    # Check if the dialog theme has been set
    [ $dependency = dialog -a ! -f $HOME/.dialogrc ] && curl -fsSL -o $HOME/.dialogrc "https://raw.githubusercontent.com/CosasDePuma/Setup/master/config/.dialogrc"
  done
}

# -----------------------------------------------------------------

inst() {

  [ $EUID -eq 0 ] && code --install-extension $1 --force --user-data-dir="$HOME/.vscode-root" || code --install-extension $1 --force
}

# -----------------------------------------------------------------

check_vscode() {
  ! which code &>/dev/null && error "Program" "vscode" "must be installed"
}

check_args() {
  options=''
  [ $# -lt 1 ] && return 1
  if [[ " $@ " =~ " -a " ]]; then
    options=${available_extensions[@]}
  elif [[ " $@ " =~ " --all " ]]; then
    options=${available_extensions[@]}
  else
    for extension in $@; do
      [[ " ${available_extensions[@]} " =~ " $extension " ]] || error "The extension" $extension "is not available"
      options="$options $extension"
    done
  fi
}

# -----------------------------------------------------------------

show_dialog() {
  dialog --clear                                                                \
    --backtitle "CosasDePuma VSCode Extensions Script"                          \
    --title "[ M A I N - M E N U ]"                                             \
    --checklist                                                                 \
  "\n
  You can use the UP/DOWN arrow keys to move between the different options.
  You can also press the first letter of the name to jump directly.
  Press SPACE to mark/unmark an option.
  "                                                                             \
    20 70 10                                                                    \
    cpptools              "C/C++ support with debug and intellisense." off      \
    docker                "Syntax highlight and linting for Dockerfiles" on     \
    githistory            "Git history, search and more (including git log)" on \
    gitlens               "Git capabilities supercharged" on                    \
    go                    "Rich Go language support" off                        \
    material-icon-theme   "Icons based on Material Design" off                  \
    python                "Rich support for the Python language" on             \
    vscode-great-icons    "A big pack of icons (100+) for your files." on       \
    vscode-icons          "Icons for Visual Studio Code" off                    \
    vscode-theme-onedark  "One Dark Theme based on Atom" on                     \
    yaml                  "Comprehensive YAML Language support" on              \
    2>"${tmp}"
  [ "$options" = '' ] && options=$(<"${tmp}")
}

# -----------------------------------------------------------------

setup() {
  for option in ${options[@]}; do
    option=$(echo $option | tr [:upper:] [:lower:])
    case $option in
      cpptools) inst ms-vscode.cpptools ;;
      docker) inst PeterJausovec.vscode-docker ;;
      githistory) inst donjayamanne.githistory ;;
      gitlens) inst eamodio.gitlens ;;
      go) inst ms-vscode.Go ;;
      material-icon-theme) inst PKief.material-icon-theme ;;
      python) inst ms-python.python ;;
      vscode-theme-onedark) inst akamud.vscode-theme-onedark ;;
      vscode-great-icons) inst emmanuelbeziat.vscode-great-icons ;;
      vscode-icons) inst robertohuertasm.vscode-icons ;;
      yaml) inst redhat.vscode-yaml ;;
      *)
        inst $option
        ;;
    esac
  done
}

# -----------------------------------------------------------------

correct() {
  clear
  success "vscode customization" "completed!"
  exit 0
}

# -----------------------------------------------------------------
#                             M A I N
# -----------------------------------------------------------------

check_vscode
init_variables
install_dependencies
check_args $@           || \
show_dialog
clear
setup                   && \
correct

# TODO:
#
# FIXME:
#

# Bash colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
