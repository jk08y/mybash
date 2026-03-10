# mybash

A professional, robust terminal setup designed to significantly boost productivity and elevate the command-line experience. This project provides a set of highly optimized configurations for Bash, Zsh, and Tmux, alongside a suite of essential utility scripts.

## Core Features

- **Advanced Shell Environment (Zsh Dominance)**
  - Configures **Zsh** with the powerful **Oh My Zsh** framework and the blazing-fast **Powerlevel10k** true-color prompt theme.
  - **Auto-Suggestions**: IDE-like predictive typing based on your command history (via `zsh-autosuggestions`).
  - **Syntax Highlighting**: Real-time validation of commands (red/green) protecting against syntax errors before execution (via `zsh-syntax-highlighting`).
  - Includes a meticulously curated set of bash aliases for faster directory navigation, safe file operations, and improved system diagnostics.
  - Secure bash configuration (`.bashrc`) with refined history handling, intelligent archive extraction, and POSIX compliance.

- **Extreme Search with FZF & Modern Tooling**
  - Instantaneous, perfectly styled fuzzy finding integrations across your terminal history and filesystem.
  - Powered automatically by `fd` (lightning fast, honors `.gitignore`) and `bat` (beautiful inline syntax highlighting previews) if installed on your system.

- **System & Network Utilities**
  - **Network Utilities Manager**: A robust CLI to check connectivity, scan ports, run speed tests, and retrieve geolocation data.
  - **Quick Backup Utility**: A safe and efficient backup tool to snapshot your critical configurations, home directory components, and system state.
  - **System Info Dashboard**: A clean, text-based overview of hardware limits, CPU load, memory utilization, and active network interfaces.
  
- **Optimized Multiplexer**
  - **Tmux Configuration**: True-color support, Vim-style pane navigation and resizing, intuitive split bindings, and a clean, responsive status bar.

## Project Architecture

```text
mybash/
│
├── configs/
│   ├── bash-aliases-custom       # Curated system and git aliases
│   ├── bashrc-custom             # Secure, high-performance Bash initialization
│   └── tmux-config               # Advanced Tmux multiplexer settings
│
├── scripts/
│   ├── network-utilities.sh      # CLI for network diagnostics
│   ├── quick-backup-script.sh    # Configuration and directory backup
│   └── system-info-tool.sh       # Hardware and system performance monitoring
│
├── terminal-install.sh           # Automated, secure installation script
└── terminal-uninstall.sh         # Clean uninstallation and state restoration
```

## Prerequisites

To get the most out of `mybash`, ensure your system meets the following requirements:

- **OS**: Ubuntu, Debian, or a closely related Linux distribution.
- **Access**: `sudo` privileges (required strictly for system package installation and changing the default shell).
- **Network**: An active internet connection to download Oh My Zsh and Powerlevel10k.

## Installation Sequence

The installation script is designed to run safely as your standard user, escalating privileges only when required via `sudo`. It automatically backs up your existing dotfiles.

1. **Clone the Repository**
   ```bash
   git clone https://github.com/jk08y/mybash.git
   cd mybash
   ```

2. **Execute Installer**
   ```bash
   chmod +x terminal-install.sh
   ./terminal-install.sh
   ```

3. **Finalize Setup**
   Restart your terminal emulator or explicitly start a new Zsh session by typing `zsh` to load the Powerlevel10k configuration wizard.

## Uninstallation and Restoration

If you wish to revert to your previous environment, the uninstallation script seamlessly restores your original configuration files from the automated timestamped backup directory.

```bash
chmod +x terminal-uninstall.sh
./terminal-uninstall.sh
```

*Note: The uninstaller preserves widely used system packages (like `git`, `curl`, and `zsh`) to avoid breaking other installed software on your machine.*

## Extensibility and Customization

The project is highly modular. You are encouraged to customize the configurations within the `configs/` directory prior to installation to fit your specific workflow requirements.

## Troubleshooting and Support

- **Shell Not Changing**: If the installation script fails to automatically change your default shell to Zsh, you can do so manually by executing `chsh -s $(command -v zsh)`.
- **Command Not Found**: Ensure that `$HOME/bin` is successfully appended to your `$PATH`. This is handled automatically by the installation script, but reloading your terminal is mandatory.

## Contribution Guidelines

We welcome contributions that improve stability, add features, or enhance documentation. Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
