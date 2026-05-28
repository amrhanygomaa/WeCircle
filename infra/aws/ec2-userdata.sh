#!/bin/bash
# WeCircle Backend — EC2 t2.micro Setup Script
# Runs on first boot automatically

set -e
exec > /var/log/wecircle-setup.log 2>&1

echo "=== WeCircle Setup Starting ==="
date

# Update system
dnf update -y

# Install Node.js 20 LTS
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs git

# Install PM2 for process management
npm install -g pm2

# Install Docker (for optional containerized run)
dnf install -y docker
systemctl enable docker
systemctl start docker

# Create app directory
mkdir -p /opt/wecircle
cd /opt/wecircle

# Clone the repository
git clone https://github.com/amrhanygomaa/WeCircle.git .

# Setup backend
cd /opt/wecircle/dashboard/backend

# Install dependencies
npm ci --only=production=false

# Load secrets from SSM Parameter Store
AWS_REGION="us-east-1"
get_param() {
  aws ssm get-parameter --name "$1" --with-decryption --region $AWS_REGION --query "Parameter.Value" --output text 2>/dev/null || echo ""
}

# Write .env from SSM
cat > .env <<EOF
NODE_ENV=production
PORT=5001
DATABASE_URL=$(get_param /wecircle/DATABASE_URL)
SUPABASE_URL=$(get_param /wecircle/SUPABASE_URL)
SUPABASE_ANON_KEY=$(get_param /wecircle/SUPABASE_ANON_KEY)
SUPABASE_SERVICE_ROLE_KEY=$(get_param /wecircle/SUPABASE_SERVICE_ROLE_KEY)
SUPABASE_JWT_SECRET=$(get_param /wecircle/SUPABASE_JWT_SECRET)
FRONTEND_URL=$(get_param /wecircle/FRONTEND_URL)
SUPER_ADMIN_EMAIL=$(get_param /wecircle/SUPER_ADMIN_EMAIL)
EOF

# Generate Prisma client
npx prisma generate

# Build TypeScript
npm run build

# Start with PM2 (auto-restart on crash)
pm2 start dist/server.js --name wecircle-backend
pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "=== WeCircle Backend Started ==="
date
