sudo mkdir -p /etc/apt/sources.list.d
timestamp="$(date +%F-%H%M%S)"
backup_dir=""

if [ -f /etc/apt/sources.list.d/debian.sources ]; then
  backup_dir="${backup_dir:-$(mktemp -d /tmp/apt-sources-backup-XXXXXX)}"
  sudo mv /etc/apt/sources.list.d/debian.sources "$backup_dir/debian.sources.bak.$timestamp"
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
  backup_dir="${backup_dir:-$(mktemp -d /tmp/apt-sources-backup-XXXXXX)}"
  sudo mv /etc/apt/sources.list "$backup_dir/sources.list.bak.$timestamp"
fi

sudo apt update
sudo apt install linux-headers-$(uname -r) -y
sudo apt install nvidia-kernel-dkms nvidia-driver firmware-misc-nonfree -y
