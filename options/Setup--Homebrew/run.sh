/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

SHELL_RC="${HOME}/.bashrc"
if ! grep -q 'brew shellenv' "$SHELL_RC"; then
    echo >> "$SHELL_RC"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$SHELL_RC"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc
