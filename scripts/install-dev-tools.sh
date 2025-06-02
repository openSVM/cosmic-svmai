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
    
    update_path
    
    echo_info "Development tools installation completed!"
    echo_info "Please run 'just dev-tools-check' to verify installations"
}

# Run main function
main "$@"