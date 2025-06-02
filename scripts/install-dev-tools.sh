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
    
    echo_info "Installing modern web frameworks and build tools..."
    install_modern_web_frameworks
    
    echo_info "Installing modern DevOps and infrastructure tools..."
    install_modern_devops_tools
    
    echo_info "Installing modern database and data tools..."
    install_modern_database_tools
    
    echo_info "Installing modern development environments..."
    install_modern_dev_environments
    
    echo_info "Installing modern AI/ML and data science tools..."
    install_modern_ai_ml_tools
    
    echo_info "Installing modern security and privacy tools..."
    install_modern_security_tools
    
    echo_info "Installing modern observability and monitoring tools..."
    install_modern_observability_tools
    
    echo_info "Installing modern mobile and cross-platform tools..."
    install_modern_mobile_tools
    
    echo_info "Installing modern desktop development tools..."
    install_modern_desktop_tools
    
    echo_info "Installing modern blockchain and Web3 tools..."
    install_modern_blockchain_tools
    
    echo_info "Installing modern API development tools..."
    install_modern_api_tools
    
    echo_info "Installing modern testing and quality assurance tools..."
    install_modern_testing_tools
    
    echo_info "Installing modern documentation tools..."
    install_modern_documentation_tools
    
    echo_info "Installing modern performance tools..."
    install_modern_performance_tools
    
    echo_info "Installing modern terminal and shell tools..."
    install_modern_terminal_tools
    
    echo_info "Installing modern package managers and build systems..."
    install_modern_package_managers
    
    echo_info "Installing modern code editors and IDEs..."
    install_modern_code_editors
    
    echo_info "Installing modern collaboration tools..."
    install_modern_collaboration_tools
    
    echo_info "Installing modern networking tools..."
    install_modern_networking_tools
    
    echo_info "Installing modern automation tools..."
    install_modern_automation_tools
    
    echo_info "Installing modern streaming and content creation tools..."
    install_modern_content_creation_tools
    
    echo_info "Installing modern game development tools..."
    install_modern_game_dev_tools
    
    echo_info "Installing modern embedded and IoT tools..."
    install_modern_embedded_iot_tools
    
    echo_info "Installing modern virtualization and container tools..."
    install_modern_virtualization_tools
    
    echo_info "Installing modern cloud-native tools..."
    install_modern_cloud_native_tools
    
    echo_info "Installing modern GitOps and deployment tools..."
    install_modern_gitops_tools
    
    echo_info "Installing modern distributed systems tools..."
    install_modern_distributed_systems_tools
    
    echo_info "Installing modern low-code/no-code tools..."
    install_modern_lowcode_tools
    
    echo_info "Installing modern accessibility tools..."
    install_modern_accessibility_tools
    
    echo_info "Installing modern design and prototyping tools..."
    install_modern_design_tools
    
    echo_info "Installing modern research and scientific computing tools..."
    install_modern_research_tools
    
    echo_info "Installing modern edge computing tools..."
    install_modern_edge_computing_tools
    
    echo_info "Installing modern quantum computing tools..."
    install_modern_quantum_tools
    
    echo_info "Installing modern augmented/virtual reality tools..."
    install_modern_ar_vr_tools
    
    echo_info "Installing modern microservices and service mesh tools..."
    install_modern_microservices_tools
    
    echo_info "Installing modern serverless tools..."
    install_modern_serverless_tools
    
    echo_info "Installing modern data pipeline tools..."
    install_modern_data_pipeline_tools
    
    echo_info "Installing modern compliance and governance tools..."
    install_modern_compliance_tools
    
    echo_info "Installing modern workflow automation tools..."
    install_modern_workflow_tools
    
    echo_info "Installing modern fintech and payment tools..."
    install_modern_fintech_tools
    
    echo_info "Installing modern e-commerce development tools..."
    install_modern_ecommerce_tools
    
    echo_info "Installing modern real-time communication tools..."
    install_modern_realtime_tools
    
    echo_info "Installing modern progressive web app tools..."
    install_modern_pwa_tools
    
    echo_info "Installing modern headless CMS tools..."
    install_modern_headless_cms_tools
    
    echo_info "Installing modern JAMstack tools..."
    install_modern_jamstack_tools
    
    echo_info "Installing modern micro-frontend tools..."
    install_modern_microfrontend_tools
    
    echo_info "Installing modern GraphQL tools..."
    install_modern_graphql_tools
    
    echo_info "Installing modern WebAssembly tools..."
    install_modern_webassembly_tools
    
    echo_info "Installing modern static site generators..."
    install_modern_static_site_generators
    
    echo_info "Installing modern code generation tools..."
    install_modern_code_generation_tools
    
    echo_info "Installing modern deployment platforms..."
    install_modern_deployment_platforms
    
    echo_info "Installing modern workflow automation tools..."
    install_modern_workflow_tools
    
    echo_info "Installing modern fintech and payment tools..."
    install_modern_fintech_tools
    
    echo_info "Installing modern e-commerce development tools..."
    install_modern_ecommerce_tools
    
    echo_info "Installing modern real-time communication tools..."
    install_modern_realtime_tools
    
    echo_info "Installing modern progressive web app tools..."
    install_modern_pwa_tools
    
    echo_info "Installing modern headless CMS tools..."
    install_modern_headless_cms_tools
    
    echo_info "Installing modern JAMstack tools..."
    install_modern_jamstack_tools
    
    echo_info "Installing modern micro-frontend tools..."
    install_modern_microfrontend_tools
    
    echo_info "Installing modern GraphQL tools..."
    install_modern_graphql_tools
    
    echo_info "Installing modern WebAssembly tools..."
    install_modern_webassembly_tools
    
    echo_info "Installing modern static site generators..."
    install_modern_static_site_generators
    
    echo_info "Installing modern code generation tools..."
    install_modern_code_generation_tools
    
    echo_info "Installing modern deployment platforms..."
    install_modern_deployment_platforms
    
    echo_info "Installing modern developer experience tools..."
    install_modern_developer_experience_tools
    
    echo_info "Installing modern data pipeline tools..."
    install_modern_data_pipeline_tools
    
    echo_info "Installing modern compliance and governance tools..."
    install_modern_compliance_tools
    
    echo_info "Installing any remaining modern tools..."
    install_remaining_modern_tools

    update_path

    echo_info "Development tools installation completed!"
    echo_info "Please run 'just dev-tools-check' to verify installations"
}

# Modern Web Frameworks and Build Tools
install_modern_web_frameworks() {
    echo_info "Installing modern web frameworks and build tools..."
    
    # Vite - Next generation frontend tooling
    if ! command -v vite &> /dev/null; then
        npm install -g vite
    fi
    
    # Tauri - Build smaller, faster, and secure desktop applications
    if ! command -v tauri &> /dev/null; then
        cargo install tauri-cli
    fi
    
    # SvelteKit - The fastest way to build svelte apps
    if ! npm list -g @sveltejs/kit &> /dev/null; then
        npm install -g @sveltejs/kit
    fi
    
    # Qwik - The HTML-first framework
    if ! npm list -g @builder.io/qwik &> /dev/null; then
        npm install -g @builder.io/qwik
    fi
    
    # Solid.js - Simple and performant reactivity
    if ! npm list -g solid-js &> /dev/null; then
        npm install -g solid-js
    fi
    
    # Astro - The web framework for content-driven websites
    if ! npm list -g astro &> /dev/null; then
        npm install -g astro
    fi
    
    # Remix - Full stack web framework
    if ! npm list -g @remix-run/dev &> /dev/null; then
        npm install -g @remix-run/dev
    fi
    
    # Fresh - The next-gen web framework
    if ! command -v fresh &> /dev/null; then
        deno install -A -f --no-check -r -n fresh https://fresh.deno.dev/install
    fi
    
    # Bun - Fast all-in-one JavaScript runtime
    if ! command -v bun &> /dev/null; then
        curl -fsSL https://bun.sh/install | bash
    fi
    
    # esbuild - An extremely fast JavaScript bundler
    if ! command -v esbuild &> /dev/null; then
        npm install -g esbuild
    fi
    
    # swc - Super-fast JavaScript/TypeScript compiler
    if ! npm list -g @swc/cli &> /dev/null; then
        npm install -g @swc/cli
    fi
    
    # Turbo - High-performance build system
    if ! command -v turbo &> /dev/null; then
        npm install -g turbo
    fi
    
    # Nx - Smart, fast and extensible build system
    if ! command -v nx &> /dev/null; then
        npm install -g nx
    fi
    
    # Lerna - Tool for managing JavaScript projects with multiple packages
    if ! command -v lerna &> /dev/null; then
        npm install -g lerna
    fi
    
    # Rush - Scalable monorepo manager
    if ! command -v rush &> /dev/null; then
        npm install -g @microsoft/rush
    fi
    
    # Parcel - Zero configuration build tool
    if ! command -v parcel &> /dev/null; then
        npm install -g parcel
    fi
    
    # Snowpack - Lightning-fast frontend build tool
    if ! command -v snowpack &> /dev/null; then
        npm install -g snowpack
    fi
    
    # Vitest - Blazing fast unit test framework
    if ! npm list -g vitest &> /dev/null; then
        npm install -g vitest
    fi
    
    # Playwright - Modern web testing
    if ! npm list -g @playwright/test &> /dev/null; then
        npm install -g @playwright/test
    fi
    
    # Storybook - Tool for building UI components
    if ! command -v storybook &> /dev/null; then
        npm install -g @storybook/cli
    fi
    
    # Chromatic - Visual testing for Storybook
    if ! npm list -g chromatic &> /dev/null; then
        npm install -g chromatic
    fi
}

# Modern DevOps and Infrastructure Tools
install_modern_devops_tools() {
    echo_info "Installing modern DevOps and infrastructure tools..."
    
    # Pulumi - Modern infrastructure as code
    if ! command -v pulumi &> /dev/null; then
        curl -fsSL https://get.pulumi.com | sh
    fi
    
    # Crossplane - Cloud native control plane framework
    if ! command -v crossplane &> /dev/null; then
        curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
    fi
    
    # ArgoCD - Declarative GitOps CD for Kubernetes
    if ! command -v argocd &> /dev/null; then
        curl -sSL -o /tmp/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
    fi
    
    # Flux - GitOps toolkit for Kubernetes
    if ! command -v flux &> /dev/null; then
        curl -s https://fluxcd.io/install.sh | sudo bash
    fi
    
    # Tekton CLI - Cloud native CI/CD
    if ! command -v tkn &> /dev/null; then
        curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_$(uname -s)_$(uname -m).tar.gz
        tar xvzf tkn_$(uname -s)_$(uname -m).tar.gz -C /tmp
        sudo install /tmp/tkn /usr/local/bin
    fi
    
    # Skaffold - Continuous development for Kubernetes
    if ! command -v skaffold &> /dev/null; then
        curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
        sudo install skaffold /usr/local/bin/
    fi
    
    # Tilt - Dev environment for teams
    if ! command -v tilt &> /dev/null; then
        curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
    fi
    
    # Garden - DevOps automation platform
    if ! command -v garden &> /dev/null; then
        curl -sL https://get.garden.io/install.sh | bash
    fi
    
    # Earthly - Build automation tool
    if ! command -v earthly &> /dev/null; then
        sudo /bin/sh -c 'wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 -O /usr/local/bin/earthly && chmod +x /usr/local/bin/earthly'
    fi
    
    # Dagger - Portable devkit for CI/CD pipelines
    if ! command -v dagger &> /dev/null; then
        curl -L https://dl.dagger.io/dagger/install.sh | sh
        sudo mv bin/dagger /usr/local/bin
    fi
    
    # Buildah - Tool for building OCI container images
    if ! command -v buildah &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y buildah
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm buildah
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y buildah
        fi
    fi
    
    # Podman - Daemonless container engine
    if ! command -v podman &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y podman
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm podman
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y podman
        fi
    fi
    
    # Kaniko - Build container images in Kubernetes
    if ! command -v kaniko &> /dev/null; then
        curl -L https://github.com/GoogleContainerTools/kaniko/releases/latest/download/executor-amd64 -o /tmp/kaniko
        sudo install /tmp/kaniko /usr/local/bin/kaniko
    fi
    
    # Trivy - Vulnerability scanner for containers
    if ! command -v trivy &> /dev/null; then
        sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" > /etc/apt/sources.list.d/trivy.list'
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
        sudo apt-get update
        sudo apt-get install trivy
    fi
    
    # Grype - Vulnerability scanner for container images
    if ! command -v grype &> /dev/null; then
        curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
    fi
    
    # Syft - SBOM generator
    if ! command -v syft &> /dev/null; then
        curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
    fi
    
    # Cosign - Container signing and verification
    if ! command -v cosign &> /dev/null; then
        curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
        sudo mv cosign-linux-amd64 /usr/local/bin/cosign
        sudo chmod +x /usr/local/bin/cosign
    fi
    
    # Dive - Tool for exploring docker images
    if ! command -v dive &> /dev/null; then
        wget https://github.com/wagoodman/dive/releases/latest/download/dive_$(uname -s)_$(uname -m).tar.gz
        tar -xf dive_$(uname -s)_$(uname -m).tar.gz
        sudo mv dive /usr/local/bin/
    fi
    
    # Lazydocker - Terminal UI for Docker
    if ! command -v lazydocker &> /dev/null; then
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    fi
}

