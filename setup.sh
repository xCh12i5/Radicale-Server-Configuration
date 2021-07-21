#!/bin/bash

#-- Section: Basic setup -------------------------------------------------------

# Change initial passwort of root.
echo "Enter password for root."
passwd

# Update the system.
apt-get update
apt-get upgrade

# Install basic packages.
apt-get install language-pack-en language-pack-en-base nano iptables-persistent python3 python3-pip fail2ban nginx certbot python3-certbot-nginx

# Make English the default language.
echo "LANG=en_US.UTF-8" > /etc/default/locale
echo "LANGUAGE=en_US" >> /etc/default/locale
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
sed -i "s/de_DE.utf8/en_US.UTF-8/g" /etc/profile
locale-gen

# Configure .bashrc file.
sed -ri "s/#?.?alias ls='ls --color=.+$'/alias ls='ls --color=auto'/g" /etc/skel/.bashrc
sed -ri "s/#?.?alias grep='grep --color=.+?'/alias grep='grep --color=auto'/g" /etc/skel/.bashrc
sed -ri "s/#?.?alias ll='ls.+?'/alias ll='ls -Ahl --group-directories-first --color=auto'/g" /etc/skel/.bashrc
cp /etc/skel/.bashrc /root/.bashrc
sed -i "s/01;32m/01;31m/g" /root/.bashrc

#-- Section: Network configuration ---------------------------------------------

# Configure IPv4 firewall rules.
iptables -F
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

# Configure IPv6 firewall rules.
ip6tables -F
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT
ip6tables -P INPUT DROP
ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables-save > /etc/iptables/rules.v6

# Configure the network stack.
sed -i "/net.ipv4.conf.default.rp_filter=1/s/^#//g" /etc/sysctl.conf
sed -i "/net.ipv4.conf.all.rp_filter=1/s/^#//g" /etc/sysctl.conf
echo "net.ipv4.tcp_timestamps=0" >> /etc/sysctl.conf

#-- Section: Finalize setup ----------------------------------------------------

# Add default user.
useradd -s /bin/bash -m CHANGEME
echo "Enter password for CHANGEME."
passwd CHANGEME
groupadd ssh-user
usermod -a -G ssh-user CHANGEME

# Clean up the system.
apt-get purge language-pack-de language-pack-de-base
apt-get autoremove
apt-get autoclean
apt-get clean
