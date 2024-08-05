#!/bin/bash

# Define the options for the checklist
options=(
    "Basic" "Run Script 1" on 
    "Dev" "Run Script 2" on
    "Security" "Run Script 3" on
    "Electronics" "Run Script 3" on
    "Communications" "Run Script 3" on
)

# Display the checklist using whiptail
selected=$(whiptail --title "Select Scripts to Run" \
                    --checklist "Choose the scripts you want to execute:" \
                    15 60 5 \
                    "${options[@]}" \
                    3>&1 1>&2 2>&3)

# Check if the user pressed Cancel
if [ $? -ne 0 ]; then
    echo "User canceled."
    exit 1
fi

chmod 777 basic.sh
chmod 777 dev.sh
chmod 777 security.sh
chmod 777 electronics.sh

apt update && apt upgrade -y

#for option in ${selected_array[@]}; do
for option in $(echo "$selected" | sed 's/"//g' | tr -d '\n'); do
    echo "Installing $option..."
    case $option in
        "Basic")
            ./basic.sh
            ;;
        "Dev")
            ./dev.sh
            ;;
        "Security")
            ./security.sh
            ;;
        "Electronics")
            ./electronics.sh
            ;;
        "Communications")
            ./coms.sh
            ;;
        *)
            echo "Unknown option: $option"
            ;;
    esac
done

echo "All selected scripts have been executed."