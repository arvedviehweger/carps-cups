#!/bin/bash

CONFIG_FILE="Icons/icon_config.txt"
IMAGEABLE_FILE="patches/new_imageable_areas.txt"
HW_FILE="patches/new_hw_block.txt"

# 1. Patch *ImageableArea-Blocks in all PPD files
echo "Patching *ImageableArea-Blocks in all PPD files..."

for file in ppd/*.ppd; do
    awk -v imagefile="$IMAGEABLE_FILE" '
    BEGIN {
        while ((getline line < imagefile) > 0) {
            newblock[++n] = line
        }
        block_inserted = 0
    }

    /^\*ImageableArea / {
        if (!block_inserted) {
            for (i = 1; i <= n; i++) print newblock[i]
            block_inserted = 1
        }
        next
    }

    {
        print
    }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done

# 1b. Patch *MaxMediaWidth, *MaxMediaHeight and *HWMargins in all PPD files
echo "Patching *MaxMediaWidth, *MaxMediaHeight and *HWMargins in all PPD files..."

for file in ppd/*.ppd; do
    awk -v hwfile="$HW_FILE" '
    BEGIN {
        while ((getline line < hwfile) > 0) {
            newblock[++n] = line
        }
        block_inserted = 0
    }

    /^\*MaxMediaWidth:|^\*MaxMediaHeight:|^\*HWMargins:/ {
        if (!block_inserted) {
            for (i = 1; i <= n; i++) print newblock[i]
            block_inserted = 1
        }
        next
    }

    {
        print
    }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done

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