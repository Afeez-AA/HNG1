# User and Group Management Script

This Bash script automates user and group management on a Linux system. It reads usernames and associated groups from a file, creates users with random passwords, assigns them to groups, and logs all actions.

## Overview

- **Functionality**: Creates users, sets up home directories, assigns users to specified groups, generates random passwords, and logs actions.
- **Logging**: Logs all actions to `/var/log/user_management.log`.
- **Password Storage**: Stores generated passwords securely in `/var/secure/user_passwords.txt`.
- **Detailed Information**: For detailed explanation of each step and how to run the script, please refer to the [blog post](https://dev.to/afeezaa/automating-user-and-group-management-with-a-bash-script-59je).

## How to Execute

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Afeez-AA/HNG1
   cd HNG1
   ```
2. **Make the Script Executable**:
   ```bash
   chmod +x create_users.sh
   ```
3. **Run the Script with an Input File**:
   ```bash
   sudo bash create_users
   ```
4. **Verify**:
   - Check the log file for actions performed:
   ```bash
   cat /var/log/user_management.log
   ```
   - View the generated passwords:
   ```bash
   sudo cat /var/secure/user_passwords.txt 
   ```

## Blog Post
For a detailed explanation of the script’s functionality, including code breakdown and best practices, refer to the [comprehensive blog post.](https://dev.to/afeezaa/automating-user-and-group-management-with-a-bash-script-59je)
