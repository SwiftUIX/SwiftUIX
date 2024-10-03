#!/bin/bash

# This script builds docc with SwiftUI module exports disabled.

# Use the script folder to refer to the other scripts.
SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DISABLE="$SCRIPT/docc-swiftui-export-disable.sh"
BUILD="$SCRIPT/docc-build.sh"
ENABLE="$SCRIPT/docc-swiftui-export-enable.sh"

chmod +x "$DISABLE"
chmod +x "$BUILD"
chmod +x "$ENABLE"

bash "$DISABLE"
bash "$BUILD"
bash "$ENABLE"