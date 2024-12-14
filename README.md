# Ultimate Terminal Enhancement

A comprehensive terminal setup to boost productivity and improve your command-line experience.

## Project Structure

```
mybash/
│
├── configs/
│   ├── bash-aliases-custom       # Custom bash aliases
│   ├── bashrc-custom             # Custom bash configuration
│   └── tmux-config               # Tmux configuration
│
├── scripts/
│   ├── network-utilities.sh      # Network-related utility scripts
│   ├── quick-backup-script.sh    # Backup utility
│   └── system-info-tool.sh       # System information gathering tool
│
├── terminal-install.sh           # Installation script
└── terminal-uninstall.sh         # Uninstallation script
```

## Features

- **Shell Customization**
  - Zsh with Oh My Zsh
  - Powerlevel10k theme
  - Custom aliases and configurations

- **Utility Tools**
  - Network utilities
  - System information tools
  - Quick backup script
  - Enhanced tmux configuration

## Prerequisites

- Ubuntu/Debian-based Linux distribution
- Basic terminal knowledge
- Git

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/jk08y/mybash.git
   cd mybash
   ```

2. Make the installation script executable:
   ```bash
   chmod +x terminal-install.sh
   ```

3. Run the installation script:
   ```bash
   ./terminal-install.sh
   ```

4. Restart your terminal or run `zsh`

## Customization

Personalize your setup by editing:
- `configs/bash-aliases-custom`
- `configs/bashrc-custom`
- `configs/tmux-config`

## Uninstallation

To remove the terminal enhancements:
```bash
./terminal-uninstall.sh
```

## Troubleshooting

- Ensure all dependencies are installed
- Check installation logs
- Verify script permissions
- Confirm you're using a compatible Linux distribution

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check [issues page](https://github.com/jk08y/mybash/issues).
