sudo apt install timeshift git -y
cd ~/Documents
mkdir -p Git
cd Git
if [ ! -d grub-btrfs ]; then
    git clone https://github.com/Antynea/grub-btrfs.git
fi
cd grub-btrfs
sudo make install
sudo systemctl start grub-btrfsd
sudo systemctl enable grub-btrfsd
