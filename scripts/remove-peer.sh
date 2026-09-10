#!/bin/bash

# Remove WireGuard Peer (Client) Script
# Usage: ./remove-peer.sh <peer-name>

if [ -z "$1" ]; then
    echo "Usage: ./remove-peer.sh <peer-name>"
    echo "Example: ./remove-peer.sh client1"
    exit 1
fi

PEER_NAME=$1
CONFIG_FILE="./wireguard-config/peers/${PEER_NAME}.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Peer config not found: $CONFIG_FILE"
    exit 1
fi

echo "🗑️  Removing WireGuard peer: $PEER_NAME"
rm -f "$CONFIG_FILE"

echo "✅ Peer removed: $PEER_NAME"
echo "🔄 Restart WireGuard to apply changes"
