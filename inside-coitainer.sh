#!/bin/bash

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
    if { [ "${CURRENT_DISTRO}" == "ubuntu" ]; }; then
        # Check if required packages are already installed
        if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v wget)" ] || [ ! -x "$(command -v install)" ] || [ ! -x "$(command -v sudo)" ] || [ ! -x "$(command -v bash)" ] || [ ! -x "$(command -v which)" ] || [ ! -x "$(command -v ps)" ]; }; then
            # Install required packages depending on the Linux distribution
            if { [ "${CURRENT_DISTRO}" == "ubuntu" ]; }; then
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

# Checking For Virtualization
function virt_check() {
    # This code checks if the system is running in a supported virtualization.
    # It returns the name of the virtualization if it is supported, or "none" if
    # it is not supported. This code is used to check if the system is running in
    # a virtual machine, and if so, if it is running in a supported virtualization.
    # systemd-detect-virt is a utility that detects the type of virtualization
    # that the system is running on. It returns a string that indicates the name
    # of the virtualization, such as "kvm" or "vmware".
    CURRENT_SYSTEM_VIRTUALIZATION=$(systemd-detect-virt)
    # This case statement checks if the virtualization that the system is running
    # on is supported. If it is not supported, the script will print an error
    # message and exit.
    case ${CURRENT_SYSTEM_VIRTUALIZATION} in
    "docker") ;;
    *)
        echo "Error: the ${CURRENT_SYSTEM_VIRTUALIZATION} virtualization is currently not supported. Please stay tuned for future updates."
        exit 1 # Exit the script with an error code.
        ;;
    esac
}

# Call the virt_check function to check for supported virtualization.
virt_check
