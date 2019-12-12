#!/bin/sh

# Proxychains configuration file
proxychains_conf=/etc/proxychains.conf

# Logging file
log=$(mktemp)

# Install function
finstall()
{
	echo "[*] Checking $1 installation..."
	if ! dpkg -l $1 > /dev/null
	then
		echo "[+] $1 already installed"
	else
		echo "[*] Installing $1..."
		apt-get install -y "${1}" 2>&1 1>"${log}"
	fi
}

# Error function
error() { echo "${1}" && cat "${log}" && exit 1; }

# Check root
test "$(id -u)" -ne 0 && error "[!] You must run this script as root!"

# Install tor
finstall tor			|| error "[!] tor cannot be installed"
finstall proxychains		|| error "[!] proxychains cannot be installed"

# Start tor service
service tor start 2>&1 1>"${log}" || error "[!] Tor cannot be started"

# Configure proxychains
echo "[*] Configuring proxychains..."
mv "${proxychains_conf}" "${proxychains_conf}".old
cat << EOF_CONF > "${proxychains_conf}"
# Proxychain configuration by @CosasDePuma

# Skip dead proxies
dynamic_chain
# Proxy DNS request (no leak for DNS data)
proxy_dns
# Quiet mode
#quiet_mode
# Timeouts in millisecons
tcp_read_time_out 15000
tcp_connect_time_out 8000

# Proxy list (Local Tor proxy)
[ProxyList]
socks5	127.0.0.1 9050
EOF_CONF

# Done
echo "[+] All correctly done!"
