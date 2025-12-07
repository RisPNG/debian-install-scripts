# Get the latest Teams for Linux download URL
download_url=$(curl -fsSL https://api.github.com/repos/IsmaelMartinez/teams-for-linux/releases/latest | jq -r '.assets[] | select(.name | endswith("amd64.deb")) | .browser_download_url')

# Download and install
wget "$download_url" -O ~/Downloads/teams-latest.deb
sudo apt install ~/Downloads/teams-latest.deb -y
sudo tee /usr/share/applications/teams-for-linux.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Teams
Exec=/opt/teams-for-linux/teams-for-linux %U --isCustomBackgroundEnabled=true --customBGServiceBaseUrl=https://raw.githubusercontent.com/RisPNG/SIG-Resources/main
Terminal=false
Type=Application
Icon=teams-for-linux
StartupWMClass=teams-for-linux
Comment=Unofficial Microsoft Teams client for Linux using Electron. It uses the Web App and wraps it as a standalone application using Electron.
MimeType=x-scheme-handler/msteams;
Categories=Chat;Network;Office;
EOF