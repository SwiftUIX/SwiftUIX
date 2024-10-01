//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension App {
    // Programmatically quit the current application.
    public static func quit() throws {
        NSApplication.shared.terminate(nil)
        throw AppQuitError.unsupported
    }
}
#else
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension App {
    // Programmatically quit the current application.
    public static func quit() throws {
        
    }
}
#endif

#if os(macOS)
@MainActor
extension App {
    public static var _isRunningFromApplicationsDirectory: Bool? {
        NSApplication._SwiftUIX_isRunningFromApplicationsDirectory
    }
    
    public static func _copyAppToApplicationsDirectoryIfNeeded(
        applicationsDirectory: URL? = nil
    ) throws {
        try NSApplication._SwiftUIX_copyAppToApplicationsDirectoryIfNeeded(applicationsDirectory: applicationsDirectory)
    }
}
#endif

// MARK: - Auxiliary

enum AppQuitError: Error {
    case unsupported
}

