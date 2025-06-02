#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo_error "This script should not be run as root"
        exit 1
    fi
}

# Install system dependencies
install_system_deps() {
    echo_info "Installing system dependencies..."
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y curl wget git build-essential pkg-config libssl-dev \
            unzip software-properties-common apt-transport-https ca-certificates \
            gnupg lsb-release snapd flatpak jq htop tmux vim neovim postgresql-client \
            sqlite3 redis-tools python3 python3-pip shellcheck
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm curl wget git base-devel openssl unzip \
            snapd flatpak jq htop tmux vim neovim postgresql sqlite redis \
            python python-pip shellcheck
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y curl wget git gcc gcc-c++ make pkgconfig openssl-devel \
            unzip snapd flatpak jq htop tmux vim neovim postgresql sqlite redis \
            python3 python3-pip ShellCheck
    else
        echo_warn "Unknown package manager. Please install dependencies manually."
    fi
}

# Install Zig latest version
install_zig() {
    echo_info "Installing Zig (latest version)..."
    
    if ! command -v zig &> /dev/null; then
        ZIG_VERSION=$(curl -s https://api.github.com/repos/ziglang/zig/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        ZIG_URL="https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz"
        
        if [ ! -d "$HOME/.local/bin" ]; then
            mkdir -p "$HOME/.local/bin"
        fi
        
        cd /tmp
        wget -O zig.tar.xz "$ZIG_URL"
        tar -xf zig.tar.xz
        mv zig-linux-x86_64-${ZIG_VERSION} "$HOME/.local/zig"
        ln -sf "$HOME/.local/zig/zig" "$HOME/.local/bin/zig"
        
        echo_info "Zig installed: $(zig version)"
    else
        echo_info "Zig already installed: $(zig version)"
    fi
}

# Install Crystal latest version
install_crystal() {
    echo_info "Installing Crystal (latest version)..."
    
    if ! command -v crystal &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            curl -fsSL https://crystal-lang.org/install.sh | sudo bash
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm crystal
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y crystal
        else
            echo_warn "Please install Crystal manually for your distribution"
        fi
    else
        echo_info "Crystal already installed: $(crystal --version)"
    fi
}

# Install React Native CLI
install_react_native() {
    echo_info "Installing React Native CLI..."
    
    # Install Node.js if not present
    if ! command -v node &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nodejs npm
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nodejs npm
        else
            echo_warn "Please install Node.js manually"
            return
        fi
    fi
    
    if ! command -v react-native &> /dev/null; then
        sudo npm install -g @react-native-community/cli
        echo_info "React Native CLI installed"
    else
        echo_info "React Native CLI already installed"
    fi
}

# Install Flutter
install_flutter() {
    echo_info "Installing Flutter..."
    
    if [ ! -d "$HOME/.local/flutter" ]; then
        cd /tmp
        # Get the latest stable release
        FLUTTER_VERSION=$(curl -s "https://api.github.com/repos/flutter/flutter/releases" | grep -o '"tag_name": "[^"]*"' | grep -v 'beta\|dev' | head -1 | cut -d'"' -f4)
        
        # Use the correct download URL for stable releases
        wget -O flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
        tar -xf flutter.tar.xz
        mv flutter "$HOME/.local/"
        
        # Add to PATH in .bashrc if not already there
        if ! grep -q 'export PATH="$HOME/.local/flutter/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.local/flutter/bin:$PATH"' >> "$HOME/.bashrc"
        fi
        
        echo_info "Flutter installed. Run 'flutter doctor' to check setup"
    else
        echo_info "Flutter already installed"
    fi
}

# Install Android Studio
install_android_studio() {
    echo_info "Installing Android Studio..."
    
    if command -v snap &> /dev/null; then
        sudo snap install android-studio --classic
    else
        echo_warn "Snap not available. Please install Android Studio manually from https://developer.android.com/studio"
    fi
}

# Install Kotlin
install_kotlin() {
    echo_info "Installing Kotlin..."
    
    if ! command -v kotlin &> /dev/null; then
        if command -v snap &> /dev/null; then
            sudo snap install kotlin --classic
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y kotlin
        else
            echo_warn "Please install Kotlin manually"
        fi
    else
        echo_info "Kotlin already installed: $(kotlin -version 2>&1)"
    fi
}

# Install Insomnia
install_insomnia() {
    echo_info "Installing Insomnia..."
    
    if command -v snap &> /dev/null; then
        sudo snap install insomnia
    elif command -v flatpak &> /dev/null; then
        flatpak install -y flathub rest.insomnia.Insomnia
    else
        echo_warn "Please install Insomnia manually"
    fi
}

# Install Tor
install_tor() {
    echo_info "Installing Tor..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y tor
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm tor
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y tor
    fi
}

# Install Tailscale
install_tailscale() {
    echo_info "Installing Tailscale..."
    
    curl -fsSL https://tailscale.com/install.sh | sh
}

# Install Yggdrasil
install_yggdrasil() {
    echo_info "Installing Yggdrasil..."
    
    YGGDRASIL_VERSION=$(curl -s https://api.github.com/repos/yggdrasil-network/yggdrasil-go/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    YGGDRASIL_URL="https://github.com/yggdrasil-network/yggdrasil-go/releases/download/${YGGDRASIL_VERSION}/yggdrasil-${YGGDRASIL_VERSION#v}-linux-amd64.tar.gz"
    
    cd /tmp
    wget -O yggdrasil.tar.gz "$YGGDRASIL_URL"
    tar -xzf yggdrasil.tar.gz
    sudo mv yggdrasil-${YGGDRASIL_VERSION#v}-linux-amd64/yggdrasil* /usr/local/bin/
}

# Install i2pd (I2P daemon)
install_i2p() {
    echo_info "Installing i2pd..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y i2pd
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm i2pd
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y i2pd
    fi
}

# Install OSVM CLI (placeholder - would need actual implementation)
install_osvm_cli() {
    echo_info "Installing OSVM CLI..."
    echo_warn "OSVM CLI installation not yet implemented - please install manually"
}

# Install Anza CLI tools (placeholder - would need actual implementation)
install_anza_cli() {
    echo_info "Installing Anza CLI tools..."
    echo_warn "Anza CLI tools installation not yet implemented - please install manually"
}

# Install Rust
install_rust() {
    echo_info "Installing Rust..."
    
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
        echo_info "Rust installed: $(rustc --version)"
    else
        echo_info "Rust already installed: $(rustc --version)"
    fi
}

# Install Go
install_go() {
    echo_info "Installing Go..."
    
    if ! command -v go &> /dev/null; then
        GO_VERSION=$(curl -s https://go.dev/VERSION?m=text)
        GO_URL="https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
        
        cd /tmp
        wget -O go.tar.gz "$GO_URL"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go.tar.gz
        
        # Add to PATH in .bashrc if not already there
        if ! grep -q 'export PATH="/usr/local/go/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="/usr/local/go/bin:$PATH"' >> "$HOME/.bashrc"
        fi
        
        echo_info "Go installed. Please source ~/.bashrc"
    else
        echo_info "Go already installed: $(go version)"
    fi
}

# Install Deno
install_deno() {
    echo_info "Installing Deno..."
    
    if ! command -v deno &> /dev/null; then
        curl -fsSL https://deno.land/install.sh | sh
        
        # Add to PATH in .bashrc if not already there
        if ! grep -q 'export PATH="$HOME/.deno/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.deno/bin:$PATH"' >> "$HOME/.bashrc"
        fi
        
        echo_info "Deno installed"
    else
        echo_info "Deno already installed: $(deno --version)"
    fi
}

# Install Bun
install_bun() {
    echo_info "Installing Bun..."
    
    if ! command -v bun &> /dev/null; then
        curl -fsSL https://bun.sh/install | bash
        
        # Add to PATH in .bashrc if not already there
        if ! grep -q 'export PATH="$HOME/.bun/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.bun/bin:$PATH"' >> "$HOME/.bashrc"
        fi
        
        echo_info "Bun installed"
    else
        echo_info "Bun already installed: $(bun --version)"
    fi
}

# Install Docker
install_docker() {
    echo_info "Installing Docker..."
    
    if command -v apt-get &> /dev/null; then
        # Add Docker's official GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Set up the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        echo_info "Docker installed. Please log out and back in for group changes to take effect"
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm docker docker-compose
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y docker docker-compose
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    else
        echo_warn "Please install Docker manually for your distribution"
    fi
}

# Install GitHub CLI
install_github_cli() {
    echo_info "Installing GitHub CLI..."
    
    if command -v apt-get &> /dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y gh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm github-cli
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y gh
    else
        echo_warn "Please install GitHub CLI manually"
    fi
}

# Install Visual Studio Code
install_vscode() {
    echo_info "Installing Visual Studio Code..."
    
    if command -v snap &> /dev/null; then
        sudo snap install code --classic
    elif command -v apt-get &> /dev/null; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt-get update
        sudo apt-get install -y code
    else
        echo_warn "Please install Visual Studio Code manually"
    fi
}

# Install fzf (fuzzy finder)
install_fzf() {
    echo_info "Installing fzf..."
    
    if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    else
        echo_info "fzf already installed"
    fi
}

# Install additional Node.js package managers
install_node_package_managers() {
    echo_info "Installing additional Node.js package managers..."
    
    if command -v npm &> /dev/null; then
        # Install pnpm
        if ! command -v pnpm &> /dev/null; then
            sudo npm install -g pnpm
        fi
        
        # Install yarn
        if ! command -v yarn &> /dev/null; then
            sudo npm install -g yarn
        fi
        
        echo_info "pnpm and yarn installed"
    else
        echo_warn "npm not found, skipping pnpm and yarn installation"
    fi
}

# Install development and testing tools
install_dev_testing_tools() {
    echo_info "Installing development and testing tools..."
    
    if command -v npm &> /dev/null; then
        # Install global development tools
        sudo npm install -g eslint prettier jest @playwright/test cypress
        echo_info "ESLint, Prettier, Jest, Playwright, and Cypress installed"
    else
        echo_warn "npm not found, skipping JavaScript development tools"
    fi
}

# Install PWA tools (placeholder - would need actual implementation)
install_pwa_tools() {
    echo_info "Installing PWA development tools..."
    
    # Install PWA-related npm packages
    if command -v npm &> /dev/null; then
        sudo npm install -g @angular/cli
        sudo npm install -g create-react-app
        sudo npm install -g lighthouse
        sudo npm install -g workbox-cli
    fi
    
    echo_warn "PWA site-specific tools (opensvm.com, larp.dev, aeamcp.com) need manual setup"
}

# Install CUDA Toolkit
install_cuda() {
    echo_info "Installing CUDA Toolkit..."
    
    # Check if NVIDIA GPU is present
    if ! lspci | grep -i nvidia &> /dev/null; then
        echo_warn "No NVIDIA GPU detected. Skipping CUDA installation."
        return
    fi
    
    if command -v nvcc &> /dev/null; then
        echo_info "CUDA already installed: $(nvcc --version | grep 'release' | awk '{print $6}' | cut -c2-)"
        return
    fi
    
    if command -v apt-get &> /dev/null; then
        # Install NVIDIA drivers and CUDA on Ubuntu/Debian
        sudo apt-get update
        sudo apt-get install -y nvidia-cuda-toolkit nvidia-driver-535
        echo_info "CUDA toolkit installed. Reboot may be required for driver changes."
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm cuda nvidia
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y cuda nvidia-driver
    else
        echo_warn "Please install CUDA manually for your distribution"
    fi
}

# Install Cursor IDE
install_cursor() {
    echo_info "Installing Cursor IDE..."
    
    if command -v cursor &> /dev/null; then
        echo_info "Cursor IDE already installed"
        return
    fi
    
    # Download and install Cursor IDE
    cd /tmp
    CURSOR_URL="https://download.cursor.sh/linux/appImage/x64"
    wget -O cursor.AppImage "$CURSOR_URL"
    chmod +x cursor.AppImage
    
    # Install to local applications
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share/applications"
    
    mv cursor.AppImage "$HOME/.local/bin/cursor"
    
    # Create desktop entry
    cat > "$HOME/.local/share/applications/cursor.desktop" << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
Exec=$HOME/.local/bin/cursor %F
Icon=cursor
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=cursor
EOF
    
    echo_info "Cursor IDE installed"
}

# Install Zed IDE
install_zed() {
    echo_info "Installing Zed IDE..."
    
    if command -v zed &> /dev/null; then
        echo_info "Zed IDE already installed"
        return
    fi
    
    # Install Zed from GitHub releases
    ZED_VERSION=$(curl -s https://api.github.com/repos/zed-industries/zed/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    ZED_URL="https://github.com/zed-industries/zed/releases/download/${ZED_VERSION}/zed-linux-x86_64.tar.gz"
    
    cd /tmp
    wget -O zed.tar.gz "$ZED_URL"
    tar -xzf zed.tar.gz
    
    mkdir -p "$HOME/.local/bin"
    mv zed-linux-x86_64/zed "$HOME/.local/bin/"
    
    echo_info "Zed IDE installed"
}

# Install Nyxt Browser
install_nyxt() {
    echo_info "Installing Nyxt Browser..."
    
    if command -v nyxt &> /dev/null; then
        echo_info "Nyxt browser already installed"
        return
    fi
    
    if command -v apt-get &> /dev/null; then
        # Try to install from package manager first
        sudo apt-get install -y nyxt || {
            echo_warn "Nyxt not available in package manager. Please install manually from https://nyxt.atlas.engineer/"
        }
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm nyxt || {
            echo_warn "Nyxt not available in package manager. Please install manually from https://nyxt.atlas.engineer/"
        }
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y nyxt || {
            echo_warn "Nyxt not available in package manager. Please install manually from https://nyxt.atlas.engineer/"
        }
    else
        echo_warn "Please install Nyxt browser manually from https://nyxt.atlas.engineer/"
    fi
}

# Install Nix Package Manager
install_nix() {
    echo_info "Installing Nix Package Manager..."
    
    if command -v nix &> /dev/null; then
        echo_info "Nix already installed: $(nix --version)"
        return
    fi
    
    # Install Nix with the official installer
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    
    # Source the Nix profile
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    
    echo_info "Nix installed. Please restart your shell or run 'source ~/.bashrc'"
}

# Install k3s (Lightweight Kubernetes)
install_k3s() {
    echo_info "Installing k3s (Lightweight Kubernetes)..."
    
    if command -v k3s &> /dev/null; then
        echo_info "k3s already installed: $(k3s --version)"
        return
    fi
    
    # Install k3s
    curl -sfL https://get.k3s.io | sh -
    
    # Add kubectl alias for k3s
    if ! grep -q 'alias kubectl="k3s kubectl"' "$HOME/.bashrc"; then
        echo 'alias kubectl="k3s kubectl"' >> "$HOME/.bashrc"
    fi
    
    echo_info "k3s installed. Use 'sudo k3s kubectl' or 'kubectl' (after sourcing bashrc)"
}

# Install Kubernetes management tools
install_k8s_tools() {
    echo_info "Installing Kubernetes management tools..."
    
    # Install kubectl if not already installed
    if ! command -v kubectl &> /dev/null && ! command -v k3s &> /dev/null; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    fi
    
    # Install k9s (Kubernetes CLI management tool)
    if ! command -v k9s &> /dev/null; then
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
        
        cd /tmp
        wget -O k9s.tar.gz "$K9S_URL"
        tar -xzf k9s.tar.gz
        sudo mv k9s /usr/local/bin/
        
        echo_info "k9s installed"
    fi
    
    # Install Lens (Kubernetes IDE) via snap if available
    if command -v snap &> /dev/null; then
        if ! snap list lens &> /dev/null; then
            sudo snap install lens --classic || echo_warn "Failed to install Lens via snap"
        fi
    fi
    
    # Install helm (Kubernetes package manager)
    if ! command -v helm &> /dev/null; then
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        echo_info "Helm installed"
    fi
}

# Install Ollama (for running LLaMA and other LLMs locally)
install_ollama() {
    echo_info "Installing Ollama (for local LLaMA models)..."
    
    if command -v ollama &> /dev/null; then
        echo_info "Ollama already installed: $(ollama --version)"
        return
    fi
    
    # Install Ollama
    curl -fsSL https://ollama.com/install.sh | sh
    
    echo_info "Ollama installed. You can now run models like: 'ollama run llama2'"
    echo_info "Popular models: llama2, codellama, mistral, vicuna"
}

# Install additional AI/ML tools
install_ai_ml_tools() {
    echo_info "Installing AI/ML development tools..."
    
    # Install llama.cpp for running models
    if [ ! -d "$HOME/.local/llama.cpp" ]; then
        cd /tmp
        git clone https://github.com/ggerganov/llama.cpp.git
        cd llama.cpp
        make -j$(nproc)
        
        mkdir -p "$HOME/.local/llama.cpp"
        cp main quantize perplexity "$HOME/.local/llama.cpp/" || true
        
        # Add to PATH
        if ! grep -q 'export PATH="$HOME/.local/llama.cpp:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.local/llama.cpp:$PATH"' >> "$HOME/.bashrc"
        fi
        
        echo_info "llama.cpp compiled and installed"
    fi
    
    # Install Python AI/ML packages if Python is available
    if command -v pip3 &> /dev/null; then
        pip3 install --user torch torchvision transformers accelerate bitsandbytes || echo_warn "Failed to install some Python AI packages"
        echo_info "Python AI/ML packages installed"
    fi
}

# Update PATH
update_path() {
    echo_info "Updating PATH..."
    
    # Add common paths to .bashrc if not already there
    PATHS_TO_ADD=(
        '$HOME/.local/bin'
        '$HOME/.local/flutter/bin'
        '$HOME/.cargo/bin'
        '/usr/local/go/bin'
        '$HOME/.deno/bin'
        '$HOME/.bun/bin'
        '$HOME/.local/llama.cpp'
    )
    
    for path in "${PATHS_TO_ADD[@]}"; do
        if ! grep -q "export PATH=\"${path}:\$PATH\"" "$HOME/.bashrc"; then
            echo "export PATH=\"${path}:\$PATH\"" >> "$HOME/.bashrc"
        fi
    done
    
    # Add Nix profile if it exists
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        if ! grep -q 'source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' "$HOME/.bashrc"; then
            echo 'source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' >> "$HOME/.bashrc"
        fi
    fi
    
    echo_info "PATH updated. Please source ~/.bashrc or restart your shell"
}

# Main installation function
main() {
    echo_info "Starting COSMIC SVM development tools installation..."
    
    check_root
    install_system_deps
    
    echo_info "Installing programming languages..."
    install_rust
    install_zig
    install_crystal
    install_go
    install_deno
    install_bun
    
    echo_info "Installing mobile development tools..."
    install_react_native
    install_flutter
    install_kotlin
    install_android_studio
    
    echo_info "Installing development tools..."
    install_insomnia
    install_vscode
    install_github_cli
    install_fzf
    
    echo_info "Installing advanced IDEs..."
    install_cursor
    install_zed
    
    echo_info "Installing container tools..."
    install_docker
    
    echo_info "Installing Kubernetes tools..."
    install_k3s
    install_k8s_tools
    
    echo_info "Installing network tools..."
    install_tor
    install_tailscale
    install_yggdrasil
    install_i2p
    
    echo_info "Installing package managers..."
    install_node_package_managers
    install_nix
    
    echo_info "Installing development and testing tools..."
    install_dev_testing_tools
    
    echo_info "Installing GPU computing tools..."
    install_cuda
    
    echo_info "Installing AI/ML tools..."
    install_ollama
    install_ai_ml_tools
    
    echo_info "Installing specialized browsers..."
    install_nyxt
    
    echo_info "Installing specialized tools..."
    install_osvm_cli
    install_anza_cli
    install_pwa_tools
    
    update_path
    
    echo_info "Development tools installation completed!"
    echo_info "Please run 'just dev-tools-check' to verify installations"
}

# Run main function
main "$@"