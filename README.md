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

1. Clone this repository to your new server or download the bootstrap script:

```bash
curl -O https://example.com/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

This will:
- Detect your OS
- Install Ansible if needed
- Create the necessary configuration files
- Run the playbook to configure your server

## Manual Installation

If you prefer to run the steps manually:

1. Install Ansible:
   - For RHEL/Rocky Linux: `sudo dnf install -y epel-release && sudo dnf install -y ansible`
   - For Ubuntu/Debian: `sudo apt update && sudo apt install -y software-properties-common && sudo apt-add-repository --yes --update ppa:ansible/ansible && sudo apt install -y ansible`

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
   mkdir -p roles/new_role/tasks
   ```

2. Add the role's main tasks file:
   ```bash
   nano roles/new_role/tasks/main.yml
   ```

3. Update the main playbook to include your new role:
   ```yaml
   - role: new_role
     when: modules.new_role | default(false)
     tags: new_role
   ```

4. Update the config.yml file to add your new module:
   ```yaml
   modules:
     # existing modules...
     new_role: true
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

## License

MIT