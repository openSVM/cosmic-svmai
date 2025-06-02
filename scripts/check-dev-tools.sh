#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

echo_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if a command exists
check_command() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>/dev/null | head -n1 || echo "version unknown")
        echo_pass "$name is installed: $version"
        return 0
    else
        echo_fail "$name is not installed"
        return 1
    fi
}

# Check if a file/directory exists
check_path() {
    local path="$1"
    local name="$2"
    
    if [ -e "$path" ]; then
        echo_pass "$name is installed at $path"
        return 0
    else
        echo_fail "$name is not found at $path"
        return 1
    fi
}

# Check Snap packages
check_snap() {
    local package="$1"
    local name="$2"
    
    if command -v snap &> /dev/null && snap list "$package" &> /dev/null; then
        echo_pass "$name is installed via Snap"
        return 0
    else
        echo_fail "$name is not installed via Snap"
        return 1
    fi
}

# Check Flatpak packages
check_flatpak() {
    local package="$1"
    local name="$2"
    
    if command -v flatpak &> /dev/null && flatpak list | grep -q "$package"; then
        echo_pass "$name is installed via Flatpak"
        return 0
    else
        echo_fail "$name is not installed via Flatpak"
        return 1
    fi
}

echo "Checking COSMIC SVM development tools installation..."
echo "=================================================="

# System tools
echo ""
echo "System Tools:"
check_command "curl" "curl"
check_command "wget" "wget"
check_command "git" "git"

# Programming Languages
echo ""
echo "Programming Languages:"
check_command "rustc" "Rust"
check_command "cargo" "Cargo (Rust package manager)"
check_command "zig" "Zig"
check_command "crystal" "Crystal"
check_command "node" "Node.js"
check_command "npm" "npm"
check_command "go" "Go"
check_command "python3" "Python 3"
check_command "pip3" "pip3"
check_command "deno" "Deno"
check_command "bun" "Bun"

# Mobile Development
echo ""
echo "Mobile Development:"
check_command "npx" "npx (React Native)"
check_path "$HOME/.local/flutter/bin/flutter" "Flutter"
check_command "kotlin" "Kotlin"

# Package Managers
echo ""
echo "Package Managers:"
check_command "pnpm" "pnpm"
check_command "yarn" "yarn"
check_command "cargo" "Cargo"

# Check Android Studio
echo ""
echo "IDE and Development Tools:"
if check_snap "android-studio" "Android Studio"; then
    :
elif check_path "/opt/android-studio" "Android Studio"; then
    :
elif check_path "/usr/local/android-studio" "Android Studio"; then
    :
else
    echo_fail "Android Studio not found"
fi

# Check Visual Studio Code
if check_snap "code" "Visual Studio Code"; then
    :
elif check_command "code" "Visual Studio Code"; then
    :
else
    echo_fail "Visual Studio Code not found"
fi

# Check Insomnia
if check_snap "insomnia" "Insomnia"; then
    :
elif check_flatpak "rest.insomnia.Insomnia" "Insomnia"; then
    :
else
    echo_fail "Insomnia not found"
fi

# Network Tools
echo ""
echo "Network Tools:"
check_command "tor" "Tor"
check_command "tailscale" "Tailscale"
check_command "yggdrasil" "Yggdrasil"
check_command "i2pd" "i2pd (I2P daemon)"

# Container Tools
echo ""
echo "Container Tools:"
check_command "docker" "Docker"
check_command "docker-compose" "Docker Compose"

# Version Control & Collaboration
echo ""
echo "Version Control & Collaboration:"
check_command "gh" "GitHub CLI"

# System Tools
echo ""
echo "System Tools:"
check_command "jq" "jq (JSON processor)"
check_command "htop" "htop"
check_command "tmux" "tmux"
check_command "fzf" "fzf (fuzzy finder)"
check_command "shellcheck" "ShellCheck"

# Specialized Tools
echo ""
echo "Specialized Tools:"
check_command "osvm" "OSVM CLI"
check_command "anza" "Anza CLI"

# PWA Tools
echo ""
echo "PWA Development Tools:"
check_command "ng" "Angular CLI"
check_command "create-react-app" "Create React App"
check_command "lighthouse" "Lighthouse"
check_command "workbox" "Workbox CLI"

# Development & Testing Tools
echo ""
echo "Development & Testing Tools:"
check_command "eslint" "ESLint"
check_command "prettier" "Prettier"
check_command "jest" "Jest"
check_command "playwright" "Playwright"
check_command "cypress" "Cypress"

# Database Tools
echo ""
echo "Database Tools:"
check_command "psql" "PostgreSQL client"
check_command "sqlite3" "SQLite"
check_command "redis-cli" "Redis CLI"

echo ""
echo "=============================================="
echo "Development tools check completed!"
echo ""
echo "Note: Failed checks indicate tools that need to be installed."
echo "Run 'just dev-tools' to install missing tools."