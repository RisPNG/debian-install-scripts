sudo apt install git wget gnome-shell-extension-apps-menu gnome-boxes gnome-snapshot gnome-characters gnome-clocks ptyxis gnome-disk-utility baobab gnome-shell-extension-manager gnome-shell-extension-prefs fastfetch file-roller font-manager gnome-tweaks libreoffice gnome-logs seahorse remmina gnome-connections gnome-sound-recorder gnome-system-monitor gnome-text-editor qbittorrent wine evince epiphany-browser nomacs-l10n diodon yt-dlp mpv libmpv-dev aptitude mc ncdu ddcutil ddccontrol gddccontrol ddccontrol-db i2c-tools curl ca-certificates qalculate-gtk fuse libfuse-dev gir1.2-gnomedesktop-3.0 python3-dbus python3-gi gir1.2-glib-2.0 dbus python3-full xclip devilspie2 ffmpeg ripgrep -y
sudo modprobe i2c-dev
sudo gpasswd -a "$USER" i2c

sudo apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.usebottles.bottles org.gnome.meld it.mijorus.gearlever io.github.flattool.Warehouse com.raggesilver.BlackBox -y