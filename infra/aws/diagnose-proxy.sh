#!/bin/bash
# WeCircle — read-only diagnostic for the EC2 box.
# Changes NOTHING. Run it on the server, paste the full output back.
#   ssh ec2-user@<box>   then:   bash /opt/wecircle/infra/aws/diagnose-proxy.sh
# (or: curl the raw file / paste this whole script into the shell)

echo "================ WeCircle proxy/TLS diagnostic ================"
date
echo

echo "---- 1. EC2 public IP (what DNS must point at) ----"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 120" 2>/dev/null)
if [ -n "$TOKEN" ]; then
  curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/public-ipv4; echo
else
  curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null; echo
fi
echo

echo "---- 2. What is listening on 80 / 443 / 3000 / 5001 ----"
sudo ss -tlnp 2>/dev/null | grep -E ':80 |:443 |:3000 |:5001 ' || echo "(ss found nothing / not permitted)"
echo

echo "---- 3. Web servers installed / running ----"
for svc in nginx caddy httpd apache2; do
  if command -v "$svc" >/dev/null 2>&1; then
    state=$(systemctl is-active "$svc" 2>/dev/null || echo "unknown")
    echo "$svc: INSTALLED, service=$state"
  else
    echo "$svc: not installed"
  fi
done
echo

echo "---- 4. nginx effective config (server_name / listen / proxy_pass) ----"
if command -v nginx >/dev/null 2>&1; then
  sudo nginx -T 2>/dev/null | grep -E 'server_name|listen |proxy_pass|ssl_certificate ' || echo "(no nginx config dump)"
else
  echo "(nginx not installed)"
fi
echo

echo "---- 5. pm2 processes ----"
pm2 list 2>/dev/null || echo "(pm2 not found for this user)"
echo

echo "---- 6. Docker containers (in case proxy runs in a container) ----"
if command -v docker >/dev/null 2>&1; then
  sudo docker ps 2>/dev/null || docker ps 2>/dev/null || echo "(docker present, cannot list)"
else
  echo "(docker not installed)"
fi
echo

echo "---- 7. DNS resolution of both domains (from the box) ----"
for d in api.wecircle.helpers-tech.com wecircle.helpers-tech.com; do
  ip=$(getent hosts "$d" | awk '{print $1}' | head -1)
  echo "$d -> ${ip:-(no resolution)}"
done
echo

echo "---- 8. Local reachability of the app ports ----"
echo -n "localhost:5001 (backend) -> "; curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5001/ 2>/dev/null || echo "no response"
echo -n "localhost:3000 (frontend) -> "; curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/ 2>/dev/null || echo "no response"
echo

echo "================ end of diagnostic ================"
