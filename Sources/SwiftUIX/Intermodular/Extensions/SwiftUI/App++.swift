//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension App {
    // Programmatically quit the current application.
    public static func quit() throws {
#if os(macOS)
        NSApplication.shared.terminate(nil)
#else
        throw AppQuitError.unsupported
#endif
    }
}

#if os(macOS)
@MainActor
extension App {
    public static var _isRunningFromApplicationsDirectory: Bool {
        NSApplication._SwiftUIX_isRunningFromApplicationsDirectory
    }
    
    public static func _copyToApplicationsDirectory() throws {
        try NSApplication._SwiftUIX_copyToApplicationsDirectoryIfNeeded()
    }
}
#endif

// MARK: - Auxiliary

enum AppQuitError: Error {
    case unsupported
}

