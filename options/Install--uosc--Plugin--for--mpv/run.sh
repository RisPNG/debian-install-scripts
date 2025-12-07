sudo apt install mpv -y
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh)"
mkdir -p ~/.config/mpv && tee ~/.config/mpv/mpv.conf <<EOF
keep-open=always
idle=yes
force-window=yes
EOF