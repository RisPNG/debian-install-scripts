# Get the latest LocalSend download URL
download_url=$(curl -fsSL https://api.github.com/repos/localsend/localsend/releases/latest | jq -r '.assets[] | select(.name | endswith("x86-64.deb")) | .browser_download_url')

# Download and install
wget "$download_url" -O ~/Downloads/localsend-latest.deb
sudo apt install ~/Downloads/localsend-latest.deb -y