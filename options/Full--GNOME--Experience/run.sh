sudo apt install gir1.2-gnomedesktop-3.0 gir1.2-gnomedesktop-4.0 libgnome-menu-3-dev gnome-shell-extension-apps-menu gnome-shell-extension-arc-menu git wget gnome-shell-extension-apps-menu gnome-disk-utility fastfetch font-manager gnome-tweaks gnome-system-monitor wine yt-dlp libmpv-dev aptitude mc ncdu ddcutil ddccontrol gddccontrol ddccontrol-db i2c-tools curl ca-certificates fuse libfuse-dev gir1.2-gnomedesktop-3.0 python3-dbus python3-gi gir1.2-glib-2.0 dbus python3-full xclip wl-clipboard devilspie2 ffmpeg ripgrep libsdl2-dev -y

# Get the latest LocalSend download URL
download_url=$(curl -fsSL https://api.github.com/repos/bassmanitram/actions-for-nautilus/releases/latest | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url')

# Download and install
wget "$download_url" -O ~/Downloads/actions-for-nautilus-latest.deb
sudo apt install ~/Downloads/actions-for-nautilus-latest.deb -y

sudo modprobe i2c-dev
sudo gpasswd -a "$USER" i2c

sudo apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.usebottles.bottles org.gnome.meld it.mijorus.gearlever io.github.flattool.Warehouse com.raggesilver.BlackBox org.gnome.Boxes org.gnome.Snapshot org.gnome.Characters org.gnome.clocks app.devsuite.Ptyxis org.gnome.baobab org.gnome.Extensions com.mattjakeman.ExtensionManager org.gnome.FileRoller org.libreoffice.LibreOffice org.gnome.Logs org.gnome.seahorse.Application org.remmina.Remmina org.gnome.Connections org.gnome.SoundRecorder org.gnome.TextEditor org.gnome.Epiphany org.nickvision.tubeconverter org.qbittorrent.qBittorrent org.gnome.Evince org.nomacs.ImageLounge io.mpv.Mpv io.github.Qalculate -y

# Get the latest Clyp download URL
download_url=$(curl -fsSL https://api.github.com/repos/murat-cileli/clyp/releases/latest | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url')

# Download and install
wget "$download_url" -O ~/Downloads/clyp-latest.deb
sudo apt install ~/Downloads/clyp-latest.deb -y

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

if ! grep -q 'fastfetch' ~/.bashrc; then
  cat >> ~/.bashrc <<'EOF'
tch() { mkdir -p "$(dirname "$1")" && touch "$1" ; }

export EDITOR=mcedit
export VISUAL=mcedit

# Run fastfetch on shell initialization
fastfetch

export PATH=$HOME/.local/bin:$PATH

# Always refer python3 and pip3 to system packages instead of version controlled tool(s)
export PATH="/usr/bin:/usr/local/bin:$PATH"
alias python3='/usr/bin/python3'
alias pip3='/usr/bin/pip3'
EOF
fi

sudo tee $HOME/.local/share/actions-for-nautilus/config.json >/dev/null <<'EOF'
{
    "actions": [
        {
            "type": "menu",
            "label": "Copy details",
            "actions": [
                {
                    "type": "command",
                    "label": "Copy name",
                    "command_line": "echo -n %B | xclip -f -selection primary | xclip -selection clipboard",
                    "use_shell": true
                },
                {
                    "type": "command",
                    "label": "Copy path",
                    "command_line": "echo -n %F | xclip -f -selection primary | xclip -selection clipboard",
                    "use_shell": true
                },
                {
                    "type": "command",
                    "label": "Copy URI",
                    "command_line": "echo -n %U | xclip -f -selection primary | xclip -selection clipboard",
                    "use_shell": true
                }
            ]
        },
        {
            "type": "command",
            "label": "Open in Code",
            "command_line": "bash -lic \"code .\"",
            "cwd": "%f",
            "use_shell": true,
            "min_items": 1,
            "max_items": 1,
            "filetypes": [
                "directory"
            ]
        },
        {
            "type": "command",
            "label": "Execute command here",
            "command_line": "bash -lic 'cmd=$(zenity --entry --text \"Enter command\" --title \"execute command in %f\" --width 800); if [ -n \"$cmd\" ]; then flatpak run com.raggesilver.BlackBox --working-directory=\"%f\" --command=\"bash -cli \\\"clear && cd %f && $cmd; echo; read -rp Press\\ Enter\\ to\\ close...\\\"\"; fi'",
            "cwd": "%f",
            "use_shell": true,
            "min_items": 1,
            "max_items": 1,
            "filetypes": [
                "directory"
            ]
        }
    ],
    "debug": false
}
EOF
