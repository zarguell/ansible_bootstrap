#!/bin/bash
set -e

echo "Linux Server Bootstrap Script"
echo "============================"
echo

# Default values
REPO_URL="https://github.com/zarguell/ansible_bootstrap.git"
CLONE_DIR="/tmp/ansible_bootstrap"

# Script options
RUN_PLAYBOOK=true
while getopts ":cr:n:" opt; do
  case ${opt} in
    c )
      # Clone only option
      RUN_PLAYBOOK=false
      ;;
    r )
      # Repository URL option
      REPO_URL=$OPTARG
      ;;
    n )
      # Clone directory option
      CLONE_DIR=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-c] [-r repo_url] [-n clone_dir]"
      echo "  -c: Clone only (don't run the playbook)"
      echo "  -r: Repository URL (default: $REPO_URL)"
      echo "  -n: Clone directory (default: $CLONE_DIR)"
      exit 1
      ;;
  esac
done

# Detect operating system
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

# Install dependencies for RHEL/Rocky Linux/CentOS
install_deps_rhel() {
    echo "Installing dependencies on RHEL/Rocky Linux..."
    sudo dnf install -y epel-release
    sudo dnf install -y ansible git
}

# Install dependencies for Ubuntu
install_deps_ubuntu() {
    echo "Installing dependencies on Ubuntu..."
    sudo apt-get update
    sudo apt-get install -y software-properties-common git
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
}

# Install dependencies for Debian
install_deps_debian() {
    echo "Installing dependencies on Debian..."
    sudo apt-get update
    sudo apt-get install -y software-properties-common git
    sudo apt-get install -y ansible
}

# Check if required dependencies are installed
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

# Clone the repository and set up configuration
clone_repo() {
    echo "Cloning bootstrap repository from $REPO_URL to $CLONE_DIR..."
    if [ -d "$CLONE_DIR" ]; then
        echo "Removing existing directory $CLONE_DIR"
        rm -rf "$CLONE_DIR"
    fi

    git clone "$REPO_URL" "$CLONE_DIR"
    cd "$CLONE_DIR"

    # Configure ansible.cfg for better output and compatibility
    if [ -f ansible.cfg ]; then
        # Add deprecation warnings suppression
        if grep -q "^deprecation_warnings" ansible.cfg; then
            sed -i 's/^deprecation_warnings.*/deprecation_warnings = False/' ansible.cfg
        else
            echo "deprecation_warnings = False" >> ansible.cfg
        fi

        # Set interpreter to auto_silent
        if grep -q "^interpreter_python" ansible.cfg; then
            sed -i 's/^interpreter_python.*/interpreter_python = auto_silent/' ansible.cfg
        else
            echo "interpreter_python = auto_silent" >> ansible.cfg
        fi

        # Remove problematic stdout callback that might not be available
        if grep -q "stdout_callback = yaml" ansible.cfg; then
            sed -i '/stdout_callback = yaml/d' ansible.cfg
        fi
    else
        # Create a minimal ansible.cfg
        cat > ansible.cfg << EOF
[defaults]
inventory = inventory
roles_path = roles
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent
deprecation_warnings = False
EOF
    fi

    # Create necessary directory structure
    echo "Creating necessary vars directories and files..."
    mkdir -p vars
    mkdir -p roles/{common,ansible_user,sudo_config,repos,oh_my_zsh,utilities,docker}/{vars,tasks,handlers,templates}

    # Create default vars file
    if [ ! -f vars/default.yml ]; then
        echo "---" > vars/default.yml
        echo "# Default variables for all roles" >> vars/default.yml
    fi

    # Create default vars files for each role
    for role in common ansible_user sudo_config repos oh_my_zsh utilities docker; do
        if [ ! -f "roles/$role/vars/default.yml" ]; then
            echo "---" > "roles/$role/vars/default.yml"
            echo "# Default variables for $role role" >> "roles/$role/vars/default.yml"
        fi
    done

    echo "Repository cloned successfully to $CLONE_DIR"
}

# Run the Ansible playbook
run_playbook() {
    echo "Running Ansible playbook..."
    cd "$CLONE_DIR"
    ansible-playbook -i inventory server_bootstrap.yml
}

# Main execution function
main() {
    detect_os

    # Check and install dependencies if needed
    if ! check_deps; then
        case $ID in
            rhel|rocky|centos|fedora|almalinux)
                install_deps_rhel
                ;;
            ubuntu)
                install_deps_ubuntu
                ;;
            debian)
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

    # Clone repository and setup
    clone_repo

    # Run playbook or show manual instructions
    if [ "$RUN_PLAYBOOK" = true ]; then
        run_playbook
        echo "Bootstrap completed successfully!"
        echo ""
        echo "Docker has been installed and configured."
        echo "You may need to log out and back in for Docker group membership to take effect."
    else
        echo "Repository cloned to $CLONE_DIR - ready for manual configuration"
        echo "To run the playbook manually: cd $CLONE_DIR && ansible-playbook -i inventory server_bootstrap.yml"
    fi
}

main