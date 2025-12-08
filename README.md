# Debian 13 "Trixie" GNOME Post-Installation Setup

This guide provides a comprehensive set of steps to configure a fresh Debian 13 "Trixie" GNOME installation from the live ISO. It covers everything from the initial setup to system updates, application installations, and theming.

These are very opinionated. You're responsible for what you do with your system.

## Initial Installation

First, you gotta boot from the `debian-live-13.x.x-amd64-gnome.iso`.

1.  Start the "Live system (amd64)".
2.  Skip the initial tour and connect to a network through `Settings`.
3.  Run the "Install Debian" application.
4.  Follow the Calamares installer prompts:
    *   Language: "American English" (Default)
    *   Location: "Asia", "Kuala Lumpur", with locale "en\_GB.UTF-8"
    *   Keyboard: "English (US)", "Default"
5.  For partitioning, choose "Manual Partitioning":
    *   Create a "New Partition Table" with the "GPT" scheme.
    *   Create a 1024 MiB `fat32` partition for `/boot/efi` and set the `boot` flag.
    *   Create a `btrfs` partition using the remaining space for the root directory (`/`).
    *   If you have any additional disks, you can create a `btrfs` partition for the directory (`/ext1`, `/ext2`, ...).
6.  Proceed to set up your user account and complete the installation.
7.  Once you've booted into your new system, it's a good idea to install `timeshift` and create your first "Initial installation" snapshot as a backup.

## System Preparation

Run the following script and choose the options you want to install:
```bash
curl -fsSL https://raw.githubusercontent.com/RisPNG/debian-install-scripts/refs/heads/main/install.sh | bash
```

### Other recommended GUI applications that can't be installed with the script

These are best installed manually from their websites.
*   [Vivaldi](https://vivaldi.com/download/)
*   [Stacher](https://stacher.io/)
*   [Insync](https://www.insynchq.com/downloads/linux#debian)
*   [Keyguard](https://github.com/AChep/keyguard-app/releases/latest)
*   [Moonlight](https://github.com/moonlight-stream/moonlight-qt/releases/latest)
*   [Beeper](https://www.beeper.com/download)
*   [Harmonoid](https://harmonoid.com/downloads#)

Reboot one last time, and you should be good to go.

[*Extra*](https://docs.google.com/document/d/14fZTNXHTvwtGg4zEr4JCuajR_uytKWGnToI8DPPUmBQ/edit?usp=sharing)
