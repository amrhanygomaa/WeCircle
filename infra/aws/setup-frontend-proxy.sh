#!/bin/bash
# WeCircle — set up an nginx reverse proxy for the Next.js dashboard.
#
# Exposes  wecircle.helpers-tech.com  ->  http://127.0.0.1:3000  (the pm2 "frontend" process)
# and obtains a Let's Encrypt TLS cert for that domain.
#
# SAFE BY DESIGN:
#   • Aborts if something OTHER than nginx already owns :443 (so it never breaks the live API).
#   • Only writes its own conf file (/etc/nginx/conf.d/wecircle-dashboard.conf) — never touches an
#     existing API server block.
#   • Tests the nginx config before reloading.
#   • Skips certbot (but leaves a working HTTP proxy) if DNS for the domain does not yet point here.
#   • Idempotent — safe to re-run.
#
# Run on the EC2 box:
#   sudo ADMIN_EMAIL=you@helpers-tech.com bash /opt/wecircle/infra/aws/setup-frontend-proxy.sh
set -euo pipefail

# ---- config (override via env) ----
DOMAIN="${DOMAIN:-wecircle.helpers-tech.com}"
UPSTREAM_PORT="${UPSTREAM_PORT:-3000}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@helpers-tech.com}"   # used for the Let's Encrypt account
CONF="/etc/nginx/conf.d/wecircle-dashboard.conf"

echo "================ WeCircle dashboard proxy setup ================"
echo "domain=$DOMAIN  upstream=127.0.0.1:$UPSTREAM_PORT  email=$ADMIN_EMAIL"
echo

# ---- 0. must be root ----
if [ "$(id -u)" -ne 0 ]; then
  echo "ABORT: run with sudo (needs to write /etc/nginx and bind ports)."; exit 1
fi

# ---- 1. find this box's public IP ----
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 120" 2>/dev/null || true)
if [ -n "$TOKEN" ]; then
  BOX_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || true)
else
  BOX_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || true)
fi
echo "This box public IP: ${BOX_IP:-UNKNOWN}"

# ---- 2. SAFETY: who owns :443 right now? ----
PORT443="$(ss -tlnp 2>/dev/null | grep ':443 ' || true)"
if [ -n "$PORT443" ]; then
  if echo "$PORT443" | grep -qi nginx; then
    echo "OK: nginx already owns :443 — will add a dashboard block alongside the existing config."
  else
    echo "ABORT: something other than nginx is listening on :443:"
    echo "  $PORT443"
    echo "Installing nginx now could break it (possibly the live API). Send this line to Claude first."
    exit 1
  fi
fi

# ---- 3. install nginx if missing ----
if ! command -v nginx >/dev/null 2>&1; then
  echo "Installing nginx..."
  dnf install -y nginx
fi
systemctl enable nginx >/dev/null 2>&1 || true

# ---- 4. write the dashboard server block (HTTP first, so ACME http-01 works) ----
echo "Writing $CONF ..."
cat > "$CONF" <<NGINX
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass         http://127.0.0.1:$UPSTREAM_PORT;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 60s;
    }
}
NGINX

echo "Testing nginx config..."
nginx -t
systemctl restart nginx
echo "nginx is serving HTTP for $DOMAIN -> 127.0.0.1:$UPSTREAM_PORT"

# ---- 5. DNS check before attempting TLS ----
DNS_IP="$(getent hosts "$DOMAIN" | awk '{print $1}' | head -1 || true)"
echo "DNS: $DOMAIN -> ${DNS_IP:-(does not resolve)}   (box is ${BOX_IP:-UNKNOWN})"
if [ -z "$DNS_IP" ] || { [ -n "$BOX_IP" ] && [ "$DNS_IP" != "$BOX_IP" ]; }; then
  echo
  echo ">>> DNS does NOT point at this box yet — SKIPPING certbot."
  echo ">>> Create an A record:  $DOMAIN  ->  ${BOX_IP:-<this box public IP>}"
  echo ">>> Then run TLS:        sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $ADMIN_EMAIL --redirect"
  echo
  echo "Dashboard is reachable over HTTP now (once DNS resolves). Done (HTTP only)."
  exit 0
fi

# ---- 6. install certbot (AL2023: official pip/venv method) ----
if ! command -v certbot >/dev/null 2>&1; then
  echo "Installing certbot (venv)..."
  dnf install -y python3 augeas-libs
  python3 -m venv /opt/certbot
  /opt/certbot/bin/pip install --upgrade pip >/dev/null
  /opt/certbot/bin/pip install certbot certbot-nginx >/dev/null
  ln -sf /opt/certbot/bin/certbot /usr/bin/certbot
fi

# ---- 7. obtain + install the cert, add HTTPS + redirect ----
echo "Requesting Let's Encrypt cert for $DOMAIN ..."
certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$ADMIN_EMAIL" --redirect

nginx -t && systemctl reload nginx
echo
echo "================ DONE ================"
echo "Dashboard live at: https://$DOMAIN"
echo "certbot auto-renew: systemctl list-timers | grep certbot  (or check the certbot renew cron/timer)"
