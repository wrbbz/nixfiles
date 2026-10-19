#!/usr/bin/env bash
# Bump @sentry/mcp-server to a given version (default: latest on npm).
#
# Regenerates everything package.nix depends on:
#   - src.hash in package.nix (the version is read from the lockfile)
#   - package-lock.json: production-only, generated after stripping the
#     unpublished workspace devDependencies, exactly as package.nix does
#     at build time
#
# Usage: ./update.sh [version]
set -euo pipefail

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
pkg=@sentry/mcp-server
version=${1:-$(npm view "$pkg" version)}
url="https://registry.npmjs.org/$pkg/-/mcp-server-$version.tgz"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "fetching $pkg@$version"
curl -fsSL -o "$tmp/src.tgz" "$url"
hash=$(nix hash file --sri --type sha256 "$tmp/src.tgz")

tar -xzf "$tmp/src.tgz" -C "$tmp"
cd "$tmp/package"
jq 'del(.devDependencies)' package.json > package.json.tmp
mv package.json.tmp package.json
npm install --package-lock-only --ignore-scripts --no-audit --no-fund >/dev/null

cp package-lock.json "$dir/"
sed -i -e "s|^    hash = \"sha256-.*\";|    hash = \"$hash\";|" "$dir/package.nix"

echo "updated to $version ($hash)"
echo "remember: git add $dir  # flakes only see tracked files"
