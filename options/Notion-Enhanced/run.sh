echo "deb [trusted=yes] https://apt.fury.io/notion-repackaged/ /" | sudo tee /etc/apt/sources.list.d/notion-repackaged.list
sudo apt update
sudo apt install notion-app-enhanced nodejs npm -y
sudo npm install -g asar
cd ~/Downloads
wget -qO- "https://gitlab.com/-/snippets/3615945/raw/main/patch-notion-enhanced.linux.sh" | sudo bash