#!/bin/bash

set -e

SRC="$HOME/devops-lab/firewall/nftables.conf"
DST="/etc/nftables.conf"
BACKUP="/etc/nftables.conf.$(date '+%Y%m%d-%H%M%S').backup"
ROLLBACK_SCRIPT="$HOME/devops-lab/scripts/rollback-firewall.sh"

echo "1. Validate configuration"
sudo nft -c -f "$SRC"

echo "2. Backup current configuration"
sudo cp "$DST" "$BACKUP"

echo "Backup created: $BACKUP"

echo "3. Schedule automatic rollback in 2 minutes"
sudo systemd-run \
  --unit=firewall-rollback \
  --on-active=2m \
  "$ROLLBACK_SCRIPT" "$BACKUP"

echo "4. Deploy new configuration"
sudo install -o root -g root -m 644 "$SRC" "$DST"

echo "5. Apply nftables configuration"
sudo nft -f "$DST"

echo "6. Show active ruleset"
sudo nft list ruleset

echo
echo "Firewall deployment completed."
echo "Backup: $BACKUP"
echo "If everything works, cancel rollback with:"
echo "sudo systemctl stop firewall-rollback.timer"