# Modern Database and Data Tools
install_modern_database_tools() {
    echo_info "Installing modern database and data tools..."
    
    # SurrealDB - Modern multi-model database
    if ! command -v surreal &> /dev/null; then
        curl -sSf https://install.surrealdb.com | sh
    fi
    
    # EdgeDB - Next-generation object-relational database
    if ! command -v edgedb &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.edgedb.com | sh
    fi
    
    # FaunaDB CLI - Serverless database
    if ! command -v fauna &> /dev/null; then
        npm install -g fauna-shell
    fi
    
    # Neon CLI - Serverless Postgres
    if ! command -v neonctl &> /dev/null; then
        npm install -g neonctl
    fi
    
    # PlanetScale CLI - Database branching
    if ! command -v pscale &> /dev/null; then
        curl -fsSL https://github.com/planetscale/cli/releases/latest/download/pscale_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/').tar.gz | tar -xz pscale
        sudo mv pscale /usr/local/bin/
    fi
    
    # Supabase CLI - Open source Firebase alternative
    if ! command -v supabase &> /dev/null; then
        npm install -g supabase
    fi
    
    # Prisma - Next-generation ORM
    if ! npm list -g prisma &> /dev/null; then
        npm install -g prisma
    fi
    
    # Drizzle ORM - TypeScript ORM
    if ! npm list -g drizzle-orm &> /dev/null; then
        npm install -g drizzle-orm
    fi
    
    # Atlas - Database schema management
    if ! command -v atlas &> /dev/null; then
        curl -sSf https://atlasgo.sh | sh
    fi
    
    # Bytebase - Database CI/CD and DevOps
    if ! command -v bytebase &> /dev/null; then
        curl -fsSL https://raw.githubusercontent.com/bytebase/bytebase/main/scripts/install.sh | bash
    fi
    
    # Vitess CLI - Database clustering system
    if ! command -v vtctlclient &> /dev/null; then
        wget https://github.com/vitessio/vitess/releases/latest/download/vitess-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz
        tar -xzf vitess-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz
        sudo mv vitess-*/bin/* /usr/local/bin/
    fi
    
    # CockroachDB CLI - Distributed SQL database
    if ! command -v cockroach &> /dev/null; then
        curl https://binaries.cockroachdb.com/cockroach-latest.linux-amd64.tgz | tar -xz
        sudo cp -i cockroach-*/cockroach /usr/local/bin/
    fi
    
    # TiDB CLI - Distributed SQL database
    if ! command -v tiup &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
    fi
    
    # ClickHouse CLI - Column-oriented database
    if ! command -v clickhouse &> /dev/null; then
        curl https://clickhouse.com/ | sh
    fi
    
    # QuestDB CLI - Time series database
    if ! command -v questdb &> /dev/null; then
        curl -L https://github.com/questdb/questdb/releases/latest/download/questdb-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz | tar xz
        sudo mv questdb*/bin/questdb.sh /usr/local/bin/questdb
    fi
    
    # TimescaleDB CLI - Time-series database
    if ! command -v timescaledb-tune &> /dev/null; then
        go install github.com/timescale/timescaledb-tune/cmd/timescaledb-tune@latest
    fi
    
    # InfluxDB CLI - Time series database
    if ! command -v influx &> /dev/null; then
        wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-$(curl -s https://api.github.com/repos/influxdata/influx-cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz
        tar xf influxdb2-client-*-linux-amd64.tar.gz
        sudo cp influx /usr/local/bin/
    fi
    
    # Apache Spark CLI - Unified analytics engine
    if ! command -v spark-submit &> /dev/null; then
        wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
        tar -xzf spark-3.5.0-bin-hadoop3.tgz
        sudo mv spark-3.5.0-bin-hadoop3 /opt/spark
        sudo ln -s /opt/spark/bin/* /usr/local/bin/
    fi
    
    # Apache Kafka CLI - Distributed streaming platform
    if ! command -v kafka-console-producer.sh &> /dev/null; then
        wget https://downloads.apache.org/kafka/2.13-3.6.0/kafka_2.13-3.6.0.tgz
        tar -xzf kafka_2.13-3.6.0.tgz
        sudo mv kafka_2.13-3.6.0 /opt/kafka
        sudo ln -s /opt/kafka/bin/* /usr/local/bin/
    fi
    
    # Redpanda CLI - Kafka-compatible streaming platform
    if ! command -v rpk &> /dev/null; then
        curl -LO https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip
        unzip rpk-linux-amd64.zip
        sudo install rpk /usr/local/bin/
    fi
}

# Modern Development Environments
install_modern_dev_environments() {
    echo_info "Installing modern development environments..."
    
    # DevPod - Codespaces alternative
    if ! command -v devpod &> /dev/null; then
        curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64"
        sudo install -c -m 0755 devpod /usr/local/bin
    fi
    
    # Gitpod CLI - Cloud development environments
    if ! command -v gp &> /dev/null; then
        curl -fsSL https://github.com/gitpod-io/gitpod/raw/main/scripts/install-gitpod-cli.sh | sh
    fi
    
    # Codespaces CLI
    if ! command -v gh &> /dev/null; then
        gh extension install github/gh-codespaces
    fi
    
    # Daytona - Development environment manager
    if ! command -v daytona &> /dev/null; then
        curl -sf https://download.daytona.io/daytona/install.sh | sudo bash
    fi
    
    # Devbox - Instant, easy, predictable shells
    if ! command -v devbox &> /dev/null; then
        curl -fsSL https://get.jetpack.io/devbox | bash
    fi
    
    # Nix-shell - Reproducible development environments
    if ! command -v nix-shell &> /dev/null && command -v nix &> /dev/null; then
        echo "nix-shell available via nix"
    fi
    
    # Flox - Virtual environments for development
    if ! command -v flox &> /dev/null; then
        curl -L https://install.flox.dev | sh
    fi
    
    # Vagrant - Development environment automation
    if ! command -v vagrant &> /dev/null; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install vagrant
    fi
    
    # Lima - Linux VMs on macOS (for Docker alternatives)
    if ! command -v lima &> /dev/null; then
        curl -fsSL https://get.lima-vm.io | sh
    fi
    
    # Multipass - Lightweight Ubuntu VMs
    if ! command -v multipass &> /dev/null; then
        sudo snap install multipass
    fi
    
    # Colima - Container runtimes on macOS
    if ! command -v colima &> /dev/null; then
        curl -LO https://github.com/abiosoft/colima/releases/latest/download/colima-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
        sudo install colima-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m) /usr/local/bin/colima
    fi
    
    # Orbstack - Fast, light, simple Docker Desktop alternative
    if ! command -v orb &> /dev/null; then
        curl -fsSL https://get.orbstack.dev | bash
    fi
}

# Modern AI/ML and Data Science Tools
install_modern_ai_ml_tools() {
    echo_info "Installing modern AI/ML and data science tools..."
    
    # LangChain CLI - Building applications with LLMs
    if ! command -v langchain &> /dev/null; then
        pip install langchain-cli
    fi
    
    # Chroma - AI-native open-source embedding database
    if ! pip show chromadb &> /dev/null; then
        pip install chromadb
    fi
    
    # Weaviate CLI - Vector database
    if ! command -v weaviate &> /dev/null; then
        curl -L https://github.com/weaviate/weaviate-cli/releases/latest/download/weaviate-cli-linux-amd64.tar.gz | tar xz
        sudo mv weaviate-cli /usr/local/bin/weaviate
    fi
    
    # Pinecone CLI - Vector database
    if ! pip show pinecone-client &> /dev/null; then
        pip install pinecone-client
    fi
    
    # Hugging Face CLI - AI model hub
    if ! pip show huggingface-hub &> /dev/null; then
        pip install huggingface-hub
    fi
    
    # Weights & Biases CLI - ML experiment tracking
    if ! pip show wandb &> /dev/null; then
        pip install wandb
    fi
    
    # MLflow - ML lifecycle management
    if ! pip show mlflow &> /dev/null; then
        pip install mlflow
    fi
    
    # DVC - Data version control
    if ! pip show dvc &> /dev/null; then
        pip install dvc
    fi
    
    # ClearML - MLOps platform
    if ! pip show clearml &> /dev/null; then
        pip install clearml
    fi
    
    # Kedro - Data science pipeline framework
    if ! pip show kedro &> /dev/null; then
        pip install kedro
    fi
    
    # Great Expectations - Data validation
    if ! pip show great-expectations &> /dev/null; then
        pip install great-expectations
    fi
    
    # Evidently - ML model monitoring
    if ! pip show evidently &> /dev/null; then
        pip install evidently
    fi
    
    # Feast - Feature store
    if ! pip show feast &> /dev/null; then
        pip install feast
    fi
    
    # Metaflow - ML infrastructure stack
    if ! pip show metaflow &> /dev/null; then
        pip install metaflow
    fi
    
    # Prefect - Modern workflow orchestration
    if ! pip show prefect &> /dev/null; then
        pip install prefect
    fi
    
    # Dagster - Data orchestrator
    if ! pip show dagster &> /dev/null; then
        pip install dagster
    fi
    
    # Apache Airflow - Workflow automation
    if ! pip show apache-airflow &> /dev/null; then
        pip install apache-airflow
    fi
    
    # Kubeflow CLI - ML workflows on Kubernetes
    if ! command -v kfp &> /dev/null; then
        pip install kfp
    fi
    
    # BentoML - ML model serving
    if ! pip show bentoml &> /dev/null; then
        pip install bentoml
    fi
    
    # Seldon Core CLI - ML deployment
    if ! command -v seldon &> /dev/null; then
        curl -L https://github.com/SeldonIO/seldon-core/releases/latest/download/seldon-linux-amd64 -o seldon
        sudo install seldon /usr/local/bin/
    fi
    
    # Ray CLI - Distributed computing
    if ! pip show ray &> /dev/null; then
        pip install ray
    fi
    
    # Dask - Parallel computing
    if ! pip show dask &> /dev/null; then
        pip install dask
    fi
    
    # Modin - Fast pandas
    if ! pip show modin &> /dev/null; then
        pip install modin
    fi
    
    # Polars - Fast DataFrame library
    if ! pip show polars &> /dev/null; then
        pip install polars
    fi
    
    # DuckDB CLI - In-process SQL OLAP database
    if ! command -v duckdb &> /dev/null; then
        curl -L https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip -o duckdb.zip
        unzip duckdb.zip
        sudo install duckdb /usr/local/bin/
    fi
}

# Modern Security and Privacy Tools
install_modern_security_tools() {
    echo_info "Installing modern security and privacy tools..."
    
    # Age - Modern encryption tool
    if ! command -v age &> /dev/null; then
        curl -L https://github.com/FiloSottile/age/releases/latest/download/age-$(curl -s https://api.github.com/repos/FiloSottile/age/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv age/age* /usr/local/bin/
    fi
    
    # SOPS - Secrets management
    if ! command -v sops &> /dev/null; then
        curl -L https://github.com/mozilla/sops/releases/latest/download/sops-$(curl -s https://api.github.com/repos/mozilla/sops/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux.amd64 -o sops
        sudo install sops /usr/local/bin/
    fi
    
    # Sealed Secrets - Kubernetes secrets encryption
    if ! command -v kubeseal &> /dev/null; then
        curl -L https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/').tar.gz | tar xz
        sudo install kubeseal /usr/local/bin/
    fi
    
    # External Secrets Operator CLI
    if ! command -v external-secrets &> /dev/null; then
        curl -L https://github.com/external-secrets/external-secrets/releases/latest/download/external-secrets-linux-amd64.tar.gz | tar xz
        sudo install external-secrets /usr/local/bin/
    fi
    
    # Falco - Runtime security monitoring
    if ! command -v falco &> /dev/null; then
        curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
        sudo apt-get update -y
        sudo apt-get install -y falco
    fi
    
    # Open Policy Agent - Policy as code
    if ! command -v opa &> /dev/null; then
        curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static
        sudo install opa /usr/local/bin/
    fi
    
    # Gatekeeper CLI - Kubernetes admission controller
    if ! command -v gator &> /dev/null; then
        curl -L https://github.com/open-policy-agent/gatekeeper/releases/latest/download/gator-$(curl -s https://api.github.com/repos/open-policy-agent/gatekeeper/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo install gator /usr/local/bin/
    fi
    
    # Kustomize - Kubernetes configuration management
    if ! command -v kustomize &> /dev/null; then
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        sudo mv kustomize /usr/local/bin/
    fi
    
    # Helm Secrets - Secrets management for Helm
    if command -v helm &> /dev/null; then
        helm plugin install https://github.com/jkroepke/helm-secrets
    fi
    
    # Vault CLI - Secrets management
    if ! command -v vault &> /dev/null; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install vault
    fi
    
    # 1Password CLI - Password manager
    if ! command -v op &> /dev/null; then
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
        sudo apt update && sudo apt install 1password-cli
    fi
    
    # Bitwarden CLI - Password manager
    if ! command -v bw &> /dev/null; then
        npm install -g @bitwarden/cli
    fi
    
    # Pass - Password store
    if ! command -v pass &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y pass
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm pass
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pass
        fi
    fi
    
    # GPG Suite tools
    if ! command -v gpg &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gnupg
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gnupg
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gnupg
        fi
    fi
    
    # Minisign - Digital signatures
    if ! command -v minisign &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y minisign
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm minisign
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y minisign
        fi
    fi
    
    # Signify - OpenBSD signing tool
    if ! command -v signify &> /dev/null; then
        git clone https://github.com/aperezdc/signify.git /tmp/signify
        cd /tmp/signify && make && sudo make install
    fi
}

# Modern Observability and Monitoring Tools
install_modern_observability_tools() {
    echo_info "Installing modern observability and monitoring tools..."
    
    # OpenTelemetry CLI - Observability framework
    if ! command -v otel &> /dev/null; then
        curl -L https://github.com/open-telemetry/opentelemetry-collector-releases/releases/latest/download/otelcol_linux_amd64.tar.gz | tar xz
        sudo mv otelcol /usr/local/bin/otel
    fi
    
    # Jaeger CLI - Distributed tracing
    if ! command -v jaeger &> /dev/null; then
        curl -L https://github.com/jaegertracing/jaeger/releases/latest/download/jaeger-$(curl -s https://api.github.com/repos/jaegertracing/jaeger/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv jaeger-*/jaeger-* /usr/local/bin/
    fi
    
    # Vector - Log and event data pipeline
    if ! command -v vector &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.vector.dev | bash -s -- -y
    fi
    
    # Loki CLI - Log aggregation system
    if ! command -v logcli &> /dev/null; then
        curl -L https://github.com/grafana/loki/releases/latest/download/logcli-linux-amd64.zip -o logcli.zip
        unzip logcli.zip
        sudo install logcli-linux-amd64 /usr/local/bin/logcli
    fi
    
    # Tempo CLI - Distributed tracing backend
    if ! command -v tempo &> /dev/null; then
        curl -L https://github.com/grafana/tempo/releases/latest/download/tempo_$(curl -s https://api.github.com/repos/grafana/tempo/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv tempo /usr/local/bin/
    fi
    
    # Mimir CLI - Horizontally scalable Prometheus
    if ! command -v mimir &> /dev/null; then
        curl -L https://github.com/grafana/mimir/releases/latest/download/mimir-linux-amd64 -o mimir
        sudo install mimir /usr/local/bin/
    fi
    
    # Cortex CLI - Horizontally scalable Prometheus
    if ! command -v cortex &> /dev/null; then
        curl -L https://github.com/cortexproject/cortex/releases/latest/download/cortex-linux-amd64 -o cortex
        sudo install cortex /usr/local/bin/
    fi
    
    # Thanos CLI - Highly available Prometheus
    if ! command -v thanos &> /dev/null; then
        curl -L https://github.com/thanos-io/thanos/releases/latest/download/thanos-$(curl -s https://api.github.com/repos/thanos-io/thanos/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv thanos-*/thanos /usr/local/bin/
    fi
    
    # VictoriaMetrics CLI - Time series database
    if ! command -v victoria-metrics &> /dev/null; then
        curl -L https://github.com/VictoriaMetrics/VictoriaMetrics/releases/latest/download/victoria-metrics-linux-amd64-$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').tar.gz | tar xz
        sudo mv victoria-metrics-prod /usr/local/bin/victoria-metrics
    fi
    
    # Grafana CLI - Visualization platform
    if ! command -v grafana-cli &> /dev/null; then
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
        wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
        sudo apt-get update
        sudo apt-get install grafana
    fi
    
    # K6 - Load testing tool
    if ! command -v k6 &> /dev/null; then
        sudo gpg -k
        sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
        echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
        sudo apt-get update
        sudo apt-get install k6
    fi
    
    # Artillery - Load testing toolkit
    if ! command -v artillery &> /dev/null; then
        npm install -g artillery
    fi
    
    # Bombardier - HTTP benchmarking tool
    if ! command -v bombardier &> /dev/null; then
        go install github.com/codesenberg/bombardier@latest
    fi
    
    # Hey - HTTP load generator
    if ! command -v hey &> /dev/null; then
        go install github.com/rakyll/hey@latest
    fi
    
    # Vegeta - HTTP load testing tool
    if ! command -v vegeta &> /dev/null; then
        curl -L https://github.com/tsenart/vegeta/releases/latest/download/vegeta_$(curl -s https://api.github.com/repos/tsenart/vegeta/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv vegeta /usr/local/bin/
    fi
    
    # Glow - Terminal markdown viewer
    if ! command -v glow &> /dev/null; then
        go install github.com/charmbracelet/glow@latest
    fi
    
    # Datadog CLI - Monitoring platform
    if ! command -v datadog-ci &> /dev/null; then
        npm install -g @datadog/datadog-ci
    fi
    
    # New Relic CLI - Observability platform
    if ! command -v newrelic &> /dev/null; then
        curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash
    fi
    
    # Honeycomb CLI - Observability platform
    if ! command -v honeycomb &> /dev/null; then
        curl -L https://github.com/honeycombio/honeycomb-cli/releases/latest/download/honeycomb_$(uname -s)_$(uname -m).tar.gz | tar xz
        sudo mv honeycomb /usr/local/bin/
    fi
    
    # Sentry CLI - Error tracking
    if ! command -v sentry-cli &> /dev/null; then
        curl -sL https://sentry.io/get-cli/ | bash
    fi
    
    # Lightstep CLI - Distributed tracing
    if ! command -v lightstep &> /dev/null; then
        npm install -g lightstep-cli
    fi
}

# Modern Mobile and Cross-Platform Tools
install_modern_mobile_tools() {
    echo_info "Installing modern mobile and cross-platform tools..."
    
    # Expo CLI - React Native development
    if ! command -v expo &> /dev/null; then
        npm install -g @expo/cli
    fi
    
    # EAS CLI - Expo Application Services
    if ! command -v eas &> /dev/null; then
        npm install -g @expo/eas-cli
    fi
    
    # Ionic CLI - Cross-platform mobile apps
    if ! command -v ionic &> /dev/null; then
        npm install -g @ionic/cli
    fi
    
    # Capacitor CLI - Cross-platform native runtime
    if ! command -v cap &> /dev/null; then
        npm install -g @capacitor/cli
    fi
    
    # Cordova CLI - Hybrid mobile app platform
    if ! command -v cordova &> /dev/null; then
        npm install -g cordova
    fi
    
    # Quasar CLI - Vue.js framework for mobile
    if ! command -v quasar &> /dev/null; then
        npm install -g @quasar/cli
    fi
    
    # NativeScript CLI - Open source framework for mobile
    if ! command -v ns &> /dev/null; then
        npm install -g @nativescript/cli
    fi
    
    # Flipper - Mobile app debugger
    if ! command -v flipper &> /dev/null; then
        npm install -g flipper
    fi
    
    # Maestro - Mobile UI testing
    if ! command -v maestro &> /dev/null; then
        curl -Ls "https://get.maestro.mobile.dev" | bash
    fi
    
    # Detox CLI - Gray box end-to-end testing
    if ! command -v detox &> /dev/null; then
        npm install -g detox-cli
    fi
    
    # Fastlane - Mobile app automation
    if ! command -v fastlane &> /dev/null; then
        sudo gem install fastlane -NV
    fi
    
    # App Center CLI - Mobile DevOps
    if ! command -v appcenter &> /dev/null; then
        npm install -g appcenter-cli
    fi
    
    # Firebase CLI - Google's mobile platform
    if ! command -v firebase &> /dev/null; then
        npm install -g firebase-tools
    fi
    
    # Amplify CLI - AWS mobile development
    if ! command -v amplify &> /dev/null; then
        npm install -g @aws-amplify/cli
    fi
    
    # Supabase CLI - Open source Firebase alternative
    if ! command -v supabase &> /dev/null; then
        npm install -g supabase
    fi
    
    # PocketBase - Backend as a service
    if ! command -v pocketbase &> /dev/null; then
        curl -L https://github.com/pocketbase/pocketbase/releases/latest/download/pocketbase_$(curl -s https://api.github.com/repos/pocketbase/pocketbase/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.zip -o pocketbase.zip
        unzip pocketbase.zip
        sudo install pocketbase /usr/local/bin/
    fi
    
    # Appwrite CLI - Backend server for mobile
    if ! command -v appwrite &> /dev/null; then
        npm install -g appwrite-cli
    fi
    
    # Realm CLI - Mobile database
    if ! command -v realm-cli &> /dev/null; then
        npm install -g mongodb-realm-cli
    fi
    
    # React Native Debugger
    if ! command -v rn-debugger &> /dev/null; then
        curl -L https://github.com/jhen0409/react-native-debugger/releases/latest/download/react-native-debugger_$(curl -s https://api.github.com/repos/jhen0409/react-native-debugger/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o rn-debugger.deb
        sudo dpkg -i rn-debugger.deb
    fi
    
    # Flipper Labs - Mobile development tools
    if ! snap list flipper &> /dev/null; then
        sudo snap install flipper
    fi
}

# Modern Desktop Development Tools
install_modern_desktop_tools() {
    echo_info "Installing modern desktop development tools..."
    
    # Tauri CLI - Build desktop apps with web technologies
    if ! command -v tauri &> /dev/null; then
        cargo install tauri-cli
    fi
    
    # Wails CLI - Build desktop apps using Go and web technologies
    if ! command -v wails &> /dev/null; then
        go install github.com/wailsapp/wails/v2/cmd/wails@latest
    fi
    
    # Neutralino CLI - Portable and lightweight cross-platform app framework
    if ! command -v neu &> /dev/null; then
        npm install -g @neutralinojs/neu
    fi
    
    # Fyne CLI - Cross platform GUI toolkit for Go
    if ! command -v fyne &> /dev/null; then
        go install fyne.io/fyne/v2/cmd/fyne@latest
    fi
    
    # Iced CLI - GUI library for Rust
    if ! command -v iced &> /dev/null; then
        cargo install iced
    fi
    
    # Egui - Immediate mode GUI library for Rust
    if ! command -v egui &> /dev/null; then
        cargo install egui_demo_app
    fi
    
    # Flutter Desktop - Google's UI toolkit for desktop
    if command -v flutter &> /dev/null; then
        flutter config --enable-linux-desktop
        flutter config --enable-macos-desktop
        flutter config --enable-windows-desktop
    fi
    
    # Qt Creator - Cross-platform IDE
    if ! command -v qtcreator &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qtcreator
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm qtcreator
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qt-creator
        fi
    fi
    
    # GTK4 Development Tools
    if ! command -v gtk4-builder-tool &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y libgtk-4-dev
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gtk4
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gtk4-devel
        fi
    fi
    
    # COSMIC development tools
    if ! command -v cosmic-edit &> /dev/null; then
        echo "COSMIC tools available in repository"
    fi
    
    # AppImage tools
    if ! command -v appimagetool &> /dev/null; then
        curl -L https://github.com/AppImage/AppImageKit/releases/latest/download/appimagetool-$(uname -m).AppImage -o appimagetool
        chmod +x appimagetool
        sudo mv appimagetool /usr/local/bin/
    fi
    
    # AppImageLauncher
    if ! command -v AppImageLauncher &> /dev/null; then
        curl -L https://github.com/TheAssassin/AppImageLauncher/releases/latest/download/appimagelauncher_$(curl -s https://api.github.com/repos/TheAssassin/AppImageLauncher/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o appimagelauncher.deb
        sudo dpkg -i appimagelauncher.deb
    fi
    
    # Flatpak development tools
    if ! command -v flatpak-builder &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y flatpak-builder
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm flatpak-builder
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y flatpak-builder
        fi
    fi
    
    # Snap development tools
    if ! command -v snapcraft &> /dev/null; then
        sudo snap install snapcraft --classic
    fi
    
    # Wine - Windows compatibility layer
    if ! command -v wine &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wine
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wine
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wine
        fi
    fi
    
    # Bottles - Wine prefix manager
    if ! command -v bottles &> /dev/null; then
        flatpak install -y flathub com.usebottles.bottles
    fi
    
    # Lutris - Gaming platform
    if ! command -v lutris &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:lutris-team/lutris -y
            sudo apt-get update
            sudo apt-get install -y lutris
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lutris
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lutris
        fi
    fi
}

# Modern Blockchain and Web3 Tools
install_modern_blockchain_tools() {
    echo_info "Installing modern blockchain and Web3 tools..."
    
    # Foundry - Ethereum development toolchain
    if ! command -v forge &> /dev/null; then
        curl -L https://foundry.paradigm.xyz | bash
        ~/.foundry/bin/foundryup
    fi
    
    # Hardhat - Ethereum development environment
    if ! npm list -g hardhat &> /dev/null; then
        npm install -g hardhat
    fi
    
    # Truffle - Ethereum development framework
    if ! command -v truffle &> /dev/null; then
        npm install -g truffle
    fi
    
    # Ganache CLI - Personal blockchain for Ethereum
    if ! command -v ganache &> /dev/null; then
        npm install -g ganache
    fi
    
    # Brownie - Python-based development framework
    if ! pip show eth-brownie &> /dev/null; then
        pip install eth-brownie
    fi
    
    # Ape Framework - Web3 development framework
    if ! pip show eth-ape &> /dev/null; then
        pip install eth-ape
    fi
    
    # Web3.py CLI - Python library for Ethereum
    if ! pip show web3 &> /dev/null; then
        pip install web3
    fi
    
    # Ethers.js CLI - Ethereum library
    if ! npm list -g ethers &> /dev/null; then
        npm install -g ethers
    fi
    
    # Solidity compiler
    if ! command -v solc &> /dev/null; then
        npm install -g solc
    fi
    
    # Vyper compiler
    if ! command -v vyper &> /dev/null; then
        pip install vyper
    fi
    
    # OpenZeppelin CLI - Smart contract development
    if ! npm list -g @openzeppelin/cli &> /dev/null; then
        npm install -g @openzeppelin/cli
    fi
    
    # Slither - Static analyzer for Solidity
    if ! pip show slither-analyzer &> /dev/null; then
        pip install slither-analyzer
    fi
    
    # Mythril - Security analysis tool
    if ! pip show mythril &> /dev/null; then
        pip install mythril
    fi
    
    # Echidna - Fuzzing tool for Ethereum
    if ! command -v echidna-test &> /dev/null; then
        curl -L https://github.com/crytic/echidna/releases/latest/download/echidna-test-$(curl -s https://api.github.com/repos/crytic/echidna/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-Linux.tar.gz | tar xz
        sudo mv echidna-test /usr/local/bin/
    fi
    
    # Manticore - Symbolic execution tool
    if ! pip show manticore &> /dev/null; then
        pip install manticore
    fi
    
    # IPFS CLI - Distributed file system
    if ! command -v ipfs &> /dev/null; then
        curl -L https://dist.ipfs.tech/kubo/latest/kubo_latest_linux-amd64.tar.gz | tar xz
        sudo mv kubo/ipfs /usr/local/bin/
    fi
    
    # Swarm CLI - Distributed storage platform
    if ! command -v swarm &> /dev/null; then
        curl -L https://github.com/ethersphere/bee/releases/latest/download/bee-linux-amd64 -o bee
        sudo install bee /usr/local/bin/swarm
    fi
    
    # Arweave CLI - Permanent data storage
    if ! npm list -g arweave &> /dev/null; then
        npm install -g arweave
    fi
    
    # Near CLI - NEAR Protocol development
    if ! command -v near &> /dev/null; then
        npm install -g near-cli
    fi
    
    # Solana CLI - Solana blockchain development
    if ! command -v solana &> /dev/null; then
        sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    fi
    
    # Anchor CLI - Solana development framework
    if ! command -v anchor &> /dev/null; then
        cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
    fi
    
    # Polygon CLI - Polygon development
    if ! npm list -g @polygon-sdk/cli &> /dev/null; then
        npm install -g @polygon-sdk/cli
    fi
    
    # Avalanche CLI - Avalanche development
    if ! command -v avalanche &> /dev/null; then
        curl -sSfL https://raw.githubusercontent.com/ava-labs/avalanche-cli/main/scripts/install.sh | sh -s
    fi
    
    # Cosmos CLI - Cosmos SDK development
    if ! command -v ignite &> /dev/null; then
        curl https://get.ignite.com/cli | bash
    fi
    
    # Polkadot CLI - Polkadot development
    if ! command -v polkadot &> /dev/null; then
        cargo install --git https://github.com/paritytech/polkadot --tag v0.9.42 polkadot --locked
    fi
    
    # Substrate CLI - Polkadot SDK
    if ! command -v substrate &> /dev/null; then
        cargo install --git https://github.com/paritytech/substrate subkey --locked
    fi
    
    # Chainlink CLI - Oracle development
    if ! command -v chainlink &> /dev/null; then
        curl -L https://github.com/smartcontractkit/chainlink/releases/latest/download/chainlink-linux-amd64 -o chainlink
        sudo install chainlink /usr/local/bin/
    fi
    
    # The Graph CLI - Indexing protocol
    if ! npm list -g @graphprotocol/graph-cli &> /dev/null; then
        npm install -g @graphprotocol/graph-cli
    fi
    
    # Ceramic CLI - Decentralized data network
    if ! npm list -g @ceramicnetwork/cli &> /dev/null; then
        npm install -g @ceramicnetwork/cli
    fi
    
    # Fleek CLI - Web3 development platform
    if ! npm list -g @fleek-platform/cli &> /dev/null; then
        npm install -g @fleek-platform/cli
    fi
}

# Modern API Development Tools
install_modern_api_tools() {
    echo_info "Installing modern API development tools..."
    
    # Hoppscotch CLI - API development ecosystem
    if ! npm list -g @hoppscotch/cli &> /dev/null; then
        npm install -g @hoppscotch/cli
    fi
    
    # Bruno - Open-source API client
    if ! command -v bruno &> /dev/null; then
        npm install -g @usebruno/cli
    fi
    
    # HTTPie - Modern command-line HTTP client
    if ! command -v http &> /dev/null; then
        pip install httpie
    fi
    
    # HTTPie Desktop
    if ! command -v httpie-desktop &> /dev/null; then
        curl -L https://github.com/httpie/desktop/releases/latest/download/HTTPie-$(curl -s https://api.github.com/repos/httpie/desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.AppImage -o httpie-desktop
        chmod +x httpie-desktop
        sudo mv httpie-desktop /usr/local/bin/
    fi
    
    # Curlie - Frontend to curl with HTTPie syntax
    if ! command -v curlie &> /dev/null; then
        go install github.com/rs/curlie@latest
    fi
    
    # XH - Friendly and fast tool for sending HTTP requests
    if ! command -v xh &> /dev/null; then
        curl -L https://github.com/ducaale/xh/releases/latest/download/xh-$(curl -s https://api.github.com/repos/ducaale/xh/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv xh-*/xh /usr/local/bin/
    fi
    
    # Swagger Codegen - API client generation
    if ! command -v swagger-codegen &> /dev/null; then
        npm install -g swagger-codegen
    fi
    
    # OpenAPI Generator - API client generation
    if ! command -v openapi-generator &> /dev/null; then
        npm install -g @openapitools/openapi-generator-cli
    fi
    
    # Insomnia CLI - API design and testing
    if ! command -v inso &> /dev/null; then
        npm install -g insomnia-inso
    fi
    
    # Stoplight CLI - API design and documentation
    if ! npm list -g @stoplight/cli &> /dev/null; then
        npm install -g @stoplight/cli
    fi
    
    # Redocly CLI - OpenAPI tools
    if ! npm list -g @redocly/cli &> /dev/null; then
        npm install -g @redocly/cli
    fi
    
    # Newman - Postman collection runner
    if ! command -v newman &> /dev/null; then
        npm install -g newman
    fi
    
    # Apidog CLI - API development platform
    if ! npm list -g apidog-cli &> /dev/null; then
        npm install -g apidog-cli
    fi
    
    # REST Client for VS Code
    if command -v code &> /dev/null; then
        code --install-extension humao.rest-client
    fi
    
    # Thunder Client for VS Code
    if command -v code &> /dev/null; then
        code --install-extension rangav.vscode-thunder-client
    fi
    
    # GraphQL CLI - GraphQL development
    if ! command -v graphql &> /dev/null; then
        npm install -g graphql-cli
    fi
    
    # GraphQL Playground CLI
    if ! npm list -g graphql-playground-cli &> /dev/null; then
        npm install -g graphql-playground-cli
    fi
    
    # Altair GraphQL Client
    if ! command -v altair &> /dev/null; then
        npm install -g altair-graphql-cli
    fi
    
    # Apollo CLI - GraphQL development
    if ! command -v apollo &> /dev/null; then
        npm install -g apollo
    fi
    
    # Hasura CLI - GraphQL API platform
    if ! command -v hasura &> /dev/null; then
        curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash
    fi
    
    # Supabase CLI - GraphQL and REST API
    if ! command -v supabase &> /dev/null; then
        npm install -g supabase
    fi
    
    # Strapi CLI - Headless CMS
    if ! command -v strapi &> /dev/null; then
        npm install -g @strapi/strapi
    fi
    
    # Directus CLI - Headless CMS
    if ! npm list -g directus &> /dev/null; then
        npm install -g directus
    fi
    
    # Payload CMS CLI
    if ! npm list -g payload &> /dev/null; then
        npm install -g payload
    fi
    
    # JSON Server - Mock REST API
    if ! command -v json-server &> /dev/null; then
        npm install -g json-server
    fi
    
    # MSW CLI - Mock Service Worker
    if ! npm list -g msw &> /dev/null; then
        npm install -g msw
    fi
    
    # WireMock - API mocking
    if ! command -v wiremock &> /dev/null; then
        curl -L https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/2.35.0/wiremock-jre8-standalone-2.35.0.jar -o /tmp/wiremock.jar
        echo '#!/bin/bash\njava -jar /tmp/wiremock.jar "$@"' | sudo tee /usr/local/bin/wiremock
        sudo chmod +x /usr/local/bin/wiremock
    fi
    
    # Prism - HTTP mock server
    if ! npm list -g @stoplight/prism-cli &> /dev/null; then
        npm install -g @stoplight/prism-cli
    fi
    
    # Mockoon CLI - API mocking
    if ! npm list -g @mockoon/cli &> /dev/null; then
        npm install -g @mockoon/cli
    fi
}

# Modern Testing and Quality Assurance Tools
install_modern_testing_tools() {
    echo_info "Installing modern testing and quality assurance tools..."
    
    # Playwright - Modern web testing
    if ! npm list -g @playwright/test &> /dev/null; then
        npm install -g @playwright/test
        npx playwright install
    fi
    
    # Cypress - JavaScript end-to-end testing
    if ! npm list -g cypress &> /dev/null; then
        npm install -g cypress
    fi
    
    # WebDriver.io - Browser automation
    if ! npm list -g @wdio/cli &> /dev/null; then
        npm install -g @wdio/cli
    fi
    
    # TestCafe - Web testing framework
    if ! npm list -g testcafe &> /dev/null; then
        npm install -g testcafe
    fi
    
    # Puppeteer - Headless Chrome automation
    if ! npm list -g puppeteer &> /dev/null; then
        npm install -g puppeteer
    fi
    
    # Selenium Grid - Browser automation
    if ! command -v selenium-server &> /dev/null; then
        curl -L https://github.com/SeleniumHQ/selenium/releases/latest/download/selenium-server-4.15.0.jar -o /tmp/selenium-server.jar
        echo '#!/bin/bash\njava -jar /tmp/selenium-server.jar "$@"' | sudo tee /usr/local/bin/selenium-server
        sudo chmod +x /usr/local/bin/selenium-server
    fi
    
    # Vitest - Blazing fast unit test framework
    if ! npm list -g vitest &> /dev/null; then
        npm install -g vitest
    fi
    
    # Jest - JavaScript testing framework
    if ! npm list -g jest &> /dev/null; then
        npm install -g jest
    fi
    
    # Mocha - JavaScript test framework
    if ! npm list -g mocha &> /dev/null; then
        npm install -g mocha
    fi
    
    # Ava - Node.js test runner
    if ! npm list -g ava &> /dev/null; then
        npm install -g ava
    fi
    
    # Tap - Test Anything Protocol
    if ! npm list -g tap &> /dev/null; then
        npm install -g tap
    fi
    
    # Lab - Test utility for Hapi.js
    if ! npm list -g @hapi/lab &> /dev/null; then
        npm install -g @hapi/lab
    fi
    
    # Karma - Test runner
    if ! npm list -g karma-cli &> /dev/null; then
        npm install -g karma-cli
    fi
    
    # Jasmine - Behavior-driven testing
    if ! npm list -g jasmine &> /dev/null; then
        npm install -g jasmine
    fi
    
    # QUnit - JavaScript unit testing
    if ! npm list -g qunit &> /dev/null; then
        npm install -g qunit
    fi
    
    # Storybook - UI component testing
    if ! command -v storybook &> /dev/null; then
        npm install -g @storybook/cli
    fi
    
    # Chromatic - Visual testing
    if ! npm list -g chromatic &> /dev/null; then
        npm install -g chromatic
    fi
    
    # Percy CLI - Visual testing
    if ! npm list -g @percy/cli &> /dev/null; then
        npm install -g @percy/cli
    fi
    
    # BackstopJS - Visual regression testing
    if ! npm list -g backstopjs &> /dev/null; then
        npm install -g backstopjs
    fi
    
    # Applitools Eyes - Visual AI testing
    if ! npm list -g @applitools/eyes-cypress &> /dev/null; then
        npm install -g @applitools/eyes-cypress
    fi
    
    # Taiko - Browser automation
    if ! npm list -g taiko &> /dev/null; then
        npm install -g taiko
    fi
    
    # CodeceptJS - Acceptance testing
    if ! npm list -g codeceptjs &> /dev/null; then
        npm install -g codeceptjs
    fi
    
    # Nightwatch - End-to-end testing
    if ! npm list -g nightwatch &> /dev/null; then
        npm install -g nightwatch
    fi
    
    # Protractor - Angular testing (legacy)
    if ! npm list -g protractor &> /dev/null; then
        npm install -g protractor
    fi
    
    # Angular Testing Utilities
    if ! npm list -g @angular/cli &> /dev/null; then
        npm install -g @angular/cli
    fi
    
    # Vue Testing Utils
    if ! npm list -g @vue/test-utils &> /dev/null; then
        npm install -g @vue/test-utils
    fi
    
    # React Testing Library
    if ! npm list -g @testing-library/react &> /dev/null; then
        npm install -g @testing-library/react
    fi
    
    # Supertest - HTTP testing
    if ! npm list -g supertest &> /dev/null; then
        npm install -g supertest
    fi
    
    # Nock - HTTP mocking
    if ! npm list -g nock &> /dev/null; then
        npm install -g nock
    fi
    
    # Sinon - Test spies, stubs and mocks
    if ! npm list -g sinon &> /dev/null; then
        npm install -g sinon
    fi
    
    # Chai - Assertion library
    if ! npm list -g chai &> /dev/null; then
        npm install -g chai
    fi
    
    # Should.js - Assertion library
    if ! npm list -g should &> /dev/null; then
        npm install -g should
    fi
    
    # Expect.js - Assertion library
    if ! npm list -g expect.js &> /dev/null; then
        npm install -g expect.js
    fi
    
    # Istanbul - Code coverage
    if ! npm list -g nyc &> /dev/null; then
        npm install -g nyc
    fi
    
    # C8 - Code coverage
    if ! npm list -g c8 &> /dev/null; then
        npm install -g c8
    fi
    
    # Codecov - Code coverage reporting
    if ! pip show codecov &> /dev/null; then
        pip install codecov
    fi
    
    # Coveralls - Code coverage reporting
    if ! npm list -g coveralls &> /dev/null; then
        npm install -g coveralls
    fi
}

# Modern Documentation Tools
install_modern_documentation_tools() {
    echo_info "Installing modern documentation tools..."
    
    # Docusaurus - Modern documentation platform
    if ! npm list -g @docusaurus/core &> /dev/null; then
        npm install -g @docusaurus/core
    fi
    
    # VitePress - Vite & Vue powered static site generator
    if ! npm list -g vitepress &> /dev/null; then
        npm install -g vitepress
    fi
    
    # GitBook CLI - Modern documentation platform
    if ! npm list -g gitbook-cli &> /dev/null; then
        npm install -g gitbook-cli
    fi
    
    # Docsify - Magical documentation site generator
    if ! npm list -g docsify-cli &> /dev/null; then
        npm install -g docsify-cli
    fi
    
    # Slidev - Presentation slides for developers
    if ! npm list -g @slidev/cli &> /dev/null; then
        npm install -g @slidev/cli
    fi
    
    # Marp CLI - Markdown presentation ecosystem
    if ! npm list -g @marp-team/marp-cli &> /dev/null; then
        npm install -g @marp-team/marp-cli
    fi
    
    # Reveal.js - HTML presentation framework
    if ! npm list -g reveal.js &> /dev/null; then
        npm install -g reveal.js
    fi
    
    # MDX - Markdown for the component era
    if ! npm list -g @mdx-js/mdx &> /dev/null; then
        npm install -g @mdx-js/mdx
    fi
    
    # Nextra - Simple, powerful and flexible site generation framework
    if ! npm list -g nextra &> /dev/null; then
        npm install -g nextra
    fi
    
    # Starlight - Documentation framework built on Astro
    if ! npm list -g @astrojs/starlight &> /dev/null; then
        npm install -g @astrojs/starlight
    fi
    
    # Mintlify - Beautiful documentation that converts users
    if ! npm list -g mintlify &> /dev/null; then
        npm install -g mintlify
    fi
    
    # Bookshop - Component-based CMS
    if ! npm list -g @bookshop/cli &> /dev/null; then
        npm install -g @bookshop/cli
    fi
    
    # Outline - Team knowledge base
    if ! npm list -g outline &> /dev/null; then
        npm install -g outline
    fi
    
    # Notion CLI - Notion API tools
    if ! npm list -g @notionhq/client &> /dev/null; then
        npm install -g @notionhq/client
    fi
    
    # Confluence CLI - Atlassian documentation
    if ! pip show atlassian-python-api &> /dev/null; then
        pip install atlassian-python-api
    fi
    
    # Sphinx - Python documentation generator
    if ! pip show sphinx &> /dev/null; then
        pip install sphinx
    fi
    
    # MkDocs - Project documentation with Markdown
    if ! pip show mkdocs &> /dev/null; then
        pip install mkdocs
    fi
    
    # Material for MkDocs - Material Design theme
    if ! pip show mkdocs-material &> /dev/null; then
        pip install mkdocs-material
    fi
    
    # Jupyter Book - Computational narratives
    if ! pip show jupyter-book &> /dev/null; then
        pip install jupyter-book
    fi
    
    # MyST Parser - Markedly Structured Text
    if ! pip show myst-parser &> /dev/null; then
        pip install myst-parser
    fi
    
    # Pandoc - Universal document converter
    if ! command -v pandoc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y pandoc
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm pandoc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pandoc
        fi
    fi
    
    # Mermaid CLI - Diagram and flowchart generation
    if ! npm list -g @mermaid-js/mermaid-cli &> /dev/null; then
        npm install -g @mermaid-js/mermaid-cli
    fi
    
    # PlantUML - UML diagram creation
    if ! command -v plantuml &> /dev/null; then
        curl -L http://sourceforge.net/projects/plantuml/files/plantuml.jar/download -o /tmp/plantuml.jar
        echo '#!/bin/bash\njava -jar /tmp/plantuml.jar "$@"' | sudo tee /usr/local/bin/plantuml
        sudo chmod +x /usr/local/bin/plantuml
    fi
    
    # Draw.io CLI - Diagramming tool
    if ! npm list -g @draw.io/cli &> /dev/null; then
        npm install -g @draw.io/cli
    fi
    
    # Excalidraw CLI - Virtual whiteboard
    if ! npm list -g @excalidraw/cli &> /dev/null; then
        npm install -g @excalidraw/cli
    fi
    
    # Remark - Markdown processor
    if ! npm list -g remark-cli &> /dev/null; then
        npm install -g remark-cli
    fi
    
    # Markdownlint CLI - Markdown linter
    if ! npm list -g markdownlint-cli &> /dev/null; then
        npm install -g markdownlint-cli
    fi
    
    # Vale - Prose linter
    if ! command -v vale &> /dev/null; then
        curl -L https://github.com/errata-ai/vale/releases/latest/download/vale_$(curl -s https://api.github.com/repos/errata-ai/vale/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_Linux_64-bit.tar.gz | tar xz
        sudo mv vale /usr/local/bin/
    fi
    
    # Alex - Inclusive language linter
    if ! npm list -g alex &> /dev/null; then
        npm install -g alex
    fi
    
    # Write Good - Naive linter for English prose
    if ! npm list -g write-good &> /dev/null; then
        npm install -g write-good
    fi
    
    # Textlint - Pluggable natural language linter
    if ! npm list -g textlint &> /dev/null; then
        npm install -g textlint
    fi
    
    # Proselint - Linter for prose
    if ! pip show proselint &> /dev/null; then
        pip install proselint
    fi
}

# Modern Performance Tools
install_modern_performance_tools() {
    echo_info "Installing modern performance tools..."
    
    # Lighthouse CLI - Web performance auditing
    if ! npm list -g lighthouse &> /dev/null; then
        npm install -g lighthouse
    fi
    
    # PageSpeed Insights CLI
    if ! npm list -g psi &> /dev/null; then
        npm install -g psi
    fi
    
    # WebPageTest CLI - Website performance testing
    if ! npm list -g webpagetest &> /dev/null; then
        npm install -g webpagetest
    fi
    
    # Unlighthouse - Site-wide Google Lighthouse scanning
    if ! npm list -g @unlighthouse/cli &> /dev/null; then
        npm install -g @unlighthouse/cli
    fi
    
    # SpeedCurve CLI - Web performance monitoring
    if ! npm list -g speedcurve &> /dev/null; then
        npm install -g speedcurve
    fi
    
    # GTmetrix CLI - Website performance testing
    if ! pip show gtmetrix-python &> /dev/null; then
        pip install gtmetrix-python
    fi
    
    # Bundle Analyzer - Webpack bundle analysis
    if ! npm list -g webpack-bundle-analyzer &> /dev/null; then
        npm install -g webpack-bundle-analyzer
    fi
    
    # Bundlesize - Keep your bundle size in check
    if ! npm list -g bundlesize &> /dev/null; then
        npm install -g bundlesize
    fi
    
    # Size Limit - Calculate the real cost of your JS
    if ! npm list -g size-limit &> /dev/null; then
        npm install -g size-limit
    fi
    
    # Cost of Modules - Find out which of your dependencies are slowing you down
    if ! npm list -g cost-of-modules &> /dev/null; then
        npm install -g cost-of-modules
    fi
    
    # Import Cost - Display import/require package size
    if command -v code &> /dev/null; then
        code --install-extension wix.vscode-import-cost
    fi
    
    # Hyperfine - Command-line benchmarking tool
    if ! command -v hyperfine &> /dev/null; then
        curl -L https://github.com/sharkdp/hyperfine/releases/latest/download/hyperfine-$(curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv hyperfine-*/hyperfine /usr/local/bin/
    fi
    
    # Bench - Benchmark your code
    if ! command -v bench &> /dev/null; then
        go install github.com/Gabriel-Ivarsson/bench@latest
    fi
    
    # Pprof - Performance profiler
    if ! command -v pprof &> /dev/null; then
        go install github.com/google/pprof@latest
    fi
    
    # Perf - Performance analysis tools
    if ! command -v perf &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y linux-tools-common linux-tools-generic
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm perf
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y perf
        fi
    fi
    
    # Valgrind - Memory debugging and profiling
    if ! command -v valgrind &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y valgrind
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm valgrind
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y valgrind
        fi
    fi
    
    # Heaptrack - Heap memory profiler
    if ! command -v heaptrack &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y heaptrack
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm heaptrack
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y heaptrack
        fi
    fi
    
    # Massif Visualizer - Memory profiling visualization
    if ! command -v massif-visualizer &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y massif-visualizer
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm massif-visualizer
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y massif-visualizer
        fi
    fi
    
    # Hotspot - Perf profiler GUI
    if ! command -v hotspot &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y hotspot
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm hotspot
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y hotspot
        fi
    fi
    
    # eBPF tools - System observability
    if ! command -v bpftrace &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y bpftrace
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm bpftrace
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y bpftrace
        fi
    fi
    
    # Flamegraph - Stack trace visualizer
    if ! command -v flamegraph &> /dev/null; then
        git clone https://github.com/brendangregg/FlameGraph.git /tmp/FlameGraph
        sudo cp /tmp/FlameGraph/*.pl /usr/local/bin/
        sudo chmod +x /usr/local/bin/*.pl
    fi
    
    # Austin - Python performance profiler
    if ! pip show austin-python &> /dev/null; then
        pip install austin-python
    fi
    
    # Py-spy - Python profiler
    if ! pip show py-spy &> /dev/null; then
        pip install py-spy
    fi
    
    # Scalene - Python performance profiler
    if ! pip show scalene &> /dev/null; then
        pip install scalene
    fi
    
    # Memory Profiler - Python memory profiler
    if ! pip show memory-profiler &> /dev/null; then
        pip install memory-profiler
    fi
    
    # Line Profiler - Python line-by-line profiler
    if ! pip show line-profiler &> /dev/null; then
        pip install line-profiler
    fi
    
    # Profiling - Python profiler
    if ! pip show profiling &> /dev/null; then
        pip install profiling
    fi
}

# Modern Terminal and Shell Tools
install_modern_terminal_tools() {
    echo_info "Installing modern terminal and shell tools..."
    
    # Alacritty - Modern terminal emulator
    if ! command -v alacritty &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:aslatter/ppa -y
            sudo apt-get update
            sudo apt-get install -y alacritty
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm alacritty
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y alacritty
        fi
    fi
    
    # WezTerm - GPU-accelerated terminal emulator
    if ! command -v wezterm &> /dev/null; then
        curl -LO https://github.com/wez/wezterm/releases/latest/download/wezterm-$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-1.ubuntu20.04.deb
        sudo dpkg -i wezterm-*.deb
    fi
    
    # Kitty - Fast, feature-rich, GPU-accelerated terminal
    if ! command -v kitty &> /dev/null; then
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
        sudo ln -sf ~/.local/kitty.app/bin/kitty /usr/local/bin/
    fi
    
    # Hyper - Electron-based terminal
    if ! command -v hyper &> /dev/null; then
        curl -L https://github.com/vercel/hyper/releases/latest/download/hyper_$(curl -s https://api.github.com/repos/vercel/hyper/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o hyper.deb
        sudo dpkg -i hyper.deb
    fi
    
    # Tabby - Modern terminal application
    if ! command -v tabby &> /dev/null; then
        curl -L https://github.com/Eugeny/tabby/releases/latest/download/tabby-$(curl -s https://api.github.com/repos/Eugeny/tabby/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x64.deb -o tabby.deb
        sudo dpkg -i tabby.deb
    fi
    
    # Fish Shell - Smart and user-friendly shell
    if ! command -v fish &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fish
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fish
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fish
        fi
    fi
    
    # Nushell - Modern shell for the GitHub era
    if ! command -v nu &> /dev/null; then
        curl -L https://github.com/nushell/nushell/releases/latest/download/nu-$(curl -s https://api.github.com/repos/nushell/nushell/releases/latest | grep tag_name | cut -d '"' -f 4)-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv nu-*/nu /usr/local/bin/
    fi
    
    # Ion Shell - Modern system shell
    if ! command -v ion &> /dev/null; then
        curl -L https://github.com/redox-os/ion/releases/latest/download/ion-x86_64-unknown-linux-gnu.tar.gz | tar xz
        sudo mv ion /usr/local/bin/
    fi
    
    # Elvish - Expressive programming language and shell
    if ! command -v elvish &> /dev/null; then
        curl -L https://dl.elv.sh/linux-amd64/elvish-$(curl -s https://api.github.com/repos/elves/elvish/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').tar.gz | tar xz
        sudo mv elvish-* /usr/local/bin/elvish
    fi
    
    # Zsh with Oh My Zsh
    if ! command -v zsh &> /dev/null; then
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
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    
    # Powerlevel10k - Zsh theme
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
    
    # Starship - Cross-shell prompt
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # Prompt - Simple, fast and customizable prompt
    if ! command -v prompt &> /dev/null; then
        go install github.com/muesli/prompt@latest
    fi
    
    # Tide - Ultimate Fish prompt
    if command -v fish &> /dev/null; then
        fish -c 'curl -sL https://git.io/fisher | source && fisher install IlanCosman/tide@v5'
    fi
    
    # Bat - Modern cat replacement
    if ! command -v bat &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y bat
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm bat
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y bat
        fi
    fi
    
    # Exa - Modern ls replacement
    if ! command -v exa &> /dev/null; then
        curl -L https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-$(curl -s https://api.github.com/repos/ogham/exa/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').zip -o exa.zip
        unzip exa.zip
        sudo mv bin/exa /usr/local/bin/
    fi
    
    # Eza - Modern ls replacement (exa successor)
    if ! command -v eza &> /dev/null; then
        curl -L https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv eza /usr/local/bin/
    fi
    
    # Lsd - Next gen ls command
    if ! command -v lsd &> /dev/null; then
        curl -L https://github.com/Peltoche/lsd/releases/latest/download/lsd-$(curl -s https://api.github.com/repos/Peltoche/lsd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv lsd-*/lsd /usr/local/bin/
    fi
    
    # Ripgrep - Modern grep replacement
    if ! command -v rg &> /dev/null; then
        curl -L https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep tag_name | cut -d '"' -f 4)-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv ripgrep-*/rg /usr/local/bin/
    fi
    
    # Fd - Modern find replacement
    if ! command -v fd &> /dev/null; then
        curl -L https://github.com/sharkdp/fd/releases/latest/download/fd-$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv fd-*/fd /usr/local/bin/
    fi
    
    # Procs - Modern ps replacement
    if ! command -v procs &> /dev/null; then
        curl -L https://github.com/dalance/procs/releases/latest/download/procs-$(curl -s https://api.github.com/repos/dalance/procs/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-linux.zip -o procs.zip
        unzip procs.zip
        sudo mv procs /usr/local/bin/
    fi
    
    # Bottom - System monitor
    if ! command -v btm &> /dev/null; then
        curl -L https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv btm /usr/local/bin/
    fi
    
    # Dust - Modern du replacement
    if ! command -v dust &> /dev/null; then
        curl -L https://github.com/bootandy/dust/releases/latest/download/dust-$(curl -s https://api.github.com/repos/bootandy/dust/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv dust-*/dust /usr/local/bin/
    fi
    
    # Duf - Modern df replacement
    if ! command -v duf &> /dev/null; then
        curl -L https://github.com/muesli/duf/releases/latest/download/duf_$(curl -s https://api.github.com/repos/muesli/duf/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_x86_64.tar.gz | tar xz
        sudo mv duf /usr/local/bin/
    fi
    
    # Tokei - Code statistics
    if ! command -v tokei &> /dev/null; then
        curl -L https://github.com/XAMPPRocky/tokei/releases/latest/download/tokei-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv tokei /usr/local/bin/
    fi
    
    # Bandwhich - Network utilization monitor
    if ! command -v bandwhich &> /dev/null; then
        curl -L https://github.com/imsnif/bandwhich/releases/latest/download/bandwhich-$(curl -s https://api.github.com/repos/imsnif/bandwhich/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv bandwhich /usr/local/bin/
    fi
    
    # Grex - Generate regex from examples
    if ! command -v grex &> /dev/null; then
        curl -L https://github.com/pemistahl/grex/releases/latest/download/grex-$(curl -s https://api.github.com/repos/pemistahl/grex/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv grex /usr/local/bin/
    fi
    
    # Fzf - Fuzzy finder
    if ! command -v fzf &> /dev/null; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi
    
    # Skim - Fuzzy finder alternative
    if ! command -v sk &> /dev/null; then
        curl -L https://github.com/lotabout/skim/releases/latest/download/skim-$(curl -s https://api.github.com/repos/lotabout/skim/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv sk /usr/local/bin/
    fi
    
    # Choose - Human-friendly alternative to cut/awk
    if ! command -v choose &> /dev/null; then
        curl -L https://github.com/theryangeary/choose/releases/latest/download/choose-x86_64-unknown-linux-musl | sudo tee /usr/local/bin/choose > /dev/null
        sudo chmod +x /usr/local/bin/choose
    fi
    
    # Zoxide - Smarter cd command
    if ! command -v zoxide &> /dev/null; then
        curl -sS https://webinstall.dev/zoxide | bash
    fi
    
    # Mcfly - Upgraded ctrl-r
    if ! command -v mcfly &> /dev/null; then
        curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly
    fi
    
    # Atuin - Magical shell history
    if ! command -v atuin &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    fi
    
    # Thefuck - Magnificent app which corrects your commands
    if ! command -v thefuck &> /dev/null; then
        pip install thefuck
    fi
    
    # Tldr - Simplified man pages
    if ! command -v tldr &> /dev/null; then
        npm install -g tldr
    fi
    
    # Tealdeer - Fast tldr client
    if ! command -v tealdeer &> /dev/null; then
        curl -L https://github.com/dbrgn/tealdeer/releases/latest/download/tealdeer-linux-x86_64-musl | sudo tee /usr/local/bin/tealdeer > /dev/null
        sudo chmod +x /usr/local/bin/tealdeer
    fi
    
    # Navi - Interactive cheatsheet
    if ! command -v navi &> /dev/null; then
        curl -L https://github.com/denisidoro/navi/releases/latest/download/navi-$(curl -s https://api.github.com/repos/denisidoro/navi/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv navi /usr/local/bin/
    fi
    
    # Broot - Tree view of directories
    if ! command -v broot &> /dev/null; then
        curl -L https://github.com/Canop/broot/releases/latest/download/broot-$(curl -s https://api.github.com/repos/Canop/broot/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.zip -o broot.zip
        unzip broot.zip
        sudo mv broot /usr/local/bin/
    fi
    
    # Tree - Directory structure display
    if ! command -v tree &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tree
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tree
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tree
        fi
    fi
    
    # Ranger - Terminal file manager
    if ! command -v ranger &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ranger
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ranger
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ranger
        fi
    fi
    
    # Nnn - Terminal file manager
    if ! command -v nnn &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nnn
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nnn
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nnn
        fi
    fi
    
    # Lf - Terminal file manager
    if ! command -v lf &> /dev/null; then
        curl -L https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz | tar xz
        sudo mv lf /usr/local/bin/
    fi
    
    # Vifm - Vi-like file manager
    if ! command -v vifm &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y vifm
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm vifm
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y vifm
        fi
    fi
}

# Modern Package Managers and Build Systems
install_modern_package_managers() {
    echo_info "Installing modern package managers and build systems..."
    
    # Pnpm - Fast, disk space efficient package manager
    if ! command -v pnpm &> /dev/null; then
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    fi
    
    # Yarn - Package manager for JavaScript
    if ! command -v yarn &> /dev/null; then
        npm install -g yarn
    fi
    
    # Bun - Fast all-in-one JavaScript runtime
    if ! command -v bun &> /dev/null; then
        curl -fsSL https://bun.sh/install | bash
    fi
    
    # Deno - Secure runtime for JavaScript and TypeScript
    if ! command -v deno &> /dev/null; then
        curl -fsSL https://deno.land/install.sh | sh
    fi
    
    # Volta - JavaScript tool manager
    if ! command -v volta &> /dev/null; then
        curl https://get.volta.sh | bash
    fi
    
    # Fnm - Fast Node.js version manager
    if ! command -v fnm &> /dev/null; then
        curl -fsSL https://fnm.vercel.app/install | bash
    fi
    
    # Nvm - Node.js version manager
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    fi
    
    # Rustup - Rust toolchain installer
    if ! command -v rustup &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    
    # Cargo - Rust package manager
    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    
    # Poetry - Python dependency management
    if ! command -v poetry &> /dev/null; then
        curl -sSL https://install.python-poetry.org | python3 -
    fi
    
    # Pipenv - Python development workflow
    if ! command -v pipenv &> /dev/null; then
        pip install pipenv
    fi
    
    # Pdm - Modern Python package manager
    if ! command -v pdm &> /dev/null; then
        curl -sSL https://pdm.fming.dev/install-pdm.py | python3 -
    fi
    
    # Rye - Experimental package management solution for Python
    if ! command -v rye &> /dev/null; then
        curl -sSf https://rye-up.com/get | bash
    fi
    
    # Uv - Extremely fast Python package installer
    if ! command -v uv &> /dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    
    # Pixi - Package management made easy
    if ! command -v pixi &> /dev/null; then
        curl -fsSL https://pixi.sh/install.sh | bash
    fi
    
    # Mamba - Fast, robust, and cross-platform package manager
    if ! command -v mamba &> /dev/null; then
        curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -o mambaforge.sh
        bash mambaforge.sh -b -p $HOME/mambaforge
        rm mambaforge.sh
    fi
    
    # Micromamba - Tiny version of mamba
    if ! command -v micromamba &> /dev/null; then
        curl micro.mamba.pm/install.sh | bash
    fi
    
    # Go - Go programming language
    if ! command -v go &> /dev/null; then
        curl -L https://go.dev/dl/go1.21.3.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf -
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    fi
    
    # Gvm - Go version manager
    if [ ! -d "$HOME/.gvm" ]; then
        bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    fi
    
    # G - Go version manager
    if ! command -v g &> /dev/null; then
        curl -sSL https://git.io/g-install | sh -s
    fi
    
    # Rbenv - Ruby version manager
    if [ ! -d "$HOME/.rbenv" ]; then
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    fi
    
    # Rvm - Ruby version manager
    if ! command -v rvm &> /dev/null; then
        curl -sSL https://get.rvm.io | bash -s stable
    fi
    
    # Bundler - Ruby dependency manager
    if ! command -v bundle &> /dev/null; then
        gem install bundler
    fi
    
    # Maven - Java build tool
    if ! command -v mvn &> /dev/null; then
        curl -L https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz | sudo tar -C /opt -xzf -
        sudo ln -s /opt/apache-maven-3.9.5/bin/mvn /usr/local/bin/mvn
    fi
    
    # Gradle - Build automation tool
    if ! command -v gradle &> /dev/null; then
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk install gradle
    fi
    
    # Sdkman - Software development kit manager
    if [ ! -d "$HOME/.sdkman" ]; then
        curl -s "https://get.sdkman.io" | bash
    fi
    
    # Coursier - Scala application and artifact manager
    if ! command -v cs &> /dev/null; then
        curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > cs
        chmod +x cs
        ./cs setup
        sudo mv cs /usr/local/bin/
    fi
    
    # Sbt - Scala build tool
    if ! command -v sbt &> /dev/null; then
        echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
        echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
        curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
        sudo apt-get update
        sudo apt-get install sbt
    fi
    
    # Mill - Scala build tool
    if ! command -v mill &> /dev/null; then
        curl -L https://github.com/com-lihaoyi/mill/releases/latest/download/mill-assembly -o mill
        chmod +x mill
        sudo mv mill /usr/local/bin/
    fi
    
    # Leiningen - Clojure build tool
    if ! command -v lein &> /dev/null; then
        curl -L https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o lein
        chmod +x lein
        sudo mv lein /usr/local/bin/
    fi
    
    # Boot - Clojure build tool
    if ! command -v boot &> /dev/null; then
        curl -fsSLo boot https://github.com/boot-clj/boot-bin/releases/download/latest/boot.sh
        chmod +x boot
        sudo mv boot /usr/local/bin/
    fi
    
    # Clojure CLI tools
    if ! command -v clojure &> /dev/null; then
        curl -O https://download.clojure.org/install/linux-install-1.11.1.1273.sh
        chmod +x linux-install-1.11.1.1273.sh
        sudo ./linux-install-1.11.1.1273.sh
    fi
    
    # Mix - Elixir build tool
    if ! command -v mix &> /dev/null; then
        curl -fsSL https://github.com/asdf-vm/asdf/archive/v0.13.1.tar.gz | tar xz
        mv asdf-0.13.1 ~/.asdf
        echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
        echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
        source ~/.bashrc
        asdf plugin add elixir
        asdf install elixir latest
        asdf global elixir latest
    fi
    
    # Hex - Elixir package manager
    if command -v mix &> /dev/null; then
        mix local.hex --force
    fi
    
    # Rebar3 - Erlang build tool
    if ! command -v rebar3 &> /dev/null; then
        curl -L https://github.com/erlang/rebar3/releases/latest/download/rebar3 -o rebar3
        chmod +x rebar3
        sudo mv rebar3 /usr/local/bin/
    fi
    
    # Stack - Haskell build tool
    if ! command -v stack &> /dev/null; then
        curl -sSL https://get.haskellstack.org/ | sh
    fi
    
    # Cabal - Haskell package manager
    if ! command -v cabal &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
    fi
    
    # Ghcup - Haskell toolchain installer
    if ! command -v ghcup &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
    fi
    
    # Nimble - Nim package manager
    if ! command -v nimble &> /dev/null; then
        curl https://nim-lang.org/choosenim/init.sh -sSf | sh
    fi
    
    # Crystal Shards - Crystal package manager
    if command -v crystal &> /dev/null; then
        echo "Shards available with Crystal"
    fi
    
    # Dart Pub - Dart package manager
    if command -v dart &> /dev/null; then
        echo "Pub available with Dart"
    fi
    
    # Flutter Pub - Flutter package manager
    if command -v flutter &> /dev/null; then
        echo "Pub available with Flutter"
    fi
    
    # Swift Package Manager
    if command -v swift &> /dev/null; then
        echo "SPM available with Swift"
    fi
    
    # Zig Package Manager
    if command -v zig &> /dev/null; then
        echo "Package manager available with Zig"
    fi
    
    # Just - Task runner
    if ! command -v just &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
    fi
    
    # Make - Build automation tool
    if ! command -v make &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y make
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm make
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y make
        fi
    fi
    
    # Ninja - Small build system
    if ! command -v ninja &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ninja-build
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ninja
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ninja-build
        fi
    fi
    
    # CMake - Cross-platform build system
    if ! command -v cmake &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y cmake
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm cmake
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y cmake
        fi
    fi
    
    # Meson - Build system
    if ! command -v meson &> /dev/null; then
        pip install meson
    fi
    
    # Bazel - Build tool
    if ! command -v bazel &> /dev/null; then
        curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
        sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
        echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
        sudo apt update && sudo apt install bazel
    fi
    
    # Please - High-performance build tool
    if ! command -v plz &> /dev/null; then
        curl -fsSL https://get.please.build | bash
    fi
    
    # Buck2 - Build system
    if ! command -v buck2 &> /dev/null; then
        curl -L https://github.com/facebook/buck2/releases/latest/download/buck2-x86_64-unknown-linux-musl.zst | zstd -d > buck2
        chmod +x buck2
        sudo mv buck2 /usr/local/bin/
    fi
    
    # Xmake - Cross-platform build utility
    if ! command -v xmake &> /dev/null; then
        curl -fsSL https://xmake.io/shget.text | bash
    fi
    
    # Tup - Build system
    if ! command -v tup &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tup
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tup
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tup
        fi
    fi
}

# Modern Code Editors and IDEs
install_modern_code_editors() {
    echo_info "Installing modern code editors and IDEs..."
    
    # Visual Studio Code
    if ! command -v code &> /dev/null; then
        curl -L https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -o vscode.deb
        sudo dpkg -i vscode.deb
        sudo apt-get install -f
    fi
    
    # VSCodium - Open source VS Code
    if ! command -v codium &> /dev/null; then
        wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
        echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
        sudo apt update && sudo apt install codium
    fi
    
    # Cursor - AI-powered code editor
    if ! command -v cursor &> /dev/null; then
        curl -L https://download.cursor.sh/linux/appImage/x64 -o cursor.AppImage
        chmod +x cursor.AppImage
        sudo mv cursor.AppImage /usr/local/bin/cursor
    fi
    
    # Zed - High-performance, multiplayer code editor
    if ! command -v zed &> /dev/null; then
        curl -f https://zed.dev/install.sh | sh
    fi
    
    # Helix - Modern text editor
    if ! command -v hx &> /dev/null; then
        curl -L https://github.com/helix-editor/helix/releases/latest/download/helix-$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep tag_name | cut -d '"' -f 4)-x86_64-linux.tar.xz | tar xJ
        sudo mv helix-*/hx /usr/local/bin/
        sudo mv helix-*/runtime /usr/local/share/helix
    fi
    
    # Neovim - Hyperextensible Vim-based text editor
    if ! command -v nvim &> /dev/null; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        sudo mv nvim.appimage /usr/local/bin/nvim
    fi
    
    # Vim - The ubiquitous text editor
    if ! command -v vim &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y vim
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm vim
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y vim
        fi
    fi
    
    # Emacs - An extensible, customizable text editor
    if ! command -v emacs &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y emacs
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm emacs
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y emacs
        fi
    fi
    
    # Spacemacs - Emacs configuration
    if [ ! -d "$HOME/.emacs.d" ]; then
        git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    fi
    
    # Doom Emacs - Emacs configuration framework
    if [ ! -d "$HOME/.doom.d" ]; then
        git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
        ~/.emacs.d/bin/doom install
    fi
    
    # Sublime Text - Sophisticated text editor
    if ! command -v subl &> /dev/null; then
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        sudo apt-get update
        sudo apt-get install sublime-text
    fi
    
    # Atom - Hackable text editor (discontinued but still available)
    if ! command -v atom &> /dev/null; then
        curl -L https://github.com/atom/atom/releases/latest/download/atom-amd64.deb -o atom.deb
        sudo dpkg -i atom.deb
        sudo apt-get install -f
    fi
    
    # Pulsar - Community-led successor to Atom
    if ! command -v pulsar &> /dev/null; then
        curl -L https://github.com/pulsar-edit/pulsar/releases/latest/download/Linux.pulsar_$(curl -s https://api.github.com/repos/pulsar-edit/pulsar/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o pulsar.deb
        sudo dpkg -i pulsar.deb
    fi
    
    # Brackets - Modern text editor (discontinued)
    if ! command -v brackets &> /dev/null; then
        curl -L https://github.com/brackets-cont/brackets/releases/latest/download/Brackets.Release.$(curl -s https://api.github.com/repos/brackets-cont/brackets/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').64-bit.deb -o brackets.deb
        sudo dpkg -i brackets.deb
    fi
    
    # IntelliJ IDEA Community - Java IDE
    if ! command -v idea &> /dev/null; then
        curl -L https://download.jetbrains.com/idea/ideaIC-$(curl -s 'https://data.services.jetbrains.com/products/releases?code=IIC&latest=true&type=release' | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4).tar.gz | tar xz
        sudo mv idea-IC-* /opt/intellij-idea-community
        sudo ln -s /opt/intellij-idea-community/bin/idea.sh /usr/local/bin/idea
    fi
    
    # PyCharm Community - Python IDE
    if ! command -v pycharm &> /dev/null; then
        curl -L https://download.jetbrains.com/python/pycharm-community-$(curl -s 'https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release' | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4).tar.gz | tar xz
        sudo mv pycharm-community-* /opt/pycharm-community
        sudo ln -s /opt/pycharm-community/bin/pycharm.sh /usr/local/bin/pycharm
    fi
    
    # WebStorm - Web development IDE
    if ! command -v webstorm &> /dev/null; then
        curl -L https://download.jetbrains.com/webstorm/WebStorm-$(curl -s 'https://data.services.jetbrains.com/products/releases?code=WS&latest=true&type=release' | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4).tar.gz | tar xz
        sudo mv WebStorm-* /opt/webstorm
        sudo ln -s /opt/webstorm/bin/webstorm.sh /usr/local/bin/webstorm
    fi
    
    # Fleet - Next-generation IDE by JetBrains
    if ! command -v fleet &> /dev/null; then
        curl -L https://download.jetbrains.com/fleet/installers/linux_x64/Fleet-$(curl -s 'https://data.services.jetbrains.com/products/releases?code=FL&latest=true&type=release' | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4).tar.gz | tar xz
        sudo mv Fleet-* /opt/fleet
        sudo ln -s /opt/fleet/bin/Fleet /usr/local/bin/fleet
    fi
    
    # Android Studio - Android development IDE
    if ! command -v android-studio &> /dev/null; then
        curl -L https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.26/android-studio-2023.1.1.26-linux.tar.gz | tar xz
        sudo mv android-studio /opt/
        sudo ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
    fi
    
    # Eclipse - IDE for Java and other languages
    if ! command -v eclipse &> /dev/null; then
        curl -L https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2023-09/R/eclipse-java-2023-09-R-linux-gtk-x86_64.tar.gz -o eclipse.tar.gz
        tar xf eclipse.tar.gz
        sudo mv eclipse /opt/
        sudo ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse
    fi
    
    # NetBeans - IDE for Java, PHP, and more
    if ! command -v netbeans &> /dev/null; then
        curl -L https://archive.apache.org/dist/netbeans/netbeans/19/netbeans-19-bin.zip -o netbeans.zip
        unzip netbeans.zip
        sudo mv netbeans /opt/
        sudo ln -s /opt/netbeans/bin/netbeans /usr/local/bin/netbeans
    fi
    
    # Code::Blocks - C/C++ IDE
    if ! command -v codeblocks &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y codeblocks
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm codeblocks
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y codeblocks
        fi
    fi
    
    # Qt Creator - Cross-platform IDE
    if ! command -v qtcreator &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qtcreator
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm qtcreator
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qt-creator
        fi
    fi
    
    # KDevelop - Cross-platform IDE
    if ! command -v kdevelop &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y kdevelop
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm kdevelop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y kdevelop
        fi
    fi
    
    # Geany - Lightweight IDE
    if ! command -v geany &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y geany
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm geany
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y geany
        fi
    fi
    
    # Theia - Cloud & desktop IDE
    if ! command -v theia &> /dev/null; then
        npm install -g @theia/cli
    fi
    
    # GitPod Local - Local development environment
    if ! command -v gitpod-local &> /dev/null; then
        npm install -g @gitpod/local-app
    fi
    
    # Lapce - Lightning-fast and powerful code editor
    if ! command -v lapce &> /dev/null; then
        curl -L https://github.com/lapce/lapce/releases/latest/download/Lapce-linux.tar.gz | tar xz
        sudo mv lapce /usr/local/bin/
    fi
    
    # Xi Editor - Modern editor with a backend written in Rust
    if ! command -v xi-core &> /dev/null; then
        cargo install xi-editor
    fi
}

# Modern Collaboration Tools
install_modern_collaboration_tools() {
    echo_info "Installing modern collaboration tools..."
    
    # Discord - Voice and text chat
    if ! command -v discord &> /dev/null; then
        curl -L "https://discord.com/api/download?platform=linux&format=deb" -o discord.deb
        sudo dpkg -i discord.deb
        sudo apt-get install -f
    fi
    
    # Slack - Team communication
    if ! command -v slack &> /dev/null; then
        curl -L https://downloads.slack-edge.com/releases/linux/4.34.121/prod/x64/slack-desktop-4.34.121-amd64.deb -o slack.deb
        sudo dpkg -i slack.deb
        sudo apt-get install -f
    fi
    
    # Microsoft Teams - Team collaboration
    if ! command -v teams &> /dev/null; then
        curl -L https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.5.00.23861_amd64.deb -o teams.deb
        sudo dpkg -i teams.deb
        sudo apt-get install -f
    fi
    
    # Zoom - Video conferencing
    if ! command -v zoom &> /dev/null; then
        curl -L https://zoom.us/client/latest/zoom_amd64.deb -o zoom.deb
        sudo dpkg -i zoom.deb
        sudo apt-get install -f
    fi
    
    # Element - Matrix client
    if ! command -v element-desktop &> /dev/null; then
        curl -L https://packages.riot.im/debian/pool/main/e/element-desktop/element-desktop_1.11.46_amd64.deb -o element.deb
        sudo dpkg -i element.deb
        sudo apt-get install -f
    fi
    
    # Mattermost Desktop - Open source messaging
    if ! command -v mattermost-desktop &> /dev/null; then
        curl -L https://releases.mattermost.com/desktop/5.5.1/mattermost-desktop-5.5.1-linux-amd64.deb -o mattermost.deb
        sudo dpkg -i mattermost.deb
        sudo apt-get install -f
    fi
    
    # Telegram Desktop - Messaging app
    if ! command -v telegram-desktop &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y telegram-desktop
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm telegram-desktop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y telegram-desktop
        fi
    fi
    
    # Signal Desktop - Private messaging
    if ! command -v signal-desktop &> /dev/null; then
        wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
        cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
        sudo apt update && sudo apt install signal-desktop
    fi
    
    # WhatsApp Desktop (unofficial)
    if ! command -v whatsapp-desktop &> /dev/null; then
        curl -L https://github.com/eneshecan/whatsapp-for-linux/releases/latest/download/whatsapp-for-linux_$(curl -s https://api.github.com/repos/eneshecan/whatsapp-for-linux/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o whatsapp.deb
        sudo dpkg -i whatsapp.deb
        sudo apt-get install -f
    fi
    
    # Jitsi Meet Desktop - Video conferencing
    if ! command -v jitsi-meet &> /dev/null; then
        curl -L https://github.com/jitsi/jitsi-meet-electron/releases/latest/download/jitsi-meet-x86_64.AppImage -o jitsi-meet.AppImage
        chmod +x jitsi-meet.AppImage
        sudo mv jitsi-meet.AppImage /usr/local/bin/jitsi-meet
    fi
    
    # Notion Desktop - Workspace and notes
    if ! command -v notion-app &> /dev/null; then
        curl -L https://github.com/notion-enhancer/notion-repackaged/releases/latest/download/notion-app_$(curl -s https://api.github.com/repos/notion-enhancer/notion-repackaged/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o notion.deb
        sudo dpkg -i notion.deb
        sudo apt-get install -f
    fi
    
    # Obsidian - Knowledge management
    if ! command -v obsidian &> /dev/null; then
        curl -L https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian_$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o obsidian.deb
        sudo dpkg -i obsidian.deb
        sudo apt-get install -f
    fi
    
    # Logseq - Knowledge management
    if ! command -v logseq &> /dev/null; then
        curl -L https://github.com/logseq/logseq/releases/latest/download/Logseq-linux-x64-$(curl -s https://api.github.com/repos/logseq/logseq/releases/latest | grep tag_name | cut -d '"' -f 4).AppImage -o logseq.AppImage
        chmod +x logseq.AppImage
        sudo mv logseq.AppImage /usr/local/bin/logseq
    fi
    
    # Roam Research Desktop
    if ! command -v roam-research &> /dev/null; then
        curl -L https://github.com/roam-unofficial/roam-desktop/releases/latest/download/Roam-Research-$(curl -s https://api.github.com/repos/roam-unofficial/roam-desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux.AppImage -o roam.AppImage
        chmod +x roam.AppImage
        sudo mv roam.AppImage /usr/local/bin/roam-research
    fi
    
    # Zettlr - Markdown editor for academic writing
    if ! command -v zettlr &> /dev/null; then
        curl -L https://github.com/Zettlr/Zettlr/releases/latest/download/Zettlr-$(curl -s https://api.github.com/repos/Zettlr/Zettlr/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.appimage -o zettlr.AppImage
        chmod +x zettlr.AppImage
        sudo mv zettlr.AppImage /usr/local/bin/zettlr
    fi
    
    # Typora - Markdown editor
    if ! command -v typora &> /dev/null; then
        wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
        sudo add-apt-repository 'deb https://typora.io/linux ./'
        sudo apt update
        sudo apt install typora
    fi
    
    # Mark Text - Markdown editor
    if ! command -v marktext &> /dev/null; then
        curl -L https://github.com/marktext/marktext/releases/latest/download/marktext-x86_64.AppImage -o marktext.AppImage
        chmod +x marktext.AppImage
        sudo mv marktext.AppImage /usr/local/bin/marktext
    fi
    
    # Zulip - Team chat
    if ! command -v zulip &> /dev/null; then
        curl -L https://github.com/zulip/zulip-desktop/releases/latest/download/Zulip-$(curl -s https://api.github.com/repos/zulip/zulip-desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.AppImage -o zulip.AppImage
        chmod +x zulip.AppImage
        sudo mv zulip.AppImage /usr/local/bin/zulip
    fi
    
    # Rocket.Chat Desktop - Team communication
    if ! command -v rocketchat &> /dev/null; then
        curl -L https://github.com/RocketChat/Rocket.Chat.Electron/releases/latest/download/rocketchat-$(curl -s https://api.github.com/repos/RocketChat/Rocket.Chat.Electron/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.deb -o rocketchat.deb
        sudo dpkg -i rocketchat.deb
        sudo apt-get install -f
    fi
    
    # Franz - Multi-service messaging app
    if ! command -v franz &> /dev/null; then
        curl -L https://github.com/meetfranz/franz/releases/latest/download/franz_$(curl -s https://api.github.com/repos/meetfranz/franz/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o franz.deb
        sudo dpkg -i franz.deb
        sudo apt-get install -f
    fi
    
    # Ferdi - Multi-service messaging app
    if ! command -v ferdi &> /dev/null; then
        curl -L https://github.com/getferdi/ferdi/releases/latest/download/ferdi_$(curl -s https://api.github.com/repos/getferdi/ferdi/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o ferdi.deb
        sudo dpkg -i ferdi.deb
        sudo apt-get install -f
    fi
    
    # Ferdium - Multi-service messaging app
    if ! command -v ferdium &> /dev/null; then
        curl -L https://github.com/ferdium/ferdium-app/releases/latest/download/Ferdium-linux-$(curl -s https://api.github.com/repos/ferdium/ferdium-app/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-amd64.deb -o ferdium.deb
        sudo dpkg -i ferdium.deb
        sudo apt-get install -f
    fi
    
    # Rambox - Multi-service messaging app
    if ! command -v rambox &> /dev/null; then
        curl -L https://github.com/ramboxapp/community-edition/releases/latest/download/Rambox-$(curl -s https://api.github.com/repos/ramboxapp/community-edition/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x64.AppImage -o rambox.AppImage
        chmod +x rambox.AppImage
        sudo mv rambox.AppImage /usr/local/bin/rambox
    fi
    
    # Station - Multi-service app manager
    if ! command -v station &> /dev/null; then
        curl -L https://github.com/getstation/desktop-app/releases/latest/download/Station-$(curl -s https://api.github.com/repos/getstation/desktop-app/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.AppImage -o station.AppImage
        chmod +x station.AppImage
        sudo mv station.AppImage /usr/local/bin/station
    fi
    
    # Wavebox - Multi-account browser
    if ! command -v wavebox &> /dev/null; then
        curl -L https://download.wavebox.app/stable/linux/deb -o wavebox.deb
        sudo dpkg -i wavebox.deb
        sudo apt-get install -f
    fi
    
    # Shift - Multi-account browser
    if ! command -v shift &> /dev/null; then
        curl -L https://update.tryshift.com/download/linux -o shift.deb
        sudo dpkg -i shift.deb
        sudo apt-get install -f
    fi
}

# Modern Networking Tools
install_modern_networking_tools() {
    echo_info "Installing modern networking tools..."
    
    # Cloudflare WARP - VPN and DNS
    if ! command -v warp-cli &> /dev/null; then
        curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        sudo apt-get update && sudo apt-get install cloudflare-warp
    fi
    
    # Nebula - Overlay network tool
    if ! command -v nebula &> /dev/null; then
        curl -L https://github.com/slackhq/nebula/releases/latest/download/nebula-linux-amd64.tar.gz | tar xz
        sudo mv nebula /usr/local/bin/
        sudo mv nebula-cert /usr/local/bin/
    fi
    
    # ZeroTier - Network virtualization
    if ! command -v zerotier-cli &> /dev/null; then
        curl -s https://install.zerotier.com | sudo bash
    fi
    
    # Netmaker - WireGuard mesh network manager
    if ! command -v netmaker &> /dev/null; then
        curl -L https://github.com/gravitl/netmaker/releases/latest/download/netmaker-linux -o netmaker
        chmod +x netmaker
        sudo mv netmaker /usr/local/bin/
    fi
    
    # Headscale - Self-hosted Tailscale control server
    if ! command -v headscale &> /dev/null; then
        curl -L https://github.com/juanfont/headscale/releases/latest/download/headscale_$(curl -s https://api.github.com/repos/juanfont/headscale/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64 -o headscale
        chmod +x headscale
        sudo mv headscale /usr/local/bin/
    fi
    
    # Innernet - Private network system
    if ! command -v innernet &> /dev/null; then
        curl -L https://github.com/tonarino/innernet/releases/latest/download/innernet-$(curl -s https://api.github.com/repos/tonarino/innernet/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv innernet /usr/local/bin/
        sudo mv innernet-server /usr/local/bin/
    fi
    
    # Bore - Modern ngrok alternative
    if ! command -v bore &> /dev/null; then
        curl -L https://github.com/ekzhang/bore/releases/latest/download/bore-$(curl -s https://api.github.com/repos/ekzhang/bore/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv bore /usr/local/bin/
    fi
    
    # Rathole - Reverse proxy for NAT traversal
    if ! command -v rathole &> /dev/null; then
        curl -L https://github.com/rapiz1/rathole/releases/latest/download/rathole-x86_64-unknown-linux-musl.zip -o rathole.zip
        unzip rathole.zip
        sudo mv rathole /usr/local/bin/
    fi
    
    # Frp - Fast reverse proxy
    if ! command -v frpc &> /dev/null; then
        curl -L https://github.com/fatedier/frp/releases/latest/download/frp_$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv frp_*/frpc /usr/local/bin/
        sudo mv frp_*/frps /usr/local/bin/
    fi
    
    # Localtunnel - Expose localhost to the world
    if ! command -v lt &> /dev/null; then
        npm install -g localtunnel
    fi
    
    # Serveo - SSH tunnel service
    if ! command -v serveo &> /dev/null; then
        echo "Serveo is a service, use: ssh -R 80:localhost:3000 serveo.net"
    fi
    
    # Cloudflared - Cloudflare tunnel
    if ! command -v cloudflared &> /dev/null; then
        curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
        chmod +x cloudflared
        sudo mv cloudflared /usr/local/bin/
    fi
    
    # Ngrok - Secure tunnels to localhost
    if ! command -v ngrok &> /dev/null; then
        curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
        echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
        sudo apt update && sudo apt install ngrok
    fi
    
    # Pagekite - Web tunneling solution
    if ! command -v pagekite &> /dev/null; then
        pip install pagekite
    fi
    
    # Zrok - Private sharing
    if ! command -v zrok &> /dev/null; then
        curl -L https://github.com/openziti/zrok/releases/latest/download/zrok_$(curl -s https://api.github.com/repos/openziti/zrok/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv zrok /usr/local/bin/
    fi
    
    # Teleport - Modern SSH connectivity
    if ! command -v tsh &> /dev/null; then
        curl -L https://get.gravitational.com/teleport-$(curl -s https://api.github.com/repos/gravitational/teleport/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64-bin.tar.gz | tar xz
        sudo mv teleport/tsh /usr/local/bin/
        sudo mv teleport/tctl /usr/local/bin/
        sudo mv teleport/teleport /usr/local/bin/
    fi
    
    # Boundary - Secure remote access
    if ! command -v boundary &> /dev/null; then
        curl -L https://releases.hashicorp.com/boundary/$(curl -s https://api.github.com/repos/hashicorp/boundary/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')/boundary_$(curl -s https://api.github.com/repos/hashicorp/boundary/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.zip -o boundary.zip
        unzip boundary.zip
        sudo mv boundary /usr/local/bin/
    fi
    
    # Step CLI - Certificate management
    if ! command -v step &> /dev/null; then
        curl -L https://github.com/smallstep/cli/releases/latest/download/step_linux_$(curl -s https://api.github.com/repos/smallstep/cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.tar.gz | tar xz
        sudo mv step_*/bin/step /usr/local/bin/
    fi
    
    # Step CA - Certificate authority
    if ! command -v step-ca &> /dev/null; then
        curl -L https://github.com/smallstep/certificates/releases/latest/download/step-ca_linux_$(curl -s https://api.github.com/repos/smallstep/certificates/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.tar.gz | tar xz
        sudo mv step-ca_*/bin/step-ca /usr/local/bin/
    fi
    
    # WireGuard - Modern VPN
    if ! command -v wg &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wireguard
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wireguard-tools
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wireguard-tools
        fi
    fi
    
    # WireGuard UI - Web interface for WireGuard
    if ! command -v wireguard-ui &> /dev/null; then
        curl -L https://github.com/ngoduykhanh/wireguard-ui/releases/latest/download/wireguard-ui-$(curl -s https://api.github.com/repos/ngoduykhanh/wireguard-ui/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv wireguard-ui /usr/local/bin/
    fi
    
    # OpenVPN - VPN solution
    if ! command -v openvpn &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openvpn
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openvpn
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openvpn
        fi
    fi
    
    # SoftEther VPN - Multi-protocol VPN
    if ! command -v vpncmd &> /dev/null; then
        curl -L https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest/download/softether-vpnserver-$(curl -s https://api.github.com/repos/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x64-64bit.tar.gz | tar xz
        cd vpnserver && sudo make
        sudo mv vpnserver /opt/
        sudo ln -s /opt/vpnserver/vpncmd /usr/local/bin/vpncmd
    fi
    
    # Pritunl - Enterprise VPN server
    if ! command -v pritunl &> /dev/null; then
        echo "deb https://repo.pritunl.com/stable/apt jammy main" | sudo tee /etc/apt/sources.list.d/pritunl.list
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        sudo apt-get update
        sudo apt-get install pritunl
    fi
}

# Modern Automation Tools
install_modern_automation_tools() {
    echo_info "Installing modern automation tools..."
    
    # n8n - Workflow automation
    if ! command -v n8n &> /dev/null; then
        npm install -g n8n
    fi
    
    # NodeRED - Flow-based programming
    if ! command -v node-red &> /dev/null; then
        npm install -g --unsafe-perm node-red
    fi
    
    # Zapier CLI - Automation platform
    if ! command -v zapier &> /dev/null; then
        npm install -g zapier-platform-cli
    fi
    
    # Automate - Desktop automation
    if ! command -v automate &> /dev/null; then
        pip install automate
    fi
    
    # Robot Framework - Generic automation framework
    if ! command -v robot &> /dev/null; then
        pip install robotframework
    fi
    
    # Selenium - Web browser automation
    if ! pip show selenium &> /dev/null; then
        pip install selenium
    fi
    
    # Playwright - Web automation
    if ! pip show playwright &> /dev/null; then
        pip install playwright
        playwright install
    fi
    
    # Pyautogui - Python automation
    if ! pip show pyautogui &> /dev/null; then
        pip install pyautogui
    fi
    
    # Xdotool - X11 automation
    if ! command -v xdotool &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y xdotool
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm xdotool
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xdotool
        fi
    fi
    
    # Xvfb - Virtual framebuffer
    if ! command -v xvfb-run &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y xvfb
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm xorg-server-xvfb
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xorg-x11-server-Xvfb
        fi
    fi
    
    # Espanso - Text expander
    if ! command -v espanso &> /dev/null; then
        curl -L https://github.com/espanso/espanso/releases/latest/download/espanso-debian-x11-amd64.deb -o espanso.deb
        sudo dpkg -i espanso.deb
        sudo apt-get install -f
    fi
    
    # AutoKey - Desktop automation utility
    if ! command -v autokey &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y autokey-gtk
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm autokey
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y autokey
        fi
    fi
    
    # Actiona - Task automation tool
    if ! command -v actiona &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y actiona
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm actiona
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y actiona
        fi
    fi
    
    # Huginn - Data agent platform
    if ! command -v huginn &> /dev/null; then
        gem install huginn
    fi
    
    # Home Assistant CLI - Smart home automation
    if ! command -v hass &> /dev/null; then
        pip install homeassistant
    fi
    
    # OpenHAB CLI - Smart home platform
    if ! command -v openhab-cli &> /dev/null; then
        curl -L https://github.com/openhab/openhab-distro/releases/latest/download/openhab-$(curl -s https://api.github.com/repos/openhab/openhab-distro/releases/latest | grep tag_name | cut -d '"' -f 4).tar.gz | tar xz
        sudo mv openhab /opt/
        sudo ln -s /opt/openhab/runtime/bin/client /usr/local/bin/openhab-cli
    fi
    
    # Node.js automation tools
    if command -v npm &> /dev/null; then
        npm install -g automation-cli
        npm install -g auto-cli
        npm install -g flow-cli
    fi
    
    # IFTTT CLI equivalent
    if ! pip show ifttt &> /dev/null; then
        pip install ifttt
    fi
    
    # Microsoft Power Automate CLI
    if ! command -v pac &> /dev/null; then
        npm install -g @microsoft/powerplatform-cli
    fi
    
    # Zapier CLI Alternative - Integromat/Make
    if ! npm list -g make-cli &> /dev/null; then
        npm install -g make-cli
    fi
    
    # Automation testing tools
    if ! pip show behave &> /dev/null; then
        pip install behave
    fi
    
    if ! pip show pytest-bdd &> /dev/null; then
        pip install pytest-bdd
    fi
    
    if ! npm list -g cucumber &> /dev/null; then
        npm install -g @cucumber/cucumber
    fi
    
    # Task scheduling tools
    if ! command -v crontab &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y cron
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm cronie
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y cronie
        fi
    fi
    
    # at - Job scheduling
    if ! command -v at &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y at
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm at
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y at
        fi
    fi
}

# Modern Content Creation and Streaming Tools
install_modern_content_creation_tools() {
    echo_info "Installing modern content creation and streaming tools..."
    
    # OBS Studio - Live streaming and recording
    if ! command -v obs &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:obsproject/obs-studio -y
            sudo apt-get update
            sudo apt-get install -y obs-studio
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm obs-studio
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y obs-studio
        fi
    fi
    
    # Streamlabs Desktop - Live streaming
    if ! command -v streamlabs &> /dev/null; then
        curl -L https://github.com/stream-labs/desktop/releases/latest/download/Streamlabs-Desktop-$(curl -s https://api.github.com/repos/stream-labs/desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux.AppImage -o streamlabs.AppImage
        chmod +x streamlabs.AppImage
        sudo mv streamlabs.AppImage /usr/local/bin/streamlabs
    fi
    
    # Restream Studio - Multi-platform streaming
    if ! command -v restream &> /dev/null; then
        curl -L https://github.com/restream/studio/releases/latest/download/Restream-Studio-$(curl -s https://api.github.com/repos/restream/studio/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux.AppImage -o restream.AppImage
        chmod +x restream.AppImage
        sudo mv restream.AppImage /usr/local/bin/restream
    fi
    
    # Lightworks - Professional video editor
    if ! command -v lightworks &> /dev/null; then
        curl -L https://www.lwks.com/dmpub/lwks-14.6.0-amd64.deb -o lightworks.deb
        sudo dpkg -i lightworks.deb
        sudo apt-get install -f
    fi
    
    # DaVinci Resolve - Professional video editor
    if ! command -v resolve &> /dev/null; then
        echo "DaVinci Resolve requires manual download from BlackMagic Design"
    fi
    
    # Kdenlive - Video editor
    if ! command -v kdenlive &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y kdenlive
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm kdenlive
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y kdenlive
        fi
    fi
    
    # OpenShot - Video editor
    if ! command -v openshot-qt &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openshot-qt
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openshot
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openshot
        fi
    fi
    
    # Shotcut - Video editor
    if ! command -v shotcut &> /dev/null; then
        curl -L https://github.com/mltframework/shotcut/releases/latest/download/shotcut-linux-x86_64-$(curl -s https://api.github.com/repos/mltframework/shotcut/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').txz | tar xJ
        sudo mv Shotcut.app /opt/shotcut
        sudo ln -s /opt/shotcut/shotcut /usr/local/bin/shotcut
    fi
    
    # Blender - 3D creation suite
    if ! command -v blender &> /dev/null; then
        curl -L https://download.blender.org/release/Blender$(curl -s https://download.blender.org/release/ | grep -o 'Blender[0-9]\+\.[0-9]\+' | tail -1 | sed 's/Blender//')/blender-$(curl -s https://download.blender.org/release/ | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | tail -1)-linux-x64.tar.xz | tar xJ
        sudo mv blender-*/ /opt/blender
        sudo ln -s /opt/blender/blender /usr/local/bin/blender
    fi
    
    # GIMP - Image editor
    if ! command -v gimp &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gimp
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gimp
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gimp
        fi
    fi
    
    # Krita - Digital painting
    if ! command -v krita &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y krita
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm krita
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y krita
        fi
    fi
    
    # Inkscape - Vector graphics editor
    if ! command -v inkscape &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y inkscape
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm inkscape
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y inkscape
        fi
    fi
    
    # Audacity - Audio editor
    if ! command -v audacity &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y audacity
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm audacity
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y audacity
        fi
    fi
    
    # Reaper - Digital audio workstation
    if ! command -v reaper &> /dev/null; then
        curl -L https://www.reaper.fm/files/6.x/reaper682_linux_x86_64.tar.xz | tar xJ
        sudo mv reaper_linux_x86_64 /opt/reaper
        sudo ln -s /opt/reaper/REAPER/reaper /usr/local/bin/reaper
    fi
    
    # Ardour - Digital audio workstation
    if ! command -v ardour &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ardour
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ardour
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ardour
        fi
    fi
    
    # LMMS - Digital audio workstation
    if ! command -v lmms &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y lmms
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lmms
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lmms
        fi
    fi
    
    # FFmpeg - Multimedia framework
    if ! command -v ffmpeg &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ffmpeg
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ffmpeg
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ffmpeg
        fi
    fi
    
    # ImageMagick - Image manipulation
    if ! command -v convert &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y imagemagick
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm imagemagick
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ImageMagick
        fi
    fi
    
    # Handbrake - Video transcoder
    if ! command -v handbrake &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y handbrake
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm handbrake
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y HandBrake-gui
        fi
    fi
    
    # VLC - Media player
    if ! command -v vlc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y vlc
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm vlc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y vlc
        fi
    fi
    
    # MPV - Media player
    if ! command -v mpv &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mpv
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mpv
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mpv
        fi
    fi
    
    # Screenkey - Screencast key display
    if ! command -v screenkey &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y screenkey
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm screenkey
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y screenkey
        fi
    fi
    
    # Key-mon - Keyboard and mouse status monitor
    if ! command -v key-mon &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y key-mon
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm key-mon
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y key-mon
        fi
    fi
    
    # SimpleScreenRecorder - Screen recording
    if ! command -v simplescreenrecorder &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y simplescreenrecorder
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm simplescreenrecorder
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y simplescreenrecorder
        fi
    fi
    
    # Green Recorder - Screen recording
    if ! command -v green-recorder &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:fossproject/ppa -y
            sudo apt-get update
            sudo apt-get install -y green-recorder
        fi
    fi
    
    # Peek - GIF recorder
    if ! command -v peek &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:peek-developers/stable -y
            sudo apt-get update
            sudo apt-get install -y peek
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm peek
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y peek
        fi
    fi
    
    # Flameshot - Screenshot tool
    if ! command -v flameshot &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y flameshot
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm flameshot
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y flameshot
        fi
    fi
    
    # Spectacle - Screenshot tool (KDE)
    if ! command -v spectacle &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y spectacle
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm spectacle
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y spectacle
        fi
    fi
    
    # Shutter - Screenshot tool
    if ! command -v shutter &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y shutter
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm shutter
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y shutter
        fi
    fi
    
    # Kazam - Screen recording
    if ! command -v kazam &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y kazam
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm kazam
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y kazam
        fi
    fi
    
    # Vokoscreen - Screen recording
    if ! command -v vokoscreen &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y vokoscreen
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm vokoscreen
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y vokoscreen
        fi
    fi
    
    # OBS Ninja - Browser-based live streaming
    echo "OBS Ninja is browser-based: https://obs.ninja"
    
    # Streamyard - Browser-based streaming studio
    echo "Streamyard is browser-based: https://streamyard.com"
    
    # Riverside.fm - Remote recording studio
    echo "Riverside.fm is browser-based: https://riverside.fm"
    
    # Descript - Audio/video editing
    echo "Descript requires manual download: https://www.descript.com"
}

# Modern Game Development Tools
install_modern_game_dev_tools() {
    echo_info "Installing modern game development tools..."
    
    # Unity Hub - Unity game engine
    if ! command -v unity-hub &> /dev/null; then
        curl -L https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage -o unity-hub.AppImage
        chmod +x unity-hub.AppImage
        sudo mv unity-hub.AppImage /usr/local/bin/unity-hub
    fi
    
    # Unreal Engine - Epic Games engine (requires manual install)
    echo "Unreal Engine requires Epic Games Launcher or manual compilation"
    
    # Godot - Open source game engine
    if ! command -v godot &> /dev/null; then
        curl -L https://downloads.tuxfamily.org/godotengine/$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep tag_name | cut -d '"' -f 4)/Godot_v$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep tag_name | cut -d '"' -f 4)_linux.x86_64.zip -o godot.zip
        unzip godot.zip
        sudo mv Godot_* /usr/local/bin/godot
    fi
    
    # Defold - Game engine
    if ! command -v defold &> /dev/null; then
        curl -L https://github.com/defold/defold/releases/latest/download/Defold-x86_64-linux.zip -o defold.zip
        unzip defold.zip
        sudo mv Defold /usr/local/bin/defold
    fi
    
    # Construct 3 - Browser-based game engine
    echo "Construct 3 is browser-based: https://www.construct.net"
    
    # GameMaker Studio - Game development IDE
    echo "GameMaker Studio requires manual download from YoYo Games"
    
    # Ren'Py - Visual novel engine
    if ! command -v renpy &> /dev/null; then
        curl -L https://www.renpy.org/dl/8.1.3/renpy-8.1.3-sdk.tar.bz2 | tar xj
        sudo mv renpy-8.1.3-sdk /opt/renpy
        sudo ln -s /opt/renpy/renpy.sh /usr/local/bin/renpy
    fi
    
    # Love2D - 2D game framework
    if ! command -v love &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y love
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm love
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y love
        fi
    fi
    
    # MonoGame - Cross-platform gaming framework
    if ! command -v monogame &> /dev/null; then
        dotnet tool install -g MonoGame.Content.Builder.Task
    fi
    
    # Cocos2d-x - Game engine
    if ! command -v cocos &> /dev/null; then
        curl -L https://github.com/cocos2d/cocos2d-x/releases/latest/download/cocos2d-x-$(curl -s https://api.github.com/repos/cocos2d/cocos2d-x/releases/latest | grep tag_name | cut -d '"' -f 4).zip -o cocos2d.zip
        unzip cocos2d.zip
        sudo mv cocos2d-x-* /opt/cocos2d-x
        sudo ln -s /opt/cocos2d-x/tools/cocos2d-console/bin/cocos.py /usr/local/bin/cocos
    fi
    
    # Bevy - Rust game engine
    if command -v cargo &> /dev/null; then
        cargo install bevy-cli
    fi
    
    # Amethyst - Data-driven game engine
    if command -v cargo &> /dev/null; then
        cargo install amethyst_tools
    fi
    
    # Panda3D - Game engine
    if ! pip show panda3d &> /dev/null; then
        pip install panda3d
    fi
    
    # Pygame - Python game library
    if ! pip show pygame &> /dev/null; then
        pip install pygame
    fi
    
    # Arcade - Python game library
    if ! pip show arcade &> /dev/null; then
        pip install arcade
    fi
    
    # Pyxel - Retro game engine
    if ! pip show pyxel &> /dev/null; then
        pip install pyxel
    fi
    
    # Processing - Creative coding environment
    if ! command -v processing &> /dev/null; then
        curl -L https://github.com/processing/processing4/releases/latest/download/processing-4.3-linux-x64.tgz | tar xz
        sudo mv processing-4.3 /opt/processing
        sudo ln -s /opt/processing/processing /usr/local/bin/processing
    fi
    
    # p5.js - JavaScript creative coding
    if ! npm list -g p5-manager &> /dev/null; then
        npm install -g p5-manager
    fi
    
    # Three.js - JavaScript 3D library
    if ! npm list -g three &> /dev/null; then
        npm install -g three
    fi
    
    # Babylon.js - JavaScript 3D engine
    if ! npm list -g babylonjs &> /dev/null; then
        npm install -g babylonjs
    fi
    
    # PlayCanvas - Web game engine
    echo "PlayCanvas is browser-based: https://playcanvas.com"
    
    # Solar2D - Cross-platform game engine
    if ! command -v solar2d &> /dev/null; then
        curl -L https://github.com/coronalabs/corona/releases/latest/download/Solar2DInstaller-linux.tar.gz | tar xz
        sudo mv Solar2DInstaller /opt/solar2d
        sudo ln -s /opt/solar2d/Solar2D /usr/local/bin/solar2d
    fi
    
    # GDevelop - Visual game creator
    if ! command -v gdevelop &> /dev/null; then
        curl -L https://github.com/4ian/GDevelop/releases/latest/download/GDevelop-5-Setup-$(curl -s https://api.github.com/repos/4ian/GDevelop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.AppImage -o gdevelop.AppImage
        chmod +x gdevelop.AppImage
        sudo mv gdevelop.AppImage /usr/local/bin/gdevelop
    fi
    
    # Tiled - 2D level editor
    if ! command -v tiled &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y tiled
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tiled
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tiled
        fi
    fi
    
    # LDTK - Level editor
    if ! command -v ldtk &> /dev/null; then
        curl -L https://github.com/deepnight/ldtk/releases/latest/download/LDtk-$(curl -s https://api.github.com/repos/deepnight/ldtk/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-installer-linux.AppImage -o ldtk.AppImage
        chmod +x ldtk.AppImage
        sudo mv ldtk.AppImage /usr/local/bin/ldtk
    fi
    
    # Aseprite - Pixel art tool
    echo "Aseprite requires purchase or manual compilation"
    
    # LibreSprite - Free Aseprite alternative
    if ! command -v libresprite &> /dev/null; then
        curl -L https://github.com/LibreSprite/LibreSprite/releases/latest/download/LibreSprite-x86_64.AppImage -o libresprite.AppImage
        chmod +x libresprite.AppImage
        sudo mv libresprite.AppImage /usr/local/bin/libresprite
    fi
    
    # Piskel - Online pixel art tool
    echo "Piskel is browser-based: https://www.piskelapp.com"
    
    # Pixelorama - Pixel art editor
    if ! command -v pixelorama &> /dev/null; then
        curl -L https://github.com/Orama-Interactive/Pixelorama/releases/latest/download/Pixelorama.x86_64 -o pixelorama
        chmod +x pixelorama
        sudo mv pixelorama /usr/local/bin/pixelorama
    fi
    
    # GIMP - Image editing (already covered in content creation)
    
    # Audacity - Audio editing (already covered in content creation)
    
    # FMOD Studio - Audio middleware
    echo "FMOD Studio requires manual download from FMOD"
    
    # Wwise - Audio engine
    echo "Wwise requires manual download from AudioKinetic"
    
    # OpenAL - Audio library
    if ! command -v openal-info &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y libopenal-dev openal-info
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openal
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openal-soft-devel
        fi
    fi
    
    # SDL2 - Multimedia library
    if ! command -v sdl2-config &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y libsdl2-dev
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sdl2
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y SDL2-devel
        fi
    fi
    
    # SFML - Multimedia library
    if ! command -v sfml &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y libsfml-dev
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sfml
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y SFML-devel
        fi
    fi
    
    # Allegro - Game programming library
    if ! command -v allegro-config &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y liballegro5-dev
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm allegro
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y allegro5-devel
        fi
    fi
}

# Modern Embedded and IoT Development Tools
install_modern_embedded_iot_tools() {
    echo_info "Installing modern embedded and IoT development tools..."
    
    # PlatformIO - Embedded development platform
    if ! command -v pio &> /dev/null; then
        pip install platformio
    fi
    
    # Arduino CLI - Arduino command line interface
    if ! command -v arduino-cli &> /dev/null; then
        curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
        sudo mv bin/arduino-cli /usr/local/bin/
    fi
    
    # Arduino IDE 2.0
    if ! command -v arduino-ide &> /dev/null; then
        curl -L https://downloads.arduino.cc/arduino-ide/arduino-ide_$(curl -s https://api.github.com/repos/arduino/arduino-ide/releases/latest | grep tag_name | cut -d '"' -f 4)_Linux_64bit.AppImage -o arduino-ide.AppImage
        chmod +x arduino-ide.AppImage
        sudo mv arduino-ide.AppImage /usr/local/bin/arduino-ide
    fi
    
    # ESP-IDF - Espressif IoT Development Framework
    if ! command -v idf.py &> /dev/null; then
        git clone --recursive https://github.com/espressif/esp-idf.git /opt/esp-idf
        /opt/esp-idf/install.sh
        echo 'alias get_idf=". /opt/esp-idf/export.sh"' >> ~/.bashrc
    fi
    
    # Zephyr - Real-time operating system
    if ! command -v west &> /dev/null; then
        pip install west
        west init ~/zephyrproject
        cd ~/zephyrproject
        west update
        west zephyr-export
        pip install -r ~/zephyrproject/zephyr/scripts/requirements.txt
    fi
    
    # Mbed CLI - ARM Mbed development
    if ! command -v mbed &> /dev/null; then
        pip install mbed-cli
    fi
    
    # Raspberry Pi Imager - SD card imaging
    if ! command -v rpi-imager &> /dev/null; then
        curl -L https://downloads.raspberrypi.org/imager/imager_latest_amd64.deb -o rpi-imager.deb
        sudo dpkg -i rpi-imager.deb
        sudo apt-get install -f
    fi
    
    # Balena CLI - Container-based IoT
    if ! command -v balena &> /dev/null; then
        curl -L https://github.com/balena-io/balena-cli/releases/latest/download/balena-cli-$(curl -s https://api.github.com/repos/balena-io/balena-cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x64-standalone.zip -o balena-cli.zip
        unzip balena-cli.zip
        sudo mv balena-cli /opt/
        sudo ln -s /opt/balena-cli/balena /usr/local/bin/balena
    fi
    
    # Balena Etcher - SD card flasher
    if ! command -v balena-etcher &> /dev/null; then
        curl -L https://github.com/balena-io/etcher/releases/latest/download/balena-etcher-electron-$(curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x64.zip -o etcher.zip
        unzip etcher.zip
        sudo mv balena-etcher-electron-* /opt/balena-etcher
        sudo ln -s /opt/balena-etcher/balena-etcher-electron /usr/local/bin/balena-etcher
    fi
    
    # Micropython - Python for microcontrollers
    if ! pip show micropython &> /dev/null; then
        pip install micropython-stubs
    fi
    
    # CircuitPython - Adafruit's Python for microcontrollers
    if ! pip show circuitpython &> /dev/null; then
        pip install circuitpython-stubs
    fi
    
    # Esptool - ESP32/ESP8266 flashing tool
    if ! command -v esptool.py &> /dev/null; then
        pip install esptool
    fi
    
    # STM32CubeMX - STM32 configuration tool
    echo "STM32CubeMX requires manual download from STMicroelectronics"
    
    # STM32CubeIDE - STM32 development environment
    echo "STM32CubeIDE requires manual download from STMicroelectronics"
    
    # OpenOCD - On-chip debugger
    if ! command -v openocd &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openocd
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openocd
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openocd
        fi
    fi
    
    # GDB - GNU Debugger (for embedded debugging)
    if ! command -v arm-none-eabi-gdb &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gdb-arm-none-eabi
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm arm-none-eabi-gdb
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y arm-none-eabi-gdb
        fi
    fi
    
    # ARM GNU Toolchain
    if ! command -v arm-none-eabi-gcc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gcc-arm-none-eabi
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm arm-none-eabi-gcc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y arm-none-eabi-gcc-cs
        fi
    fi
    
    # SEGGER J-Link tools
    echo "SEGGER J-Link tools require manual download from SEGGER"
    
    # Black Magic Probe tools
    if ! command -v blackmagic &> /dev/null; then
        git clone https://github.com/blacksphere/blackmagic.git /tmp/blackmagic
        cd /tmp/blackmagic && make
        sudo make install
    fi
    
    # PuTTY - Serial terminal
    if ! command -v putty &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y putty
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm putty
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y putty
        fi
    fi
    
    # Minicom - Serial communication
    if ! command -v minicom &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y minicom
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm minicom
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y minicom
        fi
    fi
    
    # Screen - Terminal multiplexer for serial
    if ! command -v screen &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y screen
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm screen
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y screen
        fi
    fi
    
    # Picocom - Minimal dumb-terminal emulation
    if ! command -v picocom &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y picocom
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm picocom
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y picocom
        fi
    fi
    
    # CubeMX2Makefile - Generate Makefiles from CubeMX
    if ! command -v cubemx2makefile &> /dev/null; then
        pip install cubemx2makefile
    fi
    
    # FreeRTOS tools
    echo "FreeRTOS tools available at: https://www.freertos.org/"
    
    # Contiki-NG - OS for IoT devices
    if [ ! -d "/opt/contiki-ng" ]; then
        git clone https://github.com/contiki-ng/contiki-ng.git /opt/contiki-ng
        cd /opt/contiki-ng && git submodule update --init --recursive
    fi
    
    # TinyGo - Go for microcontrollers
    if ! command -v tinygo &> /dev/null; then
        curl -L https://github.com/tinygo-org/tinygo/releases/latest/download/tinygo$(curl -s https://api.github.com/repos/tinygo-org/tinygo/releases/latest | grep tag_name | cut -d '"' -f 4).linux-amd64.tar.gz | tar xz
        sudo mv tinygo /opt/
        sudo ln -s /opt/tinygo/bin/tinygo /usr/local/bin/tinygo
    fi
    
    # Rust embedded tools
    if command -v cargo &> /dev/null; then
        rustup target add thumbv7em-none-eabihf
        cargo install cargo-binutils
        cargo install cargo-generate
        cargo install cargo-embed
        cargo install probe-run
    fi
    
    # Embassy - Rust embedded framework
    if command -v cargo &> /dev/null; then
        cargo install embassy-cli
    fi
    
    # Node-RED - IoT flow programming
    if ! command -v node-red &> /dev/null; then
        npm install -g --unsafe-perm node-red
    fi
    
    # MQTT CLI tools
    if ! command -v mosquitto_pub &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mosquitto-clients
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mosquitto
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mosquitto
        fi
    fi
    
    # MQTT X - MQTT client
    if ! command -v mqttx &> /dev/null; then
        curl -L https://github.com/emqx/MQTTX/releases/latest/download/MQTTX-$(curl -s https://api.github.com/repos/emqx/MQTTX/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.AppImage -o mqttx.AppImage
        chmod +x mqttx.AppImage
        sudo mv mqttx.AppImage /usr/local/bin/mqttx
    fi
    
    # Mongoose OS - IoT firmware development
    if ! command -v mos &> /dev/null; then
        curl -fsSL https://mongoose-os.com/downloads/mos/install.sh | /bin/bash
    fi
    
    # Kconfig tools - Kernel configuration
    if ! command -v kconfig-conf &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y kconfig-frontends
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm kconfig-frontends
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y kconfig-frontends
        fi
    fi
    
    # Device Tree Compiler
    if ! command -v dtc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y device-tree-compiler
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm dtc
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y dtc
        fi
    fi
    
    # U-Boot tools
    if ! command -v mkimage &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y u-boot-tools
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm uboot-tools
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y uboot-tools
        fi
    fi
}

# Modern Virtualization and Container Tools  
install_modern_virtualization_tools() {
    echo_info "Installing modern virtualization and container tools..."
    
    # Podman Desktop - Container management GUI
    if ! command -v podman-desktop &> /dev/null; then
        curl -L https://github.com/containers/podman-desktop/releases/latest/download/podman-desktop-$(curl -s https://api.github.com/repos/containers/podman-desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.AppImage -o podman-desktop.AppImage
        chmod +x podman-desktop.AppImage
        sudo mv podman-desktop.AppImage /usr/local/bin/podman-desktop
    fi
    
    # Rancher Desktop - Kubernetes and container management
    if ! command -v rancher-desktop &> /dev/null; then
        curl -L https://github.com/rancher-sandbox/rancher-desktop/releases/latest/download/rancher-desktop-$(curl -s https://api.github.com/repos/rancher-sandbox/rancher-desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.AppImage -o rancher-desktop.AppImage
        chmod +x rancher-desktop.AppImage
        sudo mv rancher-desktop.AppImage /usr/local/bin/rancher-desktop
    fi
    
    # OrbStack - Fast, light, simple Docker Desktop alternative
    if ! command -v orbstack &> /dev/null; then
        curl -fsSL https://get.orbstack.dev | bash
    fi
    
    # Finch - Open source container development tool
    if ! command -v finch &> /dev/null; then
        curl -L https://github.com/runfinch/finch/releases/latest/download/Finch-$(curl -s https://api.github.com/repos/runfinch/finch/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.AppImage -o finch.AppImage
        chmod +x finch.AppImage
        sudo mv finch.AppImage /usr/local/bin/finch
    fi
    
    # nerdctl - Docker-compatible CLI for containerd
    if ! command -v nerdctl &> /dev/null; then
        curl -L https://github.com/containerd/nerdctl/releases/latest/download/nerdctl-$(curl -s https://api.github.com/repos/containerd/nerdctl/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv nerdctl /usr/local/bin/
    fi
    
    # Lima - Linux VMs for macOS (also useful on Linux)
    if ! command -v limactl &> /dev/null; then
        curl -L https://github.com/lima-vm/lima/releases/latest/download/lima-$(curl -s https://api.github.com/repos/lima-vm/lima/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-Linux-x86_64.tar.gz | tar xz
        sudo mv lima-*/bin/* /usr/local/bin/
    fi
    
    # Colima - Container runtimes on macOS/Linux
    if ! command -v colima &> /dev/null; then
        curl -L https://github.com/abiosoft/colima/releases/latest/download/colima-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/') -o colima
        chmod +x colima
        sudo mv colima /usr/local/bin/
    fi
    
    # Containerd - Container runtime
    if ! command -v containerd &> /dev/null; then
        curl -L https://github.com/containerd/containerd/releases/latest/download/containerd-$(curl -s https://api.github.com/repos/containerd/containerd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv bin/* /usr/local/bin/
    fi
    
    # CRI-O - Container runtime interface
    if ! command -v crio &> /dev/null; then
        curl -L https://storage.googleapis.com/cri-o/artifacts/cri-o.amd64.$(curl -s https://api.github.com/repos/cri-o/cri-o/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').tar.gz | tar xz
        sudo mv cri-o/bin/* /usr/local/bin/
    fi
    
    # runc - CLI tool for spawning containers
    if ! command -v runc &> /dev/null; then
        curl -L https://github.com/opencontainers/runc/releases/latest/download/runc.amd64 -o runc
        chmod +x runc
        sudo mv runc /usr/local/bin/
    fi
    
    # crun - Fast and low-memory footprint container runtime
    if ! command -v crun &> /dev/null; then
        curl -L https://github.com/containers/crun/releases/latest/download/crun-$(curl -s https://api.github.com/repos/containers/crun/releases/latest | grep tag_name | cut -d '"' -f 4)-linux-amd64 -o crun
        chmod +x crun
        sudo mv crun /usr/local/bin/
    fi
    
    # Skopeo - Work with container images and image repositories
    if ! command -v skopeo &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y skopeo
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm skopeo
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y skopeo
        fi
    fi
    
    # Crane - Tool for interacting with remote images and registries
    if ! command -v crane &> /dev/null; then
        go install github.com/google/go-containerregistry/cmd/crane@latest
    fi
    
    # Reg - Docker registry v2 command line client
    if ! command -v reg &> /dev/null; then
        curl -L https://github.com/genuinetools/reg/releases/latest/download/reg-linux-amd64 -o reg
        chmod +x reg
        sudo mv reg /usr/local/bin/
    fi
    
    # Docker Buildx - Extended build capabilities
    if command -v docker &> /dev/null; then
        mkdir -p ~/.docker/cli-plugins
        curl -L https://github.com/docker/buildx/releases/latest/download/buildx-$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
        chmod +x ~/.docker/cli-plugins/docker-buildx
    fi
    
    # Docker Scout - Security analysis
    if command -v docker &> /dev/null; then
        curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh -s --
    fi
    
    # Hadolint - Dockerfile linter
    if ! command -v hadolint &> /dev/null; then
        curl -L https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64 -o hadolint
        chmod +x hadolint
        sudo mv hadolint /usr/local/bin/
    fi
    
    # Dockerfile-language-server - LSP for Dockerfiles
    if ! npm list -g dockerfile-language-server-nodejs &> /dev/null; then
        npm install -g dockerfile-language-server-nodejs
    fi
    
    # Distrobox - Use any Linux distribution inside your terminal
    if ! command -v distrobox &> /dev/null; then
        curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
    fi
    
    # Toolbox - Tool for Linux operating system containers
    if ! command -v toolbox &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y toolbox
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm toolbox
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y toolbox
        fi
    fi
    
    # LXC/LXD - System containers
    if ! command -v lxc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y lxc lxd
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm lxc lxd
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y lxc lxd
        fi
    fi
    
    # Incus - Community fork of LXD
    if ! command -v incus &> /dev/null; then
        curl -fsSL https://pkgs.zabbly.com/key.asc | sudo gpg --dearmor -o /etc/apt/keyrings/zabbly.gpg
        echo "deb [signed-by=/etc/apt/keyrings/zabbly.gpg] https://pkgs.zabbly.com/incus/stable $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/zabbly-incus-stable.list
        sudo apt update && sudo apt install incus
    fi
    
    # Firecracker - Secure and fast microVMs
    if ! command -v firecracker &> /dev/null; then
        curl -L https://github.com/firecracker-microvm/firecracker/releases/latest/download/firecracker-$(curl -s https://api.github.com/repos/firecracker-microvm/firecracker/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.tgz | tar xz
        sudo mv release-*/firecracker-* /usr/local/bin/
    fi
    
    # Cloud Hypervisor - Open source Virtual Machine Monitor
    if ! command -v cloud-hypervisor &> /dev/null; then
        curl -L https://github.com/cloud-hypervisor/cloud-hypervisor/releases/latest/download/cloud-hypervisor-static -o cloud-hypervisor
        chmod +x cloud-hypervisor
        sudo mv cloud-hypervisor /usr/local/bin/
    fi
    
    # QEMU - Machine emulator and virtualizer
    if ! command -v qemu-system-x86_64 &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qemu-system-x86 qemu-system-gui qemu-utils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm qemu-full
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qemu-kvm qemu-img virt-manager
        fi
    fi
    
    # libvirt - Virtualization management
    if ! command -v virsh &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y libvirt-daemon-system libvirt-clients
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm libvirt
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y libvirt libvirt-daemon-kvm
        fi
    fi
    
    # virt-manager - Virtual machine manager
    if ! command -v virt-manager &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y virt-manager
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm virt-manager
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y virt-manager
        fi
    fi
    
    # VirtualBox - x86 virtualization
    if ! command -v virtualbox &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
            echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
            sudo apt-get update && sudo apt-get install -y virtualbox-7.0
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm virtualbox
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y VirtualBox
        fi
    fi
    
    # VMware Workstation (commercial)
    echo "VMware Workstation requires commercial license and manual download"
    
    # Parallels Desktop (macOS only)
    echo "Parallels Desktop is macOS only"
    
    # UTM - Virtual machines for iOS and macOS
    echo "UTM is primarily for iOS/macOS"
    
    # Proxmox VE tools
    if ! command -v pvesh &> /dev/null; then
        echo "Proxmox VE tools available with Proxmox installation"
    fi
    
    # oVirt - Virtualization management platform
    if ! command -v ovirt-shell &> /dev/null; then
        echo "oVirt tools available with oVirt installation"
    fi
    
    # OpenStack CLI
    if ! command -v openstack &> /dev/null; then
        pip install python-openstackclient
    fi
    
    # Vagrant - Development environment automation
    if ! command -v vagrant &> /dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install vagrant
    fi
    
    # Packer - Machine image builder
    if ! command -v packer &> /dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install packer
    fi
    
    # Terraform - Infrastructure as code
    if ! command -v terraform &> /dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install terraform
    fi
    
    # OpenTofu - Terraform alternative
    if ! command -v tofu &> /dev/null; then
        curl -L https://github.com/opentofu/opentofu/releases/latest/download/tofu_$(curl -s https://api.github.com/repos/opentofu/opentofu/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.zip -o tofu.zip
        unzip tofu.zip
        sudo mv tofu /usr/local/bin/
    fi
    
    # Weave Ignite - GitOps for VMs
    if ! command -v ignite &> /dev/null; then
        curl -L https://github.com/weaveworks/ignite/releases/latest/download/ignite-amd64 -o ignite
        chmod +x ignite
        sudo mv ignite /usr/local/bin/
    fi
    
    # Kata Containers - Secure container runtime
    if ! command -v kata-runtime &> /dev/null; then
        curl -L https://github.com/kata-containers/kata-containers/releases/latest/download/kata-static-$(curl -s https://api.github.com/repos/kata-containers/kata-containers/releases/latest | grep tag_name | cut -d '"' -f 4)-x86_64.tar.xz | tar xJ
        sudo cp -a kata-static-*/opt/kata/* /opt/kata/
        sudo ln -s /opt/kata/bin/* /usr/local/bin/
    fi
    
    # gVisor - Application kernel for containers
    if ! command -v runsc &> /dev/null; then
        curl -fsSL https://gvisor.dev/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/gvisor-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg] https://storage.googleapis.com/gvisor/releases release main" | sudo tee /etc/apt/sources.list.d/gvisor.list > /dev/null
        sudo apt-get update && sudo apt-get install -y runsc
    fi
    
    # Youki - Container runtime written in Rust
    if ! command -v youki &> /dev/null; then
        curl -L https://github.com/containers/youki/releases/latest/download/youki_$(curl -s https://api.github.com/repos/containers/youki/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux.tar.gz | tar xz
        sudo mv youki /usr/local/bin/
    fi
}

# Modern Cloud-Native Tools
install_modern_cloud_native_tools() {
    echo_info "Installing modern cloud-native tools..."
    
    # Knative CLI - Serverless workloads on Kubernetes
    if ! command -v kn &> /dev/null; then
        curl -L https://github.com/knative/client/releases/latest/download/kn-linux-amd64 -o kn
        chmod +x kn
        sudo mv kn /usr/local/bin/
    fi
    
    # Tekton CLI - Cloud-native CI/CD
    if ! command -v tkn &> /dev/null; then
        curl -L https://github.com/tektoncd/cli/releases/latest/download/tkn_$(uname -s)_$(uname -m | sed 's/x86_64/x86_64/').tar.gz | tar xz
        sudo mv tkn /usr/local/bin/
    fi
    
    # Argo CLI - Workflow engine for Kubernetes
    if ! command -v argo &> /dev/null; then
        curl -L https://github.com/argoproj/argo-workflows/releases/latest/download/argo-linux-amd64.gz | gunzip > argo
        chmod +x argo
        sudo mv argo /usr/local/bin/
    fi
    
    # Argo CD CLI - GitOps continuous delivery
    if ! command -v argocd &> /dev/null; then
        curl -L https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 -o argocd
        chmod +x argocd
        sudo mv argocd /usr/local/bin/
    fi
    
    # Argo Rollouts - Progressive delivery
    if ! command -v kubectl-argo-rollouts &> /dev/null; then
        curl -L https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64 -o kubectl-argo-rollouts
        chmod +x kubectl-argo-rollouts
        sudo mv kubectl-argo-rollouts /usr/local/bin/
    fi
    
    # Flux CLI - GitOps toolkit
    if ! command -v flux &> /dev/null; then
        curl -s https://fluxcd.io/install.sh | sudo bash
    fi
    
    # Flagger - Progressive delivery operator
    if ! command -v flagger &> /dev/null; then
        curl -L https://github.com/fluxcd/flagger/releases/latest/download/flagger_$(curl -s https://api.github.com/repos/fluxcd/flagger/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv flagger /usr/local/bin/
    fi
    
    # Istio CLI - Service mesh
    if ! command -v istioctl &> /dev/null; then
        curl -L https://istio.io/downloadIstio | sh -
        sudo mv istio-*/bin/istioctl /usr/local/bin/
    fi
    
    # Linkerd CLI - Service mesh
    if ! command -v linkerd &> /dev/null; then
        curl -sL https://run.linkerd.io/install | sh
        sudo mv ~/.linkerd2/bin/linkerd /usr/local/bin/
    fi
    
    # Consul CLI - Service mesh and service discovery
    if ! command -v consul &> /dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install consul
    fi
    
    # Envoy Proxy - Edge and service proxy
    if ! command -v envoy &> /dev/null; then
        curl -L https://github.com/envoyproxy/envoy/releases/latest/download/envoy-$(curl -s https://api.github.com/repos/envoyproxy/envoy/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64 -o envoy
        chmod +x envoy
        sudo mv envoy /usr/local/bin/
    fi
    
    # Ambassador Edge Stack CLI
    if ! command -v edgectl &> /dev/null; then
        curl -fsSL https://metriton.datawire.io/downloads/linux/edgectl -o edgectl
        chmod +x edgectl
        sudo mv edgectl /usr/local/bin/
    fi
    
    # Kong CLI - API gateway
    if ! command -v kong &> /dev/null; then
        curl -L https://github.com/Kong/kong/releases/latest/download/kong-$(curl -s https://api.github.com/repos/Kong/kong/releases/latest | grep tag_name | cut -d '"' -f 4).amd64.deb -o kong.deb
        sudo dpkg -i kong.deb
        sudo apt-get install -f
    fi
    
    # Traefik - Cloud native application proxy
    if ! command -v traefik &> /dev/null; then
        curl -L https://github.com/traefik/traefik/releases/latest/download/traefik_$(curl -s https://api.github.com/repos/traefik/traefik/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv traefik /usr/local/bin/
    fi
    
    # HAProxy - Load balancer
    if ! command -v haproxy &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y haproxy
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm haproxy
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y haproxy
        fi
    fi
    
    # NGINX - Web server and reverse proxy
    if ! command -v nginx &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nginx
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nginx
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nginx
        fi
    fi
    
    # Caddy - Web server with automatic HTTPS
    if ! command -v caddy &> /dev/null; then
        curl -L https://github.com/caddyserver/caddy/releases/latest/download/caddy_$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv caddy /usr/local/bin/
    fi
    
    # cert-manager CLI - Kubernetes certificate management
    if ! command -v cmctl &> /dev/null; then
        curl -L https://github.com/cert-manager/cert-manager/releases/latest/download/cmctl-linux-amd64.tar.gz | tar xz
        sudo mv cmctl /usr/local/bin/
    fi
    
    # External DNS CLI - Kubernetes DNS management
    if ! command -v external-dns &> /dev/null; then
        curl -L https://github.com/kubernetes-sigs/external-dns/releases/latest/download/external-dns-$(curl -s https://api.github.com/repos/kubernetes-sigs/external-dns/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv external-dns /usr/local/bin/
    fi
    
    # KEDA CLI - Kubernetes event-driven autoscaling
    if ! command -v kedactl &> /dev/null; then
        curl -L https://github.com/kedacore/keda/releases/latest/download/keda-$(curl -s https://api.github.com/repos/kedacore/keda/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv keda /usr/local/bin/kedactl
    fi
    
    # Prometheus CLI - Monitoring and alerting
    if ! command -v promtool &> /dev/null; then
        curl -L https://github.com/prometheus/prometheus/releases/latest/download/prometheus-$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv prometheus-*/promtool /usr/local/bin/
        sudo mv prometheus-*/prometheus /usr/local/bin/
    fi
    
    # Alertmanager - Alert handling
    if ! command -v alertmanager &> /dev/null; then
        curl -L https://github.com/prometheus/alertmanager/releases/latest/download/alertmanager-$(curl -s https://api.github.com/repos/prometheus/alertmanager/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv alertmanager-*/alertmanager /usr/local/bin/
        sudo mv alertmanager-*/amtool /usr/local/bin/
    fi
    
    # Node Exporter - Hardware metrics
    if ! command -v node_exporter &> /dev/null; then
        curl -L https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv node_exporter-*/node_exporter /usr/local/bin/
    fi
    
    # Blackbox Exporter - Endpoint monitoring
    if ! command -v blackbox_exporter &> /dev/null; then
        curl -L https://github.com/prometheus/blackbox_exporter/releases/latest/download/blackbox_exporter-$(curl -s https://api.github.com/repos/prometheus/blackbox_exporter/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv blackbox_exporter-*/blackbox_exporter /usr/local/bin/
    fi
    
    # Grafana CLI - Visualization and observability
    if ! command -v grafana-cli &> /dev/null; then
        curl -L https://dl.grafana.com/oss/release/grafana-$(curl -s https://api.github.com/repos/grafana/grafana/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-1.x86_64.rpm -o grafana.rpm
        sudo rpm -i grafana.rpm || sudo dpkg -i grafana.deb
    fi
    
    # Loki - Log aggregation
    if ! command -v loki &> /dev/null; then
        curl -L https://github.com/grafana/loki/releases/latest/download/loki-linux-amd64.zip -o loki.zip
        unzip loki.zip
        sudo mv loki-linux-amd64 /usr/local/bin/loki
    fi
    
    # Promtail - Log shipping agent
    if ! command -v promtail &> /dev/null; then
        curl -L https://github.com/grafana/loki/releases/latest/download/promtail-linux-amd64.zip -o promtail.zip
        unzip promtail.zip
        sudo mv promtail-linux-amd64 /usr/local/bin/promtail
    fi
    
    # OpenTelemetry Collector - Observability data collection
    if ! command -v otelcol &> /dev/null; then
        curl -L https://github.com/open-telemetry/opentelemetry-collector-releases/releases/latest/download/otelcol_linux_amd64.tar.gz | tar xz
        sudo mv otelcol /usr/local/bin/
    fi
    
    # Fluent Bit - Log processor and forwarder
    if ! command -v fluent-bit &> /dev/null; then
        curl -L https://github.com/fluent/fluent-bit/releases/latest/download/fluent-bit-$(curl -s https://api.github.com/repos/fluent/fluent-bit/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-1.x86_64.rpm -o fluent-bit.rpm
        sudo rpm -i fluent-bit.rpm
    fi
    
    # Fluentd - Data collector
    if ! command -v fluentd &> /dev/null; then
        gem install fluentd
    fi
    
    # Elastic Stack CLI tools
    if ! command -v elasticsearch &> /dev/null; then
        curl -L https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$(curl -s https://api.github.com/repos/elastic/elasticsearch/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.tar.gz | tar xz
        sudo mv elasticsearch-* /opt/elasticsearch
        sudo ln -s /opt/elasticsearch/bin/elasticsearch /usr/local/bin/
    fi
    
    # Kibana
    if ! command -v kibana &> /dev/null; then
        curl -L https://artifacts.elastic.co/downloads/kibana/kibana-$(curl -s https://api.github.com/repos/elastic/kibana/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.tar.gz | tar xz
        sudo mv kibana-* /opt/kibana
        sudo ln -s /opt/kibana/bin/kibana /usr/local/bin/
    fi
    
    # Logstash
    if ! command -v logstash &> /dev/null; then
        curl -L https://artifacts.elastic.co/downloads/logstash/logstash-$(curl -s https://api.github.com/repos/elastic/logstash/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.tar.gz | tar xz
        sudo mv logstash-* /opt/logstash
        sudo ln -s /opt/logstash/bin/logstash /usr/local/bin/
    fi
    
    # Beats family
    if ! command -v filebeat &> /dev/null; then
        curl -L https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$(curl -s https://api.github.com/repos/elastic/beats/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.tar.gz | tar xz
        sudo mv filebeat-*/filebeat /usr/local/bin/
    fi
    
    if ! command -v metricbeat &> /dev/null; then
        curl -L https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-$(curl -s https://api.github.com/repos/elastic/beats/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.tar.gz | tar xz
        sudo mv metricbeat-*/metricbeat /usr/local/bin/
    fi
    
    # Falco - Runtime security monitoring
    if ! command -v falco &> /dev/null; then
        curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
        sudo apt-get update && sudo apt-get install -y falco
    fi
}

# Modern GitOps and Deployment Tools
install_modern_gitops_tools() {
    echo_info "Installing modern GitOps and deployment tools..."
    
    # GitHub CLI - GitHub command line tool
    if ! command -v gh &> /dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install gh
    fi
    
    # GitLab CLI - GitLab command line tool
    if ! command -v glab &> /dev/null; then
        curl -L https://github.com/profclems/glab/releases/latest/download/glab_$(curl -s https://api.github.com/repos/profclems/glab/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_Linux_x86_64.tar.gz | tar xz
        sudo mv bin/glab /usr/local/bin/
    fi
    
    # Gitea CLI - Gitea command line tool
    if ! command -v tea &> /dev/null; then
        curl -L https://github.com/go-gitea/tea/releases/latest/download/tea-$(curl -s https://api.github.com/repos/go-gitea/tea/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64 -o tea
        chmod +x tea
        sudo mv tea /usr/local/bin/
    fi
    
    # Codeberg CLI
    if ! command -v berg &> /dev/null; then
        go install codeberg.org/forgejo/cli/cmd/berg@latest
    fi
    
    # Git Flow - Git branching model
    if ! command -v git-flow &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y git-flow
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gitflow-avh
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gitflow
        fi
    fi
    
    # Git LFS - Large file storage
    if ! command -v git-lfs &> /dev/null; then
        curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
        sudo apt-get install git-lfs
    fi
    
    # Git Delta - Better git diff
    if ! command -v delta &> /dev/null; then
        curl -L https://github.com/dandavison/delta/releases/latest/download/delta-$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep tag_name | cut -d '"' -f 4)-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv delta-*/delta /usr/local/bin/
    fi
    
    # Git Cliff - Changelog generator
    if ! command -v git-cliff &> /dev/null; then
        curl -L https://github.com/orhun/git-cliff/releases/latest/download/git-cliff-$(curl -s https://api.github.com/repos/orhun/git-cliff/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv git-cliff-*/git-cliff /usr/local/bin/
    fi
    
    # Conventional Commits tools
    if ! npm list -g @commitlint/cli &> /dev/null; then
        npm install -g @commitlint/cli @commitlint/config-conventional
    fi
    
    if ! npm list -g commitizen &> /dev/null; then
        npm install -g commitizen cz-conventional-changelog
    fi
    
    # Semantic Release - Automated versioning
    if ! npm list -g semantic-release &> /dev/null; then
        npm install -g semantic-release
    fi
    
    # Release Please - Automated releases
    if ! npm list -g release-please &> /dev/null; then
        npm install -g release-please
    fi
    
    # Changesets - Version and publish workflow
    if ! npm list -g @changesets/cli &> /dev/null; then
        npm install -g @changesets/cli
    fi
    
    # Husky - Git hooks
    if ! npm list -g husky &> /dev/null; then
        npm install -g husky
    fi
    
    # Lint Staged - Run linters on staged files
    if ! npm list -g lint-staged &> /dev/null; then
        npm install -g lint-staged
    fi
    
    # Pre-commit - Git hook framework
    if ! command -v pre-commit &> /dev/null; then
        pip install pre-commit
    fi
    
    # Lefthook - Git hooks manager
    if ! command -v lefthook &> /dev/null; then
        curl -L https://github.com/evilmartians/lefthook/releases/latest/download/lefthook_$(curl -s https://api.github.com/repos/evilmartians/lefthook/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_Linux_x86_64 -o lefthook
        chmod +x lefthook
        sudo mv lefthook /usr/local/bin/
    fi
    
    # GitKraken CLI (gk)
    if ! command -v gk &> /dev/null; then
        curl -L https://github.com/gitkraken/gk-cli/releases/latest/download/gk_$(curl -s https://api.github.com/repos/gitkraken/gk-cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv gk /usr/local/bin/
    fi
    
    # Gitleaks - Secret detection
    if ! command -v gitleaks &> /dev/null; then
        curl -L https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks_$(curl -s https://api.github.com/repos/zricethezav/gitleaks/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_x64.tar.gz | tar xz
        sudo mv gitleaks /usr/local/bin/
    fi
    
    # TruffleHog - Secret scanning
    if ! command -v trufflehog &> /dev/null; then
        curl -L https://github.com/trufflesecurity/trufflehog/releases/latest/download/trufflehog_$(curl -s https://api.github.com/repos/trufflesecurity/trufflehog/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv trufflehog /usr/local/bin/
    fi
    
    # Semgrep - Static analysis
    if ! command -v semgrep &> /dev/null; then
        pip install semgrep
    fi
    
    # SonarQube Scanner
    if ! command -v sonar-scanner &> /dev/null; then
        curl -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$(curl -s https://api.github.com/repos/SonarSource/sonar-scanner-cli/releases/latest | grep tag_name | cut -d '"' -f 4)-linux.zip -o sonar-scanner.zip
        unzip sonar-scanner.zip
        sudo mv sonar-scanner-* /opt/sonar-scanner
        sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/
    fi
    
    # CodeClimate CLI
    if ! command -v codeclimate &> /dev/null; then
        curl -L https://github.com/codeclimate/codeclimate/archive/master.tar.gz | tar xz
        cd codeclimate-master && sudo make install
    fi
    
    # DeepSource CLI
    if ! command -v deepsource &> /dev/null; then
        curl https://deepsource.io/cli | sh
    fi
    
    # Renovate - Dependency updates
    if ! npm list -g renovate &> /dev/null; then
        npm install -g renovate
    fi
    
    # Dependabot CLI
    if ! command -v dependabot &> /dev/null; then
        curl -L https://github.com/dependabot/cli/releases/latest/download/dependabot-$(curl -s https://api.github.com/repos/dependabot/cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv dependabot /usr/local/bin/
    fi
    
    # FOSSA CLI - License compliance
    if ! command -v fossa &> /dev/null; then
        curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/fossas/fossa-cli/master/install-latest.sh | bash
    fi
    
    # License Finder - License detection
    if ! command -v license_finder &> /dev/null; then
        gem install license_finder
    fi
    
    # All Contributors CLI
    if ! npm list -g all-contributors-cli &> /dev/null; then
        npm install -g all-contributors-cli
    fi
    
    # Standard Version - Automated versioning
    if ! npm list -g standard-version &> /dev/null; then
        npm install -g standard-version
    fi
    
    # Auto - Generate releases
    if ! npm list -g auto &> /dev/null; then
        npm install -g auto
    fi
    
    # Shipjs - Release automation
    if ! npm list -g shipjs &> /dev/null; then
        npm install -g shipjs
    fi
    
    # Rush - Monorepo manager
    if ! npm list -g @microsoft/rush &> /dev/null; then
        npm install -g @microsoft/rush
    fi
    
    # Lerna - Monorepo tool
    if ! npm list -g lerna &> /dev/null; then
        npm install -g lerna
    fi
    
    # Nx - Smart monorepo
    if ! npm list -g nx &> /dev/null; then
        npm install -g nx
    fi
    
    # Turborepo - High-performance build system
    if ! npm list -g turbo &> /dev/null; then
        npm install -g turbo
    fi
    
    # Bit - Component-driven development
    if ! npm list -g @teambit/bvm &> /dev/null; then
        npm install -g @teambit/bvm
    fi
    
    # Moon - Build system and monorepo management tool
    if ! command -v moon &> /dev/null; then
        curl -fsSL https://moonrepo.dev/install/moon.sh | bash
    fi
    
    # Bazel - Build and test tool
    if ! command -v bazel &> /dev/null; then
        curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
        sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
        echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
        sudo apt update && sudo apt install bazel
    fi
    
    # Buck2 - Build system
    if ! command -v buck2 &> /dev/null; then
        curl -L https://github.com/facebook/buck2/releases/latest/download/buck2-x86_64-unknown-linux-musl.zst | zstd -d > buck2
        chmod +x buck2
        sudo mv buck2 /usr/local/bin/
    fi
    
    # Please - High-performance build tool
    if ! command -v plz &> /dev/null; then
        curl -fsSL https://get.please.build | bash
    fi
    
    # Pants - Build system
    if ! command -v pants &> /dev/null; then
        curl -L -o pants https://github.com/pantsbuild/pants/releases/latest/download/pants_linux_x86_64
        chmod +x pants
        sudo mv pants /usr/local/bin/
    fi
}

# Modern Distributed Systems Tools
install_modern_distributed_systems_tools() {
    echo_info "Installing modern distributed systems tools..."
    
    # Apache Kafka CLI
    if ! command -v kafka-console-producer.sh &> /dev/null; then
        curl -L https://downloads.apache.org/kafka/2.13-3.6.0/kafka_2.13-3.6.0.tgz | tar xz
        sudo mv kafka_2.13-3.6.0 /opt/kafka
        sudo ln -s /opt/kafka/bin/* /usr/local/bin/
    fi
    
    # Redpanda CLI - Kafka-compatible streaming
    if ! command -v rpk &> /dev/null; then
        curl -LO https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip
        unzip rpk-linux-amd64.zip
        sudo install rpk /usr/local/bin/
    fi
    
    # Apache Pulsar CLI
    if ! command -v pulsar &> /dev/null; then
        curl -L https://archive.apache.org/dist/pulsar/pulsar-3.1.1/apache-pulsar-3.1.1-bin.tar.gz | tar xz
        sudo mv apache-pulsar-3.1.1 /opt/pulsar
        sudo ln -s /opt/pulsar/bin/* /usr/local/bin/
    fi
    
    # NATS CLI
    if ! command -v nats &> /dev/null; then
        curl -L https://github.com/nats-io/natscli/releases/latest/download/nats-$(curl -s https://api.github.com/repos/nats-io/natscli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.zip -o nats.zip
        unzip nats.zip
        sudo mv nats-*/nats /usr/local/bin/
    fi
    
    # Apache ZooKeeper CLI
    if ! command -v zkCli.sh &> /dev/null; then
        curl -L https://downloads.apache.org/zookeeper/zookeeper-3.9.1/apache-zookeeper-3.9.1-bin.tar.gz | tar xz
        sudo mv apache-zookeeper-3.9.1-bin /opt/zookeeper
        sudo ln -s /opt/zookeeper/bin/* /usr/local/bin/
    fi
    
    # etcd CLI
    if ! command -v etcdctl &> /dev/null; then
        curl -L https://github.com/etcd-io/etcd/releases/latest/download/etcd-$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv etcd-*/etcdctl /usr/local/bin/
        sudo mv etcd-*/etcd /usr/local/bin/
    fi
    
    # Consul CLI - Service discovery
    if ! command -v consul &> /dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install consul
    fi
    
    # Nomad CLI - Workload orchestrator
    if ! command -v nomad &> /dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install nomad
    fi
    
    # Apache Cassandra CLI
    if ! command -v cqlsh &> /dev/null; then
        curl -L https://downloads.apache.org/cassandra/4.1.3/apache-cassandra-4.1.3-bin.tar.gz | tar xz
        sudo mv apache-cassandra-4.1.3 /opt/cassandra
        sudo ln -s /opt/cassandra/bin/* /usr/local/bin/
    fi
    
    # ScyllaDB CLI
    if ! command -v scylla &> /dev/null; then
        curl -L https://downloads.scylladb.com/downloads/scylla/deb/pool/main/s/scylla/scylla_$(curl -s https://api.github.com/repos/scylladb/scylla/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o scylla.deb
        sudo dpkg -i scylla.deb
        sudo apt-get install -f
    fi
    
    # Apache Spark CLI
    if ! command -v spark-submit &> /dev/null; then
        curl -L https://downloads.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz | tar xz
        sudo mv spark-3.5.0-bin-hadoop3 /opt/spark
        sudo ln -s /opt/spark/bin/* /usr/local/bin/
    fi
    
    # Apache Flink CLI
    if ! command -v flink &> /dev/null; then
        curl -L https://downloads.apache.org/flink/flink-1.18.0/flink-1.18.0-bin-scala_2.12.tgz | tar xz
        sudo mv flink-1.18.0 /opt/flink
        sudo ln -s /opt/flink/bin/* /usr/local/bin/
    fi
    
    # Apache Storm CLI
    if ! command -v storm &> /dev/null; then
        curl -L https://downloads.apache.org/storm/apache-storm-2.5.0/apache-storm-2.5.0.tar.gz | tar xz
        sudo mv apache-storm-2.5.0 /opt/storm
        sudo ln -s /opt/storm/bin/* /usr/local/bin/
    fi
    
    # Apache Beam CLI
    if ! pip show apache-beam &> /dev/null; then
        pip install apache-beam
    fi
    
    # Ray CLI - Distributed computing
    if ! pip show ray &> /dev/null; then
        pip install ray[default]
    fi
    
    # Dask CLI - Parallel computing
    if ! pip show dask &> /dev/null; then
        pip install dask[complete]
    fi
    
    # Celery - Distributed task queue
    if ! pip show celery &> /dev/null; then
        pip install celery
    fi
    
    # RQ - Redis Queue
    if ! pip show rq &> /dev/null; then
        pip install rq
    fi
    
    # Apache Airflow CLI
    if ! command -v airflow &> /dev/null; then
        pip install apache-airflow
    fi
    
    # Prefect CLI - Workflow orchestration
    if ! command -v prefect &> /dev/null; then
        pip install prefect
    fi
    
    # Dagster CLI - Data orchestration
    if ! command -v dagster &> /dev/null; then
        pip install dagster
    fi
    
    # Apache Mesos CLI
    if ! command -v mesos &> /dev/null; then
        echo "Apache Mesos requires package installation"
    fi
    
    # Marathon CLI
    if ! command -v marathon &> /dev/null; then
        echo "Marathon requires separate installation"
    fi
    
    # Apache Hadoop CLI
    if ! command -v hadoop &> /dev/null; then
        curl -L https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz | tar xz
        sudo mv hadoop-3.3.6 /opt/hadoop
        sudo ln -s /opt/hadoop/bin/* /usr/local/bin/
        sudo ln -s /opt/hadoop/sbin/* /usr/local/bin/
    fi
    
    # Apache HBase CLI
    if ! command -v hbase &> /dev/null; then
        curl -L https://downloads.apache.org/hbase/2.5.6/hbase-2.5.6-bin.tar.gz | tar xz
        sudo mv hbase-2.5.6 /opt/hbase
        sudo ln -s /opt/hbase/bin/* /usr/local/bin/
    fi
    
    # Apache Druid CLI
    if ! command -v druid &> /dev/null; then
        curl -L https://downloads.apache.org/druid/28.0.1/apache-druid-28.0.1-bin.tar.gz | tar xz
        sudo mv apache-druid-28.0.1 /opt/druid
        sudo ln -s /opt/druid/bin/* /usr/local/bin/
    fi
    
    # Apache Pinot CLI
    if ! command -v pinot-admin.sh &> /dev/null; then
        curl -L https://downloads.apache.org/pinot/apache-pinot-1.0.0/apache-pinot-1.0.0-bin.tar.gz | tar xz
        sudo mv apache-pinot-1.0.0-bin /opt/pinot
        sudo ln -s /opt/pinot/bin/* /usr/local/bin/
    fi
    
    # Apache Superset - Data visualization
    if ! pip show apache-superset &> /dev/null; then
        pip install apache-superset
    fi
    
    # Trino CLI - Distributed SQL query engine
    if ! command -v trino &> /dev/null; then
        curl -L https://repo1.maven.org/maven2/io/trino/trino-cli/435/trino-cli-435-executable.jar -o trino
        chmod +x trino
        sudo mv trino /usr/local/bin/
    fi
    
    # Presto CLI - Distributed SQL query engine
    if ! command -v presto &> /dev/null; then
        curl -L https://repo1.maven.org/maven2/io/prestosql/presto-cli/350/presto-cli-350-executable.jar -o presto
        chmod +x presto
        sudo mv presto /usr/local/bin/
    fi
    
    # Apache Drill CLI
    if ! command -v drill-embedded &> /dev/null; then
        curl -L https://downloads.apache.org/drill/drill-1.21.1/apache-drill-1.21.1.tar.gz | tar xz
        sudo mv apache-drill-1.21.1 /opt/drill
        sudo ln -s /opt/drill/bin/* /usr/local/bin/
    fi
    
    # Alluxio CLI - Data orchestration
    if ! command -v alluxio &> /dev/null; then
        curl -L https://downloads.alluxio.io/downloads/files/2.9.3/alluxio-2.9.3-bin.tar.gz | tar xz
        sudo mv alluxio-2.9.3 /opt/alluxio
        sudo ln -s /opt/alluxio/bin/* /usr/local/bin/
    fi
    
    # MinIO CLI - Object storage
    if ! command -v mc &> /dev/null; then
        curl -L https://dl.min.io/client/mc/release/linux-amd64/mc -o mc
        chmod +x mc
        sudo mv mc /usr/local/bin/
    fi
    
    # SeaweedFS CLI - Distributed file system
    if ! command -v weed &> /dev/null; then
        curl -L https://github.com/seaweedfs/seaweedfs/releases/latest/download/linux_amd64.tar.gz | tar xz
        sudo mv weed /usr/local/bin/
    fi
    
    # GlusterFS CLI - Distributed file system
    if ! command -v gluster &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y glusterfs-client
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm glusterfs
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y glusterfs-cli
        fi
    fi
    
    # Ceph CLI - Distributed storage
    if ! command -v ceph &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ceph-common
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ceph
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ceph-common
        fi
    fi
    
    # Rook CLI - Cloud-native storage orchestrator
    if ! command -v rook &> /dev/null; then
        curl -L https://github.com/rook/rook/releases/latest/download/rook-$(curl -s https://api.github.com/repos/rook/rook/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv rook /usr/local/bin/
    fi
    
    # Longhorn CLI - Cloud native distributed block storage
    if ! command -v longhornctl &> /dev/null; then
        curl -L https://github.com/longhorn/cli/releases/latest/download/longhornctl-linux-amd64 -o longhornctl
        chmod +x longhornctl
        sudo mv longhornctl /usr/local/bin/
    fi
    
    # OpenEBS CLI - Container attached storage
    if ! command -v kubectl-openebs &> /dev/null; then
        curl -L https://github.com/openebs/openebsctl/releases/latest/download/kubectl-openebs_$(curl -s https://api.github.com/repos/openebs/openebsctl/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_Linux_x86_64.tar.gz | tar xz
        sudo mv kubectl-openebs /usr/local/bin/
    fi
}

# Modern Low-Code/No-Code Tools
install_modern_lowcode_tools() {
    echo_info "Installing modern low-code/no-code tools..."
    
    # Appsmith CLI - Open source low-code platform
    if ! npm list -g appsmith &> /dev/null; then
        npm install -g appsmith
    fi
    
    # Budibase CLI - Low-code platform
    if ! npm list -g @budibase/cli &> /dev/null; then
        npm install -g @budibase/cli
    fi
    
    # ToolJet CLI - Low-code platform
    if ! npm list -g @tooljet/cli &> /dev/null; then
        npm install -g @tooljet/cli
    fi
    
    # Retool CLI - Internal tool builder
    if ! npm list -g retool-cli &> /dev/null; then
        npm install -g retool-cli
    fi
    
    # Forestadmin CLI - Admin interface generator
    if ! npm list -g forest-cli &> /dev/null; then
        npm install -g forest-cli
    fi
    
    # n8n CLI - Workflow automation (already installed in automation)
    echo "n8n already covered in automation tools"
    
    # Zapier CLI - Automation platform (already covered)
    echo "Zapier CLI already covered in automation tools"
    
    # Microsoft Power Platform CLI
    if ! npm list -g @microsoft/powerplatform-cli &> /dev/null; then
        npm install -g @microsoft/powerplatform-cli
    fi
    
    # OutSystems CLI
    if ! npm list -g @outsystems/cli &> /dev/null; then
        npm install -g @outsystems/cli
    fi
    
    # Mendix CLI
    if ! npm list -g mendix &> /dev/null; then
        npm install -g mendix
    fi
    
    # Bubble API tools
    echo "Bubble is browser-based: https://bubble.io"
    
    # Webflow CLI
    if ! npm list -g @webflow/cli &> /dev/null; then
        npm install -g @webflow/cli
    fi
    
    # Framer CLI
    if ! npm list -g framer-cli &> /dev/null; then
        npm install -g framer-cli
    fi
    
    # Figma CLI tools
    if ! npm list -g figma-export &> /dev/null; then
        npm install -g figma-export
    fi
    
    # Airtable CLI
    if ! npm list -g airtable &> /dev/null; then
        npm install -g airtable
    fi
    
    # Notion API tools
    if ! npm list -g @notionhq/client &> /dev/null; then
        npm install -g @notionhq/client
    fi
    
    # Monday.com CLI
    if ! npm list -g monday-sdk-js &> /dev/null; then
        npm install -g monday-sdk-js
    fi
    
    # Coda API tools
    if ! pip show codaio &> /dev/null; then
        pip install codaio
    fi
    
    # Google Apps Script CLI
    if ! npm list -g @google/clasp &> /dev/null; then
        npm install -g @google/clasp
    fi
    
    # Salesforce CLI
    if ! npm list -g sfdx-cli &> /dev/null; then
        npm install -g sfdx-cli
    fi
    
    # Shopify CLI
    if ! npm list -g @shopify/cli &> /dev/null; then
        npm install -g @shopify/cli
    fi
    
    # WooCommerce CLI
    if ! command -v wp &> /dev/null; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        sudo mv wp-cli.phar /usr/local/bin/wp
    fi
    
    # Strapi CLI - Headless CMS (already covered in API tools)
    echo "Strapi CLI already covered in API tools"
    
    # Contentful CLI
    if ! npm list -g contentful-cli &> /dev/null; then
        npm install -g contentful-cli
    fi
    
    # Sanity CLI
    if ! npm list -g @sanity/cli &> /dev/null; then
        npm install -g @sanity/cli
    fi
    
    # Ghost CLI
    if ! npm list -g ghost-cli &> /dev/null; then
        npm install -g ghost-cli
    fi
    
    # Netlify CLI
    if ! npm list -g netlify-cli &> /dev/null; then
        npm install -g netlify-cli
    fi
    
    # Vercel CLI
    if ! npm list -g vercel &> /dev/null; then
        npm install -g vercel
    fi
    
    # Surge CLI
    if ! npm list -g surge &> /dev/null; then
        npm install -g surge
    fi
    
    # Firebase CLI (already covered in mobile tools)
    echo "Firebase CLI already covered in mobile tools"
    
    # Supabase CLI (already covered in database tools)
    echo "Supabase CLI already covered in database tools"
    
    # PlanetScale CLI (already covered in database tools)
    echo "PlanetScale CLI already covered in database tools"
    
    # Railway CLI
    if ! npm list -g @railway/cli &> /dev/null; then
        npm install -g @railway/cli
    fi
    
    # Render CLI
    if ! command -v render &> /dev/null; then
        curl -L https://github.com/render-oss/render-cli/releases/latest/download/render-linux-x86_64 -o render
        chmod +x render
        sudo mv render /usr/local/bin/
    fi
    
    # Fly.io CLI
    if ! command -v flyctl &> /dev/null; then
        curl -L https://fly.io/install.sh | sh
    fi
    
    # Heroku CLI
    if ! command -v heroku &> /dev/null; then
        curl https://cli-assets.heroku.com/install.sh | sh
    fi
    
    # DigitalOcean CLI
    if ! command -v doctl &> /dev/null; then
        curl -sL https://github.com/digitalocean/doctl/releases/latest/download/doctl-$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv doctl /usr/local/bin/
    fi
    
    # Linode CLI
    if ! command -v linode-cli &> /dev/null; then
        pip install linode-cli
    fi
    
    # Vultr CLI
    if ! command -v vultr-cli &> /dev/null; then
        curl -L https://github.com/vultr/vultr-cli/releases/latest/download/vultr-cli_$(curl -s https://api.github.com/repos/vultr/vultr-cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_64-bit.tar.gz | tar xz
        sudo mv vultr-cli /usr/local/bin/
    fi
    
    # AWS CLI (already covered in cloud tools)
    echo "AWS CLI already covered in cloud tools"
    
    # Azure CLI (already covered in cloud tools)
    echo "Azure CLI already covered in cloud tools"
    
    # Google Cloud CLI (already covered in cloud tools)
    echo "Google Cloud CLI already covered in cloud tools"
}

# Modern Accessibility Tools
install_modern_accessibility_tools() {
    echo_info "Installing modern accessibility tools..."
    
    # axe CLI - Accessibility testing
    if ! npm list -g @axe-core/cli &> /dev/null; then
        npm install -g @axe-core/cli
    fi
    
    # Pa11y - Accessibility testing
    if ! npm list -g pa11y &> /dev/null; then
        npm install -g pa11y pa11y-ci
    fi
    
    # Lighthouse CLI (already covered in performance)
    echo "Lighthouse CLI already covered in performance tools"
    
    # WAVE CLI
    if ! npm list -g wave-cli &> /dev/null; then
        npm install -g wave-cli
    fi
    
    # Accessibility Developer Tools
    if ! npm list -g accessibility-developer-tools &> /dev/null; then
        npm install -g accessibility-developer-tools
    fi
    
    # aXe DevTools CLI
    if ! npm list -g @axe-core/webdriverjs &> /dev/null; then
        npm install -g @axe-core/webdriverjs
    fi
    
    # Tenon CLI
    if ! npm list -g tenon-cli &> /dev/null; then
        npm install -g tenon-cli
    fi
    
    # Ally.js tools
    if ! npm list -g ally.js &> /dev/null; then
        npm install -g ally.js
    fi
    
    # ESLint accessibility plugins
    if ! npm list -g eslint-plugin-jsx-a11y &> /dev/null; then
        npm install -g eslint-plugin-jsx-a11y eslint-plugin-vue-a11y
    fi
    
    # Axe Browser Extensions (manual install required)
    echo "Axe browser extensions require manual installation"
    
    # Screen readers (Linux)
    if ! command -v orca &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y orca
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm orca
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y orca
        fi
    fi
    
    # Speech Dispatcher
    if ! command -v spd-say &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y speech-dispatcher
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm speech-dispatcher
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y speech-dispatcher
        fi
    fi
    
    # Festival TTS
    if ! command -v festival &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y festival
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm festival
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y festival
        fi
    fi
    
    # eSpeak TTS
    if ! command -v espeak &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y espeak espeak-data
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm espeak-ng
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y espeak
        fi
    fi
    
    # AT-SPI tools
    if ! command -v at-spi2-core &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y at-spi2-core
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm at-spi2-core
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y at-spi2-core
        fi
    fi
    
    # High contrast themes
    if ! command -v gnome-themes-extra &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gnome-themes-extra
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gnome-themes-extra
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gnome-themes-extra
        fi
    fi
    
    # Magnification tools
    if ! command -v gnome-mag &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gnome-mag
        fi
    fi
    
    # Virtual keyboard
    if ! command -v onboard &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y onboard
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm onboard
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y onboard
        fi
    fi
    
    # Color contrast tools
    if ! npm list -g color-contrast-analyzer &> /dev/null; then
        npm install -g color-contrast-analyzer
    fi
    
    # WCAG color contrast
    if ! npm list -g wcag-contrast &> /dev/null; then
        npm install -g wcag-contrast
    fi
    
    # Colour Oracle (color blindness simulator)
    echo "Colour Oracle requires manual download from colororacle.org"
    
    # Sim Daltonism (color blindness simulator)
    echo "Sim Daltonism is macOS only"
    
    # NVDA (Windows only)
    echo "NVDA is Windows only"
    
    # JAWS (Windows only)
    echo "JAWS is Windows only"
    
    # VoiceOver testing tools (macOS/iOS only)
    echo "VoiceOver is Apple platforms only"
    
    # Accessibility Insights CLI
    if ! npm list -g accessibility-insights-cli &> /dev/null; then
        npm install -g accessibility-insights-cli
    fi
    
    # Storybook a11y addon
    if ! npm list -g @storybook/addon-a11y &> /dev/null; then
        npm install -g @storybook/addon-a11y
    fi
    
    # React accessibility testing
    if ! npm list -g react-axe &> /dev/null; then
        npm install -g react-axe
    fi
    
    # Vue accessibility testing
    if ! npm list -g vue-axe &> /dev/null; then
        npm install -g vue-axe
    fi
    
    # Angular accessibility testing
    if ! npm list -g @angular/cdk &> /dev/null; then
        npm install -g @angular/cdk
    fi
    
    # Playwright accessibility testing
    if ! npm list -g @axe-core/playwright &> /dev/null; then
        npm install -g @axe-core/playwright
    fi
    
    # Cypress accessibility testing
    if ! npm list -g cypress-axe &> /dev/null; then
        npm install -g cypress-axe
    fi
    
    # Jest accessibility testing
    if ! npm list -g jest-axe &> /dev/null; then
        npm install -g jest-axe
    fi
}

# Modern Design and Prototyping Tools
install_modern_design_tools() {
    echo_info "Installing modern design and prototyping tools..."
    
    # Figma Linux
    if ! command -v figma-linux &> /dev/null; then
        curl -L https://github.com/Figma-Linux/figma-linux/releases/latest/download/figma-linux_$(curl -s https://api.github.com/repos/Figma-Linux/figma-linux/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.deb -o figma-linux.deb
        sudo dpkg -i figma-linux.deb
        sudo apt-get install -f
    fi
    
    # Penpot - Open source design platform
    echo "Penpot is browser-based: https://penpot.app"
    
    # Akira - Native Linux design tool
    if ! command -v akira &> /dev/null; then
        flatpak install -y flathub com.github.akiraux.akira
    fi
    
    # Vectr - Vector graphics
    echo "Vectr is browser-based: https://vectr.com"
    
    # Canva CLI tools
    echo "Canva is browser-based: https://canva.com"
    
    # Adobe XD (not available on Linux)
    echo "Adobe XD not available on Linux"
    
    # Sketch (macOS only)
    echo "Sketch is macOS only"
    
    # InVision Studio (discontinued)
    echo "InVision Studio discontinued"
    
    # Principle (macOS only)
    echo "Principle is macOS only"
    
    # Framer (browser-based)
    echo "Framer is browser-based: https://framer.com"
    
    # ProtoPie (commercial)
    echo "ProtoPie requires commercial license"
    
    # Marvel App (browser-based)
    echo "Marvel App is browser-based: https://marvelapp.com"
    
    # Zeplin CLI
    if ! npm list -g @zeplin/cli &> /dev/null; then
        npm install -g @zeplin/cli
    fi
    
    # Abstract CLI
    if ! npm list -g abstract-cli &> /dev/null; then
        npm install -g abstract-cli
    fi
    
    # Plant CLI - PlantUML diagrams
    if ! npm list -g node-plantuml &> /dev/null; then
        npm install -g node-plantuml
    fi
    
    # Mermaid CLI (already covered in documentation)
    echo "Mermaid CLI already covered in documentation tools"
    
    # Draw.io Desktop
    if ! command -v drawio &> /dev/null; then
        curl -L https://github.com/jgraph/drawio-desktop/releases/latest/download/drawio-amd64-$(curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').deb -o drawio.deb
        sudo dpkg -i drawio.deb
        sudo apt-get install -f
    fi
    
    # Excalidraw Desktop
    if ! command -v excalidraw &> /dev/null; then
        curl -L https://github.com/excalidraw/excalidraw-desktop/releases/latest/download/Excalidraw-$(curl -s https://api.github.com/repos/excalidraw/excalidraw-desktop/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64.AppImage -o excalidraw.AppImage
        chmod +x excalidraw.AppImage
        sudo mv excalidraw.AppImage /usr/local/bin/excalidraw
    fi
    
    # Whimsical (browser-based)
    echo "Whimsical is browser-based: https://whimsical.com"
    
    # Miro (browser-based)
    echo "Miro is browser-based: https://miro.com"
    
    # Mural (browser-based)
    echo "Mural is browser-based: https://mural.co"
    
    # Conceptboard (browser-based)
    echo "Conceptboard is browser-based: https://conceptboard.com"
    
    # LucidChart (browser-based)
    echo "LucidChart is browser-based: https://lucidchart.com"
    
    # Visio (Windows only)
    echo "Microsoft Visio is Windows only"
    
    # OmniGraffle (macOS only)
    echo "OmniGraffle is macOS only"
    
    # Balsamiq Mockups
    if ! command -v balsamiq-mockups &> /dev/null; then
        echo "Balsamiq Mockups requires commercial license"
    fi
    
    # Wireframe.cc (browser-based)
    echo "Wireframe.cc is browser-based: https://wireframe.cc"
    
    # MockFlow (browser-based)
    echo "MockFlow is browser-based: https://mockflow.com"
    
    # Pencil Project - Prototyping tool
    if ! command -v pencil &> /dev/null; then
        curl -L https://github.com/evolus/pencil/releases/latest/download/pencil_$(curl -s https://api.github.com/repos/evolus/pencil/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_amd64.deb -o pencil.deb
        sudo dpkg -i pencil.deb
        sudo apt-get install -f
    fi
    
    # MyPaint - Digital painting
    if ! command -v mypaint &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mypaint
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mypaint
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mypaint
        fi
    fi
    
    # Aseprite alternatives
    if ! command -v pixelorama &> /dev/null; then
        echo "Pixelorama already covered in game development tools"
    fi
    
    # LibreSprite (already covered in game dev)
    echo "LibreSprite already covered in game development tools"
    
    # GIMP (already covered in content creation)
    echo "GIMP already covered in content creation tools"
    
    # Krita (already covered in content creation)
    echo "Krita already covered in content creation tools"
    
    # Inkscape (already covered in content creation)
    echo "Inkscape already covered in content creation tools"
    
    # Blender (already covered in content creation)
    echo "Blender already covered in content creation tools"
    
    # FreeCAD - 3D CAD modeler
    if ! command -v freecad &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y freecad
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm freecad
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y freecad
        fi
    fi
    
    # OpenSCAD - Programmable 3D CAD
    if ! command -v openscad &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y openscad
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm openscad
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y openscad
        fi
    fi
    
    # LibreCAD - 2D CAD
    if ! command -v librecad &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y librecad
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm librecad
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y librecad
        fi
    fi
    
    # QCAD - 2D CAD
    if ! command -v qcad &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qcad
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm qcad
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qcad
        fi
    fi
    
    # Sweet Home 3D - Interior design
    if ! command -v sweethome3d &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sweethome3d
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sweethome3d
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sweethome3d
        fi
    fi
    
    # SketchUp (browser-based free version)
    echo "SketchUp Free is browser-based: https://sketchup.com"
    
    # Fusion 360 (not available on Linux)
    echo "Fusion 360 not available on Linux"
    
    # SolidWorks (Windows only)
    echo "SolidWorks is Windows only"
    
    # AutoCAD (not available on Linux)
    echo "AutoCAD not available on Linux"
    
    # Rhino 3D (Windows/macOS only)
    echo "Rhino 3D not available on Linux"
    
    # Cinema 4D (commercial)
    echo "Cinema 4D requires commercial license"
    
    # Maya (commercial)
    echo "Maya requires commercial license"
    
    # 3ds Max (Windows only)
    echo "3ds Max is Windows only"
    
    # Houdini (commercial with free version)
    echo "Houdini requires download from SideFX"
    
    # ZBrush (commercial)
    echo "ZBrush requires commercial license"
    
    # Substance Suite (Adobe, commercial)
    echo "Substance Suite requires Adobe subscription"
    
    # Marvelous Designer (commercial)
    echo "Marvelous Designer requires commercial license"
    
    # After Effects (not available on Linux)
    echo "After Effects not available on Linux"
    
    # Premiere Pro (not available on Linux)
    echo "Premiere Pro not available on Linux"
    
    # Final Cut Pro (macOS only)
    echo "Final Cut Pro is macOS only"
    
    # Motion (macOS only)
    echo "Motion is macOS only"
    
    # Compressor (macOS only)
    echo "Compressor is macOS only"
    
    # FontForge - Font editor
    if ! command -v fontforge &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fontforge
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fontforge
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y fontforge
        fi
    fi
    
    # Birdfont - Font editor
    if ! command -v birdfont &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y birdfont
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm birdfont
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y birdfont
        fi
    fi
    
    # Glyphr Studio (browser-based)
    echo "Glyphr Studio is browser-based: https://glyphrstudio.com"
    
    # Color palette tools
    if ! npm list -g colorthief &> /dev/null; then
        npm install -g colorthief
    fi
    
    # Coolors CLI
    if ! npm list -g coolors-cli &> /dev/null; then
        npm install -g coolors-cli
    fi
    
    # Gpick - Color picker
    if ! command -v gpick &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gpick
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gpick
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gpick
        fi
    fi
    
    # Color picker tools
    if ! command -v gcolor3 &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y gcolor3
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm gcolor3
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y gcolor3
        fi
    fi
}

# Modern Research and Scientific Computing Tools
install_modern_research_tools() {
    echo_info "Installing modern research and scientific computing tools..."
    
    # Jupyter Lab - Interactive computing
    if ! pip show jupyterlab &> /dev/null; then
        pip install jupyterlab
    fi
    
    # Jupyter Notebook - Interactive computing
    if ! pip show notebook &> /dev/null; then
        pip install notebook
    fi
    
    # JupyterHub - Multi-user Jupyter
    if ! pip show jupyterhub &> /dev/null; then
        pip install jupyterhub
    fi
    
    # Binder CLI - Reproducible research
    if ! pip show repo2docker &> /dev/null; then
        pip install repo2docker
    fi
    
    # Conda - Package and environment manager
    if ! command -v conda &> /dev/null; then
        curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
        bash miniconda.sh -b -p $HOME/miniconda
        rm miniconda.sh
    fi
    
    # Mamba - Fast conda alternative (already covered in package managers)
    echo "Mamba already covered in package managers"
    
    # Micromamba - Tiny conda alternative (already covered in package managers)
    echo "Micromamba already covered in package managers"
    
    # Pixi - Package management (already covered in package managers)
    echo "Pixi already covered in package managers"
    
    # R language and RStudio Server
    if ! command -v R &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y r-base r-base-dev
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm r
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y R R-devel
        fi
    fi
    
    # IRkernel for Jupyter
    if command -v R &> /dev/null; then
        R -e "install.packages('IRkernel'); IRkernel::installspec()"
    fi
    
    # Julia language
    if ! command -v julia &> /dev/null; then
        curl -L https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz | tar xz
        sudo mv julia-* /opt/julia
        sudo ln -s /opt/julia/bin/julia /usr/local/bin/julia
    fi
    
    # Octave - MATLAB alternative
    if ! command -v octave &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y octave
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm octave
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y octave
        fi
    fi
    
    # SciLab - Scientific computing
    if ! command -v scilab &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y scilab
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm scilab
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y scilab
        fi
    fi
    
    # Sage Math - Mathematical software
    if ! command -v sage &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sagemath
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sagemath
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sagemath
        fi
    fi
    
    # Maxima - Computer algebra system
    if ! command -v maxima &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y maxima
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm maxima
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y maxima
        fi
    fi
    
    # Mathematica (commercial)
    echo "Mathematica requires Wolfram license"
    
    # MATLAB (commercial)
    echo "MATLAB requires MathWorks license"
    
    # Maple (commercial)
    echo "Maple requires Maplesoft license"
    
    # SymPy - Symbolic mathematics
    if ! pip show sympy &> /dev/null; then
        pip install sympy
    fi
    
    # NumPy - Numerical computing
    if ! pip show numpy &> /dev/null; then
        pip install numpy
    fi
    
    # SciPy - Scientific computing
    if ! pip show scipy &> /dev/null; then
        pip install scipy
    fi
    
    # Pandas - Data analysis
    if ! pip show pandas &> /dev/null; then
        pip install pandas
    fi
    
    # Matplotlib - Plotting
    if ! pip show matplotlib &> /dev/null; then
        pip install matplotlib
    fi
    
    # Seaborn - Statistical visualization
    if ! pip show seaborn &> /dev/null; then
        pip install seaborn
    fi
    
    # Plotly - Interactive plotting
    if ! pip show plotly &> /dev/null; then
        pip install plotly
    fi
    
    # Bokeh - Interactive visualization
    if ! pip show bokeh &> /dev/null; then
        pip install bokeh
    fi
    
    # Altair - Statistical visualization
    if ! pip show altair &> /dev/null; then
        pip install altair
    fi
    
    # Scikit-learn - Machine learning
    if ! pip show scikit-learn &> /dev/null; then
        pip install scikit-learn
    fi
    
    # TensorFlow - Machine learning
    if ! pip show tensorflow &> /dev/null; then
        pip install tensorflow
    fi
    
    # PyTorch - Machine learning
    if ! pip show torch &> /dev/null; then
        pip install torch torchvision torchaudio
    fi
    
    # JAX - Accelerated ML research
    if ! pip show jax &> /dev/null; then
        pip install jax jaxlib
    fi
    
    # Flax - Neural networks in JAX
    if ! pip show flax &> /dev/null; then
        pip install flax
    fi
    
    # Optax - Gradient processing and optimization
    if ! pip show optax &> /dev/null; then
        pip install optax
    fi
    
    # Haiku - Neural networks in JAX
    if ! pip show dm-haiku &> /dev/null; then
        pip install dm-haiku
    fi
    
    # XLA - Accelerated Linear Algebra
    echo "XLA is included with TensorFlow and JAX"
    
    # OpenCV - Computer vision
    if ! pip show opencv-python &> /dev/null; then
        pip install opencv-python opencv-contrib-python
    fi
    
    # PIL/Pillow - Image processing
    if ! pip show Pillow &> /dev/null; then
        pip install Pillow
    fi
    
    # ImageIO - Image I/O
    if ! pip show imageio &> /dev/null; then
        pip install imageio
    fi
    
    # Scikit-image - Image processing
    if ! pip show scikit-image &> /dev/null; then
        pip install scikit-image
    fi
    
    # NetworkX - Graph analysis
    if ! pip show networkx &> /dev/null; then
        pip install networkx
    fi
    
    # NLTK - Natural language processing
    if ! pip show nltk &> /dev/null; then
        pip install nltk
    fi
    
    # spaCy - Industrial NLP
    if ! pip show spacy &> /dev/null; then
        pip install spacy
    fi
    
    # Gensim - Topic modeling
    if ! pip show gensim &> /dev/null; then
        pip install gensim
    fi
    
    # Transformers - State-of-the-art NLP
    if ! pip show transformers &> /dev/null; then
        pip install transformers
    fi
    
    # Datasets - ML datasets
    if ! pip show datasets &> /dev/null; then
        pip install datasets
    fi
    
    # Tokenizers - Fast tokenization
    if ! pip show tokenizers &> /dev/null; then
        pip install tokenizers
    fi
    
    # Accelerate - Distributed training
    if ! pip show accelerate &> /dev/null; then
        pip install accelerate
    fi
    
    # Gradio - ML web interfaces
    if ! pip show gradio &> /dev/null; then
        pip install gradio
    fi
    
    # Streamlit - Data apps
    if ! pip show streamlit &> /dev/null; then
        pip install streamlit
    fi
    
    # Dash - Analytical web apps
    if ! pip show dash &> /dev/null; then
        pip install dash
    fi
    
    # Panel - Data visualization dashboards
    if ! pip show panel &> /dev/null; then
        pip install panel
    fi
    
    # Voila - Interactive dashboards
    if ! pip show voila &> /dev/null; then
        pip install voila
    fi
    
    # Papermill - Parameterized notebooks
    if ! pip show papermill &> /dev/null; then
        pip install papermill
    fi
    
    # NBConvert - Convert notebooks
    if ! pip show nbconvert &> /dev/null; then
        pip install nbconvert
    fi
    
    # NBFormat - Notebook format
    if ! pip show nbformat &> /dev/null; then
        pip install nbformat
    fi
    
    # JupyterBook - Computational narratives
    if ! pip show jupyter-book &> /dev/null; then
        pip install jupyter-book
    fi
    
    # MyST Parser - Markdown for scientific docs
    if ! pip show myst-parser &> /dev/null; then
        pip install myst-parser
    fi
    
    # Sphinx - Documentation generator
    if ! pip show sphinx &> /dev/null; then
        pip install sphinx
    fi
    
    # MkDocs - Documentation (already covered)
    echo "MkDocs already covered in documentation tools"
    
    # Doxygen - Code documentation
    if ! command -v doxygen &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y doxygen
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm doxygen
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y doxygen
        fi
    fi
    
    # Graphviz - Graph visualization
    if ! command -v dot &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y graphviz
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm graphviz
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y graphviz
        fi
    fi
    
    # LaTeX - Document preparation
    if ! command -v latex &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y texlive-full
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm texlive-most
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y texlive-scheme-full
        fi
    fi
    
    # Pandoc - Document converter (already covered)
    echo "Pandoc already covered in documentation tools"
    
    # Citation management
    if ! pip show pybtex &> /dev/null; then
        pip install pybtex
    fi
    
    # Reference managers
    if ! command -v zotero &> /dev/null; then
        curl -L https://download.zotero.org/client/release/$(curl -s https://api.github.com/repos/zotero/zotero/releases/latest | grep tag_name | cut -d '"' -f 4)/Zotero-$(curl -s https://api.github.com/repos/zotero/zotero/releases/latest | grep tag_name | cut -d '"' -f 4)_linux-x86_64.tar.bz2 | tar xj
        sudo mv Zotero_linux-x86_64 /opt/zotero
        sudo ln -s /opt/zotero/zotero /usr/local/bin/zotero
    fi
    
    # Mendeley (commercial)
    echo "Mendeley requires account registration"
    
    # EndNote (commercial)
    echo "EndNote requires Thomson Reuters license"
    
    # JabRef - Bibliography manager
    if ! command -v jabref &> /dev/null; then
        curl -L https://github.com/JabRef/jabref/releases/latest/download/JabRef-$(curl -s https://api.github.com/repos/JabRef/jabref/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-portable_linux.tar.gz | tar xz
        sudo mv JabRef-* /opt/jabref
        sudo ln -s /opt/jabref/bin/JabRef /usr/local/bin/jabref
    fi
    
    # Research workflows
    if ! pip show snakemake &> /dev/null; then
        pip install snakemake
    fi
    
    # Nextflow - Data-driven computational pipelines
    if ! command -v nextflow &> /dev/null; then
        curl -s https://get.nextflow.io | bash
        sudo mv nextflow /usr/local/bin/
    fi
    
    # Common Workflow Language
    if ! pip show cwltool &> /dev/null; then
        pip install cwltool
    fi
    
    # Galaxy Project tools
    if ! pip show galaxy &> /dev/null; then
        pip install galaxy
    fi
    
    # Bioinformatics tools
    if ! command -v blast+ &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ncbi-blast+
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm blast+
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ncbi-blast+
        fi
    fi
    
    # Biopython
    if ! pip show biopython &> /dev/null; then
        pip install biopython
    fi
    
    # Bioconda
    if command -v conda &> /dev/null; then
        conda config --add channels bioconda
    fi
    
    # Version control for data
    if ! pip show dvc &> /dev/null; then
        pip install dvc
    fi
    
    # Git LFS (already covered in GitOps)
    echo "Git LFS already covered in GitOps tools"
    
    # Weights & Biases (already covered in AI/ML)
    echo "Weights & Biases already covered in AI/ML tools"
    
    # MLflow (already covered in AI/ML)
    echo "MLflow already covered in AI/ML tools"
    
    # TensorBoard
    if ! pip show tensorboard &> /dev/null; then
        pip install tensorboard
    fi
    
    # Weights & Biases
    if ! pip show wandb &> /dev/null; then
        pip install wandb
    fi
    
    # Neptune
    if ! pip show neptune-client &> /dev/null; then
        pip install neptune-client
    fi
    
    # Comet
    if ! pip show comet-ml &> /dev/null; then
        pip install comet-ml
    fi
}

# Modern Edge Computing Tools
install_modern_edge_computing_tools() {
    echo_info "Installing modern edge computing tools..."
    
    # K3s - Lightweight Kubernetes (already covered)
    echo "K3s already covered in Kubernetes tools"
    
    # MicroK8s - Small Kubernetes
    if ! command -v microk8s &> /dev/null; then
        sudo snap install microk8s --classic
    fi
    
    # KubeEdge - Kubernetes edge computing
    if ! command -v keadm &> /dev/null; then
        curl -L https://github.com/kubeedge/kubeedge/releases/latest/download/keadm-$(curl -s https://api.github.com/repos/kubeedge/kubeedge/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv keadm-*/keadm /usr/local/bin/
    fi
    
    # OpenYurt - Edge computing platform
    if ! command -v yurtctl &> /dev/null; then
        curl -L https://github.com/openyurtio/openyurt/releases/latest/download/yurtctl-linux-amd64.tar.gz | tar xz
        sudo mv yurtctl /usr/local/bin/
    fi
    
    # SuperEdge - Edge computing solution
    if ! command -v edgeadm &> /dev/null; then
        curl -L https://github.com/superedge/superedge/releases/latest/download/edgeadm-linux-amd64-$(curl -s https://api.github.com/repos/superedge/superedge/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').tgz | tar xz
        sudo mv edgeadm /usr/local/bin/
    fi
    
    # Akri - Edge device discovery
    if ! command -v akri &> /dev/null; then
        curl -L https://github.com/project-akri/akri/releases/latest/download/akri-$(curl -s https://api.github.com/repos/project-akri/akri/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv akri /usr/local/bin/
    fi
    
    # Azure IoT Edge
    if ! command -v iotedge &> /dev/null; then
        curl -L https://github.com/Azure/iotedge/releases/latest/download/iotedge-$(curl -s https://api.github.com/repos/Azure/iotedge/releases/latest | grep tag_name | cut -d '"' -f 4)-linux-amd64.tar.gz | tar xz
        sudo mv iotedge /usr/local/bin/
    fi
    
    # AWS IoT Greengrass
    if ! command -v greengrass &> /dev/null; then
        echo "AWS IoT Greengrass requires AWS account setup"
    fi
    
    # Google Cloud IoT Edge
    echo "Google Cloud IoT Edge requires GCP account setup"
    
    # EdgeX Foundry CLI
    if ! command -v edgex &> /dev/null; then
        curl -L https://github.com/edgexfoundry/edgex-cli/releases/latest/download/edgex-cli_$(curl -s https://api.github.com/repos/edgexfoundry/edgex-cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv edgex-cli /usr/local/bin/edgex
    fi
    
    # FogHorn - Edge intelligence platform
    echo "FogHorn requires commercial license"
    
    # Crosser - Edge analytics
    echo "Crosser requires commercial license"
    
    # ClearBlade - Edge computing platform
    echo "ClearBlade requires commercial license"
    
    # Eclipse Hono - IoT messaging
    echo "Eclipse Hono requires container deployment"
    
    # Eclipse Ditto - Digital twins
    echo "Eclipse Ditto requires container deployment"
    
    # ThingsBoard - IoT platform
    if ! command -v tb &> /dev/null; then
        curl -L https://github.com/thingsboard/thingsboard/releases/latest/download/thingsboard-$(curl -s https://api.github.com/repos/thingsboard/thingsboard/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//').deb -o thingsboard.deb
        sudo dpkg -i thingsboard.deb
        sudo apt-get install -f
    fi
    
    # Node-RED (already covered in IoT tools)
    echo "Node-RED already covered in embedded/IoT tools"
    
    # Balena CLI (already covered in embedded tools)
    echo "Balena CLI already covered in embedded/IoT tools"
    
    # AWS IoT Device SDK
    if ! pip show AWSIoTPythonSDK &> /dev/null; then
        pip install AWSIoTPythonSDK
    fi
    
    # Azure IoT SDK
    if ! pip show azure-iot-device &> /dev/null; then
        pip install azure-iot-device
    fi
    
    # Google Cloud IoT SDK
    if ! pip show google-cloud-iot &> /dev/null; then
        pip install google-cloud-iot
    fi
    
    # MQTT brokers
    if ! command -v mosquitto &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mosquitto mosquitto-clients
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mosquitto
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mosquitto
        fi
    fi
    
    # Eclipse Mosquitto (already installed above)
    echo "Eclipse Mosquitto already installed"
    
    # VerneMQ - MQTT broker
    if ! command -v vernemq &> /dev/null; then
        curl -L https://github.com/vernemq/vernemq/releases/latest/download/vernemq-$(curl -s https://api.github.com/repos/vernemq/vernemq/releases/latest | grep tag_name | cut -d '"' -f 4)-ubuntu-focal_amd64.deb -o vernemq.deb
        sudo dpkg -i vernemq.deb
        sudo apt-get install -f
    fi
    
    # HiveMQ - MQTT broker
    echo "HiveMQ requires commercial license or HiveMQ CE"
    
    # Apache Pulsar (already covered in distributed systems)
    echo "Apache Pulsar already covered in distributed systems"
    
    # Apache Kafka (already covered in distributed systems)
    echo "Apache Kafka already covered in distributed systems"
    
    # Redis Edge
    if ! command -v redis-server &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y redis-server
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm redis
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y redis
        fi
    fi
    
    # InfluxDB (already covered in databases)
    echo "InfluxDB already covered in database tools"
    
    # TimescaleDB (already covered in databases)
    echo "TimescaleDB already covered in database tools"
    
    # OpenTSDB - Time series database
    if ! command -v tsdb &> /dev/null; then
        echo "OpenTSDB requires manual installation"
    fi
    
    # Grafana (already covered in observability)
    echo "Grafana already covered in observability tools"
    
    # Prometheus (already covered in observability)
    echo "Prometheus already covered in observability tools"
    
    # Telegraf - Metrics collection
    if ! command -v telegraf &> /dev/null; then
        curl -L https://dl.influxdata.com/telegraf/releases/telegraf-$(curl -s https://api.github.com/repos/influxdata/telegraf/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-1.x86_64.rpm -o telegraf.rpm
        sudo rpm -i telegraf.rpm
    fi
    
    # Apache NiFi - Data flow automation
    if ! command -v nifi &> /dev/null; then
        curl -L https://downloads.apache.org/nifi/1.24.0/nifi-1.24.0-bin.tar.gz | tar xz
        sudo mv nifi-1.24.0 /opt/nifi
        sudo ln -s /opt/nifi/bin/nifi.sh /usr/local/bin/nifi
    fi
    
    # StreamSets - Data movement
    echo "StreamSets requires registration"
    
    # Apache Flume - Data ingestion
    if ! command -v flume-ng &> /dev/null; then
        curl -L https://downloads.apache.org/flume/1.11.0/apache-flume-1.11.0-bin.tar.gz | tar xz
        sudo mv apache-flume-1.11.0-bin /opt/flume
        sudo ln -s /opt/flume/bin/* /usr/local/bin/
    fi
    
    # Filebeat (already covered in observability)
    echo "Filebeat already covered in observability tools"
    
    # Logstash (already covered in observability)
    echo "Logstash already covered in observability tools"
    
    # Vector (already covered in observability)
    echo "Vector already covered in observability tools"
    
    # Edge ML inference
    if ! pip show tflite-runtime &> /dev/null; then
        pip install tflite-runtime
    fi
    
    # ONNX Runtime
    if ! pip show onnxruntime &> /dev/null; then
        pip install onnxruntime
    fi
    
    # OpenVINO Toolkit
    if ! pip show openvino &> /dev/null; then
        pip install openvino
    fi
    
    # NVIDIA Jetson tools
    echo "NVIDIA Jetson tools require Jetson hardware"
    
    # Intel RealSense SDK
    if ! command -v realsense-viewer &> /dev/null; then
        echo "Intel RealSense SDK requires manual installation"
    fi
    
    # OpenCV (already covered in research tools)
    echo "OpenCV already covered in research tools"
    
    # TensorRT
    echo "TensorRT requires NVIDIA hardware and license"
    
    # Core ML Tools
    echo "Core ML Tools are Apple platform specific"
    
    # ML Kit
    echo "ML Kit is mobile platform specific"
    
    # MediaPipe
    if ! pip show mediapipe &> /dev/null; then
        pip install mediapipe
    fi
}

# Modern Quantum Computing Tools
install_modern_quantum_tools() {
    echo_info "Installing modern quantum computing tools..."
    
    # Qiskit - IBM Quantum development
    if ! pip show qiskit &> /dev/null; then
        pip install qiskit qiskit-aer qiskit-ibmq-provider
    fi
    
    # Cirq - Google Quantum development
    if ! pip show cirq &> /dev/null; then
        pip install cirq
    fi
    
    # PennyLane - Quantum ML
    if ! pip show pennylane &> /dev/null; then
        pip install pennylane
    fi
    
    # Forest SDK - Rigetti quantum computing
    if ! pip show pyquil &> /dev/null; then
        pip install pyquil
    fi
    
    # Q# - Microsoft Quantum Development Kit
    if ! command -v dotnet &> /dev/null; then
        curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel Current
    fi
    
    # Quantum Development Kit
    if command -v dotnet &> /dev/null; then
        dotnet new -i Microsoft.Quantum.ProjectTemplates
    fi
    
    # ProjectQ - Quantum computing framework
    if ! pip show projectq &> /dev/null; then
        pip install projectq
    fi
    
    # Quantum++ - C++ quantum computing library
    echo "Quantum++ requires manual C++ compilation"
    
    # QuTiP - Quantum Toolbox in Python
    if ! pip show qutip &> /dev/null; then
        pip install qutip
    fi
    
    # OpenFermion - Quantum chemistry
    if ! pip show openfermion &> /dev/null; then
        pip install openfermion
    fi
    
    # Strawberry Fields - Photonic quantum computing
    if ! pip show strawberryfields &> /dev/null; then
        pip install strawberryfields
    fi
    
    # Amazon Braket SDK
    if ! pip show amazon-braket-sdk &> /dev/null; then
        pip install amazon-braket-sdk
    fi
    
    # TensorFlow Quantum
    if ! pip show tensorflow-quantum &> /dev/null; then
        pip install tensorflow-quantum
    fi
    
    # PyQuEST - Quantum simulation
    if ! pip show pyquest-cffi &> /dev/null; then
        pip install pyquest-cffi
    fi
    
    # XACC - Quantum programming framework
    echo "XACC requires manual installation"
    
    # Quantum simulators
    if ! pip show qiskit-aer &> /dev/null; then
        pip install qiskit-aer
    fi
    
    # IBM Quantum Network access tools
    echo "IBM Quantum Network requires IBM account"
    
    # Azure Quantum tools
    if ! pip show azure-quantum &> /dev/null; then
        pip install azure-quantum
    fi
    
    # Google Quantum AI tools
    echo "Google Quantum AI requires Google Cloud account"
    
    # IonQ Cloud tools
    echo "IonQ Cloud requires IonQ account"
    
    # Rigetti Cloud tools
    echo "Rigetti Cloud requires Rigetti account"
    
    # Quantum machine learning
    if ! pip show qiskit-machine-learning &> /dev/null; then
        pip install qiskit-machine-learning
    fi
    
    # Quantum optimization
    if ! pip show qiskit-optimization &> /dev/null; then
        pip install qiskit-optimization
    fi
    
    # Quantum nature
    if ! pip show qiskit-nature &> /dev/null; then
        pip install qiskit-nature
    fi
    
    # Quantum finance
    if ! pip show qiskit-finance &> /dev/null; then
        pip install qiskit-finance
    fi
    
    # Quantum experiments
    if ! pip show qiskit-experiments &> /dev/null; then
        pip install qiskit-experiments
    fi
    
    # Quantum algorithms
    if ! pip show qiskit-algorithms &> /dev/null; then
        pip install qiskit-algorithms
    fi
}

# Modern Augmented/Virtual Reality Tools
install_modern_ar_vr_tools() {
    echo_info "Installing modern AR/VR development tools..."
    
    # Unity (already covered in game development)
    echo "Unity already covered in game development tools"
    
    # Unreal Engine (already covered in game development)
    echo "Unreal Engine already covered in game development tools"
    
    # Godot (already covered in game development)
    echo "Godot already covered in game development tools"
    
    # A-Frame - Web VR framework
    if ! npm list -g aframe-cli &> /dev/null; then
        npm install -g aframe-cli
    fi
    
    # React 360 - VR web apps
    if ! npm list -g react-360-cli &> /dev/null; then
        npm install -g react-360-cli
    fi
    
    # WebXR tools
    if ! npm list -g webxr &> /dev/null; then
        npm install -g webxr
    fi
    
    # Three.js (already covered in game development)
    echo "Three.js already covered in game development tools"
    
    # Babylon.js (already covered in game development)
    echo "Babylon.js already covered in game development tools"
    
    # OpenXR SDK
    echo "OpenXR SDK requires platform-specific installation"
    
    # SteamVR SDK
    echo "SteamVR SDK requires Steam installation"
    
    # Oculus SDK
    echo "Oculus SDK requires Meta developer account"
    
    # ARCore SDK
    echo "ARCore SDK available through Android Studio"
    
    # ARKit (iOS/macOS only)
    echo "ARKit is Apple platforms only"
    
    # Vuforia SDK
    echo "Vuforia SDK requires PTC account"
    
    # 8th Wall - Web AR
    echo "8th Wall requires 8th Wall account"
    
    # ZapWorks - AR creation
    echo "ZapWorks requires Zappar account"
    
    # Wikitude SDK
    echo "Wikitude SDK requires Wikitude license"
    
    # MaxST - AR SDK
    echo "MaxST requires MaxST license"
    
    # EasyAR SDK
    echo "EasyAR SDK requires VisionStar account"
    
    # ARToolKit - AR library
    if ! command -v artoolkit &> /dev/null; then
        echo "ARToolKit requires manual compilation"
    fi
    
    # OpenCV AR (already covered in research)
    echo "OpenCV already covered in research tools"
    
    # Blender (already covered in content creation)
    echo "Blender already covered in content creation tools"
    
    # Maya (commercial)
    echo "Maya requires Autodesk license"
    
    # 3ds Max (Windows only)
    echo "3ds Max is Windows only"
    
    # Cinema 4D (commercial)
    echo "Cinema 4D requires Maxon license"
    
    # Houdini (commercial)
    echo "Houdini requires SideFX license"
    
    # Substance Suite (commercial)
    echo "Substance Suite requires Adobe license"
    
    # ZBrush (commercial)
    echo "ZBrush requires Pixologic license"
    
    # SketchUp (browser-based free)
    echo "SketchUp Free is browser-based"
    
    # Tinkercad (browser-based)
    echo "Tinkercad is browser-based"
    
    # Fusion 360 (not on Linux)
    echo "Fusion 360 not available on Linux"
    
    # SolidWorks (Windows only)
    echo "SolidWorks is Windows only"
    
    # AutoCAD (not on Linux)
    echo "AutoCAD not available on Linux"
    
    # FreeCAD (already covered in design tools)
    echo "FreeCAD already covered in design tools"
    
    # OpenSCAD (already covered in design tools)
    echo "OpenSCAD already covered in design tools"
    
    # VR video tools
    if ! command -v ffmpeg &> /dev/null; then
        echo "FFmpeg already covered in content creation tools"
    fi
    
    # 360 video editing
    echo "360 video editing requires specialized software"
    
    # Spatial audio tools
    if ! pip show soundfile &> /dev/null; then
        pip install soundfile
    fi
    
    # VR streaming
    echo "VR streaming requires platform-specific tools"
    
    # Hand tracking
    echo "Hand tracking requires SDK integration"
    
    # Eye tracking
    echo "Eye tracking requires hardware SDK"
    
    # Haptic feedback
    echo "Haptic feedback requires hardware drivers"
    
    # Motion capture
    echo "Motion capture requires specialized hardware"
    
    # VR testing tools
    echo "VR testing tools are platform-specific"
    
    # WebXR emulators
    if ! npm list -g webxr-emulator &> /dev/null; then
        npm install -g webxr-emulator
    fi
    
    # VR performance profiling
    echo "VR performance profiling is platform-specific"
    
    # Cross-platform VR
    echo "Cross-platform VR requires engine-specific tools"
    
    # VR analytics
    echo "VR analytics requires service integration"
    
    # VR monetization
    echo "VR monetization requires platform store integration"
    
    # Social VR platforms
    echo "Social VR platforms require service accounts"
    
    # VR content management
    echo "VR content management requires platform-specific tools"
    
    # VR deployment
    echo "VR deployment is platform-specific"
    
    # VR updates
    echo "VR updates handled by platform stores"
}

# Modern Microservices and Service Mesh Tools
install_modern_microservices_tools() {
    echo_info "Installing modern microservices and service mesh tools..."
    
    # Istio (already covered in cloud-native)
    echo "Istio already covered in cloud-native tools"
    
    # Linkerd (already covered in cloud-native)
    echo "Linkerd already covered in cloud-native tools"
    
    # Consul Connect (already covered in cloud-native)
    echo "Consul already covered in cloud-native tools"
    
    # Envoy Proxy (already covered in cloud-native)
    echo "Envoy already covered in cloud-native tools"
    
    # Dapr CLI - Distributed application runtime
    if ! command -v dapr &> /dev/null; then
        curl -fsSL https://raw.githubusercontent.com/dapr/cli/master/install/install.sh | /bin/bash
    fi
    
    # Service Weaver - Programming framework for distributed applications
    if ! command -v weaver &> /dev/null; then
        go install github.com/ServiceWeaver/weaver/cmd/weaver@latest
    fi
    
    # Micro - Microservices development framework
    if ! command -v micro &> /dev/null; then
        go install github.com/micro/micro/v3@latest
    fi
    
    # Go-kit - Microservices toolkit
    echo "Go-kit is a library, not a CLI tool"
    
    # Gin - Go web framework
    echo "Gin is a library for Go"
    
    # Express.js - Node.js framework
    if ! npm list -g express-generator &> /dev/null; then
        npm install -g express-generator
    fi
    
    # Fastify CLI - Node.js framework
    if ! npm list -g fastify-cli &> /dev/null; then
        npm install -g fastify-cli
    fi
    
    # Nest.js CLI - Node.js framework
    if ! npm list -g @nestjs/cli &> /dev/null; then
        npm install -g @nestjs/cli
    fi
    
    # Koa.js generator
    if ! npm list -g koa-generator &> /dev/null; then
        npm install -g koa-generator
    fi
    
    # Hapi.js CLI
    if ! npm list -g @hapi/cli &> /dev/null; then
        npm install -g @hapi/cli
    fi
    
    # Spring Boot CLI
    if ! command -v spring &> /dev/null; then
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk install springboot
    fi
    
    # Micronaut CLI
    if ! command -v mn &> /dev/null; then
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk install micronaut
    fi
    
    # Quarkus CLI
    if ! command -v quarkus &> /dev/null; then
        curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/
        curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio
    fi
    
    # Helidon CLI
    if ! command -v helidon &> /dev/null; then
        curl -O https://helidon.io/cli/latest/linux/helidon
        chmod +x ./helidon
        sudo mv ./helidon /usr/local/bin/
    fi
    
    # Open Liberty CLI
    echo "Open Liberty uses Maven/Gradle plugins"
    
    # Dropwizard
    echo "Dropwizard uses Maven/Gradle templates"
    
    # Vert.x CLI
    if ! command -v vertx &> /dev/null; then
        curl -L https://github.com/vert-x3/vertx-stack/releases/latest/download/vertx-stack-manager-$(curl -s https://api.github.com/repos/vert-x3/vertx-stack/releases/latest | grep tag_name | cut -d '"' -f 4)-full.tar.gz | tar xz
        sudo mv vertx-stack-manager-* /opt/vertx
        sudo ln -s /opt/vertx/bin/vertx /usr/local/bin/vertx
    fi
    
    # Akka CLI
    echo "Akka uses sbt templates"
    
    # Flask CLI (Python)
    if ! pip show flask &> /dev/null; then
        pip install flask
    fi
    
    # FastAPI CLI
    if ! pip show fastapi &> /dev/null; then
        pip install fastapi uvicorn
    fi
    
    # Django CLI
    if ! pip show django &> /dev/null; then
        pip install django
    fi
    
    # Starlette CLI
    if ! pip show starlette &> /dev/null; then
        pip install starlette
    fi
    
    # Tornado CLI
    if ! pip show tornado &> /dev/null; then
        pip install tornado
    fi
    
    # Sanic CLI
    if ! pip show sanic &> /dev/null; then
        pip install sanic
    fi
    
    # Falcon CLI
    if ! pip show falcon &> /dev/null; then
        pip install falcon
    fi
    
    # Actix Web (Rust)
    echo "Actix Web uses Cargo"
    
    # Rocket (Rust)
    echo "Rocket uses Cargo"
    
    # Warp (Rust)
    echo "Warp uses Cargo"
    
    # Axum (Rust)
    echo "Axum uses Cargo"
    
    # Gin (Go)
    echo "Gin is a Go library"
    
    # Echo (Go)
    echo "Echo is a Go library"
    
    # Fiber (Go)
    echo "Fiber is a Go library"
    
    # Buffalo CLI (Go)
    if ! command -v buffalo &> /dev/null; then
        go install github.com/gobuffalo/cli/cmd/buffalo@latest
    fi
    
    # Revel CLI (Go)
    if ! command -v revel &> /dev/null; then
        go install github.com/revel/cmd/revel@latest
    fi
    
    # ASP.NET Core CLI
    if command -v dotnet &> /dev/null; then
        dotnet tool install -g dotnet-aspnet-codegenerator
    fi
    
    # Phoenix CLI (Elixir)
    if command -v mix &> /dev/null; then
        mix archive.install hex phx_new
    fi
    
    # Plug (Elixir)
    echo "Plug is an Elixir library"
    
    # Rails CLI (Ruby)
    if ! command -v rails &> /dev/null; then
        gem install rails
    fi
    
    # Sinatra (Ruby)
    if ! gem list sinatra &> /dev/null; then
        gem install sinatra
    fi
    
    # Grape (Ruby)
    if ! gem list grape &> /dev/null; then
        gem install grape
    fi
    
    # Padrino CLI (Ruby)
    if ! command -v padrino &> /dev/null; then
        gem install padrino
    fi
    
    # Laravel CLI (PHP)
    if ! command -v laravel &> /dev/null; then
        composer global require laravel/installer
    fi
    
    # Symfony CLI (PHP)
    if ! command -v symfony &> /dev/null; then
        curl -sS https://get.symfony.com/cli/installer | bash
        sudo mv ~/.symfony*/bin/symfony /usr/local/bin/symfony
    fi
    
    # Lumen CLI (PHP)
    if ! command -v lumen &> /dev/null; then
        composer global require laravel/lumen-installer
    fi
    
    # Slim Framework (PHP)
    echo "Slim Framework uses Composer"
    
    # Phalcon CLI (PHP)
    if ! command -v phalcon &> /dev/null; then
        echo "Phalcon requires extension installation"
    fi
    
    # CodeIgniter CLI (PHP)
    echo "CodeIgniter uses Composer or manual download"
    
    # CakePHP CLI (PHP)
    if ! command -v cake &> /dev/null; then
        composer global require cakephp/cakephp-codesniffer
    fi
    
    # API Gateway tools
    if ! command -v kong &> /dev/null; then
        echo "Kong already covered in cloud-native tools"
    fi
    
    # Ambassador (already covered)
    echo "Ambassador already covered in cloud-native tools"
    
    # Zuul Gateway
    echo "Zuul is a Java library"
    
    # Spring Cloud Gateway
    echo "Spring Cloud Gateway is a Java library"
    
    # NGINX (already covered)
    echo "NGINX already covered in cloud-native tools"
    
    # HAProxy (already covered)
    echo "HAProxy already covered in cloud-native tools"
    
    # Traefik (already covered)
    echo "Traefik already covered in cloud-native tools"
    
    # Load testing tools (already covered in observability)
    echo "Load testing tools already covered in observability"
    
    # Circuit breaker libraries
    echo "Circuit breaker patterns are language-specific libraries"
    
    # Service discovery tools
    echo "Service discovery tools already covered (Consul, etcd, etc.)"
    
    # Configuration management
    echo "Configuration management tools already covered"
    
    # Distributed tracing (already covered)
    echo "Distributed tracing already covered in observability"
    
    # Metrics and monitoring (already covered)
    echo "Metrics and monitoring already covered in observability"
    
    # Log aggregation (already covered)
    echo "Log aggregation already covered in observability"
    
    # Security scanning (already covered)
    echo "Security scanning already covered in security tools"
    
    # Container orchestration (already covered)
    echo "Container orchestration already covered in cloud-native"
    
    # Service mesh observability
    echo "Service mesh observability covered with Istio/Linkerd"
    
    # API documentation
    echo "API documentation tools already covered in API tools"
    
    # API testing (already covered)
    echo "API testing already covered in API tools"
    
    # Contract testing
    if ! npm list -g @pact-foundation/pact-cli &> /dev/null; then
        npm install -g @pact-foundation/pact-cli
    fi
    
    # Chaos engineering
    if ! command -v chaos &> /dev/null; then
        curl -L https://github.com/chaosblade-io/chaosblade/releases/latest/download/chaosblade-$(curl -s https://api.github.com/repos/chaosblade-io/chaosblade/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv chaosblade-*/blade /usr/local/bin/chaos
    fi
    
    # Litmus CLI - Chaos engineering for Kubernetes
    if ! command -v litmusctl &> /dev/null; then
        curl -L https://github.com/litmuschaos/litmusctl/releases/latest/download/litmusctl-linux-amd64 -o litmusctl
        chmod +x litmusctl
        sudo mv litmusctl /usr/local/bin/
    fi
    
    # Chaos Monkey
    echo "Chaos Monkey is Netflix's internal tool"
    
    # Gremlin CLI - Chaos engineering
    if ! command -v gremlin &> /dev/null; then
        echo "Gremlin requires Gremlin account"
    fi
}

# Modern Serverless Tools
install_modern_serverless_tools() {
    echo_info "Installing modern serverless tools..."
    
    # Serverless Framework
    if ! npm list -g serverless &> /dev/null; then
        npm install -g serverless
    fi
    
    # AWS SAM CLI
    if ! command -v sam &> /dev/null; then
        curl -L https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -o sam.zip
        unzip sam.zip -d sam-installation
        sudo ./sam-installation/install
    fi
    
    # Terraform (already covered)
    echo "Terraform already covered in virtualization tools"
    
    # Pulumi (already covered)
    echo "Pulumi already covered in DevOps tools"
    
    # Architect CLI
    if ! npm list -g @architect/architect &> /dev/null; then
        npm install -g @architect/architect
    fi
    
    # Zeit Now CLI (now Vercel)
    if ! npm list -g vercel &> /dev/null; then
        echo "Vercel CLI already covered in low-code tools"
    fi
    
    # Netlify CLI (already covered)
    echo "Netlify CLI already covered in low-code tools"
    
    # Firebase CLI (already covered)
    echo "Firebase CLI already covered in mobile tools"
    
    # Google Cloud Functions CLI
    if ! command -v gcloud &> /dev/null; then
        echo "Google Cloud CLI already covered in cloud tools"
    fi
    
    # Azure Functions CLI
    if ! npm list -g azure-functions-core-tools &> /dev/null; then
        npm install -g azure-functions-core-tools@4 --unsafe-perm true
    fi
    
    # OpenFaaS CLI
    if ! command -v faas-cli &> /dev/null; then
        curl -sLS https://cli.openfaas.com | sudo sh
    fi
    
    # Fn Project CLI
    if ! command -v fn &> /dev/null; then
        curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh
    fi
    
    # Kubeless CLI
    if ! command -v kubeless &> /dev/null; then
        curl -L https://github.com/kubeless/kubeless/releases/latest/download/kubeless_linux-amd64.zip -o kubeless.zip
        unzip kubeless.zip
        sudo mv bundles/kubeless_linux-amd64/kubeless /usr/local/bin/
    fi
    
    # OpenWhisk CLI
    if ! command -v wsk &> /dev/null; then
        curl -L https://github.com/apache/openwhisk-cli/releases/latest/download/OpenWhisk_CLI-$(curl -s https://api.github.com/repos/apache/openwhisk-cli/releases/latest | grep tag_name | cut -d '"' -f 4)-linux-amd64.tgz | tar xz
        sudo mv wsk /usr/local/bin/
    fi
    
    # Fission CLI
    if ! command -v fission &> /dev/null; then
        curl -Lo fission https://github.com/fission/fission/releases/latest/download/fission-$(curl -s https://api.github.com/repos/fission/fission/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64
        chmod +x fission
        sudo mv fission /usr/local/bin/
    fi
    
    # Knative CLI (already covered)
    echo "Knative CLI already covered in cloud-native tools"
    
    # Claudia.js
    if ! npm list -g claudia &> /dev/null; then
        npm install -g claudia
    fi
    
    # Zappa CLI (Python)
    if ! pip show zappa &> /dev/null; then
        pip install zappa
    fi
    
    # Chalice CLI (AWS Python)
    if ! pip show chalice &> /dev/null; then
        pip install chalice
    fi
    
    # Apex CLI
    if ! command -v apex &> /dev/null; then
        curl -L https://github.com/apex/apex/releases/latest/download/apex_linux_amd64 -o apex
        chmod +x apex
        sudo mv apex /usr/local/bin/
    fi
    
    # Up CLI
    if ! command -v up &> /dev/null; then
        curl -L https://github.com/apex/up/releases/latest/download/up_linux_amd64 -o up
        chmod +x up
        sudo mv up /usr/local/bin/
    fi
    
    # IronFunctions CLI
    echo "IronFunctions is deprecated"
    
    # Cloudflare Workers CLI
    if ! npm list -g @cloudflare/wrangler &> /dev/null; then
        npm install -g @cloudflare/wrangler
    fi
    
    # Deno Deploy CLI
    if ! command -v deployctl &> /dev/null; then
        deno install --allow-read --allow-write --allow-env --allow-net --allow-run --no-check -r -f https://deno.land/x/deploy/deployctl.ts
    fi
    
    # Fly.io CLI (already covered)
    echo "Fly.io CLI already covered in low-code tools"
    
    # Railway CLI (already covered)
    echo "Railway CLI already covered in low-code tools"
    
    # Render CLI (already covered)
    echo "Render CLI already covered in low-code tools"
    
    # Supabase CLI (already covered)
    echo "Supabase CLI already covered in database tools"
    
    # Appwrite CLI (already covered)
    echo "Appwrite CLI already covered in mobile tools"
    
    # Nhost CLI
    if ! npm list -g @nhost/cli &> /dev/null; then
        npm install -g @nhost/cli
    fi
    
    # Hasura CLI (already covered)
    echo "Hasura CLI already covered in API tools"
    
    # PostgREST
    if ! command -v postgrest &> /dev/null; then
        curl -L https://github.com/PostgREST/postgrest/releases/latest/download/postgrest-$(curl -s https://api.github.com/repos/PostgREST/postgrest/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-static-x64.tar.xz | tar xJ
        sudo mv postgrest /usr/local/bin/
    fi
    
    # Directus CLI (already covered)
    echo "Directus CLI already covered in API tools"
    
    # Strapi CLI (already covered)
    echo "Strapi CLI already covered in API tools"
    
    # Payload CMS CLI (already covered)
    echo "Payload CMS CLI already covered in API tools"
    
    # Headless CMS tools (already covered)
    echo "Headless CMS tools already covered in API tools"
    
    # Edge computing platforms
    echo "Edge computing platforms already covered in edge computing tools"
    
    # CDN integration tools
    echo "CDN tools are service-specific"
    
    # Performance monitoring (already covered)
    echo "Performance monitoring already covered in observability"
    
    # Cost optimization tools
    if ! pip show boto3 &> /dev/null; then
        pip install boto3  # For AWS cost APIs
    fi
    
    # Serverless testing tools
    if ! npm list -g serverless-offline &> /dev/null; then
        npm install -g serverless-offline
    fi
    
    # Local development tools
    if ! npm list -g localstack &> /dev/null; then
        pip install localstack
    fi
    
    # Serverless plugins ecosystem
    echo "Serverless plugins installed via serverless framework"
    
    # Multi-cloud serverless
    echo "Multi-cloud covered by framework-specific tools"
    
    # Serverless databases (already covered)
    echo "Serverless databases already covered in database tools"
    
    # Event-driven architecture tools
    echo "Event-driven tools covered in messaging/streaming tools"
    
    # Workflow orchestration (already covered)
    echo "Workflow orchestration already covered in distributed systems"
    
    # API Gateway management (already covered)
    echo "API Gateway management already covered in microservices tools"
    
    # Security and compliance (already covered)
    echo "Security tools already covered in security section"
    
    # Observability (already covered)
    echo "Observability already covered in observability section"
    
    # CI/CD integration (already covered)
    echo "CI/CD already covered in GitOps tools"
}

# Modern Data Pipeline Tools
install_modern_data_pipeline_tools() {
    echo_info "Installing modern data pipeline tools..."
    
    # Apache Airflow (already covered)
    echo "Apache Airflow already covered in distributed systems"
    
    # Prefect (already covered)
    echo "Prefect already covered in distributed systems"
    
    # Dagster (already covered)
    echo "Dagster already covered in distributed systems"
    
    # Temporal CLI - Workflow orchestration
    if ! command -v temporal &> /dev/null; then
        curl -L https://github.com/temporalio/cli/releases/latest/download/temporal_cli_$(curl -s https://api.github.com/repos/temporalio/cli/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv temporal /usr/local/bin/
    fi
    
    # Cadence CLI - Workflow orchestration
    if ! command -v cadence &> /dev/null; then
        curl -L https://github.com/uber/cadence/releases/latest/download/cadence-$(curl -s https://api.github.com/repos/uber/cadence/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
        sudo mv cadence-*/cadence /usr/local/bin/
    fi
    
    # dbt CLI - Data transformation
    if ! pip show dbt-core &> /dev/null; then
        pip install dbt-core dbt-postgres dbt-snowflake dbt-bigquery dbt-redshift
    fi
    
    # Great Expectations (already covered)
    echo "Great Expectations already covered in AI/ML tools"
    
    # Apache Beam (already covered)
    echo "Apache Beam already covered in distributed systems"
    
    # Apache Spark (already covered)
    echo "Apache Spark already covered in distributed systems"
    
    # Apache Flink (already covered)
    echo "Apache Flink already covered in distributed systems"
    
    # Apache Storm (already covered)
    echo "Apache Storm already covered in distributed systems"
    
    # Apache NiFi (already covered)
    echo "Apache NiFi already covered in edge computing"
    
    # Airbyte CLI - Data integration
    if ! command -v airbyte &> /dev/null; then
        curl -L https://github.com/airbytehq/airbyte/releases/latest/download/airbyte-$(curl -s https://api.github.com/repos/airbytehq/airbyte/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux.tar.gz | tar xz
        sudo mv airbyte /opt/
        sudo ln -s /opt/airbyte/bin/airbyte /usr/local/bin/
    fi
    
    # Fivetran CLI
    if ! command -v fivetran &> /dev/null; then
        echo "Fivetran requires Fivetran account"
    fi
    
    # Stitch CLI
    echo "Stitch requires Talend account"
    
    # Singer CLI - Data integration
    if ! pip show singer-python &> /dev/null; then
        pip install singer-python
    fi
    
    # Meltano CLI - Data integration
    if ! pip show meltano &> /dev/null; then
        pip install meltano
    fi
    
    # PipelineWise CLI
    if ! pip show pipelinewise &> /dev/null; then
        pip install pipelinewise
    fi
    
    # Apache Kafka (already covered)
    echo "Apache Kafka already covered in distributed systems"
    
    # Apache Pulsar (already covered)
    echo "Apache Pulsar already covered in distributed systems"
    
    # NATS (already covered)
    echo "NATS already covered in distributed systems"
    
    # Redis Streams
    echo "Redis already covered in edge computing"
    
    # Benthos - Stream processing
    if ! command -v benthos &> /dev/null; then
        curl -L https://github.com/benthosdev/benthos/releases/latest/download/benthos_$(curl -s https://api.github.com/repos/benthosdev/benthos/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv benthos /usr/local/bin/
    fi
    
    # Vector (already covered)
    echo "Vector already covered in observability tools"
    
    # Logstash (already covered)
    echo "Logstash already covered in observability tools"
    
    # Fluentd (already covered)
    echo "Fluentd already covered in observability tools"
    
    # Fluent Bit (already covered)
    echo "Fluent Bit already covered in observability tools"
    
    # Snowplow CLI - Event analytics
    if ! command -v snowplow &> /dev/null; then
        echo "Snowplow requires Snowplow account"
    fi
    
    # Segment CLI - Customer data platform
    if ! npm list -g @segment/cli &> /dev/null; then
        npm install -g @segment/cli
    fi
    
    # Census CLI - Reverse ETL
    if ! pip show census &> /dev/null; then
        pip install census
    fi
    
    # Hightouch CLI - Reverse ETL
    echo "Hightouch requires Hightouch account"
    
    # Rudderstack CLI
    if ! npm list -g @rudderstack/cli &> /dev/null; then
        npm install -g @rudderstack/cli
    fi
    
    # Databricks CLI
    if ! pip show databricks-cli &> /dev/null; then
        pip install databricks-cli
    fi
    
    # Dataflow CLI (Google Cloud)
    echo "Dataflow CLI available via Google Cloud SDK"
    
    # Data Factory CLI (Azure)
    echo "Data Factory CLI available via Azure CLI"
    
    # AWS Glue CLI
    echo "AWS Glue CLI available via AWS CLI"
    
    # Delta Lake tools
    if ! pip show delta-spark &> /dev/null; then
        pip install delta-spark
    fi
    
    # Apache Iceberg tools
    echo "Apache Iceberg integrated with Spark/Flink"
    
    # Apache Hudi tools
    echo "Apache Hudi integrated with Spark/Flink"
    
    # Lakehouse formats
    echo "Lakehouse formats integrated with compute engines"
    
    # Data catalog tools
    if ! pip show amundsen-databuilder &> /dev/null; then
        pip install amundsen-databuilder
    fi
    
    # Apache Atlas CLI
    echo "Apache Atlas requires Hadoop ecosystem"
    
    # DataHub CLI
    if ! pip show acryl-datahub &> /dev/null; then
        pip install acryl-datahub
    fi
    
    # Data quality tools
    if ! pip show soda-core &> /dev/null; then
        pip install soda-core
    fi
    
    # Monte Carlo CLI
    echo "Monte Carlo requires Monte Carlo account"
    
    # Bigeye CLI
    echo "Bigeye requires Bigeye account"
    
    # Data lineage tools
    echo "Data lineage tools integrated with catalogs"
    
    # Schema registry tools
    if ! command -v confluent &> /dev/null; then
        curl -L --http1.1 https://cnfl.io/cli | sh -s -- latest
    fi
    
    # Apache Avro tools
    if ! command -v avro-tools &> /dev/null; then
        curl -L https://downloads.apache.org/avro/avro-1.11.3/java/avro-tools-1.11.3.jar -o /tmp/avro-tools.jar
        echo '#!/bin/bash\njava -jar /tmp/avro-tools.jar "$@"' | sudo tee /usr/local/bin/avro-tools
        sudo chmod +x /usr/local/bin/avro-tools
    fi
    
    # Parquet tools
    if ! pip show pyarrow &> /dev/null; then
        pip install pyarrow
    fi
    
    # ORC tools
    echo "ORC tools available in Hadoop ecosystem"
    
    # Protocol Buffers
    if ! command -v protoc &> /dev/null; then
        curl -L https://github.com/protocolbuffers/protobuf/releases/latest/download/protoc-$(curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-linux-x86_64.zip -o protoc.zip
        unzip protoc.zip
        sudo mv bin/protoc /usr/local/bin/
        sudo mv include/* /usr/local/include/
    fi
    
    # Thrift tools
    if ! command -v thrift &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y thrift-compiler
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm thrift
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y thrift
        fi
    fi
    
    # MessagePack tools
    if ! pip show msgpack &> /dev/null; then
        pip install msgpack
    fi
    
    # Data serialization benchmarking
    echo "Serialization benchmarking done via application code"
    
    # Data compression tools
    if ! command -v zstd &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y zstd
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zstd
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zstd
        fi
    fi
    
    # Data migration tools
    if ! pip show flyway &> /dev/null; then
        echo "Flyway requires Java installation"
    fi
    
    # Database migration tools covered elsewhere
    echo "Database migration tools covered in database section"
}

# Modern Compliance and Governance Tools
install_modern_compliance_tools() {
    echo_info "Installing modern compliance and governance tools..."
    
    # Open Policy Agent (already covered)
    echo "Open Policy Agent already covered in security tools"
    
    # Gatekeeper (already covered)
    echo "Gatekeeper already covered in security tools"
    
    # Falco (already covered)
    echo "Falco already covered in security and observability tools"
    
    # Polaris - Kubernetes best practices
    if ! command -v polaris &> /dev/null; then
        curl -L https://github.com/FairwindsOps/polaris/releases/latest/download/polaris_linux_amd64.tar.gz | tar xz
        sudo mv polaris /usr/local/bin/
    fi
    
    # Nova - Kubernetes reliability
    if ! command -v nova &> /dev/null; then
        curl -L https://github.com/FairwindsOps/nova/releases/latest/download/nova_$(curl -s https://api.github.com/repos/FairwindsOps/nova/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv nova /usr/local/bin/
    fi
    
    # Goldilocks - Resource recommendations
    if ! command -v goldilocks &> /dev/null; then
        curl -L https://github.com/FairwindsOps/goldilocks/releases/latest/download/goldilocks_$(curl -s https://api.github.com/repos/FairwindsOps/goldilocks/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv goldilocks /usr/local/bin/
    fi
    
    # Pluto - Kubernetes deprecation detector
    if ! command -v pluto &> /dev/null; then
        curl -L https://github.com/FairwindsOps/pluto/releases/latest/download/pluto_$(curl -s https://api.github.com/repos/FairwindsOps/pluto/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv pluto /usr/local/bin/
    fi
    
    # Checkov - Infrastructure as code scanning
    if ! pip show checkov &> /dev/null; then
        pip install checkov
    fi
    
    # Terrascan - Infrastructure security
    if ! command -v terrascan &> /dev/null; then
        curl -L https://github.com/tenable/terrascan/releases/latest/download/terrascan_$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_Linux_x86_64.tar.gz | tar xz
        sudo mv terrascan /usr/local/bin/
    fi
    
    # tfsec - Terraform security scanner
    if ! command -v tfsec &> /dev/null; then
        curl -L https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64 -o tfsec
        chmod +x tfsec
        sudo mv tfsec /usr/local/bin/
    fi
    
    # Bridgecrew CLI
    if ! pip show bridgecrew &> /dev/null; then
        pip install bridgecrew
    fi
    
    # Snyk CLI - Security scanning
    if ! npm list -g snyk &> /dev/null; then
        npm install -g snyk
    fi
    
    # Aqua Security CLI
    echo "Aqua Security tools require Aqua account"
    
    # Twistlock CLI
    echo "Twistlock (now Prisma Cloud) requires Palo Alto account"
    
    # Sysdig CLI
    if ! command -v sysdig &> /dev/null; then
        echo "Sysdig requires Sysdig account"
    fi
    
    # NeuVector CLI
    echo "NeuVector requires NeuVector account"
    
    # Alcide CLI
    echo "Alcide acquired by Rapid7"
    
    # Kubernetes security benchmarks
    if ! command -v kube-bench &> /dev/null; then
        curl -L https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_$(curl -s https://api.github.com/repos/aquasecurity/kube-bench/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux_amd64.tar.gz | tar xz
        sudo mv kube-bench /usr/local/bin/
    fi
    
    # CIS benchmarks
    echo "CIS benchmarks available from Center for Internet Security"
    
    # NIST compliance tools
    echo "NIST compliance tools are framework-specific"
    
    # SOC 2 compliance tools
    echo "SOC 2 compliance requires audit firms"
    
    # GDPR compliance tools
    echo "GDPR compliance tools are application-specific"
    
    # HIPAA compliance tools
    echo "HIPAA compliance tools are healthcare-specific"
    
    # PCI DSS compliance tools
    echo "PCI DSS compliance tools are payment-specific"
    
    # ISO 27001 compliance tools
    echo "ISO 27001 compliance tools are organization-specific"
    
    # Software Bill of Materials (SBOM)
    if ! command -v syft &> /dev/null; then
        echo "Syft already covered in DevOps tools"
    fi
    
    # SPDX tools
    if ! pip show spdx-tools &> /dev/null; then
        pip install spdx-tools
    fi
    
    # CycloneDX CLI
    if ! npm list -g @cyclonedx/cli &> /dev/null; then
        npm install -g @cyclonedx/cli
    fi
    
    # License compliance
    if ! command -v license_finder &> /dev/null; then
        echo "License Finder already covered in GitOps tools"
    fi
    
    # FOSSA CLI (already covered)
    echo "FOSSA CLI already covered in GitOps tools"
    
    # WhiteSource CLI
    echo "WhiteSource (now Mend) requires Mend account"
    
    # Black Duck CLI
    echo "Black Duck requires Synopsys account"
    
    # Dependency scanning (already covered)
    echo "Dependency scanning already covered in security tools"
    
    # Vulnerability scanning (already covered)
    echo "Vulnerability scanning already covered in security tools"
    
    # Container scanning (already covered)
    echo "Container scanning already covered in security tools"
    
    # Image scanning (already covered)
    echo "Image scanning already covered in security tools"
    
    # Configuration drift detection
    if ! command -v driftctl &> /dev/null; then
        curl -L https://github.com/snyk/driftctl/releases/latest/download/driftctl_linux_amd64 -o driftctl
        chmod +x driftctl
        sudo mv driftctl /usr/local/bin/
    fi
    
    # Infrastructure compliance
    echo "Infrastructure compliance covered by IaC scanning tools"
    
    # Cloud security posture management
    echo "CSPM tools require cloud provider integration"
    
    # Cloud workload protection
    echo "CWP tools require agent deployment"
    
    # Runtime security (already covered)
    echo "Runtime security already covered with Falco"
    
    # Network security
    echo "Network security tools covered in networking section"
    
    # Data privacy tools
    echo "Data privacy tools are application-specific"
    
    # Data loss prevention
    echo "DLP tools require enterprise solutions"
    
    # Audit logging
    echo "Audit logging covered in observability tools"
    
    # Compliance reporting
    echo "Compliance reporting tools are vendor-specific"
    
    # Risk assessment tools
    echo "Risk assessment tools are organization-specific"
    
    # Penetration testing tools (already covered)
    echo "Penetration testing tools already covered in security"
    
    # Red team tools
    echo "Red team tools covered in security section"
    
    # Blue team tools
    echo "Blue team tools covered in security and observability"
    
    # Incident response tools
    echo "Incident response tools covered in observability"
    
    # Forensics tools
    echo "Digital forensics tools require specialized installation"
    
    # Threat intelligence tools
    echo "Threat intelligence tools require service integration"
    
    # Security orchestration
    echo "SOAR tools require enterprise solutions"
    
    # Vulnerability management
    echo "Vulnerability management tools require enterprise solutions"
    
    # Asset management
    echo "Asset management tools require enterprise solutions"
    
    # Configuration management
    echo "Configuration management tools already covered"
    
    # Change management
    echo "Change management tools are process-specific"
    
    # Document management
    echo "Document management tools already covered"
    
    # Training and awareness
    echo "Security training tools are service-based"
    
    # Policy management
    echo "Policy management tools are organization-specific"
    
    # Governance frameworks
    echo "Governance frameworks are organizational implementations"
}

# Modern Workflow Automation Tools
install_modern_workflow_tools() {
    echo_info "Installing modern workflow automation tools..."
    
    # GitHub Actions CLI (via GitHub CLI)
    echo "GitHub Actions managed via GitHub CLI already installed"
    
    # GitLab CI CLI (via GitLab CLI)
    echo "GitLab CI managed via GitLab CLI already installed"
    
    # Jenkins CLI
    if ! command -v jenkins-cli &> /dev/null; then
        echo "Jenkins CLI requires Jenkins server installation"
    fi
    
    # TeamCity CLI
    echo "TeamCity CLI requires JetBrains TeamCity server"
    
    # Bamboo CLI
    echo "Bamboo CLI requires Atlassian Bamboo server"
    
    # Azure DevOps CLI
    if ! command -v az &> /dev/null; then
        echo "Azure DevOps CLI available via Azure CLI already covered"
    fi
    
    # Circle CI CLI
    if ! command -v circleci &> /dev/null; then
        curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | bash
    fi
    
    # Travis CI CLI
    if ! gem list travis &> /dev/null; then
        gem install travis
    fi
    
    # Drone CLI
    if ! command -v drone &> /dev/null; then
        curl -L https://github.com/harness/drone-cli/releases/latest/download/drone_linux_amd64.tar.gz | tar xz
        sudo install drone /usr/local/bin
    fi
    
    # Buildkite CLI
    if ! command -v buildkite-agent &> /dev/null; then
        curl -fsSL https://keys.openpgp.org/vks/v1/by-fingerprint/32A37959C2FA5C3C99EFBC32A79206696452D198 | sudo gpg --dearmor -o /usr/share/keyrings/buildkite-agent-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent stable main" | sudo tee /etc/apt/sources.list.d/buildkite-agent.list
        sudo apt-get update && sudo apt-get install -y buildkite-agent
    fi
    
    # Tekton CLI (already covered)
    echo "Tekton CLI already covered in cloud-native tools"
    
    # Argo Workflows CLI (already covered)
    echo "Argo Workflows CLI already covered in cloud-native tools"
    
    # Flyte CLI - Workflow orchestration
    if ! command -v flytectl &> /dev/null; then
        curl -sL https://ctl.flyte.org/install | bash
    fi
    
    # Kubeflow Pipelines CLI
    if ! command -v kfp &> /dev/null; then
        echo "Kubeflow Pipelines CLI already covered in AI/ML tools"
    fi
    
    # Airflow CLI (already covered)
    echo "Airflow CLI already covered in distributed systems"
    
    # Prefect CLI (already covered)
    echo "Prefect CLI already covered in distributed systems"
    
    # Dagster CLI (already covered)
    echo "Dagster CLI already covered in distributed systems"
    
    # Temporal CLI (already covered)
    echo "Temporal CLI already covered in data pipeline tools"
    
    # Cadence CLI (already covered)
    echo "Cadence CLI already covered in data pipeline tools"
    
    # AWS Step Functions CLI
    echo "AWS Step Functions CLI available via AWS CLI"
    
    # Azure Logic Apps CLI
    echo "Azure Logic Apps CLI available via Azure CLI"
    
    # Google Cloud Workflows CLI
    echo "Google Cloud Workflows CLI available via gcloud"
    
    # Zapier CLI (already covered)
    echo "Zapier CLI already covered in automation tools"
    
    # Microsoft Power Automate CLI (already covered)
    echo "Power Automate CLI already covered in automation tools"
    
    # IFTTT equivalent tools (already covered)
    echo "IFTTT tools already covered in automation"
    
    # n8n CLI (already covered)
    echo "n8n CLI already covered in automation tools"
    
    # Node-RED (already covered)
    echo "Node-RED already covered in automation and IoT tools"
    
    # Apache NiFi (already covered)
    echo "Apache NiFi already covered in edge computing tools"
    
    # Benthos (already covered)
    echo "Benthos already covered in data pipeline tools"
    
    # Make (Integromat) CLI
    echo "Make CLI already covered in automation tools"
    
    # Huginn (already covered)
    echo "Huginn already covered in automation tools"
    
    # Home Assistant (already covered)
    echo "Home Assistant already covered in automation tools"
    
    # OpenHAB (already covered)
    echo "OpenHAB already covered in automation tools"
    
    # Robot Framework (already covered)
    echo "Robot Framework already covered in automation tools"
    
    # Selenium (already covered)
    echo "Selenium already covered in automation and testing tools"
    
    # Playwright (already covered)
    echo "Playwright already covered in automation and testing tools"
    
    # Puppeteer (already covered)
    echo "Puppeteer already covered in testing tools"
    
    # Workflow engines comparison tools
    echo "Workflow engines comparison requires manual evaluation"
    
    # Business process management
    echo "BPM tools require enterprise solutions"
    
    # Process mining tools
    echo "Process mining tools require specialized software"
    
    # RPA tools
    echo "RPA tools require enterprise licensing"
    
    # Document automation
    echo "Document automation tools covered in office suites"
    
    # Email automation
    echo "Email automation requires service integration"
    
    # Social media automation
    echo "Social media automation requires API integration"
    
    # Marketing automation
    echo "Marketing automation requires service platforms"
    
    # Customer relationship management
    echo "CRM automation requires CRM platforms"
    
    # Enterprise resource planning
    echo "ERP automation requires ERP systems"
    
    # Human resources automation
    echo "HR automation requires HR platforms"
    
    # Financial automation
    echo "Financial automation requires accounting systems"
    
    # Inventory management automation
    echo "Inventory automation requires inventory systems"
    
    # Supply chain automation
    echo "Supply chain automation requires SCM systems"
    
    # Quality assurance automation
    echo "QA automation already covered in testing tools"
    
    # Compliance automation (already covered)
    echo "Compliance automation already covered in compliance tools"
    
    # Security automation (already covered)
    echo "Security automation already covered in security tools"
    
    # Infrastructure automation (already covered)
    echo "Infrastructure automation already covered in DevOps tools"
    
    # Application deployment automation (already covered)
    echo "Deployment automation already covered in GitOps tools"
    
    # Monitoring automation (already covered)
    echo "Monitoring automation already covered in observability tools"
    
    # Backup automation
    echo "Backup automation requires backup solutions"
    
    # Disaster recovery automation
    echo "DR automation requires DR solutions"
    
    # Capacity planning automation
    echo "Capacity planning automation requires monitoring integration"
    
    # Performance optimization automation
    echo "Performance optimization automation requires APM tools"
    
    # Cost optimization automation
    echo "Cost optimization automation requires cloud provider tools"
    
    # Resource scheduling automation
    echo "Resource scheduling automation covered in orchestration tools"
    
    # Event-driven automation
    echo "Event-driven automation covered in messaging tools"
    
    # API-driven automation
    echo "API-driven automation covered in API tools"
    
    # Webhook automation
    echo "Webhook automation covered in API and automation tools"
    
    # Cron alternatives and modern schedulers
    if ! command -v mcron &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mcron
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mcron
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mcron
        fi
    fi
    
    # System automation scripts
    echo "System automation scripts are custom implementations"
}

# Modern Fintech and Payment Tools
install_modern_fintech_tools() {
    echo_info "Installing modern fintech and payment tools..."
    
    # Stripe CLI
    if ! command -v stripe &> /dev/null; then
        curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor | sudo tee /usr/share/keyrings/stripe.gpg
        echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | sudo tee -a /etc/apt/sources.list.d/stripe.list
        sudo apt update && sudo apt install stripe
    fi
    
    # PayPal CLI
    echo "PayPal CLI requires PayPal developer account"
    
    # Square CLI
    echo "Square CLI requires Square developer account"
    
    # Plaid CLI
    if ! npm list -g plaid &> /dev/null; then
        npm install -g plaid
    fi
    
    # Twilio CLI
    if ! command -v twilio &> /dev/null; then
        npm install -g twilio-cli
    fi
    
    # SendGrid CLI
    if ! command -v sendgrid &> /dev/null; then
        pip install sendgrid
    fi
    
    # Mailgun CLI
    if ! pip show mailgun &> /dev/null; then
        pip install mailgun
    fi
    
    # Banking APIs and fintech tools
    echo "Banking APIs require bank-specific integration"
    
    # Cryptocurrency tools
    if ! pip show web3 &> /dev/null; then
        pip install web3
    fi
    
    # DeFi development tools covered in blockchain section
    echo "DeFi tools already covered in blockchain tools"
}

# Modern E-commerce Development Tools
install_modern_ecommerce_tools() {
    echo_info "Installing modern e-commerce development tools..."
    
    # Shopify CLI (already covered)
    echo "Shopify CLI already covered in low-code tools"
    
    # WooCommerce CLI (already covered)
    echo "WooCommerce CLI already covered in low-code tools"
    
    # Magento CLI
    echo "Magento CLI requires Magento installation"
    
    # PrestaShop CLI
    echo "PrestaShop CLI requires PrestaShop installation"
    
    # OpenCart CLI
    echo "OpenCart CLI requires OpenCart installation"
    
    # Medusa CLI - Modern commerce stack
    if ! npm list -g @medusajs/medusa-cli &> /dev/null; then
        npm install -g @medusajs/medusa-cli
    fi
    
    # Saleor CLI - GraphQL e-commerce
    if ! pip show saleor &> /dev/null; then
        pip install saleor
    fi
    
    # Commerce.js CLI
    if ! npm list -g @commercejs/cli &> /dev/null; then
        npm install -g @commercejs/cli
    fi
    
    # BigCommerce CLI
    echo "BigCommerce CLI requires BigCommerce store"
    
    # Spree Commerce CLI
    if ! gem list spree &> /dev/null; then
        gem install spree
    fi
    
    # Solidus CLI
    if ! gem list solidus &> /dev/null; then
        gem install solidus
    fi
}

# Modern Real-time Communication Tools
install_modern_realtime_tools() {
    echo_info "Installing modern real-time communication tools..."
    
    # Socket.io CLI
    if ! npm list -g socket.io &> /dev/null; then
        npm install -g socket.io
    fi
    
    # WebSocket tools
    if ! npm list -g ws &> /dev/null; then
        npm install -g ws
    fi
    
    # WebRTC tools
    echo "WebRTC tools are browser-based APIs"
    
    # SignalR CLI
    echo "SignalR is an ASP.NET Core library"
    
    # Pusher CLI
    if ! npm list -g pusher &> /dev/null; then
        npm install -g pusher
    fi
    
    # Ably CLI
    if ! npm list -g ably &> /dev/null; then
        npm install -g ably
    fi
    
    # PubNub CLI
    if ! npm list -g pubnub &> /dev/null; then
        npm install -g pubnub
    fi
}

# Modern Progressive Web App Tools
install_modern_pwa_tools() {
    echo_info "Installing modern PWA tools..."
    
    # Workbox CLI
    if ! npm list -g workbox-cli &> /dev/null; then
        npm install -g workbox-cli
    fi
    
    # PWA Builder CLI
    if ! npm list -g @pwabuilder/cli &> /dev/null; then
        npm install -g @pwabuilder/cli
    fi
    
    # Lighthouse CLI (already covered)
    echo "Lighthouse CLI already covered in performance tools"
    
    # PWA tools in frameworks already covered
    echo "PWA tools in frameworks already covered"
}

# Modern Headless CMS Tools
install_modern_headless_cms_tools() {
    echo_info "Installing modern headless CMS tools..."
    
    # Strapi CLI (already covered)
    echo "Strapi CLI already covered in API tools"
    
    # Contentful CLI (already covered)
    echo "Contentful CLI already covered in low-code tools"
    
    # Sanity CLI (already covered)
    echo "Sanity CLI already covered in low-code tools"
    
    # Ghost CLI (already covered)
    echo "Ghost CLI already covered in low-code tools"
    
    # Directus CLI (already covered)
    echo "Directus CLI already covered in API tools"
    
    # Payload CMS CLI (already covered)
    echo "Payload CMS CLI already covered in API tools"
}

# Modern JAMstack Tools
install_modern_jamstack_tools() {
    echo_info "Installing modern JAMstack tools..."
    
    # Gatsby CLI
    if ! npm list -g gatsby-cli &> /dev/null; then
        npm install -g gatsby-cli
    fi
    
    # Next.js CLI
    if ! npm list -g create-next-app &> /dev/null; then
        npm install -g create-next-app
    fi
    
    # Nuxt.js CLI
    if ! npm list -g create-nuxt-app &> /dev/null; then
        npm install -g create-nuxt-app
    fi
    
    # SvelteKit CLI (already covered)
    echo "SvelteKit CLI already covered in web frameworks"
    
    # Astro CLI (already covered)
    echo "Astro CLI already covered in web frameworks"
}

# Modern Micro-frontend Tools
install_modern_microfrontend_tools() {
    echo_info "Installing modern micro-frontend tools..."
    
    # Single SPA CLI
    if ! npm list -g create-single-spa &> /dev/null; then
        npm install -g create-single-spa
    fi
    
    # Module Federation tools
    echo "Module Federation is built into Webpack 5"
    
    # Bit CLI (already covered)
    echo "Bit CLI already covered in GitOps tools"
}

# Modern GraphQL Tools
install_modern_graphql_tools() {
    echo_info "Installing modern GraphQL tools..."
    
    # GraphQL CLI (already covered)
    echo "GraphQL CLI already covered in API tools"
    
    # Apollo CLI (already covered)
    echo "Apollo CLI already covered in API tools"
    
    # Hasura CLI (already covered)
    echo "Hasura CLI already covered in API tools"
    
    # Altair GraphQL (already covered)
    echo "Altair GraphQL already covered in API tools"
    
    # GraphQL Playground (already covered)
    echo "GraphQL Playground already covered in API tools"
}

# Modern WebAssembly Tools
install_modern_webassembly_tools() {
    echo_info "Installing modern WebAssembly tools..."
    
    # wasmtime - WebAssembly runtime
    if ! command -v wasmtime &> /dev/null; then
        curl https://wasmtime.dev/install.sh -sSf | bash
    fi
    
    # wasmer - WebAssembly runtime
    if ! command -v wasmer &> /dev/null; then
        curl https://get.wasmer.io -sSfL | sh
    fi
    
    # wasm-pack - Rust-generated WebAssembly
    if ! command -v wasm-pack &> /dev/null; then
        curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
    fi
    
    # Emscripten - C/C++ to WebAssembly
    if ! command -v emcc &> /dev/null; then
        git clone https://github.com/emscripten-core/emsdk.git /opt/emsdk
        cd /opt/emsdk && ./emsdk install latest && ./emsdk activate latest
        echo 'source /opt/emsdk/emsdk_env.sh' >> ~/.bashrc
    fi
}

# Modern Static Site Generators
install_modern_static_site_generators() {
    echo_info "Installing modern static site generators..."
    
    # Hugo - Fast static site generator
    if ! command -v hugo &> /dev/null; then
        curl -L https://github.com/gohugoio/hugo/releases/latest/download/hugo_extended_$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_linux-amd64.tar.gz | tar xz
        sudo mv hugo /usr/local/bin/
    fi
    
    # Jekyll - Ruby static site generator
    if ! command -v jekyll &> /dev/null; then
        gem install jekyll bundler
    fi
    
    # Gatsby CLI (already covered)
    echo "Gatsby CLI already covered in JAMstack tools"
    
    # Next.js (already covered)
    echo "Next.js already covered in JAMstack tools"
    
    # Nuxt.js (already covered)
    echo "Nuxt.js already covered in JAMstack tools"
}

# Modern Code Generation Tools
install_modern_code_generation_tools() {
    echo_info "Installing modern code generation tools..."
    
    # OpenAPI Generator (already covered)
    echo "OpenAPI Generator already covered in API tools"
    
    # Swagger Codegen (already covered)
    echo "Swagger Codegen already covered in API tools"
    
    # Hygen - Code generator
    if ! npm list -g hygen &> /dev/null; then
        npm install -g hygen
    fi
    
    # Plop - Micro-generator framework
    if ! npm list -g plop &> /dev/null; then
        npm install -g plop
    fi
}

# Modern Deployment Platforms
install_modern_deployment_platforms() {
    echo_info "Installing modern deployment platforms..."
    
    # All deployment platform CLIs already covered in previous sections
    echo "Deployment platform CLIs already covered in low-code and serverless tools"
}

# Modern Developer Experience Tools
install_modern_developer_experience_tools() {
    echo_info "Installing modern developer experience tools..."
    
    # Most developer experience tools already covered in previous sections
    echo "Developer experience tools already covered in previous sections"
    
    # Additional DX tools
    if ! npm list -g @dx/cli &> /dev/null; then
        npm install -g @dx/cli 2>/dev/null || echo "DX CLI not available"
    fi
}

# Final function to add remaining categories
install_remaining_modern_tools() {
    echo_info "Installing remaining modern development tools..."
    
    # This function covers any remaining tools that haven't been categorized
    # Most modern tools should be covered in the above comprehensive categories
    
    # Additional package managers
    if ! command -v pkgx &> /dev/null; then
        curl -Ssf https://pkgx.sh | sh
    fi
    
    # Additional shells
    if ! command -v oil &> /dev/null; then
        pip install oil-lang
    fi
    
    # Additional text editors
    if ! command -v micro &> /dev/null; then
        curl https://getmic.ro | bash
        sudo mv micro /usr/local/bin/
    fi
    
    # Additional terminals
    if ! command -v rio &> /dev/null; then
        echo "Rio terminal requires manual installation from GitHub"
    fi
    
    # Additional multiplexers
    if ! command -v zellij &> /dev/null; then
        curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz
        sudo mv zellij /usr/local/bin/
    fi
    
    # Additional file managers
    if ! command -v yazi &> /dev/null; then
        curl -L https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip -o yazi.zip
        unzip yazi.zip
        sudo mv yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/
    fi
    
    # Additional system monitors
    if ! command -v zenith &> /dev/null; then
        cargo install zenith
    fi
    
    # Additional benchmarking tools
    if ! command -v sysbench &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y sysbench
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm sysbench
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sysbench
        fi
    fi
    
    # Additional security tools
    if ! command -v age-plugin-yubikey &> /dev/null; then
        go install github.com/str4d/age-plugin-yubikey@latest
    fi
    
    # Additional networking tools
    if ! command -v mtr &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y mtr
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mtr
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y mtr
        fi
    fi
    
    # Additional development utilities
    if ! command -v watchexec &> /dev/null; then
        curl -L https://github.com/watchexec/watchexec/releases/latest/download/watchexec-$(curl -s https://api.github.com/repos/watchexec/watchexec/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')-x86_64-unknown-linux-musl.tar.xz | tar xJ
        sudo mv watchexec-*/watchexec /usr/local/bin/
    fi
    
    # Additional modern CLI tools
    if ! command -v cht.sh &> /dev/null; then
        curl https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh
        sudo chmod +x /usr/local/bin/cht.sh
    fi
    
    echo_info "Completed installation of comprehensive modern development tools collection!"
}

# Run main function
main "$@"