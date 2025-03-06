# alias_wizard
A simple bash alias creator that shortens the time of Linux system administration.
Beware, highly customized for my needs and may be useless or confusing for you.

Three ready-made modules: net, ipt and ovpn

It is made by taking a short structure that is very abbreviated for many uses:
```bash
$ <service>-<action>[-<type>][-<any>]
```

Some examples:
```bash
$ ovpn-stat-c         'sudo systemctl status openvpn-client@client'
$ ovpn-conf-s         'sudo joe /etc/openvpn/server/server.conf'
$ ovpn-conf-s-000     'sudo joe /etc/openvpn/server/server000.conf'
$ ovpn-rest-s-1       'sudo systemctl restart openvpn-server@server1'
$ net-stat-e          'sudo netstat -tn | grep ESTABLISHED'
$ net-stat-l          'sudo netstat -tlnp'
$ net-stat-i          'sudo netstat -i'
...more!
```

Net module (ip, traceroute, netstat, arp, tcpdump, netplan) passing params:
```bash
$ net-dp-h-1.1.1.1    'sudo tcpdump host 1.1.1.1'
$ net-dp-if-eth0      'sudo tcpdump -i eth0'
$ net-dp-t-80         'sudo tcpdump proto tcp port 80'
$ net-dp-u-161        'sudo tcpdump proto udp port 161'
...
```
Warning: defaults are 'joe' text editor and network file /etc/netplan/50-cloud-init.yaml. 
(I will make it configurable soon but you can easily customize it through the module files)
```bash
$ net-conf            'sudo joe /etc/netplan/50-cloud-init.yaml'
$ net-try             'sudo netplan try'
...
```

Installation

1. Clone the repo:
```bash
git clone https://github.com/muriloat/.alias_wizard.git
```

2. Make the scripts executable:
```bash
chmod +x ~/.alias_wizard/loader.sh ~/.alias_wizard/handler.sh
```

5. Add the loader lines to your `.bash_aliases` file.
```bash
nano ~/.bash_aliases
```
Add:

```bash
# Load the Alias Wizard
if [ -f "$HOME/.alias_wizard/loader.sh" ]; then
    source "$HOME/.alias_wizard/loader.sh"
fi
```

6. Enable the modules:
```
cd ~/.alias_wizard
bash handler.sh enable ipt
bash handler.sh enable ovpn
bash handler.sh enable net
bash handler.sh list
```
```
Available modules:
  ipt [enabled]
  net [enabled]
  ovpn [enabled]
cd ~
```
* Check another options: disable, status, show

7. Source your `.bashrc` to apply changes:
```bash
source ~/.bashrc
```

8. Try some net aliases. Usage Examples:

```bash
$ ipt-list
$ ipt-list-nat
$ ovpn-conf-c
$ ovpn-rest-s
$ net-arp
$ net-cat
$ net-sh
$ net-test
```
9. Or type anything at any level for help:

```bash
$ net-s
Unknown action: s for service: net
Available actions:
  - conf
  - test
  - rest
  - cat
  - sh [t-TABLE]
  - ipr
  - ipra-PREFIX-TABLE
  - iprd-PREFIX-TABLE
  - if-[sh|u-DEV|d-DEV|r-DEV]
  - irad-IP
  - irdd-IP
  - tr-IP
  - stat [e|l|i]
  - dp-[h-IP|if-INTERFACE|t-PORT|u-PORT]
  - arp [DEV|del-IP]
  - scan-PREFIX
$ 
```