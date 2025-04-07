#!/bin/bash

set -e

echo "Linux Server Bootstrap Script"
echo "============================"
echo

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
        ID=$ID
    else
        echo "Cannot detect OS, exiting."
        exit 1
    fi
    
    echo "Detected OS: $OS $VERSION"
}

# Function to install Ansible on RHEL/Rocky Linux
install_ansible_rhel() {
    echo "Installing Ansible on RHEL/Rocky Linux..."
    sudo dnf install -y epel-release
    sudo dnf install -y ansible
}

# Function to install Ansible on Ubuntu/Debian
install_ansible_debian() {
    echo "Installing Ansible on Ubuntu/Debian..."
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
}

# Function to check if Ansible is installed
check_ansible() {
    if command -v ansible >/dev/null 2>&1; then
        echo "Ansible is already installed."
        return 0
    else
        return 1
    fi
}

# Function to run the Ansible playbook
run_playbook() {
    echo "Running Ansible playbook..."
    ansible-playbook -i inventory server_bootstrap.yml
}

# Main script execution
main() {
    detect_os
    
    if ! check_ansible; then
        case $ID in
            rhel|rocky|centos|fedora|almalinux)
                install_ansible_rhel
                ;;
            ubuntu|debian)
                install_ansible_debian
                ;;
            *)
                echo "Unsupported OS: $OS"
                exit 1
                ;;
        esac
    fi
    
    # Verify Ansible installation
    ansible --version
    
    # Create necessary files if they don't exist
    mkdir -p roles/{common,ansible_user,sudo_config,repos,oh_my_zsh,utilities}/tasks
    
    if [ ! -f inventory ]; then
        echo "localhost ansible_connection=local" > inventory
    fi
    
    if [ ! -f ansible.cfg ]; then
        echo "[defaults]" > ansible.cfg
        echo "inventory = inventory" >> ansible.cfg
        echo "roles_path = roles" >> ansible.cfg
        echo "host_key_checking = False" >> ansible.cfg
    fi
    
    if [ ! -f config.yml ]; then
        cat > config.yml << EOF
---
# Enable or disable modules
modules:
  ansible_user: true
  sudo_config: true
  repos: true
  oh_my_zsh: true
  utilities: true
EOF
    fi
    
    # Run the playbook
    run_playbook
    
    echo "Bootstrap completed successfully!"
}

main