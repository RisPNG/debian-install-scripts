# Get the latest Ente Auth download URL
download_url=$(curl -fsSL https://api.github.com/repos/ente-io/ente/releases | jq -r '[.[] | select(.tag_name | contains("auth"))][0].assets[] | select(.name | endswith("x86_64.deb")) | .browser_download_url')

# Download and install
wget "$download_url" -O ~/Downloads/ente-auth-latest.deb
sudo apt install ~/Downloads/ente-auth-latest.deb -y