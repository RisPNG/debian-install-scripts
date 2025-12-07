TANGERINE_LIST="/etc/apt/sources.list.d/home:tangerine:deb12-xfce4.18.list"
TANGERINE_KEY="/etc/apt/trusted.gpg.d/home_tangerine_deb12-xfce4.18.gpg"

# Ensure we stay on Debian repos for this bulk install
if [ -f "$TANGERINE_LIST" ] || [ -f "$TANGERINE_KEY" ]; then
    sudo rm -f "$TANGERINE_LIST" "$TANGERINE_KEY"
fi
sudo apt update


sudo apt install git wget gnome-shell-extension-apps-menu gnome-boxes gnome-snapshot gnome-characters gnome-clocks ptyxis gnome-disk-utility baobab gnome-shell-extension-manager gnome-shell-extension-prefs fastfetch file-roller font-manager gnome-tweaks libreoffice gnome-logs seahorse remmina gnome-connections gnome-sound-recorder gnome-system-monitor gnome-text-editor qbittorrent wine evince epiphany-browser nomacs-l10n diodon yt-dlp mpv libmpv-dev aptitude mc ncdu ddcutil ddccontrol gddccontrol ddccontrol-db i2c-tools curl ca-certificates qalculate-gtk fuse libfuse-dev gir1.2-gnomedesktop-3.0 python3-dbus python3-gi gir1.2-glib-2.0 dbus python3-full xclip devilspie2 ffmpeg ripgrep libsdl2-dev -y
wget -O ~/Downloads/actions-for-nautilus_2.0.0~pre2-1_all.deb https://github.com/bassmanitram/actions-for-nautilus/raw/refs/heads/v2/dist/actions-for-nautilus_2.0.0~pre2-1_all.deb && sudo apt install ~/Downloads/actions-for-nautilus_2.0.0~pre2-1_all.deb -y
sudo modprobe i2c-dev
sudo gpasswd -a "$USER" i2c

sudo apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.usebottles.bottles org.gnome.meld it.mijorus.gearlever io.github.flattool.Warehouse com.raggesilver.BlackBox -y

# Set SCRIPT_DIR to the repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"

mkdir -p ~/.config/vivaldi/Default
if [ -f "$SCRIPT_DIR/.config/vivaldi/Default/Preferences" ]; then
    cp "$SCRIPT_DIR/.config/vivaldi/Default/Preferences" \
       ~/.config/vivaldi/Default/Preferences
fi

if [ -f "$SCRIPT_DIR/.mozilla/firefox/defaultprofile/prefs.js" ]; then
    for profile in ~/.mozilla/firefox/*.default; do
        if [ -d "$profile" ]; then
            cp "$SCRIPT_DIR/.mozilla/firefox/defaultprofile/prefs.js" "$profile/prefs.js"
        fi
    done

    for profile in ~/.mozilla/firefox/*.default-esr; do
        if [ -d "$profile" ]; then
            cp "$SCRIPT_DIR/.mozilla/firefox/defaultprofile/prefs.js" "$profile/prefs.js"
        fi
    done
fi
