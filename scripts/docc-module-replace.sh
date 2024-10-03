#!/bin/bash

# This script can be run with `bash docc-module-replace.sh` from the Terminal.

# It replaces two strings in the SwiftUIX modules, and is used to disable the
# default exporting of SwiftUI when building the DocC documentation.

# Define the folders to make the replacement in, and the file name
folders=("Sources/_SwiftUIX" "Sources/SwiftUIX")
file_name="module.swift"

# Define the string to replace and its replacement
old_string=$1
new_string=$2

# Iterate over the folders
for folder in "${folders[@]}"; do

     # Construct full path to the file
    file_path="$folder/$file_name"
    
    # Check if file exists
    if [ -f "$file_path" ]; then

        # Create a temporary file
        temp_file=$(mktemp)
        
        # Perform the replacement and output to temporary file
        sed "s|$old_string|$new_string|g" "$file_path" > "$temp_file"

        # Replace the original file with the modified content
        mv "$temp_file" "$file_path"
    else
        echo "File not found: $file_path"
    fi
done