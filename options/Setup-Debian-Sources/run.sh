sudo mkdir -p /etc/apt/sources.list.d

if [ -f /etc/apt/sources.list.d/debian.sources ]; then
  sudo cp -a /etc/apt/sources.list.d/debian.sources "/etc/apt/sources.list.d/debian.sources.bak.$(date +%F-%H%M%S)"
fi

sudo tee /etc/apt/sources.list.d/debian.sources >/dev/null <<'EOF'
# Main + stable-updates
Types: deb deb-src
URIs: https://deb.debian.org/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

# Security
Types: deb deb-src
URIs: https://security.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

# Backports (opt-in)
Types: deb deb-src
URIs: https://deb.debian.org/debian
Suites: trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

# Proposed updates (usually leave disabled)
Types: deb deb-src
URIs: https://deb.debian.org/debian
Suites: trixie-proposed-updates
Components: main contrib non-free non-free-firmware
Enabled: no
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

if [ -f /etc/apt/sources.list ]; then
  sudo mv /etc/apt/sources.list "/etc/apt/sources.list.bak.$(date +%F-%H%M%S)"
fi

sudo apt update
sudo apt install -y "linux-headers-$(uname -r)"
