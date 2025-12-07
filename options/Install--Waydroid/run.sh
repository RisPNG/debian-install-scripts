# Download and run waydroid repo setup script safely
temp_script=$(mktemp)
curl -fsSL https://repo.waydro.id -o "$temp_script"
sudo bash "$temp_script"
rm -f "$temp_script"

sudo apt install waydroid -y