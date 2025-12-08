/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

LINE='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

if ! grep -Fxq "$LINE" ~/.bashrc; then
  echo "$LINE" >> ~/.bashrc
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc
