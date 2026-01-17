#!/bin/bash
set -e

# Version of Tor to bundle
TOR_VERSION="0.4.8.10"
TOR_TARBALL="tor-${TOR_VERSION}.tar.gz"
TOR_URL="https://dist.torproject.org/${TOR_TARBALL}"
TOR_DIR="tor-${TOR_VERSION}"

# Check if we already have the binary
if [ -f "../src/tor_embedded" ]; then
    echo "Tor binary already exists in src/tor_embedded. Skipping build."
    exit 0
fi

echo "Downloading Tor ${TOR_VERSION}..."
if [ ! -f "${TOR_TARBALL}" ]; then
    wget -c "${TOR_URL}"
fi

echo "Extracting..."
tar -xzf "${TOR_TARBALL}"

cd "${TOR_DIR}"

echo "Configuring Tor..."
# Disable features to reduce build time and dependencies.
# We need basic functionality.
./configure \
    --disable-asciidoc \
    --disable-system-torrc \
    --disable-manpages \
    --disable-html-manual \
    --disable-unittests \
    --enable-static-tor \
    --with-openssl-dir=/usr

echo "Building Tor..."
make -j$(nproc)

echo "Copying binary..."
cp src/app/tor ../../src/tor_embedded

echo "Done."
