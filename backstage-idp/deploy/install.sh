#!/usr/bin/env bash
# Puts this portal on a fresh Ubuntu host, behind nginx with a real
# certificate. Safe to re-run: every step is idempotent, so this doubles as
# the upgrade path once the box already exists.
#
#   PUBLIC_URL=https://play.efekaya.io \
#   GITHUB_TOKEN=ghp_... \
#   CERT_EMAIL=you@example.com \
#     ./deploy/install.sh
#
# The host is assumed to be running the kind cluster from idp-gitops already -
# the Kubernetes tab reads its API through a service account this script mints.
set -euo pipefail

: "${PUBLIC_URL:?set PUBLIC_URL, e.g. https://play.efekaya.io}"
: "${GITHUB_TOKEN:?set GITHUB_TOKEN - a classic PAT with repo + workflow + read:packages}"
CERT_EMAIL="${CERT_EMAIL:-}"

# The scaffolder is read-only in this deployment; deploy/nginx.conf refuses
# every write. Nothing to configure.

DOMAIN="${PUBLIC_URL#https://}"; DOMAIN="${DOMAIN#http://}"; DOMAIN="${DOMAIN%%/*}"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RUN_DIR="$HOME/backstage-run"
DATA_DIR="$HOME/backstage-data"

echo "### deploying $DOMAIN from $REPO_DIR"

# --- prerequisites -----------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq nginx certbot python3-certbot-nginx >/dev/null

if ! command -v node >/dev/null || [ "$(node -v | cut -c2-3)" -lt 22 ]; then
  echo "### installing node 22"
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null
  sudo apt-get install -y -qq nodejs >/dev/null
fi
sudo corepack enable

# A Backstage build wants more memory than a 2-vCPU box has spare once the kind
# cluster is up; without swap it gets OOM-killed partway through.
if [ ! -f /swapfile ]; then
  echo "### adding 4G swap"
  sudo fallocate -l 4G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile >/dev/null
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

# --- build -------------------------------------------------------------------
cd "$REPO_DIR"
echo "### yarn install"
corepack yarn install --immutable

# PUBLIC_URL has to be exported for the *frontend* build too: the bundle bakes
# app.baseUrl in at build time, so setting it only in the service would leave
# the browser talking to whatever app-config.yaml says (localhost).
export PUBLIC_URL
echo "### building"
corepack yarn workspace app build
corepack yarn workspace backend build

# --- unpack ------------------------------------------------------------------
echo "### unpacking to $RUN_DIR"
rm -rf "$RUN_DIR"; mkdir -p "$RUN_DIR" "$DATA_DIR"
tar -xzf packages/backend/dist/bundle.tar.gz -C "$RUN_DIR"
cp app-config.yaml app-config.production.yaml "$RUN_DIR/"

# The bundle ships no .yarnrc.yml, so yarn falls back to PnP and installs no
# node_modules - then plain `node packages/backend` can't resolve a thing.
printf 'nodeLinker: node-modules\n' > "$RUN_DIR/.yarnrc.yml"
cd "$RUN_DIR"
corepack yarn install --no-immutable

# --- secrets -----------------------------------------------------------------
# Not in git: a token, and a fresh service-account token for the cluster the
# Kubernetes tab reads. Regenerated on every deploy so it never goes stale.
echo "### writing .env"
K8S_URL=$(sudo kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
K8S_TOKEN=$(sudo kubectl create token backstage-viewer -n default --duration=87600h)
umask 077
cat > "$REPO_DIR/.env" <<ENV
GITHUB_TOKEN=$GITHUB_TOKEN
KUBERNETES_CLUSTER_URL=$K8S_URL
KUBERNETES_SA_TOKEN=$K8S_TOKEN
PUBLIC_URL=$PUBLIC_URL
ENV
umask 022

# --- service -----------------------------------------------------------------
echo "### systemd unit"
sudo tee /etc/systemd/system/backstage.service >/dev/null <<UNIT
[Unit]
Description=Backstage IDP portal
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$RUN_DIR
EnvironmentFile=$REPO_DIR/.env
ExecStart=/usr/bin/node packages/backend --config $RUN_DIR/app-config.yaml --config $RUN_DIR/app-config.production.yaml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT
sudo systemctl daemon-reload
sudo systemctl enable backstage >/dev/null
sudo systemctl restart backstage

# --- nginx + tls -------------------------------------------------------------
echo "### nginx"
sed -e "s/__DOMAIN__/$DOMAIN/g" "$REPO_DIR/deploy/nginx.conf" \
  | sudo tee /etc/nginx/sites-available/backstage >/dev/null
sudo ln -sf /etc/nginx/sites-available/backstage /etc/nginx/sites-enabled/backstage
sudo rm -f /etc/nginx/sites-enabled/default

# Drop any other enabled site claiming this hostname. nginx serves the first
# server block that matches, so a leftover config silently wins over this one -
# and since certbot had attached the TLS listener to the leftover, every HTTPS
# request was answered by rules this file had already replaced.
for f in /etc/nginx/sites-enabled/*; do
  [ "$(basename "$f")" = backstage ] && continue
  if sudo grep -qs "server_name[[:space:]]\+$DOMAIN;" "$f"; then
    echo "    removing conflicting site: $(basename "$f")"
    sudo rm -f "$f" "/etc/nginx/sites-available/$(basename "$f")"
  fi
done
sudo nginx -t
sudo systemctl reload nginx

if [ -n "$CERT_EMAIL" ] && [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
  echo "### certificate"
  sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$CERT_EMAIL" --redirect
fi

echo
echo "### waiting for the portal"
up=0
for _ in $(seq 1 30); do
  if [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:7007/)" = "200" ]; then
    up=1; break
  fi
  sleep 5
done
if [ "$up" = 0 ]; then
  echo "not answering yet - check: journalctl -u backstage -n 50" >&2
  exit 1
fi

# Generate the docs, then bounce the service so the search indexer's first pass
# has something to collate. Skipping the restart leaves the TechDocs tab
# returning 500 until the indexer's next scheduled run ten minutes later.
echo "### building techdocs"
"$REPO_DIR/deploy/warm-techdocs.sh"
sudo systemctl restart backstage

for _ in $(seq 1 30); do
  if [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:7007/)" = "200" ]; then
    echo "up: $PUBLIC_URL"; exit 0
  fi
  sleep 5
done
echo "came up, then did not answer after the techdocs restart - check: journalctl -u backstage -n 50" >&2
exit 1
