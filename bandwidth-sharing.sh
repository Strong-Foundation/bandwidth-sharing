#!/bin/bash

# Troubleshooting:
# - If you encounter issues, ensure your system is up-to-date and retry the installation.
# - For specific errors, refer to the 'Troubleshooting' section in the repository's documentation.

# Contributing:
# - Contributions to the script are welcome. Please follow the contributing guidelines in the repository.

# Contact Information:
# - For support, feature requests, or bug reports, please open an issue on the GitHub repository.

# License: MIT License

# Note: This script is provided 'as is', without warranty of any kind. The user is responsible for understanding the operations and risks involved.

# Check if the script is running as root
function check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run as root."
        exit 1
    fi
}

# Call the function to check root privileges
check_root

# Function to gather current system details
function system_information() {
    # This function fetches the ID, version, and major version of the current system
    if [ -f /etc/os-release ]; then
        # If /etc/os-release file is present, source it to obtain system details
        # shellcheck source=/dev/null
        source /etc/os-release
        CURRENT_DISTRO=${ID} # CURRENT_DISTRO holds the system's ID
    fi
}

# Invoke the system_information function
system_information

# Define a function to check system requirements
function installing_system_requirements() {
    # Check if the current Linux distribution is supported
    if { [ "${CURRENT_DISTRO}" == "raspbian" ]; }; then
        # Check if required packages are already installed
        if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v wget)" ] || [ ! -x "$(command -v install)" ] || [ ! -x "$(command -v sudo)" ] || [ ! -x "$(command -v bash)" ] || [ ! -x "$(command -v which)" ] || [ ! -x "$(command -v ps)" ]; }; then
            # Install required packages depending on the Linux distribution
            if { [ "${CURRENT_DISTRO}" == "raspbian" ]; }; then
                apt-get update
                apt-get install curl coreutils wget r-base-core sudo bash debianutils procps-ng -y
            fi
        fi
    else
        echo "Error: Your current distribution ${CURRENT_DISTRO} is not supported by this script. Please consider updating your distribution or using a supported one."
        exit
    fi
}

# Call the function to check for system requirements and install necessary packages if needed
installing_system_requirements

# The following function checks if the current init system is one of the allowed options.
function check_current_init_system() {
    # Get the current init system by checking the process name of PID 1.
    CURRENT_INIT_SYSTEM=$(ps -p 1 -o comm= | awk -F'/' '{print $NF}') # Extract only the command name without the full path.
    # Convert to lowercase to make the comparison case-insensitive.
    CURRENT_INIT_SYSTEM=$(echo "$CURRENT_INIT_SYSTEM" | tr '[:upper:]' '[:lower:]')
    # Log the detected init system (optional for debugging purposes).
    echo "Detected init system: ${CURRENT_INIT_SYSTEM}"
    # Define a list of allowed init systems (case-insensitive).
    ALLOWED_INIT_SYSTEMS=("systemd" "sysvinit" "init" "upstart" "bash" "sh")
    # Check if the current init system is in the list of allowed init systems
    if [[ ! "${ALLOWED_INIT_SYSTEMS[*]}" =~ ${CURRENT_INIT_SYSTEM} ]]; then
        # If the init system is not allowed, display an error message and exit with an error code.
        echo "Error: The '${CURRENT_INIT_SYSTEM}' initialization system is not supported. Please stay tuned for future updates."
        exit 1 # Exit the script with an error code.
    fi
}

# The check_current_init_system function is being called.
check_current_init_system

# Global variables
CURRENT_SYSTEM_ARCHITECTURE=$(uname -m)

# Check and installer docker.
function check_install_docker() {
    if { [ ! -x "$(command -v docker)" ] || [ ! -x "$(command -v docker-compose)" ]; }; then
        apt-get update
        apt-get install ca-certificates -y
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/raspbian/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/raspbian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        apt-get update
        apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        docker run hello-world
        service docker start
        docker run hello-world
    fi
}

# Check and install docker
check_install_docker
