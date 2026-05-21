#!/usr/bin/env bash
set -euo pipefail

REPO="KUAILESHANGWEI/edgetunnel"
BRANCH="${EDGETUNNEL_BRANCH:-main}"
INSTALL_DIR="${EDGETUNNEL_DIR:-/opt/edgetunnel}"
TARBALL_URL="https://api.github.com/repos/${REPO}/tarball/${BRANCH}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

if ! need_cmd curl; then
  echo "curl is required. Install curl and rerun this installer." >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$INSTALL_DIR"
curl -fsSL "$TARBALL_URL" -o "$tmpdir/edgetunnel.tar.gz"
tar -xzf "$tmpdir/edgetunnel.tar.gz" -C "$tmpdir"
srcdir="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

rm -rf "${INSTALL_DIR:?}/"*
cp -R "$srcdir"/. "$INSTALL_DIR"/
if [ -f "$INSTALL_DIR/install.sh" ]; then
  chmod +x "$INSTALL_DIR/install.sh"
fi

cat <<EOF
edgetunnel installed from https://github.com/${REPO}
Install directory: ${INSTALL_DIR}
Worker script: ${INSTALL_DIR}/_worker.js
Wrangler config: ${INSTALL_DIR}/wrangler.toml
EOF
