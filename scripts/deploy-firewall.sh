#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DEFAULT_CONFIG="$REPO_DIR/firewall/nftables.conf"
LOCAL_CONFIG="$REPO_DIR/firewall/nftables.local.conf"

if [ ! -f "$LOCAL_CONFIG" ]; then
    echo "ERROR: Local firewall configuration not found:"
    echo "$LOCAL_CONFIG"
    echo
    echo "Create it from the default configuration:"
    echo "cp \"$DEFAULT_CONFIG\" \"$LOCAL_CONFIG\""
    exit 1
fi

SRC="$LOCAL_CONFIG"
DST="/etc/nftables.conf"
BACKUP="/etc/nftables.conf.$(date '+%Y%m%d-%H%M%S').backup"
ROLLBACK_SCRIPT="$REPO_DIR/scripts/rollback-firewall.sh"

echo "Using local firewall configuration: $SRC"

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
