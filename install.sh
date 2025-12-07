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
USE_LOCAL_OPTIONS=false
TEMP_CLONE_DIR=""
# Default to git-based option fetch to avoid API rate limits
: "${GITHUB_FETCH_WITH_GIT:=1}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"

is_truthy() {
    case "${1,,}" in
        1|true|yes|on) return 0 ;;
        *) return 1 ;;
    esac
}

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

    if is_truthy "${GITHUB_FETCH_WITH_GIT:-}" || is_truthy "${NO_GITHUB_API:-}"; then
        if ! command -v git &> /dev/null; then
            missing+=("git")
        fi
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${YELLOW}Installing missing dependencies: ${missing[*]}${NC}"
        sudo apt update && sudo apt install -y "${missing[@]}"
    fi
}

# Fall back to the local options/ directory when GitHub API cannot be used
use_local_options_directory() {
    if [ -d "$OPTIONS_PATH" ]; then
        local local_folders=()
        for dir in "$OPTIONS_PATH"/*/; do
            [ -d "$dir" ] || continue
            local_folders+=("$(basename "$dir")")
        done

        if [ ${#local_folders[@]} -gt 0 ]; then
            FOLDERS=$(printf '%s\n' "${local_folders[@]}")
            echo -e "${YELLOW}Using local options directory instead of GitHub API.${NC}"
            USE_LOCAL_OPTIONS=true
            return 0
        fi
    fi

    return 1
}

# Ensure dpkg/apt are not left in an interrupted state
ensure_package_system_ready() {
    echo -e "${BLUE}Checking package manager state...${NC}"

    if ! sudo dpkg --configure -a; then
        echo -e "${RED}dpkg --configure -a failed. Please resolve package manager issues and re-run the installer.${NC}"
        exit 1
    fi

    if ! sudo apt-get -f install -y; then
        echo -e "${RED}Failed to repair packages with 'apt-get -f install'. Resolve package issues and retry.${NC}"
        exit 1
    fi
}

cleanup_temp_clone() {
    if [ -n "$TEMP_CLONE_DIR" ] && [ -d "$TEMP_CLONE_DIR" ]; then
        rm -rf "$TEMP_CLONE_DIR"
    fi
}

fetch_options_via_git_clone() {
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}git is not installed; cannot fetch options via git.${NC}"
        return 1
    fi

    TEMP_CLONE_DIR=$(mktemp -d)
    echo -e "${BLUE}Cloning options via git (no GitHub API)...${NC}"

    if ! git clone --depth 1 --branch "$BRANCH" "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "$TEMP_CLONE_DIR" >/dev/null 2>&1; then
        echo -e "${RED}git clone failed; cannot fetch options via git.${NC}"
        cleanup_temp_clone
        return 1
    fi

    local options_dir="${TEMP_CLONE_DIR}/${OPTIONS_PATH}"
    if [ ! -d "$options_dir" ]; then
        echo -e "${RED}Cloned repository does not contain ${OPTIONS_PATH}.${NC}"
        cleanup_temp_clone
        return 1
    fi

    local local_folders=()
    for dir in "$options_dir"/*/; do
        [ -d "$dir" ] || continue
        local_folders+=("$(basename "$dir")")
    done

    if [ ${#local_folders[@]} -eq 0 ]; then
        echo -e "${RED}No install options found in cloned repository.${NC}"
        cleanup_temp_clone
        return 1
    fi

    FOLDERS=$(printf '%s\n' "${local_folders[@]}")
    OPTIONS_PATH="$options_dir"
    USE_LOCAL_OPTIONS=true
    echo -e "${YELLOW}Using options from git clone (no GitHub API).${NC}"
    return 0
}

# Fetch available options from GitHub
fetch_options() {
    echo -e "${BLUE}Fetching available install options from GitHub...${NC}"

    if is_truthy "${GITHUB_FETCH_WITH_GIT:-}" || is_truthy "${NO_GITHUB_API:-}"; then
        if fetch_options_via_git_clone; then
            return
        fi
        echo -e "${YELLOW}Git-based fetch failed; continuing with GitHub API/local fallback.${NC}"
    fi

    local auth_header=()
    if [ -n "$GITHUB_TOKEN" ]; then
        auth_header=(-H "Authorization: Bearer $GITHUB_TOKEN")
        echo -e "${YELLOW}Using GITHUB_TOKEN for GitHub API requests.${NC}"
    elif [ -n "$GH_TOKEN" ]; then
        auth_header=(-H "Authorization: Bearer $GH_TOKEN")
        echo -e "${YELLOW}Using GH_TOKEN for GitHub API requests.${NC}"
    fi
    
    local response
    response=$(curl -sSL "${auth_header[@]}" "$GITHUB_API" || true)
    
    # Check for API errors
    if [ -z "$response" ]; then
        echo -e "${YELLOW}GitHub API returned an empty response. Checking local options directory...${NC}"
        if fetch_options_via_git_clone; then
            return
        fi
        if ! use_local_options_directory; then
            echo -e "${RED}Failed to fetch install options from GitHub and no local options were found.${NC}"
            exit 1
        fi
        return
    fi

    if echo "$response" | jq -e '.message' &> /dev/null; then
        local api_message
        api_message=$(echo "$response" | jq -r '.message')
        echo -e "${YELLOW}GitHub API responded with: ${api_message}${NC}"

        if [[ "$api_message" == *"API rate limit exceeded"* ]]; then
            echo -e "${YELLOW}Tip: set GITHUB_TOKEN or GH_TOKEN to raise the rate limit.${NC}"
        fi

        if fetch_options_via_git_clone; then
            return
        fi

        if ! use_local_options_directory; then
            echo -e "${RED}Failed to fetch install options from GitHub and no local options were found.${NC}"
            exit 1
        fi
        return
    fi
    
    # Get directories only (type == "dir")
    FOLDERS=$(echo "$response" | jq -r '.[] | select(.type == "dir") | .name')
    
    if [ -z "$FOLDERS" ]; then
        echo -e "${YELLOW}No install options returned by GitHub API. Checking local options directory...${NC}"
        if fetch_options_via_git_clone; then
            return
        fi

        if ! use_local_options_directory; then
            echo -e "${RED}No install options found in the repository.${NC}"
            exit 1
        fi
    fi
}

# Convert folder name to display name (replace double dashes with spaces)
to_display_name() {
    echo "$1" | sed 's/--/ /g'
}

# Convert display name back to folder name (replace spaces with double dashes)
to_folder_name() {
    echo "$1" | sed 's/ /--/g'
}

# Run apt maintenance commands
run_apt_maintenance() {
    echo -e "${BLUE}Running APT maintenance...${NC}"
    
    ensure_package_system_ready
    
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
    ensure_package_system_ready
    
    echo -e "${GREEN}APT maintenance complete!${NC}"
}

# Download and run script for a selected option
run_install_script() {
    local folder="$1"
    local script_url="${RAW_BASE}/${folder}/run.sh"
    local temp_script="/tmp/install_${folder}_run.sh"
    local local_script="${OPTIONS_PATH}/${folder}/run.sh"
    
    if [ "$USE_LOCAL_OPTIONS" = true ] && [ -f "$local_script" ]; then
        echo -e "${BLUE}Using local install script for: $(to_display_name "$folder")${NC}"
        DEBIAN_FRONTEND=noninteractive bash "$local_script"
        return
    fi

    echo -e "${BLUE}Downloading install script for: $(to_display_name "$folder")${NC}"

    if curl -fsSL "$script_url" -o "$temp_script"; then
        chmod +x "$temp_script"
        echo -e "${GREEN}Running install script for: $(to_display_name "$folder")${NC}"
        DEBIAN_FRONTEND=noninteractive bash "$temp_script"
        rm -f "$temp_script"
    elif [ -f "$local_script" ]; then
        echo -e "${YELLOW}Download failed. Falling back to local run.sh for: $(to_display_name "$folder")${NC}"
        DEBIAN_FRONTEND=noninteractive bash "$local_script"
    else
        echo -e "${RED}Failed to download run.sh for: $(to_display_name "$folder") and no local copy was found.${NC}"
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

    trap cleanup_temp_clone EXIT
    
    ensure_package_system_ready

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
