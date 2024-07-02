#!/bin/bash

# Function to log actions with timestamps and color coding
log() {
    local COLOR="$2"
    local TEXT="$(date +"%Y-%m-%d %T") - $1"
    local RESET="\e[0m"
    
    echo -e "${COLOR}${TEXT}${RESET}" | tee -a $LOG_FILE
}

# Function to generate a random password
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Red color for the root privilege check message
RED="\e[31m"
RESET="\e[0m"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root or with sudo${RESET}"
    exit 1
fi

# Default log and password files
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure the log and password files exist with secure permissions
mkdir -p /var/secure
touch $LOG_FILE
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

# Check if an input file is provided, otherwise prompt the user
if [[ "$#" -ne 1 ]]; then
    read -p "Enter the filename containing the user information: " INPUT_FILE
else
    INPUT_FILE=$1
fi

# Validate the input file
if [[ ! -f $INPUT_FILE ]]; then
    log "Input file does not exist: $INPUT_FILE" "\e[31m"  # Red color for errors
    exit 1
fi

# Process each line in the input file
while IFS=';' read -r username groups; do
    # Remove leading and trailing whitespace
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)

    # Check if the username is empty
    if [[ -z "$username" ]]; then
        log "Empty username. Skipping..." "\e[3;33m"  # Yellow color for skipped (italic)
        continue
    fi

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        log "User $username already exists. Skipping..." "\e[3;33m"  # Yellow color for skipped (italic)
        continue
    fi

    # Create the user with a home directory
    useradd -m -s /bin/bash "$username"
    if [[ $? -ne 0 ]]; then
        log "Failed to create user $username. Skipping..." "\e[31m"  # Red color for errors
        continue
    fi
    log "Created user $username with home directory /home/$username" "\e[34m"  # Blue color for success

    # Set home directory permissions
    chown "$username:$username" "/home/$username"
    chmod 700 "/home/$username"
    log "Set permissions for /home/$username" "\e[34m"  # Blue color for success

    # Create and add the user to additional groups
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo $group | xargs)  # Remove whitespace
        if [[ ! $(getent group $group) ]]; then
            groupadd $group
            if [[ $? -eq 0 ]]; then
                log "Created group $group" "\e[34m"  # Blue color for success
            else
                log "Failed to create group $group. Skipping group assignment for $username." "\e[31m"  # Red color for errors
                continue
            fi
        fi
        usermod -aG "$group" "$username"
        log "Added user $username to group $group" "\e[34m"  # Blue color for success
    done

    # Generate and set a random password for the user
    password=$(generate_password)
    echo "$username,$password" >> $PASSWORD_FILE
    echo "$username:$password" | chpasswd
    log "Set password for user $username" "\e[34m"  # Blue color for success

done < "$INPUT_FILE"

log "User creation process completed." "\e[34m"  # Blue color for success

exit 0
