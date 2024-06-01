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

    packages=("build-essential" "vim-nox" "valgrind" "git" "gh" "zip" "unzip" "lazygit" "tmux" "xclip")
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q $pkg; then
            sudo apt-get install -y $pkg
        else
            echo "$pkg is already installed."
        fi
    done
}

# Function to install Go
install_go() {
    if ! command -v go &>/dev/null; then
        echo "Installing Go..."
        wget https://go.dev/dl/go1.20.6.linux-amd64.tar.gz -O go.tar.gz
        sudo tar -C /usr/local -xzf go.tar.gz
        rm go.tar.gz
        echo "export PATH=$PATH:/usr/local/go/bin" >>~/.bashrc
        source ~/.bashrc
    else
        echo "Go is already installed."
    fi
}

# Function to install GVM
install_gvm() {
    if [ ! -d "$HOME/.gvm" ]; then
        echo "Installing GVM..."
        bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
        source ~/.gvm/scripts/gvm
    else
        echo "GVM is already installed."
    fi
}

# Function to install NVM and Node.js LTS
install_nvm_node() {
    if [ ! -d "$HOME/.nvm" ]; then
        echo "Installing NVM and Node.js LTS..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
        source ~/.nvm/nvm.sh
        nvm install --lts
    else
        echo "NVM is already installed."
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

# Function to install Miniconda
install_miniconda() {
    if [ ! -d "$HOME/miniconda" ]; then
        echo "Installing Miniconda..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
        bash miniconda.sh -b -p $HOME/miniconda
        rm miniconda.sh
        echo "export PATH=$HOME/miniconda/bin:$PATH" >>~/.bashrc
        source ~/.bashrc
    else
        echo "Miniconda is already installed."
    fi
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
        echo "Installing dependencies for Neovim..."
        sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

        echo "Cloning Neovim repository..."
        git clone https://github.com/neovim/neovim.git --depth=1
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
        echo "source $FZF_TAB_DIR/fzf-tab-completion/bash" >>~/.bashrc
        source ~/.bashrc
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
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
}

# Function to install lazydocker
install_lazydocker() {
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
}

# Function to install Docker Engine
install_docker() {
    # Set up Docker's apt repository
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update

    # Install Docker packages
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
}

# Run all the functions
# install_oh_my_bash
install_essentials
install_go
install_gvm
install_nvm_node
install_rust
install_miniconda
install_sdkman
install_neovim
install_makedeb
install_fzf
install_fzf_tab_completion
install_tpm
install_lazygit
install_lazydocker
install_docker

echo "All tools installed successfully!"
