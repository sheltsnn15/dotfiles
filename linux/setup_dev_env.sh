#!/bin/bash

# Helper function for logging messages with timestamp
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Trap for handling script interruptions
cleanup() {
    log "Script interrupted. Performing cleanup..."
    exit 1
}

trap cleanup SIGINT SIGTERM

# Function to install Oh My Bash
install_oh_my_bash() {
    if [ ! -d "$HOME/.oh-my-bash" ]; then
        log "Installing Oh My Bash..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" || {
            log "Failed to install Oh My Bash."
            exit 1
        }
    else
        log "Oh My Bash is already installed."
    fi
}

# Function to update and install necessary packages
install_essentials() {
    log "Updating package list and installing essential packages..."
    sudo apt-get update -y || {
        log "Package list update failed."
        exit 1
    }

    packages=(
        build-essential vim-nox valgrind git gh zip unzip tmux xclip
        ca-certificates curl ninja-build gettext libtool libtool-bin autoconf
        automake cmake g++ pkg-config libssl-dev zlib1g-dev libbz2-dev
        libreadline-dev libsqlite3-dev wget llvm libncurses5-dev xz-utils tk-dev
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev clang gdb make gettext
        ripgrep fd-find yq jq shellcheck texlive-full
    )

    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "$pkg"; then
            sudo apt-get install -y "$pkg" || {
                log "Failed to install package: $pkg"
                exit 1
            }
        else
            log "$pkg is already installed."
        fi
    done
}

# Function to set up Git configuration
setup_git() {
    log "Setting up Git global configuration..."
    git config --global user.name "Shelton Ngwenya"
    git config --global user.email "shelt15.nn@gmail.com"
}

# Function to generate SSH key and add it to GitHub using the GitHub CLI
setup_ssh_key_for_github() {
    log "Generating SSH key for GitHub..."
    ssh-keygen -t ed25519 -C "shelt15.nn@gmail.com" -f ~/.ssh/id_ed25519 -N "" || {
        log "SSH key generation failed."
        exit 1
    }
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    log "SSH key generated."

    log "Adding SSH key to GitHub using gh CLI..."
    if ! command -v gh &>/dev/null; then
        log "GitHub CLI (gh) is not installed. Installing..."
        sudo apt-get install -y gh || {
            log "Failed to install GitHub CLI."
            exit 1
        }
    fi
    gh auth login
    gh ssh-key add ~/.ssh/id_ed25519.pub --title "My SSH Key"
    log "SSH key added to GitHub."
}

# Function to install goenv
install_goenv() {
    if [ ! -d "$HOME/.goenv" ]; then
        log "Installing goenv..."
        git clone https://github.com/go-nv/goenv.git ~/.goenv || {
            log "Failed to clone goenv repository."
            exit 1
        }

        # Add goenv setup to .bashrc
        echo 'export GOENV_ROOT="$HOME/.goenv"' >>~/.bashrc
        echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >>~/.bashrc
        echo 'eval "$(goenv init -)"' >>~/.bashrc
        echo 'export PATH="$GOROOT/bin:$PATH"' >>~/.bashrc
        echo 'export PATH="$PATH:$GOPATH/bin"' >>~/.bashrc

        # Source .bashrc to ensure goenv is in the current shell environment
        source ~/.bashrc

        # Verify goenv command is now available
        if ! command -v goenv &>/dev/null; then
            log "goenv command not found after installation. Exiting."
            exit 1
        fi
    else
        log "goenv is already installed."
    fi
}

# Function to install a specific Go version
install_go_version() {
    if ! command -v goenv &>/dev/null; then
        log "goenv is not installed. Please install goenv first."
        return
    fi

    log "Available Go versions:"
    goenv install -l | grep -v - | tail -n 20

    read -p "Enter the Go version you want to install (e.g., 1.17.1), or press Enter to install the latest version: " go_version

    if [ -z "$go_version" ]; then
        go_version=$(goenv install -l | grep -v - | tail -1)
        log "Installing the latest Go version: $go_version"
    else
        log "Installing Go version: $go_version"
    fi

    goenv install "$go_version" || {
        log "Failed to install Go version: $go_version"
        exit 1
    }

    read -p "Do you want to set Go $go_version as global? (y/n): " set_global
    if [[ "$set_global" == "y" || "$set_global" == "Y" ]]; then
        goenv global "$go_version"
        log "Set Go $go_version as global version."
    fi
}

