#!/usr/bin/env bash
# Télécharge la dernière version recommandée de FXServer (Linux) dans ./artifacts
set -euo pipefail
cd "$(dirname "$0")"

API="https://changelogs-live.fivem.net/api/changelog/versions/linux/server"
URL=$(curl -fsSL "$API" | grep -o '"recommended_download":"[^"]*"' | cut -d'"' -f4)

if [ -z "$URL" ]; then
    echo "Impossible de trouver la version recommandée. Télécharge-la à la main :"
    echo "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/"
    exit 1
fi

echo "Téléchargement de $URL"
rm -rf artifacts && mkdir -p artifacts
curl -fL "$URL" -o artifacts/fx.tar.xz
tar -xf artifacts/fx.tar.xz -C artifacts
rm artifacts/fx.tar.xz

if [ ! -f secrets.cfg ]; then
    cp secrets.cfg.example secrets.cfg
    echo "secrets.cfg créé : mets-y ta clé de licence (https://portal.cfx.re)."
fi

echo "Installation terminée. Lance le serveur avec ./start.sh"
