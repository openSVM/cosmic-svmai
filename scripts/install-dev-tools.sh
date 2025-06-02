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

# Install additional programming languages
install_additional_languages() {
    echo_info "Installing additional programming languages..."
    
    # Install Java (OpenJDK)
    if ! command -v java &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openjdk-17-jdk openjdk-17-jre
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm jdk17-openjdk
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y java-17-openjdk java-17-openjdk-devel
        fi
        echo_info "Java OpenJDK installed"
    else
        echo_info "Java already installed: $(java -version 2>&1 | head -1)"
    fi
    
    # Install Swift (if on Ubuntu)
    if ! command -v swift &> /dev/null && command -v apt-get &> /dev/null; then
        # Add Swift repository and install
        wget -O - https://swift.org/keys/all-keys.asc | sudo gpg --import -
        echo "deb [signed-by=/usr/share/keyrings/swift-archive-keyring.gpg] https://download.swift.org/ubuntu$(lsb_release -rs)/swift-5.9-release $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/swift.list
        sudo apt-get update
        sudo apt-get install -y swift-lang || echo_warn "Swift installation failed - manual installation may be required"
    fi
    
    # Install Haskell
    if ! command -v ghc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y haskell-platform
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ghc cabal-install stack
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ghc cabal-install stack
        fi
        echo_info "Haskell installed"
    else
        echo_info "Haskell already installed: $(ghc --version)"
    fi
    
    # Install Elixir
    if ! command -v elixir &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y elixir
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm elixir
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y elixir
        fi
        echo_info "Elixir installed"
    else
        echo_info "Elixir already installed: $(elixir --version | head -1)"
    fi
}

# Install additional IDEs and editors
install_additional_ides() {
    echo_info "Installing additional IDEs and editors..."
    
    # Install IntelliJ IDEA Community
    if command -v snap &> /dev/null; then
        if ! snap list intellij-idea-community &> /dev/null; then
            sudo snap install intellij-idea-community --classic
            echo_info "IntelliJ IDEA Community installed"
        fi
    fi
    
    # Install WebStorm (trial/commercial)
    if command -v snap &> /dev/null; then
        if ! snap list webstorm &> /dev/null; then
            sudo snap install webstorm --classic || echo_warn "WebStorm installation failed - requires JetBrains account"
        fi
    fi
    
    # Install Emacs
    if ! command -v emacs &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y emacs
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm emacs
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y emacs
        fi
        echo_info "Emacs installed"
    else
        echo_info "Emacs already installed: $(emacs --version | head -1)"
    fi
}

# Install database management tools
install_database_tools() {
    echo_info "Installing database management tools..."
    
    # Install MongoDB Compass
    if command -v apt-get &> /dev/null; then
        if ! command -v mongodb-compass &> /dev/null; then
            wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
            echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
            sudo apt-get update
            sudo apt-get install -y mongodb-compass || echo_warn "MongoDB Compass installation failed"
        fi
    fi
    
    # Install DBeaver Community
    if command -v snap &> /dev/null; then
        if ! snap list dbeaver-ce &> /dev/null; then
            sudo snap install dbeaver-ce
            echo_info "DBeaver Community installed"
        fi
    elif command -v flatpak &> /dev/null; then
        flatpak install -y flathub io.dbeaver.DBeaverCommunity
    fi
    
    # Install pgAdmin4
    if command -v apt-get &> /dev/null; then
        curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -
        echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
        sudo apt-get update
        sudo apt-get install -y pgadmin4-desktop || echo_warn "pgAdmin4 installation failed"
    fi
}

# Install security and networking tools
install_security_tools() {
    echo_info "Installing security and networking tools..."
    
    # Install Wireshark
    if ! command -v wireshark &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wireshark
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wireshark-qt
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wireshark
        fi
        echo_info "Wireshark installed"
    fi
    
    # Install Nmap
    if ! command -v nmap &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nmap
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nmap
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nmap
        fi
        echo_info "Nmap installed"
    fi
    
    # Install OWASP ZAP
    if command -v snap &> /dev/null; then
        if ! snap list zaproxy &> /dev/null; then
            sudo snap install zaproxy --classic
            echo_info "OWASP ZAP installed"
        fi
    fi
    
    # Install Burp Suite Community
    if command -v apt-get &> /dev/null; then
        if [ ! -f /opt/BurpSuiteCommunity/BurpSuiteCommunity ]; then
            cd /tmp
            wget -O burpsuite.sh "https://portswigger.net/burp/releases/download?product=community&type=Linux"
            chmod +x burpsuite.sh
            sudo ./burpsuite.sh -q -dir /opt/BurpSuiteCommunity || echo_warn "Burp Suite installation may require manual intervention"
        fi
    fi
}

# Install performance and text processing tools
install_performance_tools() {
    echo_info "Installing performance and text processing tools..."
    
    # Install Valgrind
    if ! command -v valgrind &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y valgrind
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm valgrind
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y valgrind
        fi
        echo_info "Valgrind installed"
    fi
    
    # Install ripgrep (rg)
    if ! command -v rg &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ripgrep
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ripgrep
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ripgrep
        fi
        echo_info "ripgrep installed"
    fi
    
    # Install fd (find alternative)
    if ! command -v fd &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fd-find
            sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fd
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fd-find
        fi
        echo_info "fd installed"
    fi
    
    # Install bat (cat alternative)
    if ! command -v bat &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y bat
            sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm bat
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y bat
        fi
        echo_info "bat installed"
    fi
    
    # Install exa (ls alternative)
    if ! command -v exa &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y exa
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm exa
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y exa
        fi
        echo_info "exa installed"
    fi
}

# Install cloud CLI tools
install_cloud_tools() {
    echo_info "Installing cloud CLI tools..."
    
    # Install AWS CLI v2
    if ! command -v aws &> /dev/null; then
        cd /tmp
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        echo_info "AWS CLI v2 installed"
    fi
    
    # Install Azure CLI
    if ! command -v az &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm azure-cli
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y azure-cli
        fi
        echo_info "Azure CLI installed"
    fi
    
    # Install Google Cloud CLI
    if ! command -v gcloud &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
            curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
            sudo apt-get update
            sudo apt-get install -y google-cloud-cli
        fi
        echo_info "Google Cloud CLI installed"
    fi
    
    # Install Terraform
    if ! command -v terraform &> /dev/null; then
        cd /tmp
        TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | cut -c2-)
        wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
        unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
        sudo mv terraform /usr/local/bin/
        echo_info "Terraform installed"
    fi
    
    # Install Pulumi
    if ! command -v pulumi &> /dev/null; then
        curl -fsSL https://get.pulumi.com | sh
        if ! grep -q 'export PATH="$HOME/.pulumi/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> "$HOME/.bashrc"
        fi
        echo_info "Pulumi installed"
    fi
}

# Install terminal enhancements
install_terminal_enhancements() {
    echo_info "Installing terminal enhancements..."
    
    # Install Zsh if not already installed
    if ! command -v zsh &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y zsh
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zsh
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zsh
        fi
    fi
    
    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo_info "Oh My Zsh installed"
    fi
    
    # Install Starship prompt
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        
        # Add to bashrc and zshrc
        if ! grep -q 'eval "$(starship init bash)"' "$HOME/.bashrc" 2>/dev/null; then
            echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
        fi
        
        if [ -f "$HOME/.zshrc" ] && ! grep -q 'eval "$(starship init zsh)"' "$HOME/.zshrc"; then
            echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
        fi
        
        echo_info "Starship prompt installed"
    fi
}

# Install API testing tools
install_api_tools() {
    echo_info "Installing API testing tools..."
    
    # Install Postman
    if command -v snap &> /dev/null; then
        if ! snap list postman &> /dev/null; then
            sudo snap install postman
            echo_info "Postman installed"
        fi
    fi
    
    # Install HTTPie
    if ! command -v http &> /dev/null; then
        if command -v pip3 &> /dev/null; then
            pip3 install --user httpie
            echo_info "HTTPie installed"
        fi
    fi
    
    # Install curl alternatives
    if ! command -v curlie &> /dev/null; then
        if command -v snap &> /dev/null; then
            sudo snap install curlie
        fi
    fi
}

# Install build tools
install_build_tools() {
    echo_info "Installing build tools..."
    
    # Install CMake
    if ! command -v cmake &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y cmake
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm cmake
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y cmake
        fi
        echo_info "CMake installed"
    fi
    
    # Install Meson
    if ! command -v meson &> /dev/null; then
        if command -v pip3 &> /dev/null; then
            pip3 install --user meson ninja
            echo_info "Meson and Ninja installed"
        fi
    fi
    
    # Install Bazel
    if ! command -v bazel &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
            sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
            echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
            sudo apt-get update
            sudo apt-get install -y bazel
            echo_info "Bazel installed"
        fi
    fi
}

# Install documentation tools
install_documentation_tools() {
    echo_info "Installing documentation tools..."
    
    # Install MkDocs
    if ! command -v mkdocs &> /dev/null; then
        if command -v pip3 &> /dev/null; then
            pip3 install --user mkdocs mkdocs-material
            echo_info "MkDocs installed"
        fi
    fi
    
    # Install Sphinx
    if command -v pip3 &> /dev/null; then
        pip3 install --user sphinx sphinx-rtd-theme
        echo_info "Sphinx installed"
    fi
    
    # Install Pandoc
    if ! command -v pandoc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y pandoc
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm pandoc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pandoc
        fi
        echo_info "Pandoc installed"
    fi
}

# Install file sync and remote tools
install_remote_tools() {
    echo_info "Installing file sync and remote tools..."
    
    # Install Syncthing
    if ! command -v syncthing &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
            echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
            sudo apt-get update
            sudo apt-get install -y syncthing
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm syncthing
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y syncthing
        fi
        echo_info "Syncthing installed"
    fi
    
    # Install rclone
    if ! command -v rclone &> /dev/null; then
        curl https://rclone.org/install.sh | sudo bash
        echo_info "rclone installed"
    fi
    
    # Install Ansible
    if ! command -v ansible &> /dev/null; then
        if command -v pip3 &> /dev/null; then
            pip3 install --user ansible
            echo_info "Ansible installed"
        fi
    fi
    
    # Install SSH tools
    if ! command -v ssh-copy-id &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openssh-client
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openssh
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openssh-clients
        fi
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
        '$HOME/.pulumi/bin'
        '/opt/BurpSuiteCommunity'
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

# Additional Programming Languages
install_more_programming_languages() {
    echo_info "Installing additional programming languages..."
    
    # Ruby
    if ! command -v ruby &> /dev/null; then
        echo_info "Installing Ruby..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ruby-full
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ruby
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ruby ruby-devel
        fi
    fi
    
    # Perl
    if ! command -v perl &> /dev/null; then
        echo_info "Installing Perl..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y perl
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm perl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y perl
        fi
    fi
    
    # PHP
    if ! command -v php &> /dev/null; then
        echo_info "Installing PHP..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y php php-cli php-common php-curl php-zip php-gd php-mysql php-xml php-mbstring
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm php php-gd php-intl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y php php-cli php-common php-curl php-zip php-gd php-mysql php-xml php-mbstring
        fi
    fi
    
    # Lua
    if ! command -v lua &> /dev/null; then
        echo_info "Installing Lua..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y lua5.4 luarocks
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lua luarocks
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lua luarocks
        fi
    fi
    
    # R Language
    if ! command -v R &> /dev/null; then
        echo_info "Installing R..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y r-base r-base-dev
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm r
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y R R-devel
        fi
    fi
    
    # Julia
    if ! command -v julia &> /dev/null; then
        echo_info "Installing Julia..."
        curl -fsSL https://install.julialang.org | sh -s -- --yes
    fi
    
    # Scala
    if ! command -v scala &> /dev/null; then
        echo_info "Installing Scala..."
        curl -fLo cs https://git.io/coursier-cli-"$(uname | tr LD ld)"
        chmod +x cs
        ./cs install scala scalac
        rm cs
    fi
    
    # Clojure
    if ! command -v clojure &> /dev/null; then
        echo_info "Installing Clojure..."
        curl -O https://download.clojure.org/install/linux-install-1.11.1.1413.sh
        chmod +x linux-install-1.11.1.1413.sh
        sudo ./linux-install-1.11.1.1413.sh
        rm linux-install-1.11.1.1413.sh
    fi
    
    # F#
    if ! command -v dotnet &> /dev/null; then
        echo_info "Installing .NET and F#..."
        wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        rm packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-8.0
    fi
    
    # OCaml
    if ! command -v ocaml &> /dev/null; then
        echo_info "Installing OCaml..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ocaml opam
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ocaml opam
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ocaml opam
        fi
    fi
    
    # Erlang
    if ! command -v erl &> /dev/null; then
        echo_info "Installing Erlang..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y erlang
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm erlang
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y erlang
        fi
    fi
    
    # Nim
    if ! command -v nim &> /dev/null; then
        echo_info "Installing Nim..."
        curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y
    fi
    
    # D Language
    if ! command -v dmd &> /dev/null; then
        echo_info "Installing D Language..."
        curl -fsS https://dlang.org/install.sh | bash -s dmd
    fi
    
    # Racket
    if ! command -v racket &> /dev/null; then
        echo_info "Installing Racket..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y racket
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm racket
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y racket
        fi
    fi
}

# Additional IDEs and Editors
install_more_ides_editors() {
    echo_info "Installing additional IDEs and editors..."
    
    # Eclipse IDE
    if ! command -v eclipse &> /dev/null; then
        echo_info "Installing Eclipse IDE..."
        if command -v snap &> /dev/null; then
            sudo snap install eclipse --classic
        else
            wget -O eclipse.tar.gz "https://eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2023-12/R/eclipse-java-2023-12-R-linux-gtk-x86_64.tar.gz&r=1"
            tar -xzf eclipse.tar.gz -C "$HOME/.local/share/"
            ln -sf "$HOME/.local/share/eclipse/eclipse" "$HOME/.local/bin/eclipse"
            rm eclipse.tar.gz
        fi
    fi
    
    # NetBeans
    if ! command -v netbeans &> /dev/null; then
        echo_info "Installing NetBeans..."
        if command -v snap &> /dev/null; then
            sudo snap install netbeans --classic
        fi
    fi
    
    # Code::Blocks
    if ! command -v codeblocks &> /dev/null; then
        echo_info "Installing Code::Blocks..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y codeblocks
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm codeblocks
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y codeblocks
        fi
    fi
    
    # Qt Creator
    if ! command -v qtcreator &> /dev/null; then
        echo_info "Installing Qt Creator..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qtcreator
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm qtcreator
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qt-creator
        fi
    fi
    
    # Sublime Text
    if ! command -v subl &> /dev/null; then
        echo_info "Installing Sublime Text..."
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        sudo apt-get update
        sudo apt-get install -y sublime-text
    fi
    
    # Brackets
    if ! command -v brackets &> /dev/null; then
        echo_info "Installing Brackets..."
        if command -v snap &> /dev/null; then
            sudo snap install brackets --classic
        fi
    fi
    
    # Helix Editor
    if ! command -v hx &> /dev/null; then
        echo_info "Installing Helix Editor..."
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:maveonair/helix-editor
            sudo apt-get update
            sudo apt-get install -y helix
        else
            cargo install helix-term --locked
        fi
    fi
    
    # Kakoune
    if ! command -v kak &> /dev/null; then
        echo_info "Installing Kakoune..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y kakoune
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm kakoune
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y kakoune
        fi
    fi
    
    # Micro Editor
    if ! command -v micro &> /dev/null; then
        echo_info "Installing Micro Editor..."
        curl https://getmic.ro | bash
        sudo mv micro /usr/local/bin/
    fi
    
    # GNU Emacs
    if ! command -v emacs &> /dev/null; then
        echo_info "Installing GNU Emacs..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y emacs
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm emacs
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y emacs
        fi
    fi
}

# Game Development Tools
install_game_development_tools() {
    echo_info "Installing game development tools..."
    
    # Godot Engine
    if ! command -v godot &> /dev/null; then
        echo_info "Installing Godot Engine..."
        wget https://github.com/godotengine/godot/releases/download/4.2.1-stable/Godot_v4.2.1-stable_linux.x86_64.zip
        unzip Godot_v4.2.1-stable_linux.x86_64.zip
        sudo mv Godot_v4.2.1-stable_linux.x86_64 /usr/local/bin/godot
        rm Godot_v4.2.1-stable_linux.x86_64.zip
        chmod +x /usr/local/bin/godot
    fi
    
    # Blender
    if ! command -v blender &> /dev/null; then
        echo_info "Installing Blender..."
        if command -v snap &> /dev/null; then
            sudo snap install blender --classic
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y blender
        fi
    fi
    
    # SDL2 Development Libraries
    echo_info "Installing SDL2 development libraries..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm sdl2 sdl2_image sdl2_mixer sdl2_ttf
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y SDL2-devel SDL2_image-devel SDL2_mixer-devel SDL2_ttf-devel
    fi
    
    # LÖVE 2D
    if ! command -v love &> /dev/null; then
        echo_info "Installing LÖVE 2D..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y love
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm love
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y love
        fi
    fi
    
    # Aseprite (sprite editor)
    if ! command -v aseprite &> /dev/null; then
        echo_info "Installing Aseprite..."
        if command -v snap &> /dev/null; then
            sudo snap install aseprite
        fi
    fi
    
    # Tiled Map Editor
    if ! command -v tiled &> /dev/null; then
        echo_info "Installing Tiled Map Editor..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tiled
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tiled
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tiled
        fi
    fi
}

# Blockchain and Crypto Tools
install_blockchain_tools() {
    echo_info "Installing blockchain and crypto tools..."
    
    # Node.js (required for many blockchain tools)
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Hardhat
    if ! command -v hardhat &> /dev/null; then
        echo_info "Installing Hardhat..."
        npm install -g hardhat-shorthand
    fi
    
    # Truffle
    if ! command -v truffle &> /dev/null; then
        echo_info "Installing Truffle..."
        npm install -g truffle
    fi
    
    # Ganache CLI
    if ! command -v ganache &> /dev/null; then
        echo_info "Installing Ganache CLI..."
        npm install -g ganache-cli
    fi
    
    # Foundry
    if ! command -v forge &> /dev/null; then
        echo_info "Installing Foundry..."
        curl -L https://foundry.paradigm.xyz | bash
        source ~/.bashrc
        foundryup
    fi
    
    # Solidity Compiler
    if ! command -v solc &> /dev/null; then
        echo_info "Installing Solidity Compiler..."
        if command -v snap &> /dev/null; then
            sudo snap install solc
        else
            npm install -g solc
        fi
    fi
    
    # Web3 CLI tools
    npm install -g @ethereum/remix-project
    npm install -g eth-cli
    npm install -g @openzeppelin/cli
    
    # Bitcoin tools
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y bitcoin-core
    fi
}

# Scientific Computing Tools
install_scientific_computing_tools() {
    echo_info "Installing scientific computing tools..."
    
    # Anaconda/Miniconda
    if ! command -v conda &> /dev/null; then
        echo_info "Installing Miniconda..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda3"
        rm Miniconda3-latest-Linux-x86_64.sh
        echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
    fi
    
    # Jupyter Lab
    if ! command -v jupyter &> /dev/null; then
        echo_info "Installing Jupyter Lab..."
        pip3 install jupyterlab jupyter notebook
    fi
    
    # GNU Octave
    if ! command -v octave &> /dev/null; then
        echo_info "Installing GNU Octave..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y octave
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm octave
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y octave
        fi
    fi
    
    # Maxima (Computer Algebra System)
    if ! command -v maxima &> /dev/null; then
        echo_info "Installing Maxima..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y maxima
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm maxima
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y maxima
        fi
    fi
    
    # SageMath
    if ! command -v sage &> /dev/null; then
        echo_info "Installing SageMath..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sagemath
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sagemath
        fi
    fi
    
    # Essential Python packages for scientific computing
    pip3 install numpy scipy pandas matplotlib seaborn scikit-learn plotly dash streamlit
    pip3 install sympy networkx statsmodels xarray
}

# More Container and Orchestration Tools
install_more_container_tools() {
    echo_info "Installing more container and orchestration tools..."
    
    # Podman
    if ! command -v podman &> /dev/null; then
        echo_info "Installing Podman..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y podman
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm podman
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y podman
        fi
    fi
    
    # Buildah
    if ! command -v buildah &> /dev/null; then
        echo_info "Installing Buildah..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y buildah
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm buildah
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y buildah
        fi
    fi
    
    # Skopeo
    if ! command -v skopeo &> /dev/null; then
        echo_info "Installing Skopeo..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y skopeo
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm skopeo
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y skopeo
        fi
    fi
    
    # kubectl plugins
    if command -v kubectl &> /dev/null; then
        echo_info "Installing kubectl plugins..."
        
        # kubectx and kubens
        if ! command -v kubectx &> /dev/null; then
            sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
            sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
            sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
        fi
        
        # stern (multi pod log tailing)
        if ! command -v stern &> /dev/null; then
            curl -L https://github.com/stern/stern/releases/latest/download/stern_linux_amd64.tar.gz | tar xz
            sudo mv stern /usr/local/bin/
        fi
        
        # dive (docker image analyzer)
        if ! command -v dive &> /dev/null; then
            curl -L https://github.com/wagoodman/dive/releases/latest/download/dive_linux_amd64.tar.gz | tar xz
            sudo mv dive /usr/local/bin/
        fi
        
        # kustomize
        if ! command -v kustomize &> /dev/null; then
            curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
            sudo mv kustomize /usr/local/bin/
        fi
    fi
    
    # Istio CLI
    if ! command -v istioctl &> /dev/null; then
        echo_info "Installing Istio CLI..."
        curl -L https://istio.io/downloadIstio | sh -
        sudo mv istio-*/bin/istioctl /usr/local/bin/
        rm -rf istio-*
    fi
}

# More Cloud and Infrastructure Tools
install_more_cloud_infrastructure_tools() {
    echo_info "Installing more cloud and infrastructure tools..."
    
    # Oracle Cloud CLI
    if ! command -v oci &> /dev/null; then
        echo_info "Installing Oracle Cloud CLI..."
        bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
    fi
    
    # IBM Cloud CLI
    if ! command -v ibmcloud &> /dev/null; then
        echo_info "Installing IBM Cloud CLI..."
        curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
    fi
    
    # DigitalOcean CLI
    if ! command -v doctl &> /dev/null; then
        echo_info "Installing DigitalOcean CLI..."
        curl -LO https://github.com/digitalocean/doctl/releases/latest/download/doctl-linux-amd64.tar.gz
        tar xf doctl-linux-amd64.tar.gz
        sudo mv doctl /usr/local/bin/
        rm doctl-linux-amd64.tar.gz
    fi
    
    # Linode CLI
    if ! command -v linode-cli &> /dev/null; then
        echo_info "Installing Linode CLI..."
        pip3 install linode-cli
    fi
    
    # Vultr CLI
    if ! command -v vultr-cli &> /dev/null; then
        echo_info "Installing Vultr CLI..."
        curl -LO https://github.com/vultr/vultr-cli/releases/latest/download/vultr-cli_linux_amd64.tar.gz
        tar xf vultr-cli_linux_amd64.tar.gz
        sudo mv vultr-cli /usr/local/bin/
        rm vultr-cli_linux_amd64.tar.gz
    fi
    
    # Chef
    if ! command -v chef &> /dev/null; then
        echo_info "Installing Chef..."
        curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef-workstation
    fi
    
    # Puppet
    if ! command -v puppet &> /dev/null; then
        echo_info "Installing Puppet..."
        if command -v apt-get &> /dev/null; then
            wget https://apt.puppet.com/puppet7-release-focal.deb
            sudo dpkg -i puppet7-release-focal.deb
            sudo apt-get update
            sudo apt-get install -y puppet-agent
            rm puppet7-release-focal.deb
        fi
    fi
    
    # SaltStack
    if ! command -v salt &> /dev/null; then
        echo_info "Installing SaltStack..."
        curl -L https://bootstrap.saltproject.io -o install_salt.sh
        sudo sh install_salt.sh -P
        rm install_salt.sh
    fi
    
    # CDK (AWS Cloud Development Kit)
    if ! command -v cdk &> /dev/null; then
        echo_info "Installing AWS CDK..."
        npm install -g aws-cdk
    fi
    
    # Serverless Framework
    if ! command -v serverless &> /dev/null; then
        echo_info "Installing Serverless Framework..."
        npm install -g serverless
    fi
}

# More Security and Network Tools
install_more_security_network_tools() {
    echo_info "Installing more security and network tools..."
    
    # Nikto
    if ! command -v nikto &> /dev/null; then
        echo_info "Installing Nikto..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nikto
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nikto
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nikto
        fi
    fi
    
    # SQLmap
    if ! command -v sqlmap &> /dev/null; then
        echo_info "Installing SQLmap..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sqlmap
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sqlmap
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sqlmap
        fi
    fi
    
    # Metasploit Framework
    if ! command -v msfconsole &> /dev/null; then
        echo_info "Installing Metasploit Framework..."
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
        chmod 755 msfinstall
        ./msfinstall
        rm msfinstall
    fi
    
    # OpenVAS
    if ! command -v openvas &> /dev/null; then
        echo_info "Installing OpenVAS..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openvas
        fi
    fi
    
    # tcpdump
    if ! command -v tcpdump &> /dev/null; then
        echo_info "Installing tcpdump..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tcpdump
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tcpdump
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tcpdump
        fi
    fi
    
    # iftop
    if ! command -v iftop &> /dev/null; then
        echo_info "Installing iftop..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y iftop
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm iftop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y iftop
        fi
    fi
    
    # OpenVPN
    if ! command -v openvpn &> /dev/null; then
        echo_info "Installing OpenVPN..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openvpn
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openvpn
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openvpn
        fi
    fi
    
    # WireGuard
    if ! command -v wg &> /dev/null; then
        echo_info "Installing WireGuard..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wireguard
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wireguard-tools
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wireguard-tools
        fi
    fi
    
    # Aircrack-ng
    if ! command -v aircrack-ng &> /dev/null; then
        echo_info "Installing Aircrack-ng..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y aircrack-ng
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm aircrack-ng
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y aircrack-ng
        fi
    fi
    
    # Hydra
    if ! command -v hydra &> /dev/null; then
        echo_info "Installing Hydra..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y hydra
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm hydra
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y hydra
        fi
    fi
    
    # John the Ripper
    if ! command -v john &> /dev/null; then
        echo_info "Installing John the Ripper..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y john
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm john
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y john
        fi
    fi
}

# More Performance and Monitoring Tools
install_more_performance_monitoring_tools() {
    echo_info "Installing more performance and monitoring tools..."
    
    # Netdata
    if ! command -v netdata &> /dev/null; then
        echo_info "Installing Netdata..."
        bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive
    fi
    
    # Zabbix Agent
    if ! command -v zabbix_agentd &> /dev/null; then
        echo_info "Installing Zabbix Agent..."
        if command -v apt-get &> /dev/null; then
            wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
            sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
            sudo apt-get update
            sudo apt-get install -y zabbix-agent
            rm zabbix-release_6.0-4+ubuntu22.04_all.deb
        fi
    fi
    
    # Prometheus
    if ! command -v prometheus &> /dev/null; then
        echo_info "Installing Prometheus..."
        curl -LO https://github.com/prometheus/prometheus/releases/latest/download/prometheus-*.linux-amd64.tar.gz
        tar xvf prometheus-*.linux-amd64.tar.gz
        sudo mv prometheus-*/prometheus /usr/local/bin/
        sudo mv prometheus-*/promtool /usr/local/bin/
        rm -rf prometheus-*
    fi
    
    # Grafana
    if ! command -v grafana-server &> /dev/null; then
        echo_info "Installing Grafana..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
            wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
            sudo apt-get update
            sudo apt-get install -y grafana
        fi
    fi
    
    # sysbench
    if ! command -v sysbench &> /dev/null; then
        echo_info "Installing sysbench..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sysbench
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sysbench
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sysbench
        fi
    fi
    
    # stress-ng
    if ! command -v stress-ng &> /dev/null; then
        echo_info "Installing stress-ng..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y stress-ng
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm stress-ng
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y stress-ng
        fi
    fi
    
    # iperf3
    if ! command -v iperf3 &> /dev/null; then
        echo_info "Installing iperf3..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y iperf3
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm iperf3
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y iperf3
        fi
    fi
    
    # fio (storage benchmarking)
    if ! command -v fio &> /dev/null; then
        echo_info "Installing fio..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fio
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fio
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fio
        fi
    fi
    
    # perf
    if ! command -v perf &> /dev/null; then
        echo_info "Installing perf..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y linux-tools-common linux-tools-generic
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm perf
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y perf
        fi
    fi
}

# More File and Data Management Tools
install_more_file_data_management_tools() {
    echo_info "Installing more file and data management tools..."
    
    # Mercurial
    if ! command -v hg &> /dev/null; then
        echo_info "Installing Mercurial..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mercurial
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mercurial
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mercurial
        fi
    fi
    
    # Fossil
    if ! command -v fossil &> /dev/null; then
        echo_info "Installing Fossil..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fossil
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fossil
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fossil
        fi
    fi
    
    # 7zip
    if ! command -v 7z &> /dev/null; then
        echo_info "Installing 7zip..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y p7zip-full
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm p7zip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y p7zip p7zip-plugins
        fi
    fi
    
    # zstd compression
    if ! command -v zstd &> /dev/null; then
        echo_info "Installing zstd..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y zstd
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zstd
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zstd
        fi
    fi
    
    # lz4 compression
    if ! command -v lz4 &> /dev/null; then
        echo_info "Installing lz4..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y lz4
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lz4
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lz4
        fi
    fi
    
    # Unison file synchronizer
    if ! command -v unison &> /dev/null; then
        echo_info "Installing Unison..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y unison
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm unison
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y unison
        fi
    fi
    
    # Apache Spark
    if ! command -v spark-shell &> /dev/null; then
        echo_info "Installing Apache Spark..."
        wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
        tar -xzf spark-3.5.0-bin-hadoop3.tgz
        sudo mv spark-3.5.0-bin-hadoop3 /opt/spark
        sudo ln -s /opt/spark/bin/spark-shell /usr/local/bin/spark-shell
        rm spark-3.5.0-bin-hadoop3.tgz
    fi
    
    # Apache Kafka
    if ! command -v kafka-server-start.sh &> /dev/null; then
        echo_info "Installing Apache Kafka..."
        wget https://archive.apache.org/dist/kafka/2.13-3.6.0/kafka_2.13-3.6.0.tgz
        tar -xzf kafka_2.13-3.6.0.tgz
        sudo mv kafka_2.13-3.6.0 /opt/kafka
        sudo ln -s /opt/kafka/bin/kafka-server-start.sh /usr/local/bin/
        sudo ln -s /opt/kafka/bin/kafka-console-producer.sh /usr/local/bin/
        sudo ln -s /opt/kafka/bin/kafka-console-consumer.sh /usr/local/bin/
        rm kafka_2.13-3.6.0.tgz
    fi
}

# More Web Development Tools
install_more_web_development_tools() {
    echo_info "Installing more web development tools..."
    
    # Svelte CLI
    if ! command -v svelte &> /dev/null; then
        echo_info "Installing Svelte..."
        npm install -g @sveltejs/cli
    fi
    
    # SolidJS CLI
    if ! command -v solid &> /dev/null; then
        echo_info "Installing SolidJS..."
        npm install -g solid-cli
    fi
    
    # Lit CLI
    if ! command -v lit &> /dev/null; then
        echo_info "Installing Lit..."
        npm install -g @lit/cli
    fi
    
    # Stencil CLI
    if ! command -v stencil &> /dev/null; then
        echo_info "Installing Stencil..."
        npm install -g @stencil/cli
    fi
    
    # Qwik CLI
    if ! command -v qwik &> /dev/null; then
        echo_info "Installing Qwik..."
        npm install -g create-qwik
    fi
    
    # Tailwind CSS CLI
    if ! command -v tailwindcss &> /dev/null; then
        echo_info "Installing Tailwind CSS..."
        npm install -g tailwindcss
    fi
    
    # Vite
    if ! command -v vite &> /dev/null; then
        echo_info "Installing Vite..."
        npm install -g vite
    fi
    
    # Rollup
    if ! command -v rollup &> /dev/null; then
        echo_info "Installing Rollup..."
        npm install -g rollup
    fi
    
    # Parcel
    if ! command -v parcel &> /dev/null; then
        echo_info "Installing Parcel..."
        npm install -g parcel
    fi
    
    # esbuild
    if ! command -v esbuild &> /dev/null; then
        echo_info "Installing esbuild..."
        npm install -g esbuild
    fi
    
    # SWC
    if ! command -v swc &> /dev/null; then
        echo_info "Installing SWC..."
        npm install -g @swc/cli @swc/core
    fi
    
    # Rush monorepo manager
    if ! command -v rush &> /dev/null; then
        echo_info "Installing Rush..."
        npm install -g @microsoft/rush
    fi
    
    # Sass
    if ! command -v sass &> /dev/null; then
        echo_info "Installing Sass..."
        npm install -g sass
    fi
    
    # Less
    if ! command -v lessc &> /dev/null; then
        echo_info "Installing Less..."
        npm install -g less
    fi
    
    # Stylus
    if ! command -v stylus &> /dev/null; then
        echo_info "Installing Stylus..."
        npm install -g stylus
    fi
}

# More Mobile Development Tools
install_more_mobile_development_tools() {
    echo_info "Installing more mobile development tools..."
    
    # Xamarin CLI
    if ! command -v xamarin &> /dev/null; then
        echo_info "Installing Xamarin..."
        if command -v dotnet &> /dev/null; then
            dotnet tool install --global xamarin.android.tools
        fi
    fi
    
    # Ionic CLI
    if ! command -v ionic &> /dev/null; then
        echo_info "Installing Ionic..."
        npm install -g @ionic/cli
    fi
    
    # Cordova CLI
    if ! command -v cordova &> /dev/null; then
        echo_info "Installing Cordova..."
        npm install -g cordova
    fi
    
    # PhoneGap CLI
    if ! command -v phonegap &> /dev/null; then
        echo_info "Installing PhoneGap..."
        npm install -g phonegap
    fi
    
    # NativeScript CLI
    if ! command -v ns &> /dev/null; then
        echo_info "Installing NativeScript..."
        npm install -g @nativescript/cli
    fi
    
    # Android Debug Bridge (ADB)
    if ! command -v adb &> /dev/null; then
        echo_info "Installing Android SDK Platform Tools..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y android-tools-adb android-tools-fastboot
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm android-tools
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y android-tools
        fi
    fi
    
    # iOS tools (for Linux)
    if ! command -v ios-deploy &> /dev/null; then
        echo_info "Installing ios-deploy..."
        npm install -g ios-deploy
    fi
    
    # ios-sim
    if ! command -v ios-sim &> /dev/null; then
        echo_info "Installing ios-sim..."
        npm install -g ios-sim
    fi
    
    # React Native tools
    npm install -g react-native-rename
    npm install -g react-native-version
    npm install -g @react-native-community/cli-doctor
}

# More Testing and QA Tools
install_more_testing_qa_tools() {
    echo_info "Installing more testing and QA tools..."
    
    # Apache Bench
    if ! command -v ab &> /dev/null; then
        echo_info "Installing Apache Bench..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y apache2-utils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm apache
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y httpd-tools
        fi
    fi
    
    # wrk HTTP benchmarking tool
    if ! command -v wrk &> /dev/null; then
        echo_info "Installing wrk..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wrk
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wrk
        else
            git clone https://github.com/wg/wrk.git
            cd wrk && make && sudo cp wrk /usr/local/bin/
            cd .. && rm -rf wrk
        fi
    fi
    
    # siege load testing
    if ! command -v siege &> /dev/null; then
        echo_info "Installing siege..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y siege
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm siege
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y siege
        fi
    fi
    
    # Artillery load testing
    if ! command -v artillery &> /dev/null; then
        echo_info "Installing Artillery..."
        npm install -g artillery
    fi
    
    # Selenium WebDriver
    if ! command -v selenium-side-runner &> /dev/null; then
        echo_info "Installing Selenium tools..."
        npm install -g selenium-side-runner
        npm install -g webdriver-manager
    fi
    
    # Appium
    if ! command -v appium &> /dev/null; then
        echo_info "Installing Appium..."
        npm install -g appium
        npm install -g appium-doctor
    fi
    
    # TestCafe
    if ! command -v testcafe &> /dev/null; then
        echo_info "Installing TestCafe..."
        npm install -g testcafe
    fi
    
    # Newman (Postman CLI)
    if ! command -v newman &> /dev/null; then
        echo_info "Installing Newman..."
        npm install -g newman
    fi
    
    # Dredd API testing
    if ! command -v dredd &> /dev/null; then
        echo_info "Installing Dredd..."
        npm install -g dredd
    fi
    
    # Karate API testing
    if ! command -v karate &> /dev/null; then
        echo_info "Installing Karate..."
        npm install -g karate-cli
    fi
    
    # SonarQube Scanner
    if ! command -v sonar-scanner &> /dev/null; then
        echo_info "Installing SonarQube Scanner..."
        wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
        unzip sonar-scanner-cli-4.8.0.2856-linux.zip
        sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
        sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/
        rm sonar-scanner-cli-4.8.0.2856-linux.zip
    fi
    
    # CodeClimate CLI
    if ! command -v codeclimate &> /dev/null; then
        echo_info "Installing CodeClimate CLI..."
        curl -L https://github.com/codeclimate/codeclimate/archive/master.tar.gz | tar xvz
        cd codeclimate-master && sudo make install
        cd .. && rm -rf codeclimate-master
    fi
}

# More Documentation and Communication Tools
install_more_documentation_communication_tools() {
    echo_info "Installing more documentation and communication tools..."
    
    # GitBook CLI
    if ! command -v gitbook &> /dev/null; then
        echo_info "Installing GitBook CLI..."
        npm install -g gitbook-cli
    fi
    
    # Docusaurus
    if ! command -v docusaurus &> /dev/null; then
        echo_info "Installing Docusaurus..."
        npm install -g @docusaurus/init
    fi
    
    # VuePress
    if ! command -v vuepress &> /dev/null; then
        echo_info "Installing VuePress..."
        npm install -g vuepress
    fi
    
    # Docsify
    if ! command -v docsify &> /dev/null; then
        echo_info "Installing Docsify..."
        npm install -g docsify-cli
    fi
    
    # PlantUML
    if ! command -v plantuml &> /dev/null; then
        echo_info "Installing PlantUML..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y plantuml
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm plantuml
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y plantuml
        fi
    fi
    
    # Mermaid CLI
    if ! command -v mmdc &> /dev/null; then
        echo_info "Installing Mermaid CLI..."
        npm install -g @mermaid-js/mermaid-cli
    fi
    
    # Draw.io desktop
    if ! command -v drawio &> /dev/null; then
        echo_info "Installing Draw.io desktop..."
        if command -v snap &> /dev/null; then
            sudo snap install drawio
        fi
    fi
    
    # Slack CLI
    if ! command -v slack &> /dev/null; then
        echo_info "Installing Slack CLI..."
        npm install -g @slack/cli
    fi
    
    # Discord CLI tools
    npm install -g discord-cli
    
    # Microsoft Teams CLI
    npm install -g @microsoft/teamsfx-cli
    
    # Notion CLI
    npm install -g notion-cli
    
    # Confluence CLI
    npm install -g confluence-cli
}

# More functions continue...
# Due to length constraints, I'll continue adding the rest in the next update

# Audio/Video Editing Tools
install_audio_video_editing_tools() {
    echo_info "Installing audio/video editing tools..."
    
    # FFmpeg
    if ! command -v ffmpeg &> /dev/null; then
        echo_info "Installing FFmpeg..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ffmpeg
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ffmpeg
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ffmpeg
        fi
    fi
    
    # Audacity
    if ! command -v audacity &> /dev/null; then
        echo_info "Installing Audacity..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y audacity
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm audacity
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y audacity
        fi
    fi
    
    # OBS Studio
    if ! command -v obs &> /dev/null; then
        echo_info "Installing OBS Studio..."
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:obsproject/obs-studio
            sudo apt-get update
            sudo apt-get install -y obs-studio
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm obs-studio
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y obs-studio
        fi
    fi
    
    # Kdenlive
    if ! command -v kdenlive &> /dev/null; then
        echo_info "Installing Kdenlive..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y kdenlive
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm kdenlive
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y kdenlive
        fi
    fi
    
    # OpenShot
    if ! command -v openshot-qt &> /dev/null; then
        echo_info "Installing OpenShot..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openshot-qt
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openshot
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openshot
        fi
    fi
    
    # youtube-dl
    if ! command -v youtube-dl &> /dev/null; then
        echo_info "Installing youtube-dl..."
        curl -L https://yt-dl.org/downloads/latest/youtube-dl -o youtube-dl
        chmod +x youtube-dl
        sudo mv youtube-dl /usr/local/bin/
    fi
    
    # yt-dlp (improved youtube-dl)
    if ! command -v yt-dlp &> /dev/null; then
        echo_info "Installing yt-dlp..."
        pip3 install yt-dlp
    fi
}

# Graphics and Design Tools
install_graphics_design_tools() {
    echo_info "Installing graphics and design tools..."
    
    # GIMP
    if ! command -v gimp &> /dev/null; then
        echo_info "Installing GIMP..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gimp
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gimp
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gimp
        fi
    fi
    
    # Inkscape
    if ! command -v inkscape &> /dev/null; then
        echo_info "Installing Inkscape..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y inkscape
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm inkscape
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y inkscape
        fi
    fi
    
    # Krita
    if ! command -v krita &> /dev/null; then
        echo_info "Installing Krita..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y krita
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm krita
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y krita
        fi
    fi
    
    # ImageMagick
    if ! command -v convert &> /dev/null; then
        echo_info "Installing ImageMagick..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y imagemagick
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm imagemagick
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ImageMagick
        fi
    fi
    
    # GraphicsMagick
    if ! command -v gm &> /dev/null; then
        echo_info "Installing GraphicsMagick..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y graphicsmagick
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm graphicsmagick
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y GraphicsMagick
        fi
    fi
}

# Virtualization Tools
install_virtualization_tools() {
    echo_info "Installing virtualization tools..."
    
    # VirtualBox
    if ! command -v virtualbox &> /dev/null; then
        echo_info "Installing VirtualBox..."
        if command -v apt-get &> /dev/null; then
            wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
            sudo apt-get update
            sudo apt-get install -y virtualbox-7.0
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm virtualbox
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y VirtualBox
        fi
    fi
    
    # QEMU
    if ! command -v qemu-system-x86_64 &> /dev/null; then
        echo_info "Installing QEMU..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qemu-system qemu-utils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm qemu-desktop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qemu
        fi
    fi
    
    # KVM
    if ! command -v virsh &> /dev/null; then
        echo_info "Installing KVM and libvirt..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm libvirt qemu-desktop virt-manager
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y libvirt qemu-kvm virt-manager
        fi
    fi
    
    # Vagrant
    if ! command -v vagrant &> /dev/null; then
        echo_info "Installing Vagrant..."
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install -y vagrant
    fi
}

# Backup and Archiving Tools
install_backup_archiving_tools() {
    echo_info "Installing backup and archiving tools..."
    
    # rsync
    if ! command -v rsync &> /dev/null; then
        echo_info "Installing rsync..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y rsync
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm rsync
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y rsync
        fi
    fi
    
    # Borgbackup
    if ! command -v borg &> /dev/null; then
        echo_info "Installing Borgbackup..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y borgbackup
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm borg
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y borgbackup
        fi
    fi
    
    # Restic
    if ! command -v restic &> /dev/null; then
        echo_info "Installing Restic..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y restic
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm restic
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y restic
        fi
    fi
}

# System Administration Tools
install_system_administration_tools() {
    echo_info "Installing system administration tools..."
    
    # Ansible
    if ! command -v ansible &> /dev/null; then
        echo_info "Installing Ansible..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ansible
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ansible
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ansible
        fi
    fi
    
    # Nagios plugins
    if ! command -v check_http &> /dev/null; then
        echo_info "Installing Nagios plugins..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nagios-plugins
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm monitoring-plugins
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nagios-plugins-all
        fi
    fi
    
    # fail2ban
    if ! command -v fail2ban-client &> /dev/null; then
        echo_info "Installing fail2ban..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fail2ban
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fail2ban
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fail2ban
        fi
    fi
    
    # ufw firewall
    if ! command -v ufw &> /dev/null; then
        echo_info "Installing UFW..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ufw
        fi
    fi
    
    # logrotate
    if ! command -v logrotate &> /dev/null; then
        echo_info "Installing logrotate..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y logrotate
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm logrotate
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y logrotate
        fi
    fi
}

# Network Analysis Tools
install_network_analysis_tools() {
    echo_info "Installing network analysis tools..."
    
    # Wireshark
    if ! command -v wireshark &> /dev/null; then
        echo_info "Installing Wireshark..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wireshark
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wireshark-qt
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wireshark
        fi
    fi
    
    # nmap
    if ! command -v nmap &> /dev/null; then
        echo_info "Installing nmap..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nmap
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nmap
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nmap
        fi
    fi
    
    # netcat
    if ! command -v nc &> /dev/null; then
        echo_info "Installing netcat..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y netcat-openbsd
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openbsd-netcat
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nmap-ncat
        fi
    fi
    
    # mtr (network diagnostics)
    if ! command -v mtr &> /dev/null; then
        echo_info "Installing mtr..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mtr-tiny
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mtr
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mtr
        fi
    fi
    
    # dig and nslookup
    if ! command -v dig &> /dev/null; then
        echo_info "Installing dig..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y dnsutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm bind
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y bind-utils
        fi
    fi
}

# More Database Tools
install_more_database_tools() {
    echo_info "Installing more database tools..."
    
    # MongoDB Compass
    if ! command -v mongodb-compass &> /dev/null; then
        echo_info "Installing MongoDB Compass..."
        wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
        sudo apt-get update
        sudo apt-get install -y mongodb-compass
    fi
    
    # DBeaver
    if ! command -v dbeaver &> /dev/null; then
        echo_info "Installing DBeaver..."
        if command -v snap &> /dev/null; then
            sudo snap install dbeaver-ce
        else
            wget -O dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
            sudo dpkg -i dbeaver.deb
            rm dbeaver.deb
        fi
    fi
    
    # pgAdmin4
    if ! command -v pgadmin4 &> /dev/null; then
        echo_info "Installing pgAdmin4..."
        curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
        sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
        sudo apt-get update
        sudo apt-get install -y pgadmin4-desktop
    fi
    
    # MySQL Workbench
    if ! command -v mysql-workbench &> /dev/null; then
        echo_info "Installing MySQL Workbench..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mysql-workbench
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mysql-workbench
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mysql-workbench
        fi
    fi
    
    # InfluxDB client
    if ! command -v influx &> /dev/null; then
        echo_info "Installing InfluxDB client..."
        wget -q https://repos.influxdata.com/influxdata-archive_compat.key
        echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
        echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
        sudo apt-get update && sudo apt-get install -y influxdb2-cli
        rm influxdata-archive_compat.key
    fi
    
    # Neo4j
    if ! command -v neo4j &> /dev/null; then
        echo_info "Installing Neo4j..."
        wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
        echo 'deb https://debian.neo4j.com stable 4.4' | sudo tee -a /etc/apt/sources.list.d/neo4j.list
        sudo apt-get update
        sudo apt-get install -y neo4j
    fi
}

# Code Analysis and Quality Tools
install_code_analysis_quality_tools() {
    echo_info "Installing code analysis and quality tools..."
    
    # ESLint
    if ! command -v eslint &> /dev/null; then
        echo_info "Installing ESLint..."
        npm install -g eslint
    fi
    
    # Prettier
    if ! command -v prettier &> /dev/null; then
        echo_info "Installing Prettier..."
        npm install -g prettier
    fi
    
    # StyleLint
    if ! command -v stylelint &> /dev/null; then
        echo_info "Installing StyleLint..."
        npm install -g stylelint
    fi
    
    # JSHint
    if ! command -v jshint &> /dev/null; then
        echo_info "Installing JSHint..."
        npm install -g jshint
    fi
    
    # Standard
    if ! command -v standard &> /dev/null; then
        echo_info "Installing Standard..."
        npm install -g standard
    fi
    
    # TSLint
    if ! command -v tslint &> /dev/null; then
        echo_info "Installing TSLint..."
        npm install -g tslint
    fi
    
    # Commitizen
    if ! command -v commitizen &> /dev/null; then
        echo_info "Installing Commitizen..."
        npm install -g commitizen
    fi
    
    # Husky
    npm install -g husky
    
    # lint-staged
    npm install -g lint-staged
    
    # Bandit (Python security linter)
    if ! command -v bandit &> /dev/null; then
        echo_info "Installing Bandit..."
        pip3 install bandit
    fi
    
    # Safety (Python dependency scanner)
    if ! command -v safety &> /dev/null; then
        echo_info "Installing Safety..."
        pip3 install safety
    fi
    
    # mypy (Python type checker)
    if ! command -v mypy &> /dev/null; then
        echo_info "Installing mypy..."
        pip3 install mypy
    fi
    
    # flake8 (Python linter)
    if ! command -v flake8 &> /dev/null; then
        echo_info "Installing flake8..."
        pip3 install flake8
    fi
    
    # black (Python formatter)
    if ! command -v black &> /dev/null; then
        echo_info "Installing black..."
        pip3 install black
    fi
    
    # isort (Python import sorter)
    if ! command -v isort &> /dev/null; then
        echo_info "Installing isort..."
        pip3 install isort
    fi
}

# Deployment and CI/CD Tools
install_deployment_cicd_tools() {
    echo_info "Installing deployment and CI/CD tools..."
    
    # Jenkins CLI
    if ! command -v jenkins-cli &> /dev/null; then
        echo_info "Installing Jenkins CLI..."
        wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar 2>/dev/null || echo "Jenkins CLI requires running Jenkins instance"
    fi
    
    # GitLab Runner
    if ! command -v gitlab-runner &> /dev/null; then
        echo_info "Installing GitLab Runner..."
        curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
        sudo apt-get install -y gitlab-runner
    fi
    
    # CircleCI CLI
    if ! command -v circleci &> /dev/null; then
        echo_info "Installing CircleCI CLI..."
        curl -fLSs https://circle.ci/cli | bash
    fi
    
    # Travis CI CLI
    if ! command -v travis &> /dev/null; then
        echo_info "Installing Travis CI CLI..."
        gem install travis
    fi
    
    # Heroku CLI
    if ! command -v heroku &> /dev/null; then
        echo_info "Installing Heroku CLI..."
        curl https://cli-assets.heroku.com/install.sh | sh
    fi
    
    # Vercel CLI
    if ! command -v vercel &> /dev/null; then
        echo_info "Installing Vercel CLI..."
        npm install -g vercel
    fi
    
    # Netlify CLI
    if ! command -v netlify &> /dev/null; then
        echo_info "Installing Netlify CLI..."
        npm install -g netlify-cli
    fi
    
    # Firebase CLI
    if ! command -v firebase &> /dev/null; then
        echo_info "Installing Firebase CLI..."
        npm install -g firebase-tools
    fi
    
    # Surge.sh
    if ! command -v surge &> /dev/null; then
        echo_info "Installing Surge.sh..."
        npm install -g surge
    fi
    
    # Now CLI (Zeit)
    npm install -g now
    
    # GitHub Actions CLI
    if ! command -v act &> /dev/null; then
        echo_info "Installing Act (GitHub Actions CLI)..."
        curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    fi
}

# Logging and Monitoring Tools
install_logging_monitoring_tools() {
    echo_info "Installing logging and monitoring tools..."
    
    # Elasticsearch
    if ! command -v elasticsearch &> /dev/null; then
        echo_info "Installing Elasticsearch..."
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
        echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
        sudo apt-get update && sudo apt-get install -y elasticsearch
    fi
    
    # Kibana
    if ! command -v kibana &> /dev/null; then
        echo_info "Installing Kibana..."
        sudo apt-get install -y kibana
    fi
    
    # Logstash
    if ! command -v logstash &> /dev/null; then
        echo_info "Installing Logstash..."
        sudo apt-get install -y logstash
    fi
    
    # Fluentd
    if ! command -v fluentd &> /dev/null; then
        echo_info "Installing Fluentd..."
        curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-jammy-td-agent4.sh | sh
    fi
    
    # Vector
    if ! command -v vector &> /dev/null; then
        echo_info "Installing Vector..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.vector.dev | bash
    fi
    
    # New Relic CLI
    if ! command -v newrelic &> /dev/null; then
        echo_info "Installing New Relic CLI..."
        curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash
    fi
    
    # DataDog CLI
    if ! command -v datadog-ci &> /dev/null; then
        echo_info "Installing DataDog CLI..."
        npm install -g @datadog/datadog-ci
    fi
}

# More Terminal and Shell Tools
install_more_terminal_shell_tools() {
    echo_info "Installing more terminal and shell tools..."
    
    # Zsh
    if ! command -v zsh &> /dev/null; then
        echo_info "Installing Zsh..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y zsh
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zsh
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zsh
        fi
    fi
    
    # Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Fish shell
    if ! command -v fish &> /dev/null; then
        echo_info "Installing Fish shell..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fish
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fish
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fish
        fi
    fi
    
    # Starship prompt
    if ! command -v starship &> /dev/null; then
        echo_info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi
    
    # Alacritty terminal
    if ! command -v alacritty &> /dev/null; then
        echo_info "Installing Alacritty..."
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:aslatter/ppa
            sudo apt-get update
            sudo apt-get install -y alacritty
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm alacritty
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y alacritty
        fi
    fi
    
    # Kitty terminal
    if ! command -v kitty &> /dev/null; then
        echo_info "Installing Kitty terminal..."
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    fi
    
    # WezTerm
    if ! command -v wezterm &> /dev/null; then
        echo_info "Installing WezTerm..."
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
        sudo apt-get update
        sudo apt-get install -y wezterm
    fi
    
    # Terminal multiplexers
    if ! command -v screen &> /dev/null; then
        echo_info "Installing screen..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y screen
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm screen
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y screen
        fi
    fi
    
    # byobu
    if ! command -v byobu &> /dev/null; then
        echo_info "Installing byobu..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y byobu
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm byobu
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y byobu
        fi
    fi
    
    # Tree command
    if ! command -v tree &> /dev/null; then
        echo_info "Installing tree..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tree
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tree
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tree
        fi
    fi
    
    # lsd (better ls)
    if ! command -v lsd &> /dev/null; then
        echo_info "Installing lsd..."
        if command -v snap &> /dev/null; then
            sudo snap install lsd
        else
            cargo install lsd
        fi
    fi
    
    # dust (better du)
    if ! command -v dust &> /dev/null; then
        echo_info "Installing dust..."
        cargo install du-dust
    fi
    
    # procs (better ps)
    if ! command -v procs &> /dev/null; then
        echo_info "Installing procs..."
        cargo install procs
    fi
    
    # bottom (better top)
    if ! command -v btm &> /dev/null; then
        echo_info "Installing bottom..."
        cargo install bottom
    fi
    
    # delta (better diff)
    if ! command -v delta &> /dev/null; then
        echo_info "Installing delta..."
        cargo install git-delta
    fi
    
    # hyperfine (benchmarking)
    if ! command -v hyperfine &> /dev/null; then
        echo_info "Installing hyperfine..."
        cargo install hyperfine
    fi
}

# Reverse Engineering Tools
install_reverse_engineering_tools() {
    echo_info "Installing reverse engineering tools..."
    
    # Ghidra
    if ! command -v ghidra &> /dev/null; then
        echo_info "Installing Ghidra..."
        wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip
        unzip ghidra_10.4_PUBLIC_20230928.zip
        sudo mv ghidra_10.4_PUBLIC /opt/ghidra
        sudo ln -s /opt/ghidra/ghidraRun /usr/local/bin/ghidra
        rm ghidra_10.4_PUBLIC_20230928.zip
    fi
    
    # Radare2
    if ! command -v r2 &> /dev/null; then
        echo_info "Installing Radare2..."
        git clone https://github.com/radareorg/radare2
        cd radare2 && sys/install.sh
        cd .. && rm -rf radare2
    fi
    
    # Cutter (Radare2 GUI)
    if ! command -v cutter &> /dev/null; then
        echo_info "Installing Cutter..."
        if command -v snap &> /dev/null; then
            sudo snap install cutter
        fi
    fi
    
    # Binwalk
    if ! command -v binwalk &> /dev/null; then
        echo_info "Installing Binwalk..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y binwalk
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm binwalk
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y binwalk
        fi
    fi
    
    # Hexdump and xxd
    if ! command -v hexdump &> /dev/null; then
        echo_info "Installing hexdump..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y bsdmainutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm util-linux
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y util-linux
        fi
    fi
    
    # Strings command
    if ! command -v strings &> /dev/null; then
        echo_info "Installing strings..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y binutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm binutils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y binutils
        fi
    fi
    
    # objdump
    if ! command -v objdump &> /dev/null; then
        echo_info "Installing objdump..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y binutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm binutils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y binutils
        fi
    fi
    
    # GDB
    if ! command -v gdb &> /dev/null; then
        echo_info "Installing GDB..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gdb
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gdb
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gdb
        fi
    fi
    
    # LLDB
    if ! command -v lldb &> /dev/null; then
        echo_info "Installing LLDB..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y lldb
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lldb
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lldb
        fi
    fi
}

# Accessibility Tools
install_accessibility_tools() {
    echo_info "Installing accessibility tools..."
    
    # axe-core CLI
    if ! command -v axe &> /dev/null; then
        echo_info "Installing axe-core CLI..."
        npm install -g @axe-core/cli
    fi
    
    # Pa11y
    if ! command -v pa11y &> /dev/null; then
        echo_info "Installing Pa11y..."
        npm install -g pa11y
    fi
    
    # Lighthouse (already covered but ensuring it's here)
    if ! command -v lighthouse &> /dev/null; then
        echo_info "Installing Lighthouse..."
        npm install -g lighthouse
    fi
    
    # WAVE CLI
    npm install -g wave-cli
    
    # Axe-puppeteer
    npm install -g axe-puppeteer
    
    # Contrast ratio checker
    npm install -g contrast-ratio
}

# Data Analysis Tools
install_data_analysis_tools() {
    echo_info "Installing data analysis tools..."
    
    # Apache Superset
    if ! command -v superset &> /dev/null; then
        echo_info "Installing Apache Superset..."
        pip3 install apache-superset
    fi
    
    # DuckDB
    if ! command -v duckdb &> /dev/null; then
        echo_info "Installing DuckDB..."
        wget https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip
        unzip duckdb_cli-linux-amd64.zip
        sudo mv duckdb /usr/local/bin/
        rm duckdb_cli-linux-amd64.zip
    fi
    
    # ClickHouse client
    if ! command -v clickhouse-client &> /dev/null; then
        echo_info "Installing ClickHouse client..."
        curl https://clickhouse.com/ | sh
        sudo mv clickhouse /usr/local/bin/clickhouse-client
    fi
    
    # Miller (data processing)
    if ! command -v mlr &> /dev/null; then
        echo_info "Installing Miller..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y miller
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm miller
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y miller
        fi
    fi
    
    # VisiData
    if ! command -v vd &> /dev/null; then
        echo_info "Installing VisiData..."
        pip3 install visidata
    fi
    
    # Datamash
    if ! command -v datamash &> /dev/null; then
        echo_info "Installing Datamash..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y datamash
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm datamash
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y datamash
        fi
    fi
    
    # CSVKit
    if ! command -v csvkit &> /dev/null; then
        echo_info "Installing CSVKit..."
        pip3 install csvkit
    fi
}

# More Compression Tools
install_more_compression_tools() {
    echo_info "Installing more compression tools..."
    
    # xz
    if ! command -v xz &> /dev/null; then
        echo_info "Installing xz..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y xz-utils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm xz
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xz
        fi
    fi
    
    # bzip2
    if ! command -v bzip2 &> /dev/null; then
        echo_info "Installing bzip2..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y bzip2
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm bzip2
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y bzip2
        fi
    fi
    
    # Brotli
    if ! command -v brotli &> /dev/null; then
        echo_info "Installing Brotli..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y brotli
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm brotli
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y brotli
        fi
    fi
    
    # Pigz (parallel gzip)
    if ! command -v pigz &> /dev/null; then
        echo_info "Installing pigz..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y pigz
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm pigz
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pigz
        fi
    fi
    
    # Pbzip2 (parallel bzip2)
    if ! command -v pbzip2 &> /dev/null; then
        echo_info "Installing pbzip2..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y pbzip2
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm pbzip2
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pbzip2
        fi
    fi
}

# Embedded Development Tools
install_embedded_development_tools() {
    echo_info "Installing embedded development tools..."
    
    # Arduino CLI
    if ! command -v arduino-cli &> /dev/null; then
        echo_info "Installing Arduino CLI..."
        curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
        sudo mv bin/arduino-cli /usr/local/bin/
        rmdir bin
    fi
    
    # PlatformIO
    if ! command -v pio &> /dev/null; then
        echo_info "Installing PlatformIO..."
        pip3 install platformio
    fi
    
    # OpenOCD
    if ! command -v openocd &> /dev/null; then
        echo_info "Installing OpenOCD..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openocd
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openocd
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openocd
        fi
    fi
    
    # Minicom (serial communication)
    if ! command -v minicom &> /dev/null; then
        echo_info "Installing Minicom..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y minicom
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm minicom
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y minicom
        fi
    fi
    
    # Screen (for serial communication)
    # Already covered in terminal tools
    
    # STM32CubeProgrammer (manual installation note)
    echo_info "Note: STM32CubeProgrammer requires manual download from STMicroelectronics"
    
    # ESP-IDF
    if [ ! -d "$HOME/esp/esp-idf" ]; then
        echo_info "Installing ESP-IDF..."
        mkdir -p ~/esp
        cd ~/esp
        git clone --recursive https://github.com/espressif/esp-idf.git
        cd esp-idf
        ./install.sh esp32
        cd ~
    fi
    
    # Arm GCC Toolchain
    if ! command -v arm-none-eabi-gcc &> /dev/null; then
        echo_info "Installing ARM GCC Toolchain..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gcc-arm-none-eabi
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm arm-none-eabi-gcc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y arm-none-eabi-gcc-cs
        fi
    fi
    
    # AVR GCC Toolchain
    if ! command -v avr-gcc &> /dev/null; then
        echo_info "Installing AVR GCC Toolchain..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gcc-avr binutils-avr avr-libc
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm avr-gcc avr-binutils avr-libc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y avr-gcc avr-binutils avr-libc
        fi
    fi
}

# Server and Infrastructure Tools
install_server_infrastructure_tools() {
    echo_info "Installing server and infrastructure tools..."
    
    # Nginx
    if ! command -v nginx &> /dev/null; then
        echo_info "Installing Nginx..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nginx
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nginx
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nginx
        fi
    fi
    
    # Apache2
    if ! command -v apache2 &> /dev/null; then
        echo_info "Installing Apache2..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y apache2
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm apache
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y httpd
        fi
    fi
    
    # HAProxy
    if ! command -v haproxy &> /dev/null; then
        echo_info "Installing HAProxy..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y haproxy
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm haproxy
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y haproxy
        fi
    fi
    
    # Traefik
    if ! command -v traefik &> /dev/null; then
        echo_info "Installing Traefik..."
        curl -L https://github.com/traefik/traefik/releases/latest/download/traefik_linux_amd64.tar.gz | tar xz
        sudo mv traefik /usr/local/bin/
    fi
    
    # Caddy
    if ! command -v caddy &> /dev/null; then
        echo_info "Installing Caddy..."
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
        sudo apt-get update
        sudo apt-get install -y caddy
    fi
    
    # Let's Encrypt Certbot
    if ! command -v certbot &> /dev/null; then
        echo_info "Installing Certbot..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y certbot
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm certbot
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y certbot
        fi
    fi
    
    # Systemctl and Journalctl (should be available on systemd systems)
    # Service management tools are typically pre-installed
    
    # Consul
    if ! command -v consul &> /dev/null; then
        echo_info "Installing Consul..."
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install -y consul
    fi
    
    # Vault
    if ! command -v vault &> /dev/null; then
        echo_info "Installing Vault..."
        sudo apt-get install -y vault
    fi
    
    # Nomad
    if ! command -v nomad &> /dev/null; then
        echo_info "Installing Nomad..."
        sudo apt-get install -y nomad
    fi
    
    # Etcd
    if ! command -v etcd &> /dev/null; then
        echo_info "Installing etcd..."
        ETCD_VER=v3.5.10
        curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o etcd.tar.gz
        tar xzvf etcd.tar.gz
        sudo mv etcd-${ETCD_VER}-linux-amd64/etcd* /usr/local/bin/
        rm -rf etcd.tar.gz etcd-${ETCD_VER}-linux-amd64
    fi
}

# Additional Mega Categories for 400+ Tools

# Advanced Programming Languages and Compilers
install_advanced_programming_languages() {
    echo_info "Installing advanced programming languages and compilers..."
    
    # Assembly tools
    if ! command -v nasm &> /dev/null; then
        echo_info "Installing NASM..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nasm
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nasm
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nasm
        fi
    fi
    
    # YASM
    if ! command -v yasm &> /dev/null; then
        echo_info "Installing YASM..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y yasm
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm yasm
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y yasm
        fi
    fi
    
    # Fortran
    if ! command -v gfortran &> /dev/null; then
        echo_info "Installing GNU Fortran..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gfortran
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gcc-fortran
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gcc-gfortran
        fi
    fi
    
    # COBOL
    if ! command -v cobc &> /dev/null; then
        echo_info "Installing GnuCOBOL..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gnucobol
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gnucobol
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gnucobol
        fi
    fi
    
    # Pascal
    if ! command -v fpc &> /dev/null; then
        echo_info "Installing Free Pascal..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fpc
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fpc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fpc
        fi
    fi
    
    # Ada
    if ! command -v gnat &> /dev/null; then
        echo_info "Installing GNAT Ada compiler..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gnat
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gcc-ada
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gcc-gnat
        fi
    fi
    
    # Tcl
    if ! command -v tclsh &> /dev/null; then
        echo_info "Installing Tcl..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tcl
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tcl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tcl
        fi
    fi
    
    # Tk
    if ! command -v wish &> /dev/null; then
        echo_info "Installing Tk..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tk
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tk
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tk
        fi
    fi
    
    # Scheme
    if ! command -v scheme &> /dev/null; then
        echo_info "Installing MIT Scheme..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mit-scheme
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mit-scheme
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mit-scheme
        fi
    fi
    
    # Common Lisp
    if ! command -v sbcl &> /dev/null; then
        echo_info "Installing SBCL (Steel Bank Common Lisp)..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sbcl
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sbcl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sbcl
        fi
    fi
    
    # V Language
    if ! command -v v &> /dev/null; then
        echo_info "Installing V Language..."
        git clone https://github.com/vlang/v
        cd v && make && sudo ./v symlink
        cd .. && rm -rf v
    fi
    
    # Zig (already covered but ensuring)
    # Crystal (already covered but ensuring)
    
    # AWK (should be installed but ensuring)
    if ! command -v awk &> /dev/null; then
        echo_info "Installing AWK..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gawk
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gawk
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gawk
        fi
    fi
    
    # sed (should be installed)
    if ! command -v sed &> /dev/null; then
        echo_info "Installing sed..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sed
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sed
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sed
        fi
    fi
}

# Database Management Systems
install_database_management_systems() {
    echo_info "Installing database management systems..."
    
    # MariaDB
    if ! command -v mariadb &> /dev/null; then
        echo_info "Installing MariaDB..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mariadb-server mariadb-client
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mariadb
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mariadb-server mariadb
        fi
    fi
    
    # MySQL
    if ! command -v mysql &> /dev/null; then
        echo_info "Installing MySQL..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mysql-server mysql-client
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mysql
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mysql-server mysql
        fi
    fi
    
    # CouchDB
    if ! command -v couchdb &> /dev/null; then
        echo_info "Installing CouchDB..."
        if command -v apt-get &> /dev/null; then
            curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc | sudo apt-key add -
            echo "deb https://apache.bintray.com/couchdb-deb/ focal main" | sudo tee -a /etc/apt/sources.list
            sudo apt-get update && sudo apt-get install -y couchdb
        fi
    fi
    
    # CassandraDB
    if ! command -v cassandra &> /dev/null; then
        echo_info "Installing Cassandra..."
        wget -q -O - https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
        sudo sh -c 'echo "deb http://www.apache.org/dist/cassandra/debian 311x main" > /etc/apt/sources.list.d/cassandra.sources.list'
        sudo apt-get update && sudo apt-get install -y cassandra
    fi
    
    # TimescaleDB
    if ! command -v timescaledb-tune &> /dev/null; then
        echo_info "Installing TimescaleDB..."
        sudo sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/ubuntu/ $(lsb_release -c -s) main' > /etc/apt/sources.list.d/timescaledb.list"
        wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
        sudo apt-get update && sudo apt-get install -y timescaledb-2-postgresql-14
    fi
    
    # RethinkDB
    if ! command -v rethinkdb &> /dev/null; then
        echo_info "Installing RethinkDB..."
        source /etc/lsb-release && echo "deb https://download.rethinkdb.com/repository/ubuntu-$DISTRIB_CODENAME $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
        wget -qO- https://download.rethinkdb.com/repository/raw/pubkey.gpg | sudo apt-key add -
        sudo apt-get update && sudo apt-get install -y rethinkdb
    fi
    
    # ArangoDB
    if ! command -v arangodb &> /dev/null; then
        echo_info "Installing ArangoDB..."
        curl -OL https://download.arangodb.com/arangodb311/DEBIAN/Release.key
        sudo apt-key add - < Release.key
        echo 'deb https://download.arangodb.com/arangodb311/DEBIAN/ /' | sudo tee /etc/apt/sources.list.d/arangodb.list
        sudo apt-get update && sudo apt-get install -y arangodb3
        rm Release.key
    fi
    
    # OrientDB
    echo_info "Installing OrientDB..."
    wget https://s3.us-east-2.amazonaws.com/orientdb3/releases/3.2.15/orientdb-3.2.15.tar.gz
    tar -xzf orientdb-3.2.15.tar.gz
    sudo mv orientdb-3.2.15 /opt/orientdb
    sudo ln -s /opt/orientdb/bin/orientdb.sh /usr/local/bin/orientdb
    rm orientdb-3.2.15.tar.gz
    
    # Graph databases already covered (Neo4j)
    
    # ScyllaDB
    if ! command -v scylla &> /dev/null; then
        echo_info "Installing ScyllaDB..."
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5e08fbd8b5d6ec9c
        sudo curl -L --output /etc/apt/sources.list.d/scylla.list http://downloads.scylladb.com/deb/ubuntu/scylla-5.0-focal.list
        sudo apt-get update && sudo apt-get install -y scylla
    fi
}

# Advanced Development Frameworks
install_advanced_development_frameworks() {
    echo_info "Installing advanced development frameworks..."
    
    # Django
    if ! command -v django-admin &> /dev/null; then
        echo_info "Installing Django..."
        pip3 install django
    fi
    
    # Flask
    pip3 install flask
    
    # FastAPI
    pip3 install fastapi uvicorn
    
    # Tornado
    pip3 install tornado
    
    # Bottle
    pip3 install bottle
    
    # Pyramid
    pip3 install pyramid
    
    # CherryPy
    pip3 install cherrypy
    
    # Falcon
    pip3 install falcon
    
    # Sanic
    pip3 install sanic
    
    # Quart
    pip3 install quart
    
    # Starlette
    pip3 install starlette
    
    # Express.js (via npm)
    npm install -g express-generator
    
    # Koa.js
    npm install -g koa-generator
    
    # Hapi.js
    npm install -g @hapi/cli
    
    # Fastify
    npm install -g fastify-cli
    
    # NestJS
    npm install -g @nestjs/cli
    
    # AdonisJS
    npm install -g @adonisjs/cli
    
    # Feathers
    npm install -g @feathersjs/cli
    
    # Strapi
    npm install -g @strapi/strapi
    
    # Keystone
    npm install -g @keystone-6/cli
    
    # GraphQL tools
    npm install -g graphql-cli
    npm install -g @graphql-codegen/cli
    npm install -g apollo
    
    # REST API frameworks
    npm install -g json-server
    npm install -g mockoon-cli
    
    # Spring Boot CLI
    if ! command -v spring &> /dev/null && command -v java &> /dev/null; then
        echo_info "Installing Spring Boot CLI..."
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk install springboot
    fi
}

# Code Formatters and Linters Mega Pack
install_code_formatters_linters_mega() {
    echo_info "Installing comprehensive code formatters and linters..."
    
    # JavaScript/TypeScript
    npm install -g xo
    npm install -g semistandard
    npm install -g @typescript-eslint/parser
    npm install -g @typescript-eslint/eslint-plugin
    npm install -g tslint-config-prettier
    npm install -g tslint-plugin-prettier
    
    # CSS/SCSS/Less
    npm install -g stylelint-config-standard
    npm install -g stylelint-config-prettier
    npm install -g sass-lint
    npm install -g lesshint
    npm install -g csslint
    npm install -g postcss-cli
    npm install -g autoprefixer
    
    # Python formatters/linters
    pip3 install autopep8
    pip3 install yapf
    pip3 install pycodestyle
    pip3 install pydocstyle
    pip3 install pylint
    pip3 install vulture
    pip3 install radon
    pip3 install mccabe
    pip3 install pyflakes
    pip3 install prospector
    pip3 install pylama
    
    # Go formatters/linters
    if command -v go &> /dev/null; then
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
        go install golang.org/x/tools/cmd/goimports@latest
        go install mvdan.cc/gofumpt@latest
        go install github.com/segmentio/golines@latest
        go install honnef.co/go/tools/cmd/staticcheck@latest
        go install github.com/kisielk/errcheck@latest
        go install github.com/mdempsky/unconvert@latest
        go install github.com/gordonklaus/ineffassign@latest
        go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
    fi
    
    # Rust formatters/linters
    if command -v cargo &> /dev/null; then
        rustup component add rustfmt
        rustup component add clippy
        cargo install cargo-audit
        cargo install cargo-outdated
        cargo install cargo-tree
        cargo install cargo-watch
        cargo install cargo-expand
        cargo install cargo-bloat
    fi
    
    # C/C++ formatters/linters
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y clang-format clang-tidy cppcheck
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm clang cppcheck
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y clang-tools-extra cppcheck
    fi
    
    # Java formatters/linters
    npm install -g google-java-format
    
    # PHP formatters/linters
    if command -v composer &> /dev/null; then
        composer global require friendsofphp/php-cs-fixer
        composer global require squizlabs/php_codesniffer
        composer global require phpmd/phpmd
        composer global require sebastian/phpcpd
    fi
    
    # Ruby formatters/linters
    if command -v gem &> /dev/null; then
        gem install rubocop
        gem install reek
        gem install flog
        gem install flay
        gem install rails_best_practices
        gem install brakeman
    fi
    
    # Swift formatters/linters
    if command -v swift &> /dev/null; then
        echo_info "Note: SwiftLint and SwiftFormat require Xcode or manual installation"
    fi
    
    # Shell script linters (shellcheck already installed)
    npm install -g bash-language-server
    
    # YAML linters
    pip3 install yamllint
    npm install -g yaml-lint
    
    # JSON linters
    npm install -g jsonlint
    
    # XML linters
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y libxml2-utils
    fi
    
    # Markdown linters
    npm install -g markdownlint-cli
    npm install -g remark-cli
    npm install -g alex
    npm install -g write-good
    
    # SQL formatters
    npm install -g sql-formatter
    pip3 install sqlparse
    
    # Dockerfile linters
    if ! command -v hadolint &> /dev/null; then
        wget -O hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
        chmod +x hadolint
        sudo mv hadolint /usr/local/bin/
    fi
    
    # TOML linters
    pip3 install toml
}

# Testing Frameworks Mega Pack
install_testing_frameworks_mega() {
    echo_info "Installing comprehensive testing frameworks..."
    
    # JavaScript Testing
    npm install -g jest
    npm install -g mocha
    npm install -g jasmine
    npm install -g ava
    npm install -g tape
    npm install -g nyc
    npm install -g chai
    npm install -g sinon
    npm install -g karma-cli
    npm install -g protractor
    npm install -g webdriverio
    npm install -g codeceptjs
    npm install -g puppeteer
    npm install -g playwright-cli
    npm install -g cypress-cli
    npm install -g @storybook/cli
    npm install -g chromatic
    
    # Python Testing
    pip3 install pytest
    pip3 install pytest-cov
    pip3 install pytest-xdist
    pip3 install pytest-mock
    pip3 install pytest-django
    pip3 install pytest-flask
    pip3 install unittest2
    pip3 install nose2
    pip3 install coverage
    pip3 install tox
    pip3 install factory-boy
    pip3 install faker
    pip3 install hypothesis
    pip3 install responses
    pip3 install vcr.py
    pip3 install selenium
    pip3 install behave
    pip3 install robot-framework
    pip3 install locust
    
    # Go Testing Tools
    if command -v go &> /dev/null; then
        go install github.com/onsi/ginkgo/v2/ginkgo@latest
        go install github.com/onsi/gomega@latest
        go install github.com/stretchr/testify@latest
        go install github.com/golang/mock/mockgen@latest
        go install github.com/vektra/mockery/v2@latest
        go install gotest.tools/gotestsum@latest
        go install github.com/rakyll/gotest@latest
    fi
    
    # Rust Testing Tools
    if command -v cargo &> /dev/null; then
        cargo install cargo-tarpaulin
        cargo install cargo-nextest
        cargo install cargo-mutants
    fi
    
    # Java Testing Tools
    if command -v mvn &> /dev/null; then
        echo_info "Maven-based projects can use JUnit, TestNG, Mockito via pom.xml"
    fi
    if command -v gradle &> /dev/null; then
        echo_info "Gradle-based projects can use testing frameworks via build.gradle"
    fi
    
    # PHP Testing
    if command -v composer &> /dev/null; then
        composer global require phpunit/phpunit
        composer global require codeception/codeception
        composer global require behat/behat
        composer global require phpspec/phpspec
        composer global require mockery/mockery
    fi
    
    # Ruby Testing
    if command -v gem &> /dev/null; then
        gem install rspec
        gem install minitest
        gem install cucumber
        gem install capybara
        gem install factory_bot
        gem install webmock
        gem install vcr
        gem install timecop
        gem install shoulda-matchers
    fi
    
    # C# Testing (if .NET is installed)
    if command -v dotnet &> /dev/null; then
        echo_info ".NET testing frameworks available via NuGet packages"
    fi
    
    # Performance Testing
    npm install -g k6
    pip3 install pytest-benchmark
    
    # API Testing
    npm install -g supertest
    pip3 install requests
    pip3 install httpx
}

# Project Management and Productivity Tools
install_project_management_productivity() {
    echo_info "Installing project management and productivity tools..."
    
    # Time tracking
    npm install -g zeit-pkg
    pip3 install timewarrior
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y timewarrior
    fi
    
    # Task management
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y task tasksh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm task tasksh
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y task tasksh
    fi
    
    # Note taking
    npm install -g notable-cli
    npm install -g joplin
    pip3 install notable
    
    # Calendar and scheduling
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y calcurse
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm calcurse
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y calcurse
    fi
    
    # Mind mapping
    if command -v snap &> /dev/null; then
        sudo snap install freeplane
        sudo snap install xmind
    fi
    
    # PDF tools
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y poppler-utils qpdf pdftk
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm poppler qpdf pdftk
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y poppler-utils qpdf pdftk
    fi
    
    # Presentation tools
    npm install -g reveal-md
    npm install -g @marp-team/marp-cli
    pip3 install hovercraft
    
    # Email tools
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y mutt neomutt thunderbird
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm mutt neomutt thunderbird
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y mutt neomutt thunderbird
    fi
    
    # RSS readers
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y newsboat
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm newsboat
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y newsboat
    fi
}

# Specialized Scientific Tools
install_specialized_scientific_tools() {
    echo_info "Installing specialized scientific tools..."
    
    # Bioinformatics
    pip3 install biopython
    pip3 install pysam
    pip3 install htseq
    pip3 install cutadapt
    pip3 install multiqc
    
    # Chemistry
    pip3 install rdkit-pypi
    pip3 install chempy
    pip3 install ase
    
    # Physics
    pip3 install astropy
    pip3 install sunpy
    pip3 install qutip
    pip3 install pyephem
    
    # Mathematics
    pip3 install sage
    pip3 install gap
    pip3 install pari
    
    # Statistics
    pip3 install statsmodels
    pip3 install lifelines
    pip3 install pymc3
    pip3 install arviz
    
    # Geographic Information Systems
    pip3 install geopandas
    pip3 install folium
    pip3 install cartopy
    pip3 install rasterio
    pip3 install shapely
    pip3 install fiona
    
    # Image processing
    pip3 install opencv-python
    pip3 install pillow
    pip3 install scikit-image
    pip3 install imageio
    
    # Signal processing
    pip3 install scipy
    pip3 install librosa
    pip3 install pydub
    
    # Finance
    pip3 install yfinance
    pip3 install quantlib
    pip3 install zipline
    pip3 install backtrader
    
    # Weather data
    pip3 install metpy
    pip3 install siphon
    
    # QGIS (Geographic Information System)
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y qgis
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm qgis
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y qgis
    fi
    
    # ParaView (scientific visualization)
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y paraview
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm paraview
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y paraview
    fi
    
    # ROOT (CERN data analysis framework)
    if command -v snap &> /dev/null; then
        sudo snap install root-framework
    fi
    
    # Geant4 (particle physics simulation)
    echo_info "Note: Geant4 requires manual installation from CERN"
    
    # Molecular visualization
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y pymol
    fi
}

# Additional Massive Tool Categories

# Network Utilities and Analysis Mega Pack
install_network_utilities_mega() {
    echo_info "Installing comprehensive network utilities..."
    
    # Network scanning tools
    if ! command -v masscan &> /dev/null; then
        echo_info "Installing masscan..."
        git clone https://github.com/robertdavidgraham/masscan
        cd masscan && make && sudo make install
        cd .. && rm -rf masscan
    fi
    
    # Network discovery
    if ! command -v zmap &> /dev/null; then
        echo_info "Installing zmap..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y zmap
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zmap
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zmap
        fi
    fi
    
    # Network enumeration
    if ! command -v enum4linux &> /dev/null; then
        echo_info "Installing enum4linux..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y enum4linux
        fi
    fi
    
    # SMB enumeration
    if ! command -v smbclient &> /dev/null; then
        echo_info "Installing smbclient..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y smbclient
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm smbclient
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y samba-client
        fi
    fi
    
    # DNS tools
    if ! command -v dnsrecon &> /dev/null; then
        echo_info "Installing dnsrecon..."
        pip3 install dnsrecon
    fi
    
    if ! command -v dnsenum &> /dev/null; then
        echo_info "Installing dnsenum..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y dnsenum
        fi
    fi
    
    # Subdomain enumeration
    if ! command -v sublist3r &> /dev/null; then
        echo_info "Installing Sublist3r..."
        pip3 install sublist3r
    fi
    
    # Network stress testing
    if ! command -v hping3 &> /dev/null; then
        echo_info "Installing hping3..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y hping3
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm hping
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y hping3
        fi
    fi
    
    # Packet crafting
    if ! command -v scapy &> /dev/null; then
        echo_info "Installing Scapy..."
        pip3 install scapy
    fi
    
    # Network protocols
    if ! command -v socat &> /dev/null; then
        echo_info "Installing socat..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y socat
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm socat
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y socat
        fi
    fi
    
    # Network monitoring
    if ! command -v bmon &> /dev/null; then
        echo_info "Installing bmon..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y bmon
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm bmon
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y bmon
        fi
    fi
    
    if ! command -v vnstat &> /dev/null; then
        echo_info "Installing vnstat..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y vnstat
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm vnstat
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y vnstat
        fi
    fi
    
    # Bandwidth testing
    if ! command -v speedtest &> /dev/null; then
        echo_info "Installing speedtest-cli..."
        pip3 install speedtest-cli
    fi
    
    # Network analysis
    if ! command -v darkstat &> /dev/null; then
        echo_info "Installing darkstat..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y darkstat
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm darkstat
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y darkstat
        fi
    fi
    
    # WiFi tools
    if ! command -v wavemon &> /dev/null; then
        echo_info "Installing wavemon..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wavemon
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wavemon
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wavemon
        fi
    fi
    
    # Network security
    if ! command -v ettercap &> /dev/null; then
        echo_info "Installing ettercap..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ettercap-text-only
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ettercap
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ettercap
        fi
    fi
    
    # Web application testing
    if ! command -v dirb &> /dev/null; then
        echo_info "Installing dirb..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y dirb
        fi
    fi
    
    if ! command -v gobuster &> /dev/null; then
        echo_info "Installing gobuster..."
        if command -v go &> /dev/null; then
            go install github.com/OJ/gobuster/v3@latest
        fi
    fi
    
    # SSL/TLS testing
    if ! command -v sslscan &> /dev/null; then
        echo_info "Installing sslscan..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sslscan
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sslscan
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sslscan
        fi
    fi
    
    if ! command -v testssl &> /dev/null; then
        echo_info "Installing testssl.sh..."
        git clone https://github.com/drwetter/testssl.sh.git
        sudo mv testssl.sh /opt/
        sudo ln -s /opt/testssl.sh/testssl.sh /usr/local/bin/testssl
    fi
}

# System Utilities Mega Pack
install_system_utilities_mega() {
    echo_info "Installing comprehensive system utilities..."
    
    # Process management
    if ! command -v pgrep &> /dev/null; then
        echo_info "Installing procps..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y procps
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm procps-ng
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y procps-ng
        fi
    fi
    
    # System information
    if ! command -v neofetch &> /dev/null; then
        echo_info "Installing neofetch..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y neofetch
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm neofetch
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y neofetch
        fi
    fi
    
    if ! command -v screenfetch &> /dev/null; then
        echo_info "Installing screenfetch..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y screenfetch
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm screenfetch
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y screenfetch
        fi
    fi
    
    # Hardware information
    if ! command -v lshw &> /dev/null; then
        echo_info "Installing lshw..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y lshw
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lshw
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lshw
        fi
    fi
    
    if ! command -v hwinfo &> /dev/null; then
        echo_info "Installing hwinfo..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y hwinfo
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm hwinfo
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y hwinfo
        fi
    fi
    
    # CPU information
    if ! command -v cpuinfo &> /dev/null; then
        echo_info "Installing cpuinfo..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y cpuid
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm cpuid
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y cpuid
        fi
    fi
    
    # Memory information
    if ! command -v dmidecode &> /dev/null; then
        echo_info "Installing dmidecode..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y dmidecode
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm dmidecode
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y dmidecode
        fi
    fi
    
    # Disk utilities
    if ! command -v smartctl &> /dev/null; then
        echo_info "Installing smartmontools..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y smartmontools
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm smartmontools
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y smartmontools
        fi
    fi
    
    if ! command -v hdparm &> /dev/null; then
        echo_info "Installing hdparm..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y hdparm
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm hdparm
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y hdparm
        fi
    fi
    
    # Benchmarking
    if ! command -v dd &> /dev/null; then
        echo_info "Installing coreutils (dd included)..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y coreutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm coreutils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y coreutils
        fi
    fi
    
    # Power management
    if ! command -v powertop &> /dev/null; then
        echo_info "Installing powertop..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y powertop
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm powertop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y powertop
        fi
    fi
    
    # USB utilities
    if ! command -v lsusb &> /dev/null; then
        echo_info "Installing usbutils..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y usbutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm usbutils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y usbutils
        fi
    fi
    
    # PCI utilities
    if ! command -v lspci &> /dev/null; then
        echo_info "Installing pciutils..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y pciutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm pciutils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pciutils
        fi
    fi
    
    # File systems
    if ! command -v ncdu &> /dev/null; then
        echo_info "Installing ncdu..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ncdu
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ncdu
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ncdu
        fi
    fi
    
    # File recovery
    if ! command -v testdisk &> /dev/null; then
        echo_info "Installing testdisk..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y testdisk
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm testdisk
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y testdisk
        fi
    fi
    
    if ! command -v photorec &> /dev/null; then
        echo_info "PhotoRec is included with testdisk"
    fi
    
    # Disk partitioning
    if ! command -v gparted &> /dev/null; then
        echo_info "Installing gparted..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gparted
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gparted
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gparted
        fi
    fi
    
    # System monitoring
    if ! command -v glances &> /dev/null; then
        echo_info "Installing glances..."
        pip3 install glances
    fi
    
    if ! command -v atop &> /dev/null; then
        echo_info "Installing atop..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y atop
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm atop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y atop
        fi
    fi
    
    # Log analysis
    if ! command -v multitail &> /dev/null; then
        echo_info "Installing multitail..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y multitail
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm multitail
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y multitail
        fi
    fi
    
    # System cleanup
    if ! command -v bleachbit &> /dev/null; then
        echo_info "Installing bleachbit..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y bleachbit
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm bleachbit
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y bleachbit
        fi
    fi
}

# Communication Tools Mega Pack
install_communication_tools_mega() {
    echo_info "Installing comprehensive communication tools..."
    
    # IRC clients
    if ! command -v irssi &> /dev/null; then
        echo_info "Installing irssi..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y irssi
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm irssi
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y irssi
        fi
    fi
    
    if ! command -v weechat &> /dev/null; then
        echo_info "Installing weechat..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y weechat
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm weechat
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y weechat
        fi
    fi
    
    # Matrix clients
    if ! command -v element-desktop &> /dev/null; then
        echo_info "Installing Element..."
        if command -v snap &> /dev/null; then
            sudo snap install element-desktop
        fi
    fi
    
    # Signal
    if command -v snap &> /dev/null; then
        sudo snap install signal-desktop
    fi
    
    # Telegram
    if command -v snap &> /dev/null; then
        sudo snap install telegram-desktop
    fi
    
    # WhatsApp
    if command -v snap &> /dev/null; then
        sudo snap install whatsapp-for-linux
    fi
    
    # Discord
    if command -v snap &> /dev/null; then
        sudo snap install discord
    fi
    
    # Skype
    if command -v snap &> /dev/null; then
        sudo snap install skype
    fi
    
    # Zoom
    if command -v snap &> /dev/null; then
        sudo snap install zoom-client
    fi
    
    # Slack
    if command -v snap &> /dev/null; then
        sudo snap install slack
    fi
    
    # Microsoft Teams
    if command -v snap &> /dev/null; then
        sudo snap install teams-for-linux
    fi
    
    # Email clients (additional)
    if ! command -v evolution &> /dev/null; then
        echo_info "Installing Evolution..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y evolution
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm evolution
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y evolution
        fi
    fi
    
    # VoIP
    if command -v snap &> /dev/null; then
        sudo snap install jami
    fi
    
    # Terminal-based communication
    if ! command -v talk &> /dev/null; then
        echo_info "Installing talk..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y talk
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm netkit-ntalk
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y talk
        fi
    fi
    
    # File sharing
    if ! command -v magic-wormhole &> /dev/null; then
        echo_info "Installing magic-wormhole..."
        pip3 install magic-wormhole
    fi
    
    # Video conferencing
    if command -v snap &> /dev/null; then
        sudo snap install jitsi-meet-desktop
    fi
}

# Media Tools Mega Pack
install_media_tools_mega() {
    echo_info "Installing comprehensive media tools..."
    
    # Audio players
    if ! command -v mpg123 &> /dev/null; then
        echo_info "Installing mpg123..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mpg123
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mpg123
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mpg123
        fi
    fi
    
    if ! command -v sox &> /dev/null; then
        echo_info "Installing sox..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sox
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sox
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sox
        fi
    fi
    
    if ! command -v mplayer &> /dev/null; then
        echo_info "Installing mplayer..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mplayer
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mplayer
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mplayer
        fi
    fi
    
    if ! command -v mpv &> /dev/null; then
        echo_info "Installing mpv..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mpv
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mpv
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mpv
        fi
    fi
    
    if ! command -v vlc &> /dev/null; then
        echo_info "Installing VLC..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y vlc
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm vlc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y vlc
        fi
    fi
    
    # Audio editing
    if ! command -v lame &> /dev/null; then
        echo_info "Installing lame..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y lame
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lame
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lame
        fi
    fi
    
    if ! command -v flac &> /dev/null; then
        echo_info "Installing flac..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y flac
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm flac
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y flac
        fi
    fi
    
    # Image viewers
    if ! command -v feh &> /dev/null; then
        echo_info "Installing feh..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y feh
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm feh
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y feh
        fi
    fi
    
    if ! command -v sxiv &> /dev/null; then
        echo_info "Installing sxiv..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sxiv
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sxiv
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sxiv
        fi
    fi
    
    # PDF viewers
    if ! command -v evince &> /dev/null; then
        echo_info "Installing evince..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y evince
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm evince
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y evince
        fi
    fi
    
    if ! command -v zathura &> /dev/null; then
        echo_info "Installing zathura..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y zathura
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zathura zathura-pdf-mupdf
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zathura zathura-pdf-mupdf
        fi
    fi
    
    # Video editing (additional)
    if ! command -v pitivi &> /dev/null; then
        echo_info "Installing pitivi..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y pitivi
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm pitivi
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pitivi
        fi
    fi
    
    # Screen recording
    if ! command -v recordmydesktop &> /dev/null; then
        echo_info "Installing recordmydesktop..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y recordmydesktop
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm recordmydesktop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y recordmydesktop
        fi
    fi
    
    if ! command -v simplescreenrecorder &> /dev/null; then
        echo_info "Installing simplescreenrecorder..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y simplescreenrecorder
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm simplescreenrecorder
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y simplescreenrecorder
        fi
    fi
    
    # Streaming
    if ! command -v streamlink &> /dev/null; then
        echo_info "Installing streamlink..."
        pip3 install streamlink
    fi
    
    # Image manipulation
    if ! command -v optipng &> /dev/null; then
        echo_info "Installing optipng..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y optipng
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm optipng
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y optipng
        fi
    fi
    
    if ! command -v jpegoptim &> /dev/null; then
        echo_info "Installing jpegoptim..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y jpegoptim
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm jpegoptim
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y jpegoptim
        fi
    fi
    
    # 3D graphics
    if command -v snap &> /dev/null; then
        sudo snap install freecad
        sudo snap install openscad
    fi
}

# Additional Developer Tools Collection
install_additional_developer_tools_collection() {
    echo_info "Installing additional developer tools collection..."
    
    # API documentation generators
    npm install -g @apidevtools/swagger-cli
    npm install -g redoc-cli
    npm install -g api-spec-converter
    
    # Static site generators
    npm install -g gatsby-cli
    npm install -g next
    npm install -g nuxt
    npm install -g eleventy
    npm install -g hexo-cli
    npm install -g hugo-cli
    npm install -g jekyll
    npm install -g gridsome
    
    # Component libraries
    npm install -g @storybook/cli
    npm install -g bit-bin
    
    # Micro-frontends
    npm install -g single-spa
    npm install -g @module-federation/cli
    
    # Database migration tools
    npm install -g db-migrate
    npm install -g knex
    npm install -g sequelize-cli
    npm install -g typeorm
    npm install -g prisma
    
    # ORM and ODM tools
    pip3 install sqlalchemy
    pip3 install peewee
    pip3 install mongoengine
    pip3 install pymongo
    
    # Template engines
    npm install -g handlebars
    npm install -g mustache
    npm install -g ejs
    npm install -g pug-cli
    
    # Build automation
    npm install -g grunt-cli
    npm install -g gulp-cli
    npm install -g brunch
    npm install -g webpack-cli
    npm install -g @angular/cli
    npm install -g @vue/cli
    
    # CSS preprocessors
    npm install -g node-sass
    npm install -g less
    npm install -g stylus
    
    # PostCSS tools
    npm install -g postcss-cli
    npm install -g autoprefixer
    npm install -g cssnano-cli
    
    # Image optimization
    npm install -g imagemin-cli
    npm install -g svgo
    
    # Font tools
    npm install -g webfont
    npm install -g fontmin
    
    # Minification
    npm install -g uglify-js
    npm install -g terser
    npm install -g html-minifier
    npm install -g clean-css-cli
    
    # Bundle analyzers
    npm install -g webpack-bundle-analyzer
    npm install -g bundlesize
    
    # PWA tools
    npm install -g @pwa/cli
    npm install -g workbox-cli
    
    # Performance testing
    npm install -g autocannon
    npm install -g clinic
    npm install -g 0x
    
    # Accessibility testing
    npm install -g lighthouse-ci
    npm install -g axe-cli
    
    # Code complexity analysis
    npm install -g plato
    npm install -g jscpd
    npm install -g jsinspect
    
    # Documentation tools
    npm install -g jsdoc
    npm install -g typedoc
    npm install -g documentation
    npm install -g esdoc
    
    # Package management
    npm install -g lerna
    npm install -g nx
    npm install -g changesets
    
    # Development servers
    npm install -g http-server
    npm install -g live-server
    npm install -g browser-sync
    npm install -g nodemon
    npm install -g pm2
    npm install -g forever
    
    # Database tools
    npm install -g mongodb-runner
    npm install -g redis-commander
    
    # File watchers
    npm install -g chokidar-cli
    npm install -g onchange
    
    # Environment management
    npm install -g dotenv-cli
    npm install -g cross-env
    
    # Process managers
    npm install -g concurrently
    npm install -g npm-run-all
    
    # Git tools
    npm install -g conventional-changelog-cli
    npm install -g semantic-release
    npm install -g standard-version
    npm install -g commitizen
    npm install -g husky
    npm install -g lint-staged
    
    # Schema validation
    npm install -g ajv-cli
    npm install -g joi
    
    # Mock servers
    npm install -g json-server
    npm install -g nock
    
    # Code generators
    npm install -g yeoman-generator
    npm install -g plop
    npm install -g hygen
    
    # License checking
    npm install -g license-checker
    npm install -g licensee
    
    # Security scanning
    npm install -g audit-ci
    npm install -g snyk
    npm install -g retire
    
    # Dependency management
    npm install -g npm-check-updates
    npm install -g david
    npm install -g depcheck
    npm install -g dependency-cruiser
    
    # Benchmarking
    npm install -g benchmark
    pip3 install asv
    
    # Code migration
    npm install -g jscodeshift
    npm install -g upgrade
    
    # Protocol buffer tools
    if command -v go &> /dev/null; then
        go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
        go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    fi
    
    # gRPC tools
    npm install -g grpc-tools
    npm install -g @grpc/grpc-js
    pip3 install grpcio grpcio-tools
    
    # Message queue tools
    pip3 install celery
    npm install -g bull-board
    
    # Event streaming
    npm install -g kafkajs
    pip3 install kafka-python
    
    # Monitoring and alerting
    npm install -g prom-client
    pip3 install prometheus-client
    
    # Distributed tracing
    npm install -g jaeger-client
    pip3 install opentelemetry-api
    
    # Service discovery
    npm install -g consul
    pip3 install python-consul
    
    # Configuration management
    npm install -g nconf
    pip3 install configparser
    
    # Logging
    npm install -g winston
    npm install -g pino
    pip3 install loguru
    pip3 install structlog
    
    # Caching
    npm install -g node-cache
    pip3 install redis
    pip3 install memcached
    
    # Rate limiting
    npm install -g express-rate-limit
    pip3 install ratelimit
    
    # Authentication
    npm install -g passport
    npm install -g jsonwebtoken
    pip3 install pyjwt
    pip3 install passlib
    
    # Validation
    npm install -g joi
    npm install -g yup
    pip3 install marshmallow
    pip3 install cerberus
    
    # Serialization
    npm install -g msgpack
    pip3 install msgpack
    pip3 install protobuf
    
    # Encryption
    npm install -g crypto-js
    pip3 install cryptography
    pip3 install bcrypt
    
    # Networking
    npm install -g axios
    npm install -g node-fetch
    pip3 install httpx
    pip3 install aiohttp
    
    # WebSocket tools
    npm install -g ws
    npm install -g socket.io
    pip3 install websockets
    pip3 install python-socketio
    
    # Real-time communication
    npm install -g socket.io-client
    pip3 install socketio-client
    
    # File processing
    npm install -g csv-parser
    npm install -g xlsx
    pip3 install openpyxl
    pip3 install csv
    
    # PDF processing
    npm install -g pdf-lib
    npm install -g puppeteer-pdf
    pip3 install pypdf2
    pip3 install reportlab
    
    # Email handling
    npm install -g nodemailer
    pip3 install sendgrid
    pip3 install mailgun
    
    # SMS handling
    npm install -g twilio
    pip3 install twilio
    
    # Push notifications
    npm install -g node-pushnotifications
    pip3 install pyfcm
    
    # Social media APIs
    npm install -g twitter-api-v2
    pip3 install tweepy
    pip3 install facebook-sdk
    
    # Payment processing
    npm install -g stripe
    pip3 install stripe
    
    # Calendar integration
    npm install -g googleapis
    pip3 install google-api-python-client
    
    # Maps and geolocation
    npm install -g @googlemaps/js-api-loader
    pip3 install googlemaps
    pip3 install geopy
    
    # Machine learning serving
    pip3 install flask-restx
    pip3 install fastapi
    pip3 install mlflow
    pip3 install bentoml
    
    # Computer vision
    pip3 install opencv-python
    pip3 install pillow
    pip3 install scikit-image
    
    # Natural language processing
    pip3 install nltk
    pip3 install spacy
    pip3 install textblob
    
    # Data visualization
    pip3 install plotly
    pip3 install bokeh
    pip3 install altair
    
    # Web scraping
    pip3 install beautifulsoup4
    pip3 install scrapy
    pip3 install selenium
    
    # Game development
    pip3 install pygame
    npm install -g phaser
    
    # Blockchain development
    npm install -g web3
    npm install -g ethers
    pip3 install web3
    
    # IoT development
    pip3 install paho-mqtt
    npm install -g mqtt
    
    # Desktop application frameworks
    npm install -g electron
    npm install -g nw
    pip3 install tkinter
    pip3 install pyqt5
    
    # Cross-platform development
    npm install -g capacitor
    npm install -g cordova
    
    # CLI development
    npm install -g commander
    npm install -g inquirer
    pip3 install click
    pip3 install argparse
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
    install_additional_languages
    
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
    install_additional_ides
    
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
    
    echo_info "Installing database tools..."
    install_database_tools
    
    echo_info "Installing security tools..."
    install_security_tools
    
    echo_info "Installing performance tools..."
    install_performance_tools
    
    echo_info "Installing cloud CLI tools..."
    install_cloud_tools
    
    echo_info "Installing terminal enhancements..."
    install_terminal_enhancements
    
    echo_info "Installing API testing tools..."
    install_api_tools
    
    echo_info "Installing build tools..."
    install_build_tools
    
    echo_info "Installing documentation tools..."
    install_documentation_tools
    
    echo_info "Installing file sync and remote tools..."
    install_remote_tools
    
    echo_info "Installing specialized browsers..."
    install_nyxt
    
    echo_info "Installing specialized tools..."
    install_osvm_cli
    install_anza_cli
    install_pwa_tools
    
    echo_info "Installing additional programming languages..."
    install_more_programming_languages
    
    echo_info "Installing additional IDEs and editors..."
    install_more_ides_editors
    
    echo_info "Installing game development tools..."
    install_game_development_tools
    
    echo_info "Installing blockchain and crypto tools..."
    install_blockchain_tools
    
    echo_info "Installing scientific computing tools..."
    install_scientific_computing_tools
    
    echo_info "Installing more container and orchestration tools..."
    install_more_container_tools
    
    echo_info "Installing more cloud and infrastructure tools..."
    install_more_cloud_infrastructure_tools
    
    echo_info "Installing more security and network tools..."
    install_more_security_network_tools
    
    echo_info "Installing more performance and monitoring tools..."
    install_more_performance_monitoring_tools
    
    echo_info "Installing more file and data management tools..."
    install_more_file_data_management_tools
    
    echo_info "Installing more web development tools..."
    install_more_web_development_tools
    
    echo_info "Installing more mobile development tools..."
    install_more_mobile_development_tools
    
    echo_info "Installing more testing and QA tools..."
    install_more_testing_qa_tools
    
    echo_info "Installing more documentation and communication tools..."
    install_more_documentation_communication_tools
    
    echo_info "Installing audio/video editing tools..."
    install_audio_video_editing_tools
    
    echo_info "Installing graphics and design tools..."
    install_graphics_design_tools
    
    echo_info "Installing virtualization tools..."
    install_virtualization_tools
    
    echo_info "Installing backup and archiving tools..."
    install_backup_archiving_tools
    
    echo_info "Installing system administration tools..."
    install_system_administration_tools
    
    echo_info "Installing network analysis tools..."
    install_network_analysis_tools
    
    echo_info "Installing more database tools..."
    install_more_database_tools
    
    echo_info "Installing code analysis and quality tools..."
    install_code_analysis_quality_tools
    
    echo_info "Installing deployment and CI/CD tools..."
    install_deployment_cicd_tools
    
    echo_info "Installing logging and monitoring tools..."
    install_logging_monitoring_tools
    
    echo_info "Installing more terminal and shell tools..."
    install_more_terminal_shell_tools
    
    echo_info "Installing reverse engineering tools..."
    install_reverse_engineering_tools
    
    echo_info "Installing accessibility tools..."
    install_accessibility_tools
    
    echo_info "Installing data analysis tools..."
    install_data_analysis_tools
    
    echo_info "Installing more compression and archiving tools..."
    install_more_compression_tools
    
    echo_info "Installing embedded development tools..."
    install_embedded_development_tools
    
    echo_info "Installing server and infrastructure tools..."
    install_server_infrastructure_tools
    
    echo_info "Installing advanced programming languages and compilers..."
    install_advanced_programming_languages
    
    echo_info "Installing database management systems..."
    install_database_management_systems
    
    echo_info "Installing advanced development frameworks..."
    install_advanced_development_frameworks
    
    echo_info "Installing comprehensive code formatters and linters..."
    install_code_formatters_linters_mega
    
    echo_info "Installing comprehensive testing frameworks..."
    install_testing_frameworks_mega
    
    echo_info "Installing project management and productivity tools..."
    install_project_management_productivity
    
    echo_info "Installing specialized scientific tools..."
    install_specialized_scientific_tools
    
    echo_info "Installing comprehensive network utilities..."
    install_network_utilities_mega
    
    echo_info "Installing comprehensive system utilities..."
    install_system_utilities_mega
    
    echo_info "Installing comprehensive communication tools..."
    install_communication_tools_mega
    
    echo_info "Installing comprehensive media tools..."
    install_media_tools_mega
    
    echo_info "Installing additional developer tools collection..."
    install_additional_developer_tools_collection

    update_path

    echo_info "Development tools installation completed!"
    echo_info "Please run 'just dev-tools-check' to verify installations"
}

# Run main function
main "$@"