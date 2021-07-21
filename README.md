cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
nano /etc/ssh/sshd_config
systemctl restart ssh.service
python3 -m pip install --upgrade radicale
useradd --system --user-group --home-dir / --shell /sbin/nologin radicale
mkdir -p /etc/radicale/
mkdir -p /var/lib/radicale/collections/
chown -R radicale:radicale /var/lib/radicale/collections/
chmod -R o= /var/lib/radicale/collections/
openssl passwd -6
nano /etc/nginx/htpasswd
chmod u=rw /etc/nginx/htpasswd
nano /etc/radicale/config
nano /lib/systemd/system/radicale.service
ln -s /lib/systemd/system/radicale.service /etc/systemd/system/radicale.service
nano /etc/nginx/nginx.conf

    server_tokens off;

unlink /etc/nginx/modules-enabled/50-mod-http-geoip.conf
unlink /etc/nginx/modules-enabled/50-mod-mail.conf
unlink /etc/nginx/sites-enabled/default
nano /etc/nginx/sites-available/reverse-proxy.conf
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
systemctl restart nginx.service
certbot --agree-tos --nginx -d CHANGEME
nano /etc/letsencrypt/options-ssl-nginx.conf
systemctl start radicale.service
systemctl enable radicale.service
systemctl daemon-reload
systemctl restart nginx.service
certbot renew --dry-run

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
nano /etc/fail2ban/jail.local

    ignoreip = 127.0.0.1/8 ::1

    [sshd]
    enabled = true
    port    = ssh

    [nginx-http-auth]
    enabled = true
    filter  = nginx-http-auth

systemctl daemon-reload
systemctl restart fail2ban.service
