echo 'deb http://download.opensuse.org/repositories/home:/tangerine:/deb12-xfce4.18/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:tangerine:deb12-xfce4.18.list
curl -fsSL https://download.opensuse.org/repositories/home:tangerine:deb12-xfce4.18/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_tangerine_deb12-xfce4.18.gpg > /dev/null
sudo apt update
sudo apt install qview -y