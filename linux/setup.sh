#! /bin/sh

# >> COLORS
# --------------

BOLD="\033[1m"
NO_COLOR="\033[0m"
COLOR_BLUE="\033[38;5;12m"
COLOR_WHITE="\033[38;5;15m"
COLOR_GREEN="\033[38;5;40m"
COLOR_YELLOW="\033[38;5;228m"
BACKGROUND_RED="\033[48;5;9m"

# >> DISTRO CONFIG
# ---------------------

MANAGER="apt install"

# >> PRIVILEGES CHECKER
# --------------------------

if [ "$(id -u)" != "0" ]; then
	echo "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: You must be root${NO_COLOR}"
	exit
fi

# >> FUNCTIONS
# -----------------

err() {
	echo "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: Bad return code while trying to $2 $1${NO_COLOR}"
    exit
}

# >> UNINSTALLER
# -------------------

if [ "$1" = "uninstall" ]; then
    echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Uninstalling custom configuration!"
    ( rm -rf $HOME/.oh-my-zsh $HOME/.zsh* $HOME/.vim* && ( [ "$SUDO_USER" != "" ] && chsh -s $(which bash) $SUDO_USER || chsh -s $(which bash) $USER ) && apt-get purge -y vim zsh vim fonts-powerline ttf-ancient-fonts ) 1>/dev/null 2>/dev/null 3>/dev/null
    if [ $? -ne 0 ]; then err configuration uninstall; fi
    echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_BLUE}Successfully uninstalled!"
    exit
fi

# >> MAIN SCRIPT
# -------------------

# ----- GIT -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Installing ${COLOR_GREEN}git ${NO_COLOR}"
	( git --version || ( ${MANAGER} -y git ) ) 1>/dev/null 2>/dev/null 3>/dev/null
	if [ $? -ne 0 ]; then err git install; fi
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}git ${COLOR_BLUE}successfully installed!${NO_COLOR}"

# ----- CURL -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Installing ${COLOR_GREEN}curl ${NO_COLOR}"
	( curl --version || wget --version || ( ${MANAGER} -y curl ) ) 1>/dev/null 2>/dev/null 3>/dev/null
	if [ $? -ne 0 ]; then err git install; fi
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}curl ${COLOR_BLUE}successfully installed!${NO_COLOR}"

# ----- ZSH -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Installing ${COLOR_GREEN}zsh ${NO_COLOR}"
	( zsh --version || ( ${MANAGER} -y zsh ) ) 1>/dev/null 2>/dev/null 3>/dev/null
	if [ $? -ne 0 ]; then err zsh install; fi
	
	[ "$SUDO_USER" != "" ] && chsh -s $(which zsh) $SUDO_USER || chsh -s $(which zsh) $USER
	if [ $? -ne 0 ]; then err zsh configure; fi
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}zsh ${COLOR_BLUE}successfully installed!${NO_COLOR}"

# ----- VIM -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Installing ${COLOR_GREEN}vim ${NO_COLOR}"
	( vim --version || ( ${MANAGER} -y vim ) ) 1>/dev/null 2>/dev/null 3>/dev/null
	if [ $? -ne 0 ]; then err vim install; fi
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}vim ${COLOR_BLUE}successfully installed!${NO_COLOR}"

# ----- VIM-PLUG -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Installing ${COLOR_GREEN}vim-plug ${NO_COLOR}"
	if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    ( curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ) 1>/dev/null 2>/dev/null 3>/dev/null
	  if [ $? -ne 0 ]; then err vim-plug install; fi
  fi
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}vim-plug ${COLOR_BLUE}successfully installed!${NO_COLOR}"

# ----- .VIMRC -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Configuring ${COLOR_GREEN}.vimrc ${NO_COLOR}"
  ( curl -o $HOME/.vimrc https://raw.githubusercontent.com/CosasDePuma/Setup/master/vim/.vimrc ) 1>/dev/null 2>/dev/null 3>/dev/null
  if [ $? -ne 0 ]; then err .vimrc configure; fi
  vim -c "PlugInstall" -c "q!" -c "q!"
  sed -i -e 's/" colorscheme/colorscheme/g' $HOME/.vimrc
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}.vimrc ${COLOR_BLUE}successfully configured!${NO_COLOR}"

# ----- OH-MY-ZSH -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Installing ${COLOR_GREEN}oh-my-zsh ${NO_COLOR}"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        ( git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh ) 1>/dev/null 2>/dev/null 3>/dev/null
	    if [ $? -ne 0 ]; then err oh-my-zsh download; fi
    fi
    if [ ! -f "$HOME/.zshrc" ]; then
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
        if [ $? -ne 0 ]; then err oh-my-zsh installing; fi  
    fi
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}oh-my-zsh ${COLOR_BLUE}successfully installed! ${NO_COLOR}"

# ----- BULLET-TRAIN ZSH THEME -----
echo "${BOLD}${COLOR_YELLOW}[.] ${COLOR_BLUE}Installing ${COLOR_GREEN}bullet-train zsh theme ${NO_COLOR}"
    ( curl -o $HOME/.oh-my-zsh/themes/bullet-train.zsh-theme https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme ) 1>/dev/null 2>/dev/null 3>/dev/null
    if [ $? -ne 0 ]; then err "bullet-train zsh theme" download; fi
    ( ${MANAGER} ttf-ancient-fonts fonts-powerline -y ) 1>/dev/null 2>/dev/null 3>/dev/null
    if [ $? -ne 0 ]; then err "bullet-train zsh theme" install; fi
    sed -i -e 's/ZSH_THEME="\w*/ZSH_THEME="bullet-train/g' $HOME/.zshrc
    
    if ! grep -q "BULLETTRAIN_PROMPT_ORDER" $HOME/.zshrc; then
        echo "BULLETTRAIN_PROMPT_ORDER=(\n\
    time            \n\
    status          \n\
    custom          \n\
    context         \n\
    dir             \n\
    # perl          \n\
    ruby            \n\
    virtualenv      \n\
    # nvm           \n\
    # aws           \n\
    # go            \n\
    # elixir        \n\
    git             \n\
    # hg            \n\
    cmd_exec_time   \n\
)" >> $HOME/.zshrc
    fi

    if [ $? -ne 0 ]; then err "bullet-train zsh theme" config; fi
echo "${BOLD}${COLOR_YELLOW}[✓] ${COLOR_GREEN}bullet-train zsh theme ${COLOR_BLUE}successfully installed! ${NO_COLOR}"

# >> PERMISSIONS
# -------------------
[ "$SUDO_USER" != "" ] && chown -R $SUDO_USER $HOME/.vim $HOME/.vimrc $HOME/.oh-my-zsh $HOME/.zshrc

# >> EXIT
# -------------------

echo "${BOLD}${COLOR_YELLOW}[!] ${COLOR_BLUE}All programs successfully installed. Please, close all your open terminals and/or reboot the computer... ${NO_COLOR}"
    exit
