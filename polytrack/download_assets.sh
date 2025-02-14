#!/bin/bash

# Define the input file containing the list of URLs
INPUT_FILE="urls.txt"
# Base URL to remove
BASE_URL="https://html-classic.itch.zone/html/11880944/"

# Ensure the file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Convert Windows line endings to Unix format (if needed)
# This will NOT break the script even if run multiple times
if command -v dos2unix >/dev/null 2>&1; then
    dos2unix "$INPUT_FILE" 2>/dev/null
else
    sed -i 's/\r$//' "$INPUT_FILE"
fi

echo "✅ File '$INPUT_FILE' converted to Unix format (if necessary)."

# Read each line (URL) from the file
while IFS= read -r url; do
    # Trim trailing carriage returns and spaces
    url=$(echo "$url" | tr -d '\r' | xargs)

    # Remove the base URL and fix path formatting
    relative_path=$(echo "$url" | sed "s|$BASE_URL||g" | sed 's|^/||')

    # Ensure the directory exists before downloading
    dir_path=$(dirname "$relative_path")
    mkdir -p "$dir_path"

    # Debugging: Print the correct URL and path
    echo "Downloading: $url"
    echo "Saving as: $relative_path"

    # Download the file, ignoring certificate errors and using a browser-like agent
    wget --no-check-certificate --user-agent="Mozilla/5.0" -O "./$relative_path" "$url"

    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to download: $url"
    else
        echo "✅ Successfully downloaded: $relative_path"
    fi

done < "$INPUT_FILE"

echo "✅ All files processed!"
