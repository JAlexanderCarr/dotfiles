# Dotfiles

This repository contains all configuration files, scripts, and automation helpers for setting up a development environment on Linux and macOS. The setup is OS-aware and supports multiple package managers.

## Repository Structure

- **files/**: All core dotfiles to be installed in your home directory (e.g., zshrc, bashrc, gitconfig, etc.).
- **fonts/**: Developer fonts organized by subfolder (one folder per font family) and a generic installation script that installs all .otf fonts from every subdirectory.
- **packages/**: OS-aware installation scripts for development tools, programming languages, Docker, Kubernetes, and more. Each script handles installation for multiple distributions and package managers.
- **scripts/**: Main automation scripts:
  - `install.sh`: Installs dotfiles, all packages, and fonts. Orchestrates the setup process and provides clear logs.
  - `restore_backup.sh`: Restores dotfiles and configs from backup, with safety prompts.

## How to Install Everything

1. **Clone the Repository**

   ```sh
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

2. **Run the Main Install Script**

   ```sh
   bash scripts/install.sh
   ```

   This will:
   - Backup your existing dotfiles/configs
   - Install all files from `files/` to your home directory
   - Install all packages in `packages/` (OS-aware)
   - Install all developer fonts found in subfolders under `fonts/` (add new fonts by creating a new subfolder with .otf files)
   - Log each step with clear output

   > **Note:** The scripts do not use `sudo` internally. If you need to install to system directories, run the script with the necessary privileges.

## How to Restore Backups

If you want to restore your previous dotfiles/configs from a backup:

```sh
bash scripts/restore_backup.sh
```

You will be prompted before restoring. Use the `-y` flag to skip the prompt for automation:

```sh
bash scripts/restore_backup.sh -y
```

## Supported Operating Systems & Package Managers

- **macOS**: Homebrew
- **Debian/Ubuntu**: apt
- **Fedora**: dnf
- **CentOS/RHEL/Amazon Linux**: yum
- **Arch Linux**: pacman

## Customization

- Edit or add files in `files/` to manage your dotfiles.
- Add or update package scripts in `packages/` to install additional tools.
- Place additional fonts in `fonts/` and update `fonts/install.sh` as needed.
