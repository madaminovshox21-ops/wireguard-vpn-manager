# Customization Guide 🛠️

## Adding Features

### 1. User Authentication

**File: `wireguard-config/auth.conf`**

```bash
# Add user management
docker-compose exec wireguard useradd -m -s /bin/bash newuser
docker-compose exec wireguard passwd newuser
```

### 2. Traffic Monitoring

**Add to docker-compose.yml:**

```yaml
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

### 3. Rate Limiting

**File: `scripts/rate-limit.sh`**

```bash
#!/bin/bash

# Limit bandwidth per peer
docker-compose exec wireguard tc qdisc add dev eth0 root tbf \
  rate 10mbit burst 32kbit latency 400ms
```

### 4. Peer Scheduling

**File: `scripts/schedule-peer.sh`**

```bash
#!/bin/bash

# Enable/disable peer at specific times
# Add to crontab for automation

PEER=$1
ACTION=$2  # enable/disable

if [ "$ACTION" = "enable" ]; then
    docker-compose exec wireguard wg set wg0 peer $PEER up
else
    docker-compose exec wireguard wg set wg0 peer $PEER down
fi
```

### 5. API Integration

**Create: `api/app.py`**

```python
from flask import Flask, jsonify, request
import docker

app = Flask(__name__)
client = docker.from_env()

@app.route('/api/peers', methods=['GET'])
def get_peers():
    """Get all active peers"""
    container = client.containers.get('wireguard')
    result = container.exec_run('wg show all peers')
    return jsonify({'peers': result.output.decode()})

@app.route('/api/peer', methods=['POST'])
def add_peer():
    """Add new peer"""
    data = request.json
    peer_name = data.get('name')
    # Implementation here
    return jsonify({'status': 'success', 'peer': peer_name})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### 6. Bandwidth Monitoring

**File: `docker-compose.monitoring.yml`**

```yaml
services:
  influxdb:
    image: influxdb:latest
    ports:
      - "8086:8086"
    environment:
      - INFLUXDB_DB=wireguard

  telegraf:
    image: telegraf:latest
    volumes:
      - ./telegraf.conf:/etc/telegraf/telegraf.conf
    depends_on:
      - influxdb
```

## Environment Variables

### Core Configuration

```bash
SERVER_IP=your-domain.com           # VPN server address
SERVER_PORT=51820                   # VPN port
INTERNAL_SUBNET=10.0.0.0            # VPN subnet
PEERS=5                             # Number of peers
PEERDNS=8.8.8.8                     # DNS servers
```

### Security Variables

```bash
ADMIN_USERNAME=admin                # Dashboard user
ADMIN_PASSWORD=secure-pass          # Dashboard password
PRIVATE_KEY_LENGTH=32               # Key length in bytes
```

### Performance Variables

```bash
MTU=1420                            # Maximum transmission unit
KEEPALIVE=25                        # Keepalive interval
BUFFER_SIZE=262144                  # Network buffer size
```

## Network Configuration

### Custom Subnet

```bash
# Change INTERNAL_SUBNET in docker-compose.yml
# Example: 192.168.100.0/24

INTERNAL_SUBNET=192.168.100.0
```

### IPv6 Support

```bash
# Add to wireguard environment
- IPV6_ENABLED=1
- IPV6_SUBNET=fd00::/64
```

### DNS Configuration

```bash
# Multiple DNS servers
PEERDNS=1.1.1.1,1.0.0.1,8.8.8.8

# Or use Pi-hole
PEERDNS=192.168.1.100
```

## Docker Customization

### Build Custom Image

**Create: `docker/Dockerfile`**

```dockerfile
FROM linuxserver/wireguard:latest

# Add custom scripts
COPY scripts/ /custom-scripts/
RUN chmod +x /custom-scripts/*.sh

# Custom entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

### Resource Limits

```yaml
services:
  wireguard:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

## Adding Webhooks

**File: `webhooks/handler.py`**

```python
from fastapi import FastAPI, HTTPException
import subprocess

app = FastAPI()

@app.post("/webhook/peer-added")
async def on_peer_added(data: dict):
    """Triggered when new peer is added"""
    peer_name = data.get('peer_name')
    # Send notification
    subprocess.run(['notify-send', f'New peer: {peer_name}'])
    return {"status": "success"}

@app.post("/webhook/peer-removed")
async def on_peer_removed(data: dict):
    """Triggered when peer is removed"""
    peer_name = data.get('peer_name')
    # Log event
    with open('events.log', 'a') as f:
        f.write(f"Peer removed: {peer_name}\n")
    return {"status": "success"}
```

## Adding Database Support

**File: `db/models.py`**

```python
from sqlalchemy import create_engine, Column, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class Peer(Base):
    __tablename__ = 'peers'
    
    id = Column(String, primary_key=True)
    name = Column(String, unique=True)
    public_key = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_connected = Column(DateTime)
    
class ConnectionLog(Base):
    __tablename__ = 'connection_logs'
    
    id = Column(String, primary_key=True)
    peer_id = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow)
    bytes_sent = Column(String)
    bytes_received = Column(String)
```

## CLI Extension

**File: `cli/vpn-cli.sh`**

```bash
#!/bin/bash

case "$1" in
    status)
        docker-compose exec wireguard wg show
        ;;
    add-peer)
        bash scripts/add-peer.sh $2
        ;;
    remove-peer)
        bash scripts/remove-peer.sh $2
        ;;
    backup)
        bash scripts/backup-config.sh
        ;;
    *)
        echo "Usage: vpn-cli {status|add-peer|remove-peer|backup}"
        ;;
esac
```

---

**Need help?** Open an issue or check discussions!
