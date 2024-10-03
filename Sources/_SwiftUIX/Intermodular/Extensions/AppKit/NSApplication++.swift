//
// Copyright (c) Vatsal Manot
//

import Foundation

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
    public static var _SwiftUIX_isRunningFromApplicationsDirectory: Bool? {
        let bundleURL: URL = Bundle.main.bundleURL
        let applicationsURL: URL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        var applicationsPath: String = applicationsURL.path
        
        if applicationsPath.hasSuffix("/") {
            applicationsPath.removeLast()
        }
        
        if bundleURL.deletingLastPathComponent().path.hasPrefix(applicationsURL.path) {
            return true
        } else {
            if bundleURL._isPossiblyTranslocated {
                #if DEBUG
                guard ProcessInfo.processInfo.environment["__XCODE_BUILT_PRODUCTS_DIR_PATHS"] == nil else {
                    return false
                }
                #endif
                
                return nil
            } else {
                return false
            }
        }
    }
            
    public static func _SwiftUIX_copyAppToApplicationsDirectoryIfNeeded(
        applicationsDirectory: URL? = nil
    ) throws {
        guard _SwiftUIX_isRunningFromApplicationsDirectory == false else {
            return
        }
        
        let bundle: Bundle = Bundle.main
        let bundleURL: URL = bundle.bundleURL
                
        // Assert that the bundle URL points to an .app bundle
        assert(bundleURL.pathExtension == "app", "The bundle URL must point to an .app bundle.")
        
        let fileManager = FileManager.default
        let applicationsDirectory: URL = applicationsDirectory ?? URL(fileURLWithPath: "/Applications", isDirectory: true)
        let destinationURL: URL = applicationsDirectory.lastPathComponent.hasPrefix(bundleURL.lastPathComponent) ? applicationsDirectory : applicationsDirectory.appendingPathComponent(bundleURL.lastPathComponent)
        
        // Check if the app is already running from the /Applications folder
        if bundleURL.deletingLastPathComponent() == applicationsDirectory {
            debugPrint("The app is already running from the /Applications folder.")
            
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
    
    fileprivate enum CopyToApplicationsDirectoryError: Error {
        case unknown(Error)
    }
}

#endif

// MARK: - Auxiliary

extension URL {
    fileprivate var _isPossiblyTranslocated: Bool {
        path.contains("AppTranslocation")
    }
}