# Function to install Node.js using n
install_node() {
    if ! command -v node &>/dev/null; then
        log "Installing Node.js..."
        curl -L https://bit.ly/n-install | bash || {
            log "Node.js installation failed."
            exit 1
        }
        source ~/.bashrc
    else
        log "Node.js is already installed."
    fi
}

# Function to install Rust
install_rust() {
    if ! command -v rustc &>/dev/null; then
        log "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || {
            log "Rust installation failed."
            exit 1
        }
        source $HOME/.cargo/env
    else
        log "Rust is already installed."
    fi
}

# Function to install pyenv
install_pyenv() {
    if [ ! -d "$HOME/.pyenv" ]; then
        log "Installing pyenv..."
        curl https://pyenv.run | bash || {
            log "Failed to install pyenv."
            exit 1
        }

        echo 'export PYENV_ROOT="${HOME}/.pyenv"' >>~/.bashrc
        echo 'export PATH="${PYENV_ROOT}/bin:${PATH}"' >>~/.bashrc
        echo 'eval "$(pyenv init --path)"' >>~/.bashrc
        echo 'eval "$(pyenv init -)"' >>~/.bashrc

        source ~/.bashrc
    else
        log "pyenv is already installed."
    fi
}

# Function to install a specific Python version
install_python_version() {
    if ! command -v pyenv &>/dev/null; then
        log "pyenv is not installed. Please install pyenv first."
        return
    fi

    log "Available Python versions:"
    pyenv install --list | grep -v - | grep -v b | tail -n 20

    read -p "Enter the Python version you want to install (e.g., 3.9.7), or press Enter to install the latest version: " python_version

    if [ -z "$python_version" ]; then
        python_version=$(pyenv install --list | grep -v - | grep -v b | tail -1)
        log "Installing the latest Python version: $python_version"
    else
        log "Installing Python version: $python_version"
    fi

    pyenv install "$python_version" || {
        log "Failed to install Python version: $python_version"
        exit 1
    }

    read -p "Do you want to set Python $python_version as global? (y/n): " set_global
    if [[ "$set_global" == "y" || "$set_global" == "Y" ]]; then
        pyenv global "$python_version"
        log "Set Python $python_version as global version."
    fi
}

# Function to install SDKMAN
install_sdkman() {
    if [ ! -d "$HOME/.sdkman" ]; then
        log "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash || {
            log "SDKMAN installation failed."
            exit 1
        }
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        log "SDKMAN is already installed."
    fi
}

# Function to build and install Neovim from source
install_neovim() {
    if ! command -v nvim &>/dev/null; then
        log "Cloning Neovim repository..."
        git clone https://github.com/neovim/neovim.git ~/Documents/Packages/neovim || {
            log "Failed to clone Neovim repository."
            exit 1
        }

        log "Building Neovim..."
        cd ~/Documents/Packages/neovim
        make CMAKE_BUILD_TYPE=Release || {
            log "Neovim build failed."
            exit 1
        }

        log "Installing Neovim..."
        sudo make install || {
            log "Failed to install Neovim."
            exit 1
        }
        make clean
    else
        log "Neovim is already installed."
    fi
}

# Function to install fzf
install_fzf() {
    if [ ! -d "$HOME/.fzf" ]; then
        log "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || {
            log "Failed to clone fzf repository."
            exit 1
        }
        ~/.fzf/install --all
    else
        log "fzf is already installed."
    fi
}

# Function to install fzf-tab-completion
install_fzf_tab_completion() {
    FZF_TAB_DIR="$HOME/.local/share/fzf"
    if [ ! -d "$FZF_TAB_DIR" ]; then
        log "Creating directory for fzf-tab-completion..."
        mkdir -p "$FZF_TAB_DIR"
    fi

    if [ ! -d "$FZF_TAB_DIR/fzf-tab-completion" ]; then
        log "Installing fzf-tab-completion..."
        git clone https://github.com/lincheney/fzf-tab-completion.git "$FZF_TAB_DIR/fzf-tab-completion" || {
            log "Failed to clone fzf-tab-completion."
            exit 1
        }
    else
        log "fzf-tab-completion is already installed."
    fi
}

# Function to install Tmux Plugin Manager
install_tpm() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || {
            log "Failed to install Tmux Plugin Manager."
            exit 1
        }
    else
        log "Tmux Plugin Manager is already installed."
    fi
}

# Function to install lazygit using Go
install_lazygit() {
    if ! command -v lazygit &>/dev/null; then
        log "Installing lazygit..."
        go install github.com/jesseduffield/lazygit@latest || {
            log "Failed to install lazygit."
            exit 1
        }
    else
        log "lazygit is already installed."
    fi
}

