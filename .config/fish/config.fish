if status is-interactive

    # +----------------------------------+
    # |             Homebrew             |
    # +----------------------------------+
    # Package manager for macOS and Linux
    # https://brew.sh/

    if test -x /opt/homebrew/bin/brew
        set -gx HOMEBREW_NO_ANALYTICS 1
        fish_add_path /opt/homebrew/bin
        eval (/opt/homebrew/bin/brew shellenv)
    end

    # +----------------------------------+
    # |               Bat                |
    # +----------------------------------+
    # Better `cat` command with syntax highlighting
    # https://github.com/sharkdp/bat

    if type -q bat
        alias cat="bat --style=plain --color=always --paging=never"
        abbr -a --position anywhere -- -h '-h | bat -plhelp'
        abbr -a --position anywhere -- --help '--help | bat -plhelp'
    end

    # +----------------------------------+
    # |              Direnv              |
    # +----------------------------------+
    # Environment switcher for the shell
    # https://direnv.net/

    if type -q direnv
      direnv hook fish | source
    end


    # +----------------------------------+
    # |               LSD                |
    # +----------------------------------+
    # Modern replacement for `ls` with colors and icons
    # https://github.com/lsd-rs/lsd

    if type -q lsd
        alias l="lsd --color=always"
        alias ls="lsd --color=always"
        alias ll="lsd -l --color=always"
        alias la="lsd -la --color=always"
    end

    # +----------------------------------+
    # |             Starship             |
    # +----------------------------------+
    # Cross-shell prompt for any shell
    # https://starship.rs/

    if type -q starship
        starship init fish | source
    end

    # +----------------------------------+
    # |              Zoxide              |
    # +----------------------------------+
    # Smart directory jumper
    # https://github.com/ajeetdsouza/zoxide

    if type -q zoxide
        zoxide init fish --cmd cd | source
    end

end

