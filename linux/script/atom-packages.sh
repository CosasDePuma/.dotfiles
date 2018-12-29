#! /bin/bash

# -----------------------------------------------------------------
#                         V A R I A B L E S
# -----------------------------------------------------------------

dependencies=( dialog )
available_packages=(
  atom-live-server ask-stack autoclose-html autocomplete-paths
  auto-update-packages emmet expose file-icons highlight-selected
  language-markdown markdown-pdf minimap pigments platformio-ide-terminal
  project-manager )

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
  apm install $1
}

# -----------------------------------------------------------------

check_apm() {
  ! which apm &>/dev/null && error "Program" "atom" "must be installed"
}

check_args() {
  options=''
  [ $# -lt 1 ] && return 1
  if [[ " $@ " =~ " -a " ]]; then
    options=${available_packages[@]}
  elif [[ " $@ " =~ " --all " ]]; then
    options=${available_packages[@]}
  else
    for package in $@; do
      [[ " ${available_packages[@]} " =~ " $package " ]] || error "The package" $package "is not available"
      options="$options $package"
    done
  fi
}

# -----------------------------------------------------------------

show_dialog() {
  dialog --clear                                                                \
    --backtitle "CosasDePuma Atom Packages Script"                              \
    --title "[ M A I N - M E N U ]"                                             \
    --checklist                                                                 \
  "\n
  You can use the UP/DOWN arrow keys to move between the different options.
  You can also press the first letter of the name to jump directly.
  Press SPACE to mark/unmark an option.
  "                                                                             \
    20 70 10                                                                    \
    Atom-Live-Server        "Launch a http server with reloads" on              \
    Ask-Stack               "Quickly get answers from Stack Overflow" off       \
    Autoclose-HTML          "Automates closing of HTML Tags" off                \
    Autocomplete-Paths      "Adds path autocompletion to autocomplete+" on      \
    Auto-Update-Packages    "Keep your Atom packages up to date" on             \
    Emmet                   "The essential toolkit for web-developers" on       \
    Expose                  "Quick tab overview of open files" off              \
    File-Icons              "File-specific icons in Atom" on                    \
    Highlight-Selected      "Highlight occurrences of a selection" on           \
    Language-Markdown       "Adds grammar support for Markdown" on              \
    Markdown-PDF            "Convert markdown to pdf, png or jpeg" on           \
    Minimap                 "A preview of the full source code" on              \
    Pigments                "A package to display colors" on                    \
    PlatformIO-IDE-Terminal "A terminal package for Atom" on                    \
    Project-Manager         "Project Manager for easy access to projects" on    \
    2>"${tmp}"
  [ "$options" = '' ] && options=$(<"${tmp}")
}

# -----------------------------------------------------------------

setup() {
  for option in ${options[@]}; do
    option=$(echo $option | tr [:upper:] [:lower:])
    case $option in
      *)
        inst $option
        ;;
    esac
  done
}

# -----------------------------------------------------------------

correct() {
  clear
  success "atom customization" "completed!"
  exit 0
}

# -----------------------------------------------------------------
#                             M A I N
# -----------------------------------------------------------------

check_apm
init_variables
install_dependencies
check_args $@           || \
show_dialog
clear
setup                   && \
correct

# TODO:
# - Create "man" page
# - Add "time to load"
# FIXME:
#

# Bash colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
