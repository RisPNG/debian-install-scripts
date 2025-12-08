if ! grep -q 'venv()' ~/.bashrc; then
  cat >> ~/.bashrc <<'EOF'
export WORKON_HOME="${WORKON_HOME:-$HOME/.venvs}"

venv() {
  local cmd="$1"
  local name="$2"
  shift 2
  mkdir -p "$WORKON_HOME"
  case "$cmd" in
  "")
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│                Python Virtual Environment Manager               │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo
    echo "Usage:"
    echo "  venv create | make | mk <name>      # Create a new virtual environment"
    echo "  venv activate | use <name>          # Activate (create if missing) environment"
    echo "  venv deactivate | exit | quit | q   # Deactivate current environment"
    echo "  venv (del)ete | remove | rm <name>  # Delete a virtual environment"
    echo "  venv list | ls                      # List all environments"
    echo
    echo "Examples:"
    echo "  venv make myproject                 # Create 'myproject' environment"
    echo "  venv use myproject                  # Activate 'myproject'"
    echo "  venv deactivate                     # Exit current environment"
    echo "  venv rm oldproject                  # Remove 'oldproject'"
    echo "  venv list                           # Show all environments"
    echo
    ;;
  create | make | mk)
    if [ -z "$name" ]; then
      echo "Error: Virtual environment name required."
      return 1
    fi
    if [ -d "$WORKON_HOME/$name" ]; then
      echo "Virtual environment '$name' already exists."
      return 1
    fi
    echo "Creating virtual environment '$name'..."
    python -m venv "$WORKON_HOME/$name" && echo "Created virtual environment at $WORKON_HOME/$name"
    ;;
  activate | use)
    if [ -z "$name" ]; then
      echo "Error: Virtual environment name required."
      return 1
    fi

    if [ ! -d "$WORKON_HOME/$name" ]; then
      echo "Virtual environment '$name' does not exist."
      echo

      # Show available environments
      if [ -d "$WORKON_HOME" ] && [ "$(ls -A "$WORKON_HOME" 2>/dev/null)" ]; then
        echo "Available environments:"
        ls -1 "$WORKON_HOME" | sed 's/^/  • /'
        echo
      fi

      # Ask if user wants to create the environment
      echo -n "Would you like to create and activate '$name'? [y/N]: "
      read -r response
      case "$response" in
        [yY]|[yY][eE][sS])
          echo "Creating virtual environment '$name'..."
          if python -m venv "$WORKON_HOME/$name"; then
            echo "Created virtual environment at $WORKON_HOME/$name"
          else
            echo "Failed to create virtual environment: $name"
            return 1
          fi
          ;;
        *)
          echo "Cancelled."
          return 1
          ;;
      esac
    fi

    if [ -f "$WORKON_HOME/$name/bin/activate" ]; then
      # shellcheck disable=SC1090
      source "$WORKON_HOME/$name/bin/activate"
      echo "Activated virtual environment: $name"
    else
      echo "Failed to activate virtual environment: $name"
    fi
    ;;
  deactivate | exit | quit | q)
    if type deactivate &>/dev/null; then
      deactivate && echo "Deactivated virtual environment"
    else
      echo "No active virtual environment to deactivate."
    fi
    ;;
  delete | del | remove | rm)
    if [ -z "$name" ]; then
      echo "Error: Virtual environment name required."
      return 1
    fi
    if [ ! -d "$WORKON_HOME/$name" ]; then
      echo "Virtual environment '$name' does not exist."

      # Show available environments for reference
      if [ -d "$WORKON_HOME" ] && [ "$(ls -A "$WORKON_HOME" 2>/dev/null)" ]; then
        echo
        echo "Available environments:"
        ls -1 "$WORKON_HOME" | sed 's/^/  • /'
      fi
      return 1
    fi

    echo -n "Are you sure you want to delete virtual environment '$name'? [y/N]: "
    read -r response
    case "$response" in
      [yY]|[yY][eE][sS])
        echo "Deleting virtual environment '$name'..."
        rm -rf "$WORKON_HOME/$name" && echo "Deleted virtual environment: $name"
        ;;
      *)
        echo "Cancelled."
        ;;
    esac
    ;;
  list | ls)
    echo "Available virtual environments:"
    if [ -d "$WORKON_HOME" ] && [ "$(ls -A "$WORKON_HOME" 2>/dev/null)" ]; then
      # Show current active environment if any
      if [ -n "$VIRTUAL_ENV" ]; then
        current_env=$(basename "$VIRTUAL_ENV")
        ls -1 "$WORKON_HOME" | while read -r env; do
          if [ "$env" = "$current_env" ]; then
            echo "  • $env (active)"
          else
            echo "  • $env"
          fi
        done
      else
        ls -1 "$WORKON_HOME" | sed 's/^/  • /'
      fi
    else
      echo "  (no environments found)"
    fi
    ;;
  *)
    echo "Unknown command: '$cmd'"
    echo "Type 'venv' for help."
    ;;
  esac
}
EOF
fi
