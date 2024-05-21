//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS)

import Foundation
import SwiftUI

extension Bundle {
    public var _SwiftUIX_appIconImage: AppKitOrUIKitImage? {
#if os(macOS)
        if let icon = infoDictionary?["CFBundleIconFile"] as? String, let image = image(forResource: icon) {
            return image
        }
        
        if
            let bundleIdentifier,
            let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
        {
            return NSWorkspace.shared.icon(forFile: url.pathExtension)
        }
#endif
        
        if
            let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last
        {
            return AppKitOrUIKitImage(named: .bundleResource(lastIcon, in: self))
        } else if let iconFile = infoDictionary?["CFBundleIconFile"] as? String {
            return AppKitOrUIKitImage(named: .bundleResource(iconFile, in: self))
        } else {
            return nil
        }
    }
}

#endif
