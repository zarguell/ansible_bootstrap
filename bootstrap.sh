#!/bin/bash

set -e

echo "Linux Server Bootstrap Script"
echo "============================"
echo

# Default repository URL - replace with your actual repository URL when you create it
REPO_URL="https://github.com/zarguell/ansible_bootstrap.git"
CLONE_DIR="/tmp/ansible_bootstrap"

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

# Function to install Ansible and Git on RHEL/Rocky Linux
install_deps_rhel() {
    echo "Installing dependencies on RHEL/Rocky Linux..."
    sudo dnf install -y epel-release
    sudo dnf install -y ansible git
}

# Function to install Ansible and Git on Ubuntu/Debian
install_deps_debian() {
    echo "Installing dependencies on Ubuntu/Debian..."
    sudo apt-get update
    sudo apt-get install -y software-properties-common git
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
}

# Function to check if Ansible and Git are installed
check_deps() {
    missing_deps=false
    
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Ansible is not installed."
        missing_deps=true
    fi
    
    if ! command -v git >/dev/null 2>&1; then
        echo "Git is not installed."
        missing_deps=true
    fi
    
    if [ "$missing_deps" = true ]; then
        return 1
    else
        echo "Required dependencies are already installed."
        return 0
    fi
}

# Function to clone the repository
clone_repo() {
    echo "Cloning bootstrap repository..."
    if [ -d "$CLONE_DIR" ]; then
        echo "Removing existing directory $CLONE_DIR"
        rm -rf "$CLONE_DIR"
    fi
    
    git clone "$REPO_URL" "$CLONE_DIR"
    cd "$CLONE_DIR"
}

# Function to run the Ansible playbook
run_playbook() {
    echo "Running Ansible playbook..."
    cd "$CLONE_DIR"
    ansible-playbook -i inventory server_bootstrap.yml
}

# Main script execution
main() {
    detect_os
    
    if ! check_deps; then
        case $ID in
            rhel|rocky|centos|fedora|almalinux)
                install_deps_rhel
                ;;
            ubuntu|debian)
                install_deps_debian
                ;;
            *)
                echo "Unsupported OS: $OS"
                exit 1
                ;;
        esac
    fi
    
    # Verify installations
    ansible --version
    git --version
    
    # Clone the repository and run the playbook
    clone_repo
    run_playbook
    
    echo "Bootstrap completed successfully!"
    echo "You can find the configuration files in $CLONE_DIR"
    echo "To make further changes, edit the files and re-run the playbook with:"
    echo "cd $CLONE_DIR && ansible-playbook -i inventory server_bootstrap.yml"
}

main