# Linux Server Bootstrap System

A modular Ansible-based system for bootstrapping new Linux servers with your preferred configuration.

## Features

- Automatic OS detection (RHEL/Rocky Linux and Ubuntu/Debian)
- Modular design with Ansible roles
- Passwordless sudo for ansible user
- Oh My Zsh installation with Powerlevel10k theme
- Repository configuration for different distributions
- Common utility package installation
- Local playbook execution

## Quick Start

1. Download and run the bootstrap script:

```bash
curl -O https://example.com/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

This will:
- Detect your OS
- Install Ansible and Git if needed
- Clone the repository
- Run the playbook to configure your server

## Script Options

The bootstrap script supports several options:

```
./bootstrap.sh [-c] [-r repo_url] [-n clone_dir]
```

- `-c`: Clone only (don't run the playbook)
- `-r`: Set custom repository URL (default: https://github.com/yourusername/linux-server-bootstrap.git)
- `-n`: Set custom clone directory (default: /tmp/linux-server-bootstrap)

Examples:

```bash
# Clone only, don't run the playbook
./bootstrap.sh -c

# Use a custom repository
./bootstrap.sh -r https://github.com/myusername/my-bootstrap.git

# Specify a custom clone directory
./bootstrap.sh -n /opt/bootstrap

# Combine options
./bootstrap.sh -c -r https://github.com/myusername/my-bootstrap.git -n /opt/bootstrap
```

## Manual Installation

If you prefer to run the steps manually:

1. Install Ansible and Git:
   - For RHEL/Rocky Linux: `sudo dnf install -y epel-release && sudo dnf install -y ansible git`
   - For Ubuntu/Debian: `sudo apt update && sudo apt install -y software-properties-common git && sudo apt-add-repository --yes --update ppa:ansible/ansible && sudo apt install -y ansible`

2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/linux-server-bootstrap.git
   cd linux-server-bootstrap
   ```

3. Run the playbook:
   ```bash
   ansible-playbook -i inventory server_bootstrap.yml
   ```

## Configuration

Edit the `config.yml` file to enable or disable specific modules:

```yaml
---
# Enable or disable modules
modules:
  ansible_user: true
  sudo_config: true
  repos: true
  oh_my_zsh: true
  utilities: true
```

## Modules

### ansible_user
Creates a dedicated ansible user for automation tasks.

### sudo_config
Configures passwordless sudo access for the ansible user.

### repos
Configures additional repositories based on the Linux distribution.

### oh_my_zsh
Installs and configures Oh My Zsh with the Powerlevel10k theme.

### utilities
Installs common utility packages for system administration.

## Customization

### Adding Utility Packages

Edit `roles/utilities/vars/default.yml` or the OS-specific vars files to add or remove packages.

### Adding Custom Repositories

Edit the repository configuration files in `roles/repos/tasks/` to add custom repositories for your OS.

### Extending Functionality

To add new functionality:

1. Create a new role:
   ```bash
   mkdir -p roles/new_role/{tasks,vars}
   ```

2. Add the role's main tasks file:
   ```bash
   nano roles/new_role/tasks/main.yml
   ```

3. Create a default vars file:
   ```bash
   nano roles/new_role/vars/default.yml
   ```

4. Update the main playbook to include your new role:
   ```yaml
   - role: new_role
     when: modules.new_role | default(false)
     tags: new_role
   ```

5. Update the config.yml file to add your new module:
   ```yaml
   modules:
     # existing modules...
     new_role: true
   ```

## Repository Structure

```
bootstrap/
├── bootstrap.sh                # Main bash script to detect OS and install Ansible
├── ansible.cfg                 # Ansible configuration
├── inventory                   # Inventory file for local execution
├── server_bootstrap.yml        # Main playbook
├── config.yml                  # Configuration file to enable/disable modules
├── README.md                   # Documentation
└── roles/                      # Ansible roles directory
    ├── common/                 # Common tasks across all servers
    │   ├── tasks/
    │   ├── handlers/
    │   └── vars/
    ├── ansible_user/           # Create ansible user
    │   ├── tasks/
    │   └── vars/
    ├── sudo_config/            # Configure sudo for ansible user
    │   ├── tasks/
    │   └── vars/
    ├── repos/                  # Repository configuration
    │   ├── tasks/
    │   └── vars/
    ├── oh_my_zsh/              # Oh My Zsh installation
    │   ├── tasks/
    │   └── vars/
    └── utilities/              # Utility packages installation
        ├── tasks/
        └── vars/
```

## Troubleshooting

### SSH Key Setup

If the script can't find your SSH key, you'll need to manually set it up:

```bash
ssh-copy-id ansible@your-server
```

### Permissions Issues

If you encounter permissions issues, ensure you're running the playbook with sudo privileges:

```bash
sudo ansible-playbook -i inventory server_bootstrap.yml
```

### Playbook Failures

If the playbook fails, check:

1. That all required vars files exist:
   ```bash
   ls -la roles/*/vars/
   ```

2. That the inventory file is correct:
   ```bash
   cat inventory
   ```

3. For more detailed error information, run the playbook with increased verbosity:
   ```bash
   ansible-playbook -i inventory server_bootstrap.yml -vvv
   ```

## License

MIT