#!/bin/sh
# shellcheck disable=SC1091

# Import the core utils
test -z "$SETUP_CORE_REMOTE" && SETUP_CORE_REMOTE=https://raw.githubusercontent.com/CosasDePuma/Setup/real-config/.config.sh
export SETUP_CORE_REMOTE
if test -f ~/.core.sh; then . ~/.core.sh; else curl -fso ~/.core.sh "$SETUP_CORE_REMOTE"; fi
if test -f $(dirname "$0")/.core.sh; then . $(dirname "$0")/.core.sh; else . ~/.core.sh; fi

# RustUp Repository
test -z "$RUSTUP_LINK" && RUSTUP_LINK=https://sh.rustup.rs
export RUSTUP_LINK

# Install rustup
dbgmsg 'Installing rustup with an external script'
xternsdwnld "$RUSTUP_LINK" -y

# Check command
. $HOME/.cargo/env	|| errlog "rust cannot be installed correctly"
checkcmd rustc		|| errlog "rust cannot be found"

# Done
ggwp