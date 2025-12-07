sudo apt install -y apt-transport-https curl
sudo mkdir -p /etc/apt/keyrings
curl -sSfL https://packages.openvpn.net/packages-repo.gpg | sudo tee /etc/apt/keyrings/openvpn.asc >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/openvpn.asc] https://packages.openvpn.net/openvpn3/debian trixie main" | sudo tee /etc/apt/sources.list.d/openvpn3.list >/dev/null
sudo apt update
sudo apt install -y openvpn3-client