#!/bin/sh

# Debug messages
debug() { printf '\n-------------- DEBUG ---------------\nSTDOUT => %s\nSTDERR => %s\nTMP_CURL => %s\n\n' "$LOG_OUT" "$LOG_ERR" "$TMP_CURL"; }
# Success message
okmsg() { printf '[+] %s\n' "$1"; }
# Information message
dbgmsg() { printf '[?] %s...\n' "$1"; }
# Error message
errmsg() { printf '[!] %s\n' "$1"; exit 1; }
errlog() { printf '[!] %s\n\n[?] Traceback:\n%s\n\nFor more information, read %s and %s files\n' "$1" "$(cat "$LOG_ERR")" "$LOG_OUT" "$LOG_ERR"; exit 1; }
# Privilege verficiation
checkroot() { test "$(id -u)" -eq 0 || errmsg 'You must run this script as root!'; }
# Logging alias
blackhole() { eval "$@" 1>>"$LOG_OUT" 2>>"$LOG_ERR"; }
# Check if a command/program is installed (silently)
silentcheck() { blackhole pathcheck "$1"; }
# Check if a command/program is installed
pathcheck() { command -v "$1"; }
# Check if a command/program is installed (verbose)
checkcmd() { dbgmsg "Checking $1"; silentcheck "$1"; }
# Install a program via package manager
pkginst() { dbgmsg "Installing $1"; if blackhole "$PCK_MNGR" install -y "${1}"; then okmsg "$1 installed!"; else errlog "$1 cannot be installed"; fi; }
# Install a program via package manager if it is not installed
pkgget() { checkcmd "$1" || pkginst "$1"; }
# Install vía online script (http)
xterndwnld() { blackhole curl -o "$TMP_CURL" "$1"; }
# Install vía online script (https)
xternsdwnld() { blackhole curl --proto '=https' --tlsv1.2 -o "$TMP_CURL" "$1"; }
# Check if the download was correctly done
checkdwnld() { test -f "$TMP_CURL" || errlog 'Must run xterndwnld before executing $0'; }
# Install a zip binary in the tools directory
unziptool() { checkdwnld; pkgget zip; test -d "$TOOLS_DIR" || mkdir "$TOOLS_DIR"; blackhole unzip -od "$TOOLS_DIR" "$TMP_CURL" || errlog "Cannot unzip the file";  }
# Retrieve the ownership of the tools to the user
owntool() { chown -R "$USER":"$USER" "$TOOLS_DIR"/"$1"; }
# Install a program via script
shinstall() { checkdwnld; if blackhole sh "$TMP_CURL" "$@"; then okmsg 'Correctly installed'; else errlog 'Cannot install the program using the script'; fi; }
# Copy the file appending .old.bck extension
bckup() { cp "$1" "$1".old.bck; }
# Success exit message
ggwp() { okmsg 'Done!'; exit 0; }

# Log files
LOG_OUT="$(mktemp)"
export LOG_OUT
LOG_ERR="$(mktemp)"
# Curl temporally file
TMP_CURL="/tmp/file"
export TMP_CURL
# Package Manager
PCK_MNGR="$(pathcheck apt-get)" # || pathcheck yum || pathcheck pacman || pathcheck snap)"
export PCK_MNGR
# Tools directory
TOOLS_DIR=/tools/
export TOOLS_DIR

# Requirements
test -n "$PCK_MNGR" || errmsg 'No available package manager'