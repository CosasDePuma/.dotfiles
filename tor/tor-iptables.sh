#! /bin/bash

set -e


if [ "$(id -u)" != "0" ]; then
	echo "${BOLD}${COLOR_WHITE}${BACKGROUND_RED}ERROR: You must be root${NO_COLOR}"
	return 1
fi


tor_uid=$(docker exec -u torproxy tor id -u || echo 1000)


trans_port="9050"
dns_port="5353"


action="-A"
if iptables -t nat -C OUTPUT -p tcp --syn -j REDIRECT --to-ports "$trans_port" 2>/dev/null ; then
	echo "[WARNING]: DELETING iptables rules for tor redirection."
	echo "If this was not your intent, rerun this script to append the rules again."
    action="-D"
else
	echo "APPENDING iptables rules for tor redirection."
fi


iptables -t nat "$action" OUTPUT -m owner --uid-owner "$tor_uid" -j RETURN
ptables -t nat "$action" OUTPUT -p udp --dport 53 -j REDIRECT --to-ports "$dns_port"

for clearnet in 127.0.0.0/9 127.128.0.0/10; do
		iptables -t nat "$action" OUTPUT -d "$clearnet" -j RETURN
done

iptables -t nat "$action" OUTPUT -p tcp --syn -j REDIRECT --to-ports "$trans_port"
iptables "$action" OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

for clearnet in 127.0.0.0/8; do
		iptables "$action" OUTPUT -d "$clearnet" -j ACCEPT
done

iptables "$action" OUTPUT -m owner --uid-owner "$tor_uid" -j ACCEPT
iptables "$action" OUTPUT -j REJECT
