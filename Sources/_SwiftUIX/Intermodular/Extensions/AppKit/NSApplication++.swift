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

extension NSApplication {
    public func _SwiftUIX_copyToApplicationsFolderIfNeeded() throws {
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
            print("Successfully copied the app to the Applications folder.")
        } catch {
            assertionFailure("Failed to copy the app to the Applications folder. Error: \(error)")
        }
    }
}

#endif
