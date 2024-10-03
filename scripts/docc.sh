#!/bin/bash

# This script can be run with `bash docc.sh` from the Terminal.

# It prepares the package for DocC by disabling SwiftUI module
# exports then builds DocC documentation for hosting on GitHub
# pages. It also reverts the initial module export changes for
# when it's run locally.

# Use the local script folder to refer to other scripts.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BUILD_SCRIPT="$SCRIPT_DIR/docc-build.sh"
REPLACE_SCRIPT="$SCRIPT_DIR/docc-module-replace.sh"

chmod +x "$BUILD_SCRIPT"
chmod +x "$REPLACE_SCRIPT"

bash "$REPLACE_SCRIPT" "@_exported import SwiftUI" "import SwiftUI"
bash "$BUILD_SCRIPT"
bash "$REPLACE_SCRIPT" "import SwiftUI" "@_exported import SwiftUI"