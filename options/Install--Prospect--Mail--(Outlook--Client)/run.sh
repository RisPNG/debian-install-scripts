# Get the latest Prospect Mail download URL
download_url=$(curl -fsSL https://api.github.com/repos/julian-alarcon/prospect-mail/releases/latest | jq -r '.assets[] | select(.name | endswith("amd64.deb")) | .browser_download_url')

# Download and install
wget "$download_url" -O ~/Downloads/prospect-mail-latest.deb
sudo apt install ~/Downloads/prospect-mail-latest.deb -y