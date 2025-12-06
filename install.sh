#!/bin/bash

# Configuration
GITHUB_USER="RisPNG"
REPO_NAME="debian-install-scripts"
BRANCH="main"
OPTIONS_PATH="options"
API_URL="https://api.github.com/repos/${GITHUB_USER}/${REPO_NAME}/contents/${OPTIONS_PATH}?ref=${BRANCH}"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Install gum if not present
install_gum() {
    if ! command -v gum &> /dev/null; then
        echo -e "${YELLOW}Installing gum...${NC}"
        
        # Detect architecture
        ARCH=$(dpkg --print-architecture)
        
        # Get latest release
        GUM_VERSION=$(curl -s https://api.github.com/repos/charmbracelet/gum/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
        
        if [ -z "$GUM_VERSION" ]; then
            echo -e "${RED}Could not determine latest gum version${NC}"
            exit 1
        fi
        
        # Download and install
        GUM_DEB="gum_${GUM_VERSION#v}_${ARCH}.deb"
        wget -q "https://github.com/charmbracelet/gum/releases/download/${GUM_VERSION}/${GUM_DEB}" -O /tmp/gum.deb
        
        sudo dpkg -i /tmp/gum.deb
        rm /tmp/gum.deb
        
        echo -e "${GREEN}gum installed successfully!${NC}"
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("curl" "jq" "wget")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing missing dependencies: ${missing[*]}${NC}"
        sudo apt update
        sudo apt install -y "${missing[@]}"
    fi
    
    # Install gum
    install_gum
}

# Fetch available options from GitHub
fetch_options() {
    gum style --foreground 212 --border double --padding "1 2" --margin "1" "Fetching available options from GitHub..."
    
    local response=$(curl -s "$API_URL")
    
    if [ -z "$response" ]; then
        gum style --foreground 196 "Error: Could not fetch options from GitHub"
        exit 1
    fi
    
    # Parse folder names using jq
    local folders=$(echo "$response" | jq -r '.[] | select(.type=="dir") | .name')
    
    if [ -z "$folders" ]; then
        gum style --foreground 196 "Error: No folders found in ${OPTIONS_PATH}"
        exit 1
    fi
    
    echo "$folders"
}

# Create gum menu from folders
create_menu() {
    local folders=("$@")
    local display_items=()
    
    for folder in "${folders[@]}"; do
        # Replace dashes with spaces for display
        local display_name="${folder//-/ }"
        display_items+=("$display_name")
    done
    
    # Show multi-select menu using gum
    gum style --foreground 212 --bold "Select packages to install:"
    echo ""
    
    local selected=$(printf '%s\n' "${display_items[@]}" | \
        gum choose --no-limit \
        --cursor.foreground 212 \
        --header "Use ↑/↓ to navigate, Space to select, Enter to confirm" \
        --height 15)
    
    # Convert display names back to folder names
    if [ -n "$selected" ]; then
        echo "$selected" | while IFS= read -r line; do
            # Replace spaces back to dashes
            echo "${line// /-}"
        done
    fi
}

# Run system update commands
run_updates() {
    gum style --foreground 212 --bold "Running system updates..."
    
    gum spin --spinner dot --title "Updating system..." -- \
        bash -c 'sudo apt update && \
        sudo apt modernize-sources -y && \
        sudo apt update && \
        sudo apt upgrade -y && \
        sudo apt full-upgrade -y && \
        sudo apt dist-upgrade -y && \
        sudo apt update && \
        sudo apt autoclean -y && \
        sudo apt autopurge -y && \
        sudo apt autoremove -y && \
        sudo apt clean -y'
}

# Download and execute run.sh from selected folder
execute_script() {
    local folder=$1
    local display_name="${folder//-/ }"
    local script_url="${RAW_URL}/${OPTIONS_PATH}/${folder}/run.sh"
    local temp_script="/tmp/${folder}_run.sh"
    
    gum style --foreground 212 --bold "Installing: ${display_name}"
    
    # Download the script
    if curl -sSL "$script_url" -o "$temp_script" 2>/dev/null; then
        # Make it executable
        chmod +x "$temp_script"
        
        # Execute it
        bash "$temp_script"
        
        # Clean up
        rm -f "$temp_script"
        
        gum style --foreground 42 "✓ Completed: ${display_name}"
        echo ""
    else
        gum style --foreground 196 "✗ Error: Could not download ${script_url}"
        return 1
    fi
}

# Main function
main() {
    clear
    
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        'Debian Modular Installer' 'Powered by Charm'
    
    echo ""
    
    # Check and install dependencies
    check_dependencies
    
    echo ""
    
    # Fetch available options
    folders=$(fetch_options)
    
    if [ -z "$folders" ]; then
        gum style --foreground 196 "No options available"
        exit 1
    fi
    
    # Convert to array
    readarray -t folder_array <<< "$folders"
    
    echo ""
    
    # Show menu and get selection
    selected=$(create_menu "${folder_array[@]}")
    
    if [ -z "$selected" ]; then
        echo ""
        gum style --foreground 214 "No packages selected. Exiting."
        exit 0
    fi
    
    echo ""
    
    # Show selected packages
    gum style --foreground 212 --bold "Selected packages:"
    echo "$selected" | while IFS= read -r line; do
        echo "  • ${line//-/ }"
    done
    
    echo ""
    
    # Ask for confirmation
    gum confirm "Proceed with installation?" || {
        gum style --foreground 214 "Installation cancelled."
        exit 0
    }
    
    echo ""
    
    # Run pre-installation updates
    gum style --border double --padding "0 1" --border-foreground 212 "Pre-Installation Updates"
    run_updates
    
    echo ""
    
    # Execute selected scripts
    gum style --border double --padding "0 1" --border-foreground 212 "Installing Selected Packages"
    echo ""
    
    echo "$selected" | while IFS= read -r folder; do
        execute_script "$folder"
    done
    
    # Run post-installation updates
    gum style --border double --padding "0 1" --border-foreground 212 "Post-Installation Updates"
    run_updates
    
    echo ""
    
    gum style \
        --foreground 42 --border-foreground 42 --border double \
        --align center --width 50 --margin "1 2" --padding "1 4" \
        '✓ Installation Complete!'
}

# Run main function
main
