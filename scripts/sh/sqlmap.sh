#!/bin/sh

# Logging file
log=$(mktemp)

# Install function
finstall()
{
	echo "[*] Checking $1 installation..."
	if dpkg -l $1 > /dev/null
	then
		echo "[+] $1 already installed"
	else
		echo "[*] Installing $1..."
		apt-get install -y "${1}" 2>&1 1>"${log}"
	fi
}

# Custom command function
command()
{
	# Comprobamos si existen los custom commands
	if test ! -f $HOME/.commands
	then
		echo "# Custom commands by @CosasDePuma" > $HOME/.commands
		echo "source $HOME/.commands" >> $HOME/.profile
	fi

	# Añadimos el comando
	if test $(cat $HOME/.commands | grep -c sqlmapanon) -eq 0
	then
		echo "alias sqlmapanon='sqlmap --tor --tor-type=SOCKS5 --check-tor --random-agent'" >> $HOME/.commands
	fi

	# Damos permisos a los custom commands
	chown $USER:$USER $HOME/.commands
}

# Error function
error() { echo "[!] ${1}" && cat "${log}" && exit 1; }

# Check root
test "$(id -u)" -ne 0 && error "[!] You must run this script as root!"

# Check the tools folder
test -d /tools || mkdir /tools

# Download and install proxychains and tor
finstall curl || error "curl cannot be installed"
curl -fsSL https://raw.githubusercontent.com/CosasDePuma/Setup/real-config/scripts/sh/proxychains.sh | sh

# Download sqlmap
echo "[*] Downloading sqlmap..."
finstall git || error "git cannot be installed"
if test ! -d /tools/sqlmap
then
	git clone -q https://github.com/sqlmapproject/sqlmap /tools/sqlmap || error "cannot download sqlmap"
	chown -R $USER:$USER /tools
fi

# Install sqlmap
echo "[*] Installing sqlmap..."
test -e /usr/bin/sqlmap || ln -s /tools/sqlmap/sqlmap.py /usr/bin/sqlmap || error "cannot install sqlmap"
echo "[+] sqlmap installed"

# Create the custom command
echo "[+] Creating custom command"
command

# Done
echo "[+] All correctly done!"
