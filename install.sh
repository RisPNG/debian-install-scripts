#!/bin/bash

# Debian Modular Installer Script
# Uses Charm Gum for interactive UI
# Reads install options from GitHub repo

set -e

REPO_OWNER="RisPNG"
REPO_NAME="debian-install-scripts"
BRANCH="main"
OPTIONS_PATH="options"
GITHUB_API="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents/${OPTIONS_PATH}?ref=${BRANCH}"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/${OPTIONS_PATH}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if gum is installed
check_gum() {
    if ! command -v gum &> /dev/null; then
        echo -e "${YELLOW}Charm Gum is not installed. Installing...${NC}"
        # Install gum
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install gum -y
        echo -e "${GREEN}Gum installed successfully!${NC}"
    fi
}

# Check for required tools
check_dependencies() {
    local missing=()
    
    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${YELLOW}Installing missing dependencies: ${missing[*]}${NC}"
        sudo apt update && sudo apt install -y "${missing[@]}"
    fi
}

# Fetch available options from GitHub
fetch_options() {
    echo -e "${BLUE}Fetching available install options from GitHub...${NC}"
    
    local response
    response=$(curl -s "$GITHUB_API")
    
    # Check for API errors
    if echo "$response" | jq -e '.message' &> /dev/null; then
        echo -e "${RED}Error fetching from GitHub: $(echo "$response" | jq -r '.message')${NC}"
        exit 1
    fi
    
    # Get directories only (type == "dir")
    FOLDERS=$(echo "$response" | jq -r '.[] | select(.type == "dir") | .name')
    
    if [ -z "$FOLDERS" ]; then
        echo -e "${RED}No install options found in the repository.${NC}"
        exit 1
    fi
}

# Convert folder name to display name (replace dashes with spaces)
to_display_name() {
    echo "$1" | sed 's/-/ /g'
}

# Convert display name back to folder name (replace spaces with dashes)
to_folder_name() {
    echo "$1" | sed 's/ /-/g'
}

# Run apt maintenance commands
run_apt_maintenance() {
    echo -e "${BLUE}Running APT maintenance...${NC}"
    
    sudo apt update
    
    # Check if modernize-sources exists (newer apt versions)
    if apt-get --help 2>&1 | grep -q "modernize-sources"; then
        sudo apt modernize-sources -y
        sudo apt update
    fi
    
    sudo apt upgrade -y
    sudo apt full-upgrade -y
    sudo apt dist-upgrade -y
    sudo apt update
    sudo apt autoclean -y
    
    # Use autopurge if available, otherwise autoremove with purge
    if apt-get --help 2>&1 | grep -q "autopurge"; then
        sudo apt autopurge -y
    else
        sudo apt autoremove --purge -y
    fi
    
    sudo apt autoremove -y
    sudo apt clean -y
    
    echo -e "${GREEN}APT maintenance complete!${NC}"
}

# Download and run script for a selected option
run_install_script() {
    local folder="$1"
    local script_url="${RAW_BASE}/${folder}/run.sh"
    local temp_script="/tmp/install_${folder}_run.sh"
    
    echo -e "${BLUE}Downloading install script for: $(to_display_name "$folder")${NC}"
    
    if curl -fsSL "$script_url" -o "$temp_script"; then
        chmod +x "$temp_script"
        echo -e "${GREEN}Running install script for: $(to_display_name "$folder")${NC}"
        bash "$temp_script"
        rm -f "$temp_script"
    else
        echo -e "${RED}Failed to download run.sh for: $(to_display_name "$folder")${NC}"
        return 1
    fi
}

# Main function
main() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║          Debian Modular Installer                         ║"
    echo "║          Using Charm Gum for interactive selection        ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check and install dependencies
    check_dependencies
    check_gum
    
    # Fetch available options
    fetch_options
    
    # Build display names array
    declare -a display_names
    while IFS= read -r folder; do
        display_names+=("$(to_display_name "$folder")")
    done <<< "$FOLDERS"
    
    # Show selection UI with gum
    echo -e "${YELLOW}Use arrow keys to navigate, Space to select/deselect, Enter to confirm${NC}"
    echo ""
    
    # Use gum choose with multi-select
    selected=$(printf '%s\n' "${display_names[@]}" | gum choose --no-limit --cursor.foreground="212" --selected.foreground="120" --header="Select packages to install:")
    
    # Check if anything was selected
    if [ -z "$selected" ]; then
        echo -e "${YELLOW}No options selected. Exiting.${NC}"
        exit 0
    fi
    
    # Show what will be installed
    echo ""
    echo -e "${BLUE}You have selected the following for installation:${NC}"
    echo "$selected" | while read -r name; do
        echo -e "  ${GREEN}✓${NC} $name"
    done
    echo ""
    
    # Confirm installation
    if gum confirm "Proceed with installation?"; then
        echo ""
        echo -e "${GREEN}Starting installation process...${NC}"
        echo ""
        
        # Run pre-install apt maintenance
        echo -e "${BLUE}═══ PRE-INSTALL MAINTENANCE ═══${NC}"
        run_apt_maintenance
        echo ""
        
        # Run install scripts for each selected option
        echo -e "${BLUE}═══ INSTALLING SELECTED PACKAGES ═══${NC}"
        echo "$selected" | while read -r display_name; do
            folder_name=$(to_folder_name "$display_name")
            echo ""
            echo -e "${YELLOW}────────────────────────────────────────${NC}"
            run_install_script "$folder_name"
        done
        echo ""
        
        # Run post-install apt maintenance
        echo -e "${BLUE}═══ POST-INSTALL MAINTENANCE ═══${NC}"
        run_apt_maintenance
        echo ""
        
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║          Installation Complete!                           ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
}

# Run main function
main "$@"
