sudo apt install autoconf build-essential curl flex fop gcc git icu-devtools inotify-tools libcurl4-openssl-dev libedit-dev libgl1-mesa-dev libglu1-mesa-dev libicu-dev libncurses-dev libpam0g-dev libpng-dev libreadline-dev libssh-dev libssl-dev libwxgtk-webview3.2-dev libwxgtk3.2-dev libxml2-dev libxml2-utils libxslt1-dev m4 make unixodbc-dev unzip uuid-dev xsltproc zlib1g-dev bison -y
wget -O ~/Downloads/libssl1_1.deb http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1w-0+deb11u3_amd64.deb && sudo apt install ~/Downloads/libssl1_1.deb -y
wget -O ~/Downloads/wkhtmltopdf.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && sudo apt install ~/Downloads/wkhtmltopdf.deb -y

curl https://mise.run | sh
echo "eval \"\$(/home/$USER/.local/bin/mise activate bash)\"" >> ~/.bashrc
source ~/.bashrc
git config --global credential.helper store
mise use --global python@3.10
mise use --global rust@latest
mise use --global go@latest
mise use --global java@latest
mise use --global node@latest