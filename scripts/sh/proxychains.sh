#!/bin/sh
# shellcheck disable=SC1091

# Import the core utils
test -z "$SETUP_CORE_REMOTE" && SETUP_CORE_REMOTE=https://raw.githubusercontent.com/CosasDePuma/Setup/real-config/.config.sh
export SETUP_CORE_REMOTE
if test -f ~/.core.sh; then . ~/.core.sh; else curl -fso ~/.core.sh "$SETUP_CORE_REMOTE"; fi
if test -f $(dirname "$0")/.core.sh; then . $(dirname "$0")/.core.sh; else . ~/.core.sh; fi

# Tor configuration file
test -z "$TOR_CONF" && TOR_CONF=/etc/tor/torrc
export TOR_CONF
# Proxychains configuration file
test -z "$PROXYCHAINS_CONF" && PROXYCHAINS_CONF=/etc/proxychains.conf
export PROXYCHAINS_CONF

# Check permissions
checkroot

# Install tor
pkgget tor
# Install proxychains
pkgget proxychains

# Configuring tor
bckup "$TOR_CONF"
printf 'SocksPort 0.0.0.0:9050' > "$TOR_CONF"

# Configuring proxychains
bckup "$PROXYCHAINS_CONF"
printf '# Proxychains configuration by @CosasDePuma\n\n' > "$PROXYCHAINS_CONF"
printf '# Skip dead proxies\ndynamic_chain\n# Proxy DNS request (no leak for DNS data)\nproxy_dns\n# Quiet mode\n#quiet_mode\n# Timeouts in millisecons\ntcp_read_time_out 15000\ntcp_connect_time_out 8000\n\n' >> "$PROXYCHAINS_CONF"
printf '# Proxy list (Local Tor proxy)\n[ProxyList]\nsocks5	127.0.0.1 9050 # tor\n' >> "$PROXYCHAINS_CONF"

# Start tor service
dbgmsg "Starting tor service"
blackhole service tor start || errlog "tor service cannot be started"

# Check command
checkcmd proxychains || errlog "proxychains cannot be found"
# Done
ggwp