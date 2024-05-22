//
// Copyright (c) Vatsal Manot
//

#if os(macOS) || targetEnvironment(macCatalyst)

import AppKit
import Cocoa
import Swift
import SwiftUI

@available(macCatalyst, unavailable)
extension NSApplication {
    public var firstKeyWindow: NSWindow? {
        keyWindow
    }
}

@available(macCatalyst, unavailable)
extension NSApplication {
    public static var _SwiftUIX_isRunningFromApplicationsDirectory: Bool = {
        let bundleURL = Bundle.main.bundleURL
        let applicationsURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        
        if bundleURL.deletingLastPathComponent() == applicationsURL {
            return true
        } else {
            return false
        }
    }()
    
    enum CopyToApplicationsDirectoryError: Error {
        case unknown(Error)
    }
    
    public static func _SwiftUIX_copyToApplicationsDirectoryIfNeeded() throws {
        let bundleURL = Bundle.main.bundleURL
        
        // Assert that the bundle URL points to an .app bundle
        assert(bundleURL.pathExtension == "app", "The bundle URL must point to an .app bundle.")
        
        let fileManager = FileManager.default
        let applicationsURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        
        let destinationURL = applicationsURL.appendingPathComponent(bundleURL.lastPathComponent)
        
        // Check if the app is already running from the /Applications folder
        if bundleURL.deletingLastPathComponent() == applicationsURL {
            print("The app is already running from the /Applications folder.")
            return
        }
        
        // Assert that the destination URL is different from the bundle URL
        assert(destinationURL != bundleURL, "The destination URL must be different from the bundle URL.")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                // Assert that the existing item at the destination URL is a directory (app bundle)
                var isDirectory: ObjCBool = false
                fileManager.fileExists(atPath: destinationURL.path, isDirectory: &isDirectory)
                assert(isDirectory.boolValue, "The existing item at the destination URL must be a directory (app bundle).")
                
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: bundleURL, to: destinationURL)
        } catch {
            throw CopyToApplicationsDirectoryError.unknown(error)
        }
    }
}

#endif
