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

    packages=("build-essential" "vim-nox" "valgrind" "git" "gh" "zip" "unzip" "lazygit" "tmux" "xclip" "ca-certificates" "curl" "ninja-build" "gettext" "libtool" "libtool-bin" "autoconf" "automake" "cmake" "g++" "pkg-config" "unzip")
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q $pkg; then
            sudo apt-get install -y $pkg
        else
            echo "$pkg is already installed."
        fi
    done
}

# Function to install Go using goenv
install_goenv() {
    if [ ! -d "$HOME/.goenv" ]; then
        echo "Installing goenv..."
        git clone https://github.com/go-nv/goenv.git ~/.goenv

        echo 'export GOENV_ROOT="$HOME/.goenv"' >>~/.bashrc
        echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >>~/.bashrc
        echo 'eval "$(goenv init -)"' >>~/.bashrc

        # Add GOPATH and GOROOT to .bashrc
        echo 'export GOROOT=$(goenv root)/versions/$(goenv version)/go' >>~/.bashrc
        echo 'export GOPATH="$HOME/go"' >>~/.bashrc
        echo 'export PATH="$GOROOT/bin:$PATH"' >>~/.bashrc
        echo 'export PATH="$GOPATH/bin:$PATH"' >>~/.bashrc

        # Apply changes to current shell session
        source ~/.bashrc
    else
        echo "goenv is already installed."
    fi
}

# Function to install Go using goenv
install_go_version() {
    if ! command -v go &>/dev/null; then
        echo "Installing Go..."
        # Ensure goenv is initialized
        source ~/.bashrc
    else
        echo "Go is already installed."
    fi
}

# Function to install Node.js using n
install_node() {
    if ! command -v node &>/dev/null; then
        echo "Installing Node.js..."
        curl -L https://bit.ly/n-install | bash

        # Add n to PATH in .bashrc
        echo 'export N_PREFIX="$HOME/n"' >>~/.bashrc
        echo 'export PATH="$N_PREFIX/bin:$PATH"' >>~/.bashrc

        # Apply changes to current shell session
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
        echo 'source $HOME/.cargo/env' >>~/.bashrc
    else
        echo "Rust is already installed."
    fi
}

# Function to install pyenv
install_pyenv() {
    if [ ! -d "$HOME/.pyenv" ]; then
        echo "Installing pyenv..."
        curl https://pyenv.run | bash

        echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.bashrc
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.bashrc
        echo 'eval "$(pyenv init -)"' >>~/.bashrc

        # Apply changes to current shell session
        source ~/.bashrc
    else
        echo "pyenv is already installed."
    fi
}

# Function to install SDKMAN
install_sdkman() {
    if [ ! -d "$HOME/.sdkman" ]; then
        echo "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
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

# Function to install makedeb
install_makedeb() {
    if ! command -v makedeb &>/dev/null; then
        echo "Installing makedeb..."
        bash -ci "$(wget -qO - 'https://shlink.makedeb.org/install')"
    else
        echo "makedeb is already installed."
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

# Function to install lazygit
install_lazygit() {
    if ! command -v lazygit &>/dev/null; then
        echo "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    else
        echo "lazygit is already installed."
    fi
}

# Function to install lazydocker
install_lazydocker() {
    if ! command -v lazydocker &>/dev/null; then
        echo "Installing lazydocker..."
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    else
        echo "lazydocker is already installed."
    fi
}

# Function to install Docker Engine
# Function to install Docker Engine
install_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Installing Docker..."

        # Step 1: Install Prerequisites
        sudo apt update
        sudo apt install -y apt-transport-https ca-certificates curl gnupg

        # Step 2: Add Docker’s Official GPG Key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

        # Step 3: Add Docker Repo to Linux Mint
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

        # Refresh package list
        sudo apt update

        # Step 4: Install Docker
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker $USER
    else
        echo "Docker is already installed."
    fi
}

# Run all the functions
install_essentials
install_goenv
install_go_version
install_node
install_rust
install_pyenv
install_sdkman
install_neovim
install_makedeb
install_fzf
install_fzf_tab_completion
install_tpm
install_lazygit
install_lazydocker
install_docker

# Re-source .bashrc to apply changes
source ~/.bashrc

echo "All tools installed successfully!"
