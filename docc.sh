#!/bin/bash

# This script can be run with `bash docc.sh` from the Terminal.

# It prepares the package for DocC by disabling SwiftUI module
# exports then builds DocC documentation for hosting on GitHub
# pages. It also reverts the initial module export changes for
# when it's run locally.

chmod +x docc-build.sh
chmod +x docc-module-replace.sh

./docc-module-replace.sh "@_exported import SwiftUI" "import SwiftUI"
./docc-build.sh
./docc-module-replace.sh "import SwiftUI" "@_exported import SwiftUI"