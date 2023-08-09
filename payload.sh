#!/bin/bash

clear

if [ -f /etc/os-release ]; then
    source /etc/os-release
    distribution_name=$NAME

    echo "You are running: $distribution_name"
else
    echo "Could not determine distribution name."
fi
echo "BETA unshackle payload"
passwd_method() {
echo "========== Users ==========="
while IFS=: read -r username password uid gid full_name home_directory shell; do
    if [ $uid -ge 1000 ] || [ $uid -eq 0 ]; then
        echo "Username: $username"
        echo "Home Directory: $home_directory"
        echo "Shell: $shell"
        echo "============================"
    fi
done < /etc/passwd
read -p "Enter username to reset the password: " choice
passwd $choice
}
show_menu() {
    echo "========= unshackle ========="
    echo "1. passwd bin method"
    echo "2. Exit"
    echo "============================"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            clear
            passwd_method
            read -p "Press Enter to continue..."
            show_menu
            ;;
        2)
            clear
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            read -p "Press Enter to continue..."
            show_menu
            ;;
    esac
}
show_menu
