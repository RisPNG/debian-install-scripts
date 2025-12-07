# Download VS Code
wget -O ~/Downloads/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

# Pre-configure debconf to accept Microsoft repository without prompting
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

# Install with non-interactive frontend and force config options
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  ~/Downloads/vscode.deb