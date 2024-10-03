#!/bin/bash

# This script builds DocC documentation for hosting on GitHub pages.

# Build DocC documentation
swift package resolve;
xcodebuild docbuild -scheme SwiftUIX -derivedDataPath /tmp/docbuild -destination 'generic/platform=iOS';

# Transform the generated documentation for static hosting
$(xcrun --find docc) process-archive \
    transform-for-static-hosting /tmp/docbuild/Build/Products/Debug-iphoneos/SwiftUIX.doccarchive \
    --output-path docs \
    --hosting-base-path 'SwiftUIX';

# Inject a redirect script into the empty documentation root
echo "<script>window.location.href += \"/documentation/swiftuix\"</script>" > docs/index.html;