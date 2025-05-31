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
            gnupg lsb-release snapd flatpak
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm curl wget git base-devel openssl unzip \
            snapd flatpak
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y curl wget git gcc gcc-c++ make pkgconfig openssl-devel \
            unzip snapd flatpak
    else
        echo_warn "Unknown package manager. Please install dependencies manually."
    fi
}

# Install Zig latest version
install_zig() {
    echo_info "Installing Zig (latest version)..."
    
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
}

# Install Crystal latest version
install_crystal() {
    echo_info "Installing Crystal (latest version)..."
    
    if command -v apt-get &> /dev/null; then
        curl -fsSL https://crystal-lang.org/install.sh | sudo bash
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm crystal
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y crystal
    else
        echo_warn "Please install Crystal manually for your distribution"
    fi
}

# Install React Native CLI
install_react_native() {
    echo_info "Installing React Native CLI..."
    
    # Install Node.js if not present
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    sudo npm install -g @react-native-community/cli
    echo_info "React Native CLI installed"
}

# Install Flutter
install_flutter() {
    echo_info "Installing Flutter..."
    
    if [ ! -d "$HOME/.local/flutter" ]; then
        cd /tmp
        FLUTTER_VERSION=$(curl -s https://api.github.com/repos/flutter/flutter/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        wget -O flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
        tar -xf flutter.tar.xz
        mv flutter "$HOME/.local/"
        
        # Add to PATH in .bashrc if not already there
        if ! grep -q 'export PATH="$HOME/.local/flutter/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.local/flutter/bin:$PATH"' >> "$HOME/.bashrc"
        fi
    fi
    
    echo_info "Flutter installed. Run 'flutter doctor' to check setup"
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
    
    if command -v snap &> /dev/null; then
        sudo snap install kotlin --classic
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y kotlin
    else
        echo_warn "Please install Kotlin manually"
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

# Update PATH
update_path() {
    echo_info "Updating PATH..."
    
    # Add common paths to .bashrc if not already there
    PATHS_TO_ADD=(
        '$HOME/.local/bin'
        '$HOME/.local/flutter/bin'
        '$HOME/.cargo/bin'
    )
    
    for path in "${PATHS_TO_ADD[@]}"; do
        if ! grep -q "export PATH=\"${path}:\$PATH\"" "$HOME/.bashrc"; then
            echo "export PATH=\"${path}:\$PATH\"" >> "$HOME/.bashrc"
        fi
    done
    
    echo_info "PATH updated. Please source ~/.bashrc or restart your shell"
}

# Main installation function
main() {
    echo_info "Starting COSMIC SVM development tools installation..."
    
    check_root
    install_system_deps
    
    echo_info "Installing programming languages..."
    install_zig
    install_crystal
    
    echo_info "Installing mobile development tools..."
    install_react_native
    install_flutter
    install_kotlin
    install_android_studio
    
    echo_info "Installing development tools..."
    install_insomnia
    
    echo_info "Installing network tools..."
    install_tor
    install_tailscale
    install_yggdrasil
    install_i2p
    
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