sudo apt install timeshift git -y
cd ~/Documents
mkdir Git
cd Git
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install
sudo systemctl start grub-btrfsd
sudo systemctl enable grub-btrfsd