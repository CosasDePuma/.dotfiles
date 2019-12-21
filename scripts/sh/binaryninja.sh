#!/bin/sh
# shellcheck disable=SC1091

# Import the core utils
test -z "$SETUP_CORE_REMOTE" && SETUP_CORE_REMOTE=https://raw.githubusercontent.com/CosasDePuma/Setup/real-config/.config.sh
export SETUP_CORE_REMOTE
if test -f ~/.core.sh; then . ~/.core.sh; else curl -fso ~/.core.sh "$SETUP_CORE_REMOTE"; fi
if test -f $(dirname "$0")/.core.sh; then . $(dirname "$0")/.core.sh; else . ~/.core.sh; fi

# BinaryNinja Repository
test -z "$BINARYNINJA_LINK" && BINARYNINJA_LINK=https://cdn.binary.ninja/installers/BinaryNinja-demo.zip
export BINARYNINJA_LINK

# Check permissions
checkroot

# Download the binary
dbgmsg 'Downloading release'
xternsdwnld "$BINARYNINJA_LINK"

# Unzip the binary
dbgmsg 'Unzipping the binary'
unziptool
owntool binaryninja

# Create a symlink
blackhole ln -sf "$TOOLS_DIR"/binaryninja/binaryninja /usr/bin/binaryninja

# Check command
checkcmd binaryninja || errlog "binaryninja cannot be found"
# Done
ggwp