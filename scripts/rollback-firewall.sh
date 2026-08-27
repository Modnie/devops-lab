#!/bin/bash

set -e

BACKUP="$1"
DST="/etc/nftables.conf"

if [ -z "$BACKUP" ]; then
    echo "Usage: $0 BACKUP_FILE"
    exit 1
fi

echo "Restoring firewall backup: $BACKUP"

cp "$BACKUP" "$DST"
nft -f "$DST"

echo "Firewall rollback completed"
