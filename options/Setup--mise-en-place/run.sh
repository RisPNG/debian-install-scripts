sudo apt install autoconf build-essential curl flex fop gcc git icu-devtools inotify-tools libcurl4-openssl-dev libedit-dev libgl1-mesa-dev libglu1-mesa-dev libicu-dev libncurses-dev libpam0g-dev libpng-dev libreadline-dev libssh-dev libssl-dev libwxgtk-webview3.2-dev libwxgtk3.2-dev libxml2-dev libxml2-utils libxslt1-dev m4 make unixodbc-dev unzip uuid-dev xsltproc zlib1g-dev bison -y
download_url=$(curl -fsSL https://api.github.com/repos/newinnovations/wkhtml-packaging/releases/latest | jq -r '.assets[] | select(.name | endswith("trixie_amd64.deb")) | .browser_download_url')
wget "$download_url" -O ~/Downloads/wkhtmltopdf.deb
sudo apt install ~/Downloads/wkhtmltopdf.deb -y

curl https://mise.run | sh
if ! grep -q 'mise activate' ~/.bashrc; then
    echo "eval \"\$(/home/$USER/.local/bin/mise activate bash)\"" >> ~/.bashrc
fi
source ~/.bashrc
git config --global credential.helper store
mise use --global python@3.10
mise use --global rust@latest
mise use --global go@latest
mise use --global java@latest
mise use --global node@latest
