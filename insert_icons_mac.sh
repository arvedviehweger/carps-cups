#!/bin/bash

CONFIG_FILE="Icons/icon_config.txt"

# Read each line from the configuration file
while IFS=' ' read -r ppd_file icon_path; do
    if [[ -f "ppd/$ppd_file" ]]; then
        echo "Adding icon path to $ppd_file..."
        # Use awk to insert the icon path directly below the *NickName: line
        awk -v icon="*APPrinterIconPath: \"$icon_path\"" '
        {
            print $0
            if ($1 == "*NickName:") {
                print icon
            }
        }' "ppd/$ppd_file" > "ppd/${ppd_file}.tmp" && mv "ppd/${ppd_file}.tmp" "ppd/$ppd_file"
    else
        echo "Warning: $ppd_file not found!"
    fi
done < "$CONFIG_FILE"