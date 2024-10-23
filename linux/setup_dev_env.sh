#!/bin/bash

# Function to install Oh My Bash
install_oh_my_bash() {
    if [ ! -d "$HOME/.oh-my-bash" ]; then
        echo "Installing Oh My Bash..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
    else
        echo "Oh My Bash is already installed."
    fi
}

# Function to update and install necessary packages
install_essentials() {
    echo "Updating package list and installing essential packages..."
    sudo apt-get update

    packages=(
        "build-essential" "vim-nox" "valgrind" "git" "gh" "zip" "unzip" "tmux"
        "xclip" "ca-certificates" "curl" "ninja-build" "gettext" "libtool"
        "libtool-bin" "autoconf" "automake" "cmake" "g++" "pkg-config" "unzip"
        "libssl-dev" "zlib1g-dev" "libbz2-dev" "libreadline-dev" "libsqlite3-dev"
        "wget" "llvm" "libncurses5-dev" "xz-utils" "tk-dev" "libxml2-dev"
        "libxmlsec1-dev" "libffi-dev" "liblzma-dev" "clang" "gdb" "make"
    )

    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q $pkg; then
            sudo apt-get install -y $pkg
        else
            echo "$pkg is already installed."
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
    ssh-keygen -t ed25519 -C "shelt15.nn@gmail.com" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    log "SSH key generated."

    log "Adding SSH key to GitHub using gh CLI..."
    if ! command -v gh &>/dev/null; then
        log "GitHub CLI (gh) is not installed. Installing..."
        sudo apt-get install -y gh
    fi
    gh auth login
    gh ssh-key add ~/.ssh/id_ed25519.pub --title "My SSH Key"
    log "SSH key added to GitHub."
}

# Function to install Go using goenv and latest version of Go
install_goenv() {
    if [ ! -d "$HOME/.goenv" ]; then
        echo "Installing goenv..."
        git clone https://github.com/go-nv/goenv.git ~/.goenv

        echo 'export GOENV_ROOT="$HOME/.goenv"' >>~/.bashrc
        echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >>~/.bashrc
        echo 'eval "$(goenv init -)"' >>~/.bashrc
        export PATH="$GOROOT/bin:$PATH" >>~/.bashrc
        export PATH="$PATH:$GOPATH/bin" >>~/.bashrc

        # Apply changes to current shell session
        source ~/.bashrc
    else
        echo "goenv is already installed."
    fi

    # Install the latest Go version
    latest_go_version=$(goenv install -l | grep -v - | tail -1)
    goenv install $latest_go_version
    goenv global $latest_go_version
}

# Function to install Node.js using n
install_node() {
    if ! command -v node &>/dev/null; then
        echo "Installing Node.js..."
        curl -L https://bit.ly/n-install | bash

        # No need to manually export the PATH, n installer takes care of it
        source ~/.bashrc
    else
        echo "Node.js is already installed."
    fi
}

# Function to install Rust
install_rust() {
    if ! command -v rustc &>/dev/null; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    else
        echo "Rust is already installed."
    fi
}

# Function to install pyenv and latest Python version
install_pyenv() {
    if [ ! -d "$HOME/.pyenv" ]; then
        echo "Installing pyenv..."
        curl https://pyenv.run | bash

        echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.bashrc
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.bashrc
        echo 'eval "$(pyenv init --path)"' >>~/.bashrc
        echo 'eval "$(pyenv init -)"' >>~/.bashrc

        # Apply changes to current shell session
        source ~/.bashrc
    else
        echo "pyenv is already installed."
    fi

    # Install the latest Python version
    latest_python_version=$(pyenv install --list | grep -v - | grep -v b | tail -1)
    pyenv install $latest_python_version
    pyenv global $latest_python_version
}

# Function to install SDKMAN
install_sdkman() {
    if [ ! -d "$HOME/.sdkman" ]; then
        echo "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        echo "SDKMAN is already installed."
    fi
}

# Function to build and install Neovim from source
install_neovim() {
    if ! command -v nvim &>/dev/null; then
        echo "Cloning Neovim repository..."
        git clone https://github.com/neovim/neovim.git
        mkdir -p ~/Documents/Packages/
        mv neovim ~/Documents/Packages/

        echo "Building Neovim..."
        cd ~/Documents/Packages/neovim
        make CMAKE_BUILD_TYPE=Release

        echo "Installing Neovim..."
        sudo make install

        echo "Cleaning up build files..."
        make clean
    else
        echo "Neovim is already installed."
    fi
}

# Function to install fzf
install_fzf() {
    if [ ! -d "$HOME/.fzf" ]; then
        echo "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    else
        echo "fzf is already installed."
    fi
}

# Function to install fzf-tab-completion
install_fzf_tab_completion() {
    FZF_TAB_DIR="$HOME/.local/share/fzf"
    if [ ! -d "$FZF_TAB_DIR" ]; then
        echo "Creating directory for fzf-tab-completion..."
        mkdir -p "$FZF_TAB_DIR"
    fi

    if [ ! -d "$FZF_TAB_DIR/fzf-tab-completion" ]; then
        echo "Installing fzf-tab-completion..."
        git clone https://github.com/lincheney/fzf-tab-completion.git "$FZF_TAB_DIR/fzf-tab-completion"
    else
        echo "fzf-tab-completion is already installed."
    fi
}

# Function to install Tmux Plugin Manager
install_tpm() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    else
        echo "Tmux Plugin Manager is already installed."
    fi
}

# Function to install lazygit using Go
install_lazygit() {
    if ! command -v lazygit &>/dev/null; then
        echo "Installing lazygit..."
        go install github.com/jesseduffield/lazygit@latest
    else
        echo "lazygit is already installed."
    fi
}

# Function to install lazydocker using Go
install_lazydocker() {
    if ! command -v lazydocker &>/dev/null; then
        echo "Installing lazydocker..."
        go install github.com/jesseduffield/lazydocker@latest
    else
        echo "lazydocker is already installed."
    fi
}

# Function to install usql using Go
install_usql() {
    if ! command -v usql &>/dev/null; then
        echo "Installing usql..."
        go install -tags most github.com/xo/usql@latest
    else
        echo "usql is already installed."
    fi
}

# Function to install PlatformIO CLI
install_platformio() {
    if [ ! -d "$HOME/.platformio" ]; then
        echo "Installing PlatformIO CLI..."
        curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py | python3

        # Check if ~/.local/bin/ is in the PATH
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo "export PATH=\$HOME/.local/bin:\$PATH" >>~/.bashrc
            echo "Added ~/.local/bin to PATH."
            source ~/.bashrc
        fi

        # Create symlinks for PlatformIO
        ln -s ~/.platformio/penv/bin/platformio ~/.local/bin/platformio
        ln -s ~/.platformio/penv/bin/pio ~/.local/bin/pio
        ln -s ~/.platformio/penv/bin/piodebuggdb ~/.local/bin/piodebuggdb

        echo "PlatformIO CLI installation and symlinks created."
    else
        echo "PlatformIO CLI is already installed."
    fi
}

# Function to install dnvm
install_dnvm() {
    echo "Installing dnvm..."
    curl --proto '=https' -sSf https://dnvm.net/install.sh | sh
}

# Function to install phpenv
install_phpenv() {
    echo "Installing phpenv..."
    curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash
}

# Run all the functions
install_essentials
setup_git
setup_ssh_key_for_github
install_goenv
install_node
install_rust
install_pyenv
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

# Re-source .bashrc to apply changes
source ~/.bashrc

echo "All tools installed successfully! Please restart your session for the changes to take effect."
