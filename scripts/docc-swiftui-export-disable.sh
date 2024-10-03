#!/bin/bash

# This script disables the SwiftUI module export.

# Use the script folder to refer to the main script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPT="$DIR/docc-swiftui-export-change.sh"

# Add execution mode to script, then run it
chmod +x "$SCRIPT"
bash "$SCRIPT" "@_exported import SwiftUI" "import SwiftUI"