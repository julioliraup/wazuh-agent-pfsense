#!/bin/sh

_fatal_error () {
  echo -e "\033[0;33merror: $1\033[0m"
  exit 1
}

_success () {
  echo -e "\033[0;32mSuccess: $1\033[0m"
}

_change_repo_freebsd_to () {
  [ "$1" == "yes" ] && expression='s/FreeBSD: { enabled: no/FreeBSD: { enabled: yes/' || expression='s/FreeBSD: { enabled: yes/FreeBSD: { enabled: no/'
  [ "$1" == "yes" ] && actual="no" || actual="yes"

  dir="/usr/local/etc/pkg/repos"

  for file in $dir/*.conf; do
    if grep -q "FreeBSD: { enabled: $actual" "$file"; then
      sed -i "" -e "$expression" "$file"
      if [ "$?" == "1" ];then
        sed -i "" -e "$expression" /usr/local/etc/pfSense/pkg/repos/*.conf || _fatal_error "file in /usr/local/etc/pfSense/pkg/repos/ not changed"
      fi
      echo "$file: Package FreeBSD are changed"
    else
      echo "$file Not found pattern of FreeBSD section"
    fi
  done
  if grep -q -r "FreeBSD: { enabled: $actual" $dir; then
    grep -r "FreeBSD: { enabled: $actual" $dir --color
    _fatal_error "Do not changed FreeBSD packages"
  fi
}

[ "$1" == "--help" ] && echo "USE: $0 <WAZUH-SERVER>"
[ "$1" == "" ] && _fatal_error "USE: $0 <WAZUH-SERVER>"

_change_repo_freebsd_to "yes" && _success "Enabled packages FreeBSD"
echo "y" | pkg update -q && _success "Updated packages" || echo "[Warning] Do not update system. Run: pkg update -f"
wazuh_version=$(pkg search -q "^wazuh-agent") && _success "Found $wazuh_version" || _fatal_error "Do no found wazuh-agent. Check repo version"
pkg install -qy "$wazuh_version" && _success "$wazuh_version installed" || _fatal_error "Do no install $wazuh_version. Run pkg install $wazuh_version"
_change_repo_freebsd_to "no" && _success "FreeBSD repo are disabled" || _fatal_error "Disable FreeBSD repo for do not problems"
echo "y" | pkg clean -yq && _success "Removing unless packages" || _fatal_error "Do no clean system"
echo "y" | pkg update -yq && _success "Update packages" || _fatal_error "Check your connection"
cp /etc/localtime /var/ossec/etc/
sed -i '' -e "s/>IP</>$1</" /var/ossec/etc/ossec.conf
sed -i '' -e 's/>udp</>tcp</' /var/ossec/etc/ossec.conf
sysrc wazuh_agent_enable="YES" || _fatal_error "Install sysrc and try: sysrc wazuh_agent_enable='YES'"
ln -s /usr/local/etc/rc.d/wazuh-agent /usr/local/etc/rc.d/wazuh-agent.sh
service wazuh-agent start
echo "0 4 * * * find /var/ossec/logs/ossec/ -d 1 -mtime +30 -type d -exec rm -rf {} \; > /dev/null" >> /etc/cron.d/wazuh-log.cron _success "Wazuh-agent online"
