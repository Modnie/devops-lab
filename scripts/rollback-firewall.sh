#!/bin/bash

set -e

BACKUP="/etc/nftables.conf.backup"
DST="/etc/nftables.conf"

echo "Restoring firewall backup"

cp "$BACKUP" "$DST"
nft -f "$DST"

echo "Firewall rollback completed"
