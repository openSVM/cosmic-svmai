# COSMIC SVM Development Tools

This document describes the development tools setup for COSMIC SVM applications.

## Quick Start

```bash
# Install all development tools
just dev-tools

# Check installation status
just dev-tools-check
```

## Supported Tools

### Programming Languages

- **Rust**: Systems programming language focused on safety, speed, and concurrency
- **Zig (latest version)**: Fast, robust, optimal programming language
- **Crystal (latest version)**: Fast as C, slick as Ruby
- **Go**: Open source programming language for building simple, reliable, and efficient software
- **Node.js & npm**: JavaScript runtime and package manager
- **Python 3 & pip**: High-level programming language and package installer
- **Deno**: Secure runtime for JavaScript and TypeScript
- **Bun**: Fast all-in-one JavaScript runtime

### Mobile Development

- **React Native CLI**: Create mobile apps with React
- **Flutter**: Google's UI toolkit for mobile, web, and desktop
- **Kotlin**: Modern programming language for Android development
- **Android Studio**: Official IDE for Android development

### Development Tools

- **Visual Studio Code**: Lightweight but powerful source code editor
- **Insomnia**: REST/GraphQL API client
- **GitHub CLI**: Command line tool for GitHub
- **fzf**: Command-line fuzzy finder

### Container Tools

- **Docker**: Platform for developing, shipping, and running applications in containers
- **Docker Compose**: Tool for defining and running multi-container Docker applications

### Package Managers

- **pnpm**: Fast, disk space efficient package manager
- **yarn**: Reliable, secure, and fast dependency management
- **Cargo**: Rust package manager (installed with Rust)

### Network Tools

- **Tor**: Anonymous communication network
- **Tailscale**: Zero-config VPN built on WireGuard
- **Yggdrasil**: End-to-end encrypted IPv6 network
- **i2p**: Anonymous overlay network

### System Tools

- **jq**: Command-line JSON processor
- **htop**: Interactive process viewer
- **tmux**: Terminal multiplexer
- **ShellCheck**: Static analysis tool for shell scripts
- **vim/neovim**: Text editors

### Database Tools

- **PostgreSQL client**: Command line client for PostgreSQL
- **SQLite**: Self-contained SQL database engine
- **Redis CLI**: Command line interface for Redis

### Development & Testing Tools

- **ESLint**: JavaScript code analysis tool
- **Prettier**: Code formatter
- **Jest**: JavaScript testing framework
- **Playwright**: Browser automation library
- **Cypress**: End-to-end testing framework

### PWA Development Tools

- **Angular CLI**: Command line interface for Angular
- **Create React App**: Set up modern React web apps
- **Lighthouse**: Web page quality auditing
- **Workbox**: JavaScript libraries for PWAs

### Specialized Tools

- **OSVM CLI**: OpenSVM command line interface (placeholder)
- **Anza CLI**: Anza development tools (placeholder)

## Manual Installation

If the automated installation fails or you prefer manual setup, you can install tools individually:

### Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

### Zig
```bash
# Download latest from https://ziglang.org/download/
wget https://ziglang.org/download/$(version)/zig-linux-x86_64-$(version).tar.xz
tar -xf zig-linux-x86_64-$(version).tar.xz
sudo mv zig-linux-x86_64-$(version) /opt/zig
sudo ln -s /opt/zig/zig /usr/local/bin/zig
```

### Crystal
```bash
curl -fsSL https://crystal-lang.org/install.sh | sudo bash
```

### Go
```bash
# Download from https://golang.org/dl/
wget https://go.dev/dl/go$(version).linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go$(version).linux-amd64.tar.gz
echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
```

### Flutter
```bash
# Download from https://flutter.dev/docs/get-started/install/linux
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$(version)-stable.tar.xz
tar -xf flutter_linux_$(version)-stable.tar.xz
sudo mv flutter /opt/
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
```

### Docker
```bash
# Ubuntu/Debian
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Deno
```bash
curl -fsSL https://deno.land/install.sh | sh
echo 'export PATH="$HOME/.deno/bin:$PATH"' >> ~/.bashrc
```

### Bun
```bash
curl -fsSL https://bun.sh/install | bash
echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc
```

## PWA Development

For developing Progressive Web Apps for opensvm.com, larp.dev, and aeamcp.com:

1. Install the PWA development tools with `just dev-tools`
2. Use Angular CLI for opensvm.com:
   ```bash
   ng new opensvm-app
   ng add @angular/pwa
   ```
3. Use React for other PWAs:
   ```bash
   npx create-react-app larp-app
   npx create-react-app aeamcp-app
   ```

## Troubleshooting

### Permission Issues
If you encounter permission issues, ensure you're not running as root:
```bash
whoami  # Should not be root
```

### PATH Issues
After installation, source your shell profile:
```bash
source ~/.bashrc
# or
source ~/.zshrc
```

### Missing Dependencies
Install system dependencies manually if the script fails:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install curl wget git build-essential pkg-config libssl-dev \
    jq htop tmux vim neovim postgresql-client sqlite3 redis-tools \
    python3 python3-pip shellcheck

# Fedora
sudo dnf install curl wget git gcc gcc-c++ make pkgconfig openssl-devel \
    jq htop tmux vim neovim postgresql sqlite redis python3 python3-pip ShellCheck

# Arch Linux
sudo pacman -S curl wget git base-devel openssl jq htop tmux vim neovim \
    postgresql sqlite redis python python-pip shellcheck
```

### Docker Permission Issues
After installing Docker, add your user to the docker group:
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Node.js/npm Issues
If you encounter npm permission issues, you can fix them by changing npm's default directory:
```bash
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

## Contributing

To add support for new development tools:

1. Add installation logic to `scripts/install-dev-tools.sh`
2. Add verification logic to `scripts/check-dev-tools.sh`
3. Update this documentation
4. Test the installation on a clean system