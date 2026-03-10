#!/usr/bin/env python3
"""
screenshot-generator.py
A utility to generate fake terminal screenshots using the rich library.
If 'rich' isn't installed, it outputs instructions on how to install it safely.
"""

import sys
import os

try:
    from rich.console import Console
    from rich.syntax import Syntax
    from rich.text import Text
except ImportError:
    print("\n[ERROR] The 'rich' python library is required to generate mock screenshots.")
    print("Please install it using your system package manager:")
    print("  sudo apt install python3-rich")
    print("\nOr, if you prefer pip in a virtual environment:")
    print("  python3 -m venv venv")
    print("  source venv/bin/activate")
    print("  pip install rich")
    sys.exit(1)

def generate_mock_screenshot(filename: str, content: str, title: str):
    # Ensure the screenshots directory exists
    os.makedirs("screenshots", exist_ok=True)
    filepath = os.path.join("screenshots", filename)
    
    console = Console(record=True, width=100)
    
    # Print the mock terminal interface
    console.print(f"[bold blue]jk@jk:~/projects/mybash$[/bold blue] {title}")
    console.print(content)
    console.print("[bold blue]jk@jk:~/projects/mybash$[/bold blue] ")
    
    # Export as SVG
    from rich.terminal_theme import MONOKAI
    console.save_svg(filepath, title=title, theme=MONOKAI)
    print(f"\n[SUCCESS] Generated mock screenshot: {filepath}")

# -- Define the content for the screenshots --

network_demo = """[INFO] Checking Internet Connectivity...
[SUCCESS] Internet Connection Successful via 8.8.8.8
[INFO] Scanning ports for 127.0.0.1 from 1 to 1024...
[SUCCESS] Port 22 is open
[SUCCESS] Port 80 is open"""

backup_demo = """[INFO] Starting Quick Backup Utility
=========================================
[INFO] Backing up configuration files...
[SUCCESS] Backed up /home/jk/.bashrc to /home/jk/Backups/.bashrc_20260310_084512.tar.gz
[INFO] Creating system information snapshot...
[SUCCESS] System information snapshot saved to /home/jk/Backups/system_info_20260310_084512.txt
[SUCCESS] Cleanup complete.
=========================================
[SUCCESS] Backup sequence completed!"""

sysinfo_demo = """
[bold blue]===== SYSTEM INFORMATION =====[/bold blue]
[bold green]Hardware Details:[/bold green]
  Hostname:     jk-dev-machine
  Kernel:       6.8.0-100-generic
  Architecture: x86_64

[bold green]CPU Information:[/bold green]
  Model:        AMD Ryzen 9 5900X 12-Core Processor
  Cores:        24

[bold green]Memory Details:[/bold green]
  Total: 31Gi
  Used:  14Gi
  Free:  2.1Gi"""

def main():
    print("Generating Mock Terminal Screenshots (SVG format)...")
    generate_mock_screenshot("network_utils.svg", network_demo, "./network-utilities.sh all")
    generate_mock_screenshot("backup_script.svg", backup_demo, "./quick-backup-script.sh configs")
    generate_mock_screenshot("system_info.svg", sysinfo_demo, "./system-info-tool.sh info")
    print("\nAll done! You can view the SVG files in a web browser.")

if __name__ == "__main__":
    main()
