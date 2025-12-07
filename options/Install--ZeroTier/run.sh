# Download and run zerotier install script safely
temp_script=$(mktemp)
curl -fsSL https://install.zerotier.com -o "$temp_script"
sudo bash "$temp_script"
rm -f "$temp_script"

sudo systemctl enable zerotier-one --now