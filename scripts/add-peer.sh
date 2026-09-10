#!/bin/bash

# Add WireGuard Peer (Client) Script
# Usage: ./add-peer.sh <peer-name>

if [ -z "$1" ]; then
    echo "Usage: ./add-peer.sh <peer-name>"
    echo "Example: ./add-peer.sh client1"
    exit 1
fi

PEER_NAME=$1
CONFIG_DIR="./wireguard-config"

echo "➕ Adding new WireGuard peer: $PEER_NAME"

# Access container and add peer
docker-compose exec -T wireguard bash -c \
    "wg genkey | tee /tmp/${PEER_NAME}_private.key | wg pubkey > /tmp/${PEER_NAME}_public.key"

echo "✅ Peer added: $PEER_NAME"
echo "📄 Private key: $(docker-compose exec -T wireguard cat /tmp/${PEER_NAME}_private.key)"
echo "📄 Public key: $(docker-compose exec -T wireguard cat /tmp/${PEER_NAME}_public.key)"
echo ""
echo "ℹ️  Add this to your peer config file"
