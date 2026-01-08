#!/usr/bin/env bash
set -euo pipefail

# Fetches latest versions from Cloudsmith and updates default.nix

REPO_URL="https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/dists/bookworm/main/binary-amd64/Packages"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/../default.nix"

echo "Fetching package index..."
PACKAGES=$(curl -sL "$REPO_URL")

# Extract latest doublezero version (highest version number)
get_latest_version() {
    local package="$1"
    echo "$PACKAGES" | awk -v pkg="$package" '
        /^Package:/ { current_pkg = $2 }
        /^Version:/ && current_pkg == pkg { print $2 }
    ' | sort -V | tail -1
}

get_package_info() {
    local package="$1"
    local version="$2"
    echo "$PACKAGES" | awk -v pkg="$package" -v ver="$version" '
        /^Package:/ { current_pkg = $2; in_block = 0 }
        /^Version:/ && current_pkg == pkg && $2 == ver { in_block = 1 }
        in_block && /^SHA256:/ { print "sha256=" $2 }
        in_block && /^Filename:/ { print "filename=" $2 }
        /^$/ { in_block = 0 }
    '
}

# Get latest versions
DOUBLEZERO_VERSION=$(get_latest_version "doublezero")
SOLANA_VERSION=$(get_latest_version "doublezero-solana")

echo "Latest doublezero: $DOUBLEZERO_VERSION"
echo "Latest doublezero-solana: $SOLANA_VERSION"

# Strip the -1 suffix for the version in nix (0.8.0-1 -> 0.8.0)
DOUBLEZERO_NIX_VERSION="${DOUBLEZERO_VERSION%-*}"
SOLANA_NIX_VERSION="${SOLANA_VERSION%-*}"

# Get SHA256 hashes
eval "$(get_package_info "doublezero" "$DOUBLEZERO_VERSION")"
DOUBLEZERO_SHA256="$sha256"

eval "$(get_package_info "doublezero-solana" "$SOLANA_VERSION")"
SOLANA_SHA256="$sha256"

echo "doublezero SHA256: $DOUBLEZERO_SHA256"
echo "doublezero-solana SHA256: $SOLANA_SHA256"

# Read current versions from default.nix
CURRENT_DOUBLEZERO=$(grep -A2 'pname = "doublezero"' "$DEFAULT_NIX" | grep 'version =' | head -1 | sed 's/.*"\(.*\)".*/\1/')
CURRENT_SOLANA=$(grep -A2 'pname = "doublezero-solana"' "$DEFAULT_NIX" | grep 'version =' | sed 's/.*"\(.*\)".*/\1/')

echo "Current doublezero: $CURRENT_DOUBLEZERO"
echo "Current doublezero-solana: $CURRENT_SOLANA"

UPDATED=0

# Update doublezero-solana if needed
if [ "$CURRENT_SOLANA" != "$SOLANA_NIX_VERSION" ]; then
    echo "Updating doublezero-solana: $CURRENT_SOLANA -> $SOLANA_NIX_VERSION"
    sed -i "s/pname = \"doublezero-solana\";/pname = \"doublezero-solana\";/; /pname = \"doublezero-solana\";/{n;s/version = \".*\"/version = \"$SOLANA_NIX_VERSION\"/}" "$DEFAULT_NIX"
    # Update sha256 for solana (first occurrence after doublezero-solana)
    sed -i "0,/doublezero-solana/{ /doublezero-solana/,/sha256 = /{ s/sha256 = \"[a-f0-9]*\"/sha256 = \"$SOLANA_SHA256\"/ } }" "$DEFAULT_NIX"
    UPDATED=1
fi

# Update doublezero if needed
if [ "$CURRENT_DOUBLEZERO" != "$DOUBLEZERO_NIX_VERSION" ]; then
    echo "Updating doublezero: $CURRENT_DOUBLEZERO -> $DOUBLEZERO_NIX_VERSION"
    # Update version in the main derivation (after "in stdenv.mkDerivation")
    sed -i "/^in stdenv.mkDerivation/,/^}$/{s/version = \"$CURRENT_DOUBLEZERO\"/version = \"$DOUBLEZERO_NIX_VERSION\"/}" "$DEFAULT_NIX"
    # Update sha256 for main package
    sed -i "/^in stdenv.mkDerivation/,/^}$/{s/sha256 = \"[a-f0-9]*\"/sha256 = \"$DOUBLEZERO_SHA256\"/}" "$DEFAULT_NIX"
    UPDATED=1
fi

if [ "$UPDATED" -eq 1 ]; then
    echo "Updates applied to default.nix"
    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "UPDATED=true" >> "$GITHUB_OUTPUT"
        echo "DOUBLEZERO_VERSION=$DOUBLEZERO_NIX_VERSION" >> "$GITHUB_OUTPUT"
        echo "SOLANA_VERSION=$SOLANA_NIX_VERSION" >> "$GITHUB_OUTPUT"
    fi
else
    echo "Already up to date"
    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "UPDATED=false" >> "$GITHUB_OUTPUT"
    fi
fi
