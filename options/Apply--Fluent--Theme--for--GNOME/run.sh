cd ~/Documents/Git
git clone https://github.com/vinceliuice/Fluent-icon-theme
cd Fluent-icon-theme
chmod +x install.sh && ./install.sh -a
mkdir -p ~/.icons/Fluent && cp -r cursors/dist/* ~/.icons/Fluent/
mkdir -p ~/.icons/Fluent-Dark && cp -r cursors/dist-dark/* ~/.icons/Fluent-Dark/
cd ..
git clone https://github.com/vinceliuice/Fluent-gtk-theme
cd Fluent-gtk-theme
chmod +x install.sh && ./install.sh && ./install.sh --tweaks round