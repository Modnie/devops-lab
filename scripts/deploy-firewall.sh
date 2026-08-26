#!/bin/bash

set -e

SRC="$HOME/devops-lab/firewall/nftables.conf"
DST="/etc/nftables.conf"
BACKUP="/etc/nftables.conf.backup"

echo "1. Validate configuration"
sudo nft -c -f "$SRC"

echo "2. Backup current configuration"
sudo cp "$DST" "$BACKUP"

echo "3. Deploy new configuration"
sudo cp "$SRC" "$DST"

echo "4. Apply nftables configuration"
sudo nft -f "$DST"

echo "5. Show active ruleset"
sudo nft list ruleset

echo "Firewall deployment completed successfully"