# Function to install lazydocker using Go
install_lazydocker() {
    if ! command -v lazydocker &>/dev/null; then
        log "Installing lazydocker..."
        go install github.com/jesseduffield/lazydocker@latest || {
            log "Failed to install lazydocker."
            exit 1
        }
    else
        log "lazydocker is already installed."
    fi
}

# Function to install usql using Go
install_usql() {
    if ! command -v usql &>/dev/null; then
        log "Installing usql..."
        go install -tags most github.com/xo/usql@latest || {
            log "Failed to install usql."
            exit 1
        }
    else
        log "usql is already installed."
    fi
}

# Function to install PlatformIO CLI
install_platformio() {
    if [ ! -d "$HOME/.platformio" ]; then
        log "Ensuring Python 3 is accessible for PlatformIO..."
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"

        log "Downloading and installing PlatformIO CLI..."
        curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
        python3 get-platformio.py || {
            log "PlatformIO installation failed."
            exit 1
        }

        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo "export PATH=\$HOME/.local/bin:\$PATH" >>~/.bashrc
            log "Added ~/.local/bin to PATH."
            source ~/.bashrc
        fi

        if [ -d "$HOME/.platformio/penv/bin" ]; then
            ln -s ~/.platformio/penv/bin/platformio ~/.local/bin/platformio
            ln -s ~/.platformio/penv/bin/pio ~/.local/bin/pio
            ln -s ~/.platformio/penv/bin/piodebuggdb ~/.local/bin/piodebuggdb
            log "PlatformIO CLI installation and symlinks created."
        else
            log "PlatformIO CLI installation failed."
        fi
    else
        log "PlatformIO CLI is already installed."
    fi
}

# Function to install dnvm
install_dnvm() {
    log "Installing dnvm..."
    curl --proto '=https' -sSf https://dnvm.net/install.sh | sh || {
        log "dnvm installation failed."
        exit 1
    }
}

# Function to install phpenv
install_phpenv() {
    log "Installing phpenv..."
    curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash || {
        log "phpenv installation failed."
        exit 1
    }
}

# Main menu function for interactive selection
main_menu() {
    while true; do
        echo "Select an option:"
        echo "1) Install essential packages"
        echo "2) Setup Git configuration"
        echo "3) Setup SSH key for GitHub"
        echo "4) Install Oh My Bash"
        echo "5) Install goenv"
        echo "6) Install Go version"
        echo "7) Install pyenv"
        echo "8) Install Python version"
        echo "9) Install Node.js"
        echo "10) Install Rust"
        echo "11) Install SDKMAN"
        echo "12) Install Neovim"
        echo "13) Install fzf"
        echo "14) Install fzf-tab-completion"
        echo "15) Install Tmux Plugin Manager"
        echo "16) Install lazygit"
        echo "17) Install lazydocker"
        echo "18) Install usql"
        echo "19) Install PlatformIO"
        echo "20) Install dnvm"
        echo "21) Install phpenv"
        echo "22) Install all components"
        echo "23) Exit"
        read -p "Enter your choice [1-23]: " choice

        case $choice in
            1) install_essentials ;;
            2) setup_git ;;
            3) setup_ssh_key_for_github ;;
            4) install_oh_my_bash ;;
            5) install_goenv ;;
            6) install_go_version ;;
            7) install_pyenv ;;
            8) install_python_version ;;
            9) install_node ;;
            10) install_rust ;;
            11) install_sdkman ;;
            12) install_neovim ;;
            13) install_fzf ;;
            14) install_fzf_tab_completion ;;
            15) install_tpm ;;
            16) install_lazygit ;;
            17) install_lazydocker ;;
            18) install_usql ;;
            19) install_platformio ;;
            20) install_dnvm ;;
            21) install_phpenv ;;
            22)
                install_essentials
                setup_git
                setup_ssh_key_for_github
                install_oh_my_bash
                install_goenv
                install_go_version
                install_pyenv
                install_python_version
                install_node
                install_rust
                install_sdkman
                install_neovim
                install_fzf
                install_fzf_tab_completion
                install_tpm
                install_lazygit
                install_lazydocker
                install_usql
                install_platformio
                install_dnvm
                install_phpenv
                ;;
            23) log "Exiting..."; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
        echo ""
    done
}

# Run the main menu
main_menu

source ~/.bashrc
log "All selected tools installed successfully! Please restart your session for the changes to take effect."
