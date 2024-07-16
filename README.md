# DASH SCRIPT FOR INSTALL WAZUH-AGENT
After download and extract install wazuh-agent without running two codes!
Use:
```sh
fetch https://github.com/julioliraup/wazuh-agent-pfsense/archive/refs/heads/main.zip
unzip main.zip
cd wazuh-agent-pfsense-main/
sh main.sh <WAZUH-MANAGER-ADDRESS>
```
> WAZUH MANAGER ADDRESS: set IP or domain (FQDN) with argument

## TROUBLESHOOT
If dont show packages repo
```sh
pkg install -fy pkg pfSense-repo pfSense-upgrade
```
