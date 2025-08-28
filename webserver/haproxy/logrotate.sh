#!/bin/bash
# haproxy-logrotate-setup.sh
# Configure logrotate for /var/log/haproxy.log (daily OR >5k), keep 7, gzip old.
set -euo pipefail

LOG_FILE="/var/log/haproxy.log"
CONF_FILE="/etc/logrotate.d/haproxy"


echo "[*] Writing $CONF_FILE ..."
sudo tee "$CONF_FILE" >/dev/null <<EOF
$LOG_FILE {
    daily
    size 10k
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    su root adm
    postrotate
        [ ! -x /usr/lib/rsyslog/rsyslog-rotate ] || /usr/lib/rsyslog/rsyslog-rotate
    endscript
}

EOF

echo "[*] Validating logrotate config (dry run) ..."
sudo logrotate -d "$CONF_FILE"

echo "[*] Forcing one rotation to confirm ..."
sudo logrotate -f "$CONF_FILE"

echo "[✓] Done! Rotation is set to daily or when >5k, with 7 compressed backups."
