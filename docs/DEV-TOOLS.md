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

- **Zig (latest version)**: Fast, robust, optimal programming language
- **Crystal (latest version)**: Fast as C, slick as Ruby

### Mobile Development

- **React Native CLI**: Create mobile apps with React
- **Flutter**: Google's UI toolkit for mobile, web, and desktop
- **Kotlin**: Modern programming language for Android development
- **Android Studio**: Official IDE for Android development

### Development Tools

- **Insomnia**: REST/GraphQL API client

### Network Tools

- **Tor**: Anonymous communication network
- **Tailscale**: Zero-config VPN built on WireGuard
- **Yggdrasil**: End-to-end encrypted IPv6 network
- **i2p**: Anonymous overlay network

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

### Flutter
```bash
# Download from https://flutter.dev/docs/get-started/install/linux
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$(version)-stable.tar.xz
tar -xf flutter_linux_$(version)-stable.tar.xz
sudo mv flutter /opt/
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
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
sudo apt install curl wget git build-essential pkg-config libssl-dev

# Fedora
sudo dnf install curl wget git gcc gcc-c++ make pkgconfig openssl-devel

# Arch Linux
sudo pacman -S curl wget git base-devel openssl
```

## Contributing

To add support for new development tools:

1. Add installation logic to `scripts/install-dev-tools.sh`
2. Add verification logic to `scripts/check-dev-tools.sh`
3. Update this documentation
4. Test the installation on a clean system