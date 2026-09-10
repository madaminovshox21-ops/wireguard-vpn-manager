# Deployment Guide 🚀

## Cloud Deployment

### Digital Ocean

1. **Create Droplet**
   - Choose Ubuntu 20.04 LTS
   - Select $5/month plan (minimum)
   - Choose region close to your location

2. **SSH into Droplet**
   ```bash
   ssh root@your_droplet_ip
   ```

3. **Install Dependencies**
   ```bash
   apt update && apt upgrade -y
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   apt install docker-compose -y
   ```

4. **Clone & Deploy**
   ```bash
   git clone https://github.com/madaminovshox21-ops/wireguard-vpn-manager.git
   cd wireguard-vpn-manager
   sed -i 's/your-server-ip.com/YOUR_DROPLET_IP/g' docker-compose.yml
   docker-compose up -d
   ```

### AWS (EC2)

1. **Launch Instance**
   - AMI: Ubuntu Server 20.04 LTS
   - Instance type: t2.micro (free tier)
   - Security group: Allow UDP 51820, TCP 8080

2. **Connect & Install**
   ```bash
   ssh -i your-key.pem ubuntu@your-instance-ip
   
   # Install Docker
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker $USER
   sudo apt install docker-compose -y
   ```

3. **Deploy**
   ```bash
   git clone https://github.com/madaminovshox21-ops/wireguard-vpn-manager.git
   cd wireguard-vpn-manager
   docker-compose up -d
   ```

### Linode

Same process as Digital Ocean - use the provided StackScript for automation.

## Home Server Deployment

### Raspberry Pi 4

```bash
# Install Raspberry Pi OS (64-bit)
# Then SSH and run:

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install docker-compose

# Clone and deploy
git clone https://github.com/madaminovshox21-ops/wireguard-vpn-manager.git
cd wireguard-vpn-manager
docker-compose up -d
```

### Linux Server

```bash
# Ubuntu 20.04+
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER

# Clone repo
git clone https://github.com/madaminovshox21-ops/wireguard-vpn-manager.git
cd wireguard-vpn-manager

# Deploy
docker-compose up -d
```

## Port Forwarding Setup

### For Home Network

1. Access your router admin page (usually 192.168.1.1)
2. Find Port Forwarding section
3. Forward external port 51820 → internal IP:51820 (UDP)
4. Forward external port 8080 → internal IP:8080 (TCP)
5. Get your public IP from: https://ipinfo.io
6. Update docker-compose.yml with public IP

## SSL/TLS Setup (Optional)

### Using Let's Encrypt with Nginx

```bash
# Install Nginx
sudo apt install nginx

# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d your-domain.com

# Add to Nginx config
# location / {
#     proxy_pass http://localhost:8080;
# }
```

## Monitoring & Maintenance

### Check Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs -f
```

### Update Services
```bash
docker-compose pull
docker-compose up -d
```

### Auto-update with Watchtower
```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --cleanup
```

## Backup Strategy

### Daily Backups
```bash
# Add to crontab
0 2 * * * cd /path/to/wireguard-vpn-manager && bash scripts/backup-config.sh
```

### Remote Backup
```bash
# Sync to S3
sudo apt install awscli
aws s3 sync ./backups s3://your-bucket/wireguard-backups/
```

## Security Hardening

### Firewall Setup
```bash
# UFW (Ubuntu)
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 51820/udp
sudo ufw allow 8080/tcp
```

### Change Defaults
```bash
# Edit docker-compose.yml
ADMIN_PASSWORD=your-super-strong-password
SERVERPORT=12345  # Change from 51820
```

### SSH Hardening
```bash
# Disable root login
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## Troubleshooting

### VPN not working
```bash
# Check firewall
sudo ufw status
sudo iptables -L

# Check WireGuard status
docker-compose exec wireguard wg
```

### High latency
- Choose server geographically closer to you
- Check network bandwidth
- Optimize kernel parameters

### Can't access dashboard
- Check if port 8080 is open: `sudo netstat -tulpn | grep 8080`
- Verify firewall rules
- Check docker logs: `docker-compose logs wg-ui`

---

For more help, open an issue on GitHub!
