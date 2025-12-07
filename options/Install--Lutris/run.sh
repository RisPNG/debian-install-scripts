echo 'deb http://download.opensuse.org/repositories/home:/3rdp4r7yr3p0:/4pp5c0nfm15c/Debian_13/ /' | sudo tee /etc/apt/sources.list.d/home:3rdp4r7yr3p0:4pp5c0nfm15c.list
curl -fsSL https://download.opensuse.org/repositories/home:3rdp4r7yr3p0:4pp5c0nfm15c/Debian_13/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_3rdp4r7yr3p0_4pp5c0nfm15c.gpg > /dev/null
sudo apt update
sudo apt install -y lutris