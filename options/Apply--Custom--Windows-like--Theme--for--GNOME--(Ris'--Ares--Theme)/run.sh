# Download and apply dconf settings safely
temp_conf=$(mktemp)
curl -fsSL https://raw.githubusercontent.com/RisPNG/debian-install-scripts/refs/heads/main/Ares.conf -o "$temp_conf"
dconf load / < "$temp_conf"
rm -f "$temp_conf"