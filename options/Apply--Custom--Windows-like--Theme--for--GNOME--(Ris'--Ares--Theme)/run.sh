sudo apt install gir1.2-gnomedesktop-3.0 gir1.2-gnomedesktop-4.0 libgnome-menu-3-dev gnome-shell-extension-apps-menu gnome-shell-extension-arc-menu -y
# Download and apply dconf settings safely
temp_conf=$(mktemp)
curl -fsSL https://raw.githubusercontent.com/RisPNG/debian-install-scripts/refs/heads/main/Ares.conf -o "$temp_conf"
dconf load / < "$temp_conf"
rm -f "$temp_conf"