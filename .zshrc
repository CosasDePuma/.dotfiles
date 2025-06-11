# +----------------------------------+
# |             Homebrew             |
# +----------------------------------+
# Package manager for macOS and Linux
# https://brew.sh/

test -x /opt/homebrew/bin/brew && {
  export HOMEBREW_NO_ANALYTICS=1
  export PATH="${PATH}:/opt/homebrew/bin"
  eval $(/opt/homebrew/bin/brew shellenv)
}

# +----------------------------------+
# |               Bat                |
# +----------------------------------+
# Better `cat` command with syntax highlighting
# https://github.com/sharkdp/bat

command -v bat >/dev/null 2>&1 && {
  alias -- cat='bat --style=plain --color=always --paging=never'
  alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
}

# +----------------------------------+
# |               LSD                |
# +----------------------------------+
# Modern replacement for `ls` with colors and icons
# https://github.com/lsd-rs/lsd

command -v lsd >/dev/null 2>&1 && {
  alias -- l='lsd --color=always'
  alias -- ls='lsd --color=always'
  alias -- ll='lsd -l --color=always'
  alias -- la='lsd -la --color=always'
}

# +----------------------------------+
# |             Starship             |
# +----------------------------------+
# Cross-shell prompt for any shell
# https://starship.rs/

command -v starship >/dev/null 2>&1 && {
  eval "$(starship init zsh)"
}

# +----------------------------------+
# |              Zoxide              |
# +----------------------------------+
# Smart directory jumper
# https://github.com/ajeetdsouza/zoxide

command -v zoxide >/dev/null 2>&1 && {
  eval "$(zoxide init zsh --cmd cd)"
}
