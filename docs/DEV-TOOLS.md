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
- **Java (OpenJDK)**: Enterprise-grade programming language and platform
- **Swift**: Programming language for iOS, macOS, and server-side development
- **Haskell**: Advanced functional programming language
- **Elixir**: Dynamic, functional language designed for maintainable and scalable applications

### Mobile Development

- **React Native CLI**: Create mobile apps with React
- **Flutter**: Google's UI toolkit for mobile, web, and desktop
- **Kotlin**: Modern programming language for Android development
- **Android Studio**: Official IDE for Android development

### Development Tools

- **Visual Studio Code**: Lightweight but powerful source code editor
- **IntelliJ IDEA Community**: Professional IDE for Java and other JVM languages
- **WebStorm**: JavaScript and Node.js IDE by JetBrains
- **Emacs**: Extensible, customizable text editor and computing environment
- **Cursor IDE**: AI-powered code editor with advanced autocomplete and chat features
- **Zed IDE**: High-performance, multiplayer code editor focused on speed and collaboration
- **Insomnia**: REST/GraphQL API client
- **GitHub CLI**: Command line tool for GitHub
- **fzf**: Command-line fuzzy finder

### Container Tools

- **Docker**: Platform for developing, shipping, and running applications in containers
- **Docker Compose**: Tool for defining and running multi-container Docker applications

### Kubernetes Tools

- **k3s**: Lightweight Kubernetes distribution perfect for development
- **kubectl**: Kubernetes command-line tool
- **k9s**: Terminal UI for managing Kubernetes clusters
- **Helm**: Kubernetes package manager
- **Lens**: Kubernetes IDE for managing clusters (via Snap)

### Package Managers

- **pnpm**: Fast, disk space efficient package manager
- **yarn**: Reliable, secure, and fast dependency management
- **Nix**: Purely functional package manager with reproducible builds
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
- **MongoDB Compass**: GUI for MongoDB database management
- **DBeaver Community**: Universal database tool for developers and database administrators
- **pgAdmin4**: Web-based administration tool for PostgreSQL

### GPU Computing Tools

- **CUDA Toolkit**: NVIDIA's parallel computing platform and programming model
- **nvidia-smi**: NVIDIA System Management Interface for GPU monitoring

### AI/ML Tools

- **Ollama**: Run large language models locally (LLaMA, Mistral, CodeLLaMA, etc.)
- **llama.cpp**: Efficient inference of LLaMA models in C++
- **PyTorch**: Deep learning framework (via pip)
- **Transformers**: State-of-the-art ML library (via pip)

### Security Tools

- **Wireshark**: Network protocol analyzer and packet capture tool
- **Nmap**: Network discovery and security auditing utility
- **OWASP ZAP**: Web application security scanner
- **Burp Suite Community**: Web vulnerability scanner and proxy tool

### Performance and Text Processing Tools

- **Valgrind**: Memory debugging and profiling tool
- **ripgrep (rg)**: Fast text search tool, grep alternative
- **fd**: Simple, fast, and user-friendly alternative to find
- **bat**: Cat clone with syntax highlighting and Git integration
- **exa**: Modern replacement for ls with additional features

### Cloud CLI Tools

- **AWS CLI**: Command line interface for Amazon Web Services
- **Azure CLI**: Command line interface for Microsoft Azure
- **Google Cloud CLI**: Command line interface for Google Cloud Platform
- **Terraform**: Infrastructure as code tool for cloud provisioning
- **Pulumi**: Modern infrastructure as code platform

### Terminal Enhancements

- **Zsh**: Advanced shell with powerful features
- **Oh My Zsh**: Framework for managing Zsh configuration
- **Starship**: Cross-shell prompt with customizable styling

### API Testing Tools

- **Postman**: Comprehensive API development and testing platform
- **HTTPie**: Command line HTTP client with intuitive syntax
- **curlie**: Frontend to curl that adds ease of use of httpie

### Build Tools

- **CMake**: Cross-platform build system generator
- **Meson**: Fast and user-friendly build system
- **Bazel**: Build tool for large-scale software development

### Documentation Tools

- **MkDocs**: Static site generator for project documentation
- **Sphinx**: Documentation generator with extensive customization
- **Pandoc**: Universal document converter

### File Sync and Remote Tools

- **Syncthing**: Continuous file synchronization program
- **rclone**: Command line program to manage files on cloud storage
- **Ansible**: IT automation platform for configuration management
- **SSH tools**: Secure shell client and utilities

### Specialized Browsers

- **Nyxt Browser**: Hackable, programmable browser with Lisp-based configuration

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

### CUDA Toolkit
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nvidia-cuda-toolkit nvidia-driver-535

# Check installation
nvcc --version
nvidia-smi
```

### Cursor IDE
```bash
# Download and install AppImage
wget -O cursor.AppImage https://download.cursor.sh/linux/appImage/x64
chmod +x cursor.AppImage
mkdir -p ~/.local/bin
mv cursor.AppImage ~/.local/bin/cursor
```

### Zed IDE
```bash
# Download from GitHub releases
ZED_VERSION=$(curl -s https://api.github.com/repos/zed-industries/zed/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
wget -O zed.tar.gz "https://github.com/zed-industries/zed/releases/download/${ZED_VERSION}/zed-linux-x86_64.tar.gz"
tar -xzf zed.tar.gz
mkdir -p ~/.local/bin
mv zed-linux-x86_64/zed ~/.local/bin/
```

### Nix Package Manager
```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
# Restart shell or source the nix profile
```

### k3s (Lightweight Kubernetes)
```bash
curl -sfL https://get.k3s.io | sh -
# Add kubectl alias
echo 'alias kubectl="k3s kubectl"' >> ~/.bashrc
```

### Kubernetes Tools
```bash
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# k9s
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
wget -O k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf k9s.tar.gz
sudo mv k9s /usr/local/bin/

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Ollama (Local LLM Runner)
```bash
curl -fsSL https://ollama.com/install.sh | sh

# Run a model (example)
ollama run llama2
ollama run codellama
```

### llama.cpp
```bash
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
make -j$(nproc)
# Binaries will be in the current directory
```

### Nyxt Browser
```bash
# Ubuntu/Debian (if available in repos)
sudo apt install nyxt

# Otherwise download from https://nyxt.atlas.engineer/
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