# ===============================================

# +----------------------------------+
# |             Cleaning             |
# +----------------------------------+
# Remove unnecessary files and directories

test -f ~/.zshenv      && rm -f ~/.zshenv
test -f ~/.zprofile    && rm -f ~/.zprofile
test -f ~/.zshrc.local && rm -f ~/.zshrc.local

# ===============================================

# +----------------------------------+
# |               Bat                |
# +----------------------------------+
# Better `cat` command with syntax highlighting
# 🦇 https://github.com/sharkdp/bat

command -v bat >/dev/null 2>&1 && {
  alias -- cat='bat --style=plain --color=always --paging=never'
  alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
}

# +----------------------------------+
# |             Homebrew             |
# +----------------------------------+
# Package manager for macOS
# 🍺 https://brew.sh/

test -x /opt/homebrew/bin/brew && {
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

# +----------------------------------+
# |               Lsd                |
# +----------------------------------+
# Modern replacement for `ls` with colors and icons
# 💊 https://github.com/lsd-rs/lsd

command -v lsd >/dev/null 2>&1 && {
  alias -- l='lsd --color=always'
  alias -- ls='lsd --color=always'
  alias -- ll='lsd -l --color=always'
  alias -- la='lsd -la --color=always'
}

# +----------------------------------+
# |             OrbStack             |
# +----------------------------------+
# Lightweight Docker alternative for macOS
# 🔮 https://orbstack.dev/

test -f ~/.orbstack/shell/init.zsh && {
  source ~/.orbstack/shell/init.zsh
}

# +----------------------------------+
# |             Starship             |
# +----------------------------------+
# Cross-shell prompt for any shell
# 🚀 https://starship.rs/

command -v starship >/dev/null 2>&1 && {
  eval "$(starship init zsh)"
}

# +----------------------------------+
# |              Zoxide              |
# +----------------------------------+
# Smart directory jumper
# 🦓 https://github.com/ajeetdsouza/zoxide

command -v zoxide >/dev/null 2>&1 && {
  eval "$(zoxide init zsh --cmd cd)"
}

# ===============================================

# +----------------------------------+
# |             Binaries             |
# +----------------------------------+
# Add custom binary paths to PATH

# Programming language: 🐻‍❄️ Golang
test -d "${HOME}/go/bin" && export PATH="${PATH}:${HOME}/go/bin"

# Programming language: 🐍 Python
test -d "${HOME}/.local/bin" && export PATH="${PATH}:${HOME}/.local/bin"

# Programming language: 🦀 Rust
test -d "${HOME}/.cargo/bin" && export PATH="${PATH}:${HOME}/.cargo/bin"
