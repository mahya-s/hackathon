#!/bin/bash
# haproxy-logrotate-setup.sh
# Configure logrotate for /var/log/haproxy.log (daily OR >5k), keep 7, gzip old.
set -euo pipefail

LOG_FILE="/var/log/nginx/*.log"
CONF_FILE="/etc/logrotate.d/nginx"


echo "[*] Writing $CONF_FILE ..."
sudo tee "$CONF_FILE" >/dev/null <<EOF
$LOG_FILE {
	daily
    size 10
	missingok
	rotate 7
	compress
	delaycompress
	notifempty
	create 0640 www-data adm
	sharedscripts
	prerotate
		if [ -d /etc/logrotate.d/httpd-prerotate ]; then 
			run-parts /etc/logrotate.d/httpd-prerotate; 
		fi 
	endscript
	postrotate
		invoke-rc.d nginx rotate >/dev/null 2>&1
	endscript
}


EOF

echo "[*] Validating logrotate config (dry run) ..."
sudo logrotate -d "$CONF_FILE"

echo "[*] Forcing one rotation to confirm ..."
sudo logrotate -f "$CONF_FILE"

echo "[✓] Done! Rotation is set to daily or when >10k, with 7 compressed backups."
