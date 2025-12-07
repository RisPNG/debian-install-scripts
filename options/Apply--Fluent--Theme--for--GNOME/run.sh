# Pre-install sassc to avoid interactive prompts
sudo apt-get install -y sassc libsass1

cd ~/Documents/Git

# Clone or update Fluent-icon-theme
if [ -d "Fluent-icon-theme" ]; then
    cd Fluent-icon-theme
    git pull
else
    git clone https://github.com/vinceliuice/Fluent-icon-theme
    cd Fluent-icon-theme
fi
chmod +x install.sh && ./install.sh -a
mkdir -p ~/.icons/Fluent && cp -r cursors/dist/* ~/.icons/Fluent/
mkdir -p ~/.icons/Fluent-Dark && cp -r cursors/dist-dark/* ~/.icons/Fluent-Dark/
cd ..

# Clone or update Fluent-gtk-theme
if [ -d "Fluent-gtk-theme" ]; then
    cd Fluent-gtk-theme
    git pull
else
    git clone https://github.com/vinceliuice/Fluent-gtk-theme
    cd Fluent-gtk-theme
fi
chmod +x install.sh && ./install.sh && ./install.sh --tweaks round

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"

mkdir -p ~/.var/app/com.raggesilver.BlackBox/config/glib-2.0/settings
if [ -f "$SCRIPT_DIR/.var/app/com.raggesilver.BlackBox/config/glib-2.0/settings/keyfile" ]; then
    cp "$SCRIPT_DIR/.var/app/com.raggesilver.BlackBox/config/glib-2.0/settings/keyfile" \
       ~/.var/app/com.raggesilver.BlackBox/config/glib-2.0/settings/keyfile
fi

mkdir -p ~/.local/share/gnome-shell/extensions
if [ -d "$SCRIPT_DIR/.local/share/gnome-shell/extensions" ]; then
    cp -r "$SCRIPT_DIR/.local/share/gnome-shell/extensions/"* \
          ~/.local/share/gnome-shell/extensions/
fi