TARGET="/etc/sudoers.d/99-$(whoami)-nopasswd"
echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee "$TARGET" > /dev/null
sudo chown root:root "$TARGET"
sudo chmod 0440 "$TARGET"
sudo visudo -c
