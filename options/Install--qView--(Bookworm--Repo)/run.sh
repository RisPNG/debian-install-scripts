LIST_FILE="/etc/apt/sources.list.d/home:tangerine:deb12-xfce4.18.list"
KEY_FILE="/etc/apt/trusted.gpg.d/home_tangerine_deb12-xfce4.18.gpg"

echo 'deb http://download.opensuse.org/repositories/home:/tangerine:/deb12-xfce4.18/Debian_12/ /' | sudo tee "$LIST_FILE"
curl -fsSL https://download.opensuse.org/repositories/home:tangerine:deb12-xfce4.18/Debian_12/Release.key | gpg --dearmor | sudo tee "$KEY_FILE" > /dev/null
sudo apt update
sudo apt install qview -y

# Remove the Bookworm repo so the rest of the system stays on Debian packages
sudo rm -f "$LIST_FILE" "$KEY_FILE"
sudo apt update
