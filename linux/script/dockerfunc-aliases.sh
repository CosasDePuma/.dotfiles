#! /bin/bash

# -----------------------------------------------------------------
#                         V A R I A B L E S
# -----------------------------------------------------------------

dependencies=( dialog )
available_extensions=( eclipse hollywood metasploit-framework
  netcat nmap searchsploit swipl )

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
  tmp=/tmp/dockerfunc.sh.$$
  update_="apt-get update -y -qq"
  install_="apt-get install -y -qq"
  dockerfunc=$HOME/.dockerfunc
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

append() {
  echo "$1() {"                         >> $dockerfunc
  echo "  docker run --name $1 $2"      >> $dockerfunc
  echo "}"                              >> $dockerfunc
  [ "$3" != "" ] && echo "alias $3=$1"  >> $dockerfunc
  echo                                  >> $dockerfunc
}

# -----------------------------------------------------------------

check_args() {
  options=''
  [ $# -lt 1 ] && return 1
  if [[ " $@ " =~ " -a " ]]; then
    options=${available_extensions[@]}
  elif [[ " $@ " =~ " --all " ]]; then
    options=${available_extensions[@]}
  else
    for container in $@; do
      [[ " ${available_extensions[@]} " =~ " $container " ]] || error "The container" $container "is not available"
      options="$options $container"
    done
  fi
}

# -----------------------------------------------------------------

show_dialog() {
  dialog --clear                                                                \
    --backtitle "CosasDePuma Dockerfunc Script"                                 \
    --title "[ M A I N - M E N U ]"                                             \
    --checklist                                                                 \
  "\n
  You can use the UP/DOWN arrow keys to move between the different options.
  You can also press the first letter of the name to jump directly.
  Press SPACE to mark/unmark an option.
  "                                                                             \
    20 90 10                                                                    \
  eclipse                 "The most widely used Java IDE" on                    \
  hollywood               "Fake a Hollywood Hacker Screen in Linux Terminal" on \
  metasploit-framework    "The world's best penetration testing software" on    \
  netcat                  "Featured networking utility using TCP/IP" off        \
  nmap                    "The Network Mapper" off                              \
  searchsploit            "Command line search tool for Exploit-DB" on          \
  swipl                   "Comprehensive free Prolog environment" on            \
    2>"${tmp}"
  [ "$options" = '' ] && options=$(<"${tmp}")
}

# -----------------------------------------------------------------

setup() {
  info "creating .dockerfunc in" $dockerfunc

  cat >$dockerfunc <<HEADER
#  -------------------------
# |        FUNCTIONS        |
#  -------------------------

docker_purge() {
    local containers
    containers=( \$(docker ps -aq) )

    local volumes
    volumes=( \$(docker ps --filter status=exited -q) )

    local images
    images=( \$(docker images -q) )

    docker stop \${containers[@]}
    docker rm \${containers[@]}
    docker rm -v \${volumes[@]}
    docker rmi -f \${images[@]}
}

#  -------------------------
# |      MY CONTAINERS      |
#  -------------------------

HEADER

  for option in ${options[@]}; do
    option=$(echo $option | tr [:upper:] [:lower:])
    case $option in
      eclipse)
        append $option "--interactive --tty --volume /tmp/.X11-unix:/tmp/.X11-unix --env DISPLAY=unix\$DISPLAY --volume \$PWD:/home/developer rafdouglas/eclipse_docker:eclipse_mars_JavaEE || docker start $option"
        ;;
      hollywood)
        append $option "--rm --interactive --tty jess/$option"
        ;;
      metasploit-framework)
        append $option "--interactive --tty --rm --volume \$HOME/.msf4/modules:/modules metasploitframework/$1" msfconsole
        ;;
      netcat)
        append $option "--rm --interactive --tty --net host jess/$option \"\$@\"" nc
        ;;
      nmap)
        append $option "--rm --interactive --tty --net host jess/$option \"\$@\""
        ;;
      searchsploit)
        append $option "--rm --tty --volume \$PWD:Downloads cosasdepuma/$option \"\$@\""
        ;;
      swipl)
        append $option "--interactive --tty --rm --volume \$PWD:/pl $option" prolog
        ;;
    esac
  done


  if ! grep ".cosasdepuma" $HOME/.bashrc | grep -q "source"; then
    grep ".dockerfunc" $HOME/.bashrc | grep -q "source" || echo -e "\n# Dockerfunc\nsource $dockerfunc" >> $HOME/.bashrc
  fi
  source $HOME/.bashrc
}

# -----------------------------------------------------------------

correct() {
  clear
  success "dockerfunc" "customization completed!"
  exit 0
}

# -----------------------------------------------------------------
#                             M A I N
# -----------------------------------------------------------------

init_variables
install_dependencies
check_args $@           || \
show_dialog
clear
setup                   && \
correct

# TODO:
# - Append: config/.dockerfunc functions
# FIXME:
#

# Bash colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
