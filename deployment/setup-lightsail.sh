#!/bin/bash
# AWS Lightsail Initial Setup Script (Cloudflare Tunnel version)

set -e

echo "🚀 Setting up AWS Lightsail instance for Timeless Love Backend (Cloudflare Tunnel)..."
echo ""

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y
echo ""

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi
echo ""

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi
echo ""

# Install Git
echo "📚 Installing Git..."
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
    echo "✅ Git installed"
else
    echo "✅ Git already installed"
fi
echo ""

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /opt/timeless-love
sudo chown $USER:$USER /opt/timeless-love
echo "✅ Application directory created at /opt/timeless-love"
echo ""

# Set up firewall (SSH only - Cloudflare Tunnel handles the rest)
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp    # SSH
sudo ufw deny 80/tcp     # Not needed with Cloudflare Tunnel
sudo ufw deny 443/tcp    # Not needed with Cloudflare Tunnel
sudo ufw --force enable
echo "✅ Firewall configured"
echo ""

# Create log directories
echo "📝 Creating log directories..."
mkdir -p /opt/timeless-love/logs
echo "✅ Log directories created"
echo ""

echo "✅ AWS Lightsail instance setup complete!"
echo ""
echo "Next steps:"
echo "1. Log out and log back in for Docker group changes to take effect"
echo "2. Clone your repository to /opt/timeless-love"
echo "3. Create .env.production file with your configuration"
echo "4. Set up Cloudflare Tunnel (see deployment guide)"
echo "5. Run deploy.sh to deploy the application"
