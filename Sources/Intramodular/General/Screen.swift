//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A representation of the device's screen.
public class Screen: ObservableObject {
    public static let main = Screen()
    
    private let notificationCenter = NotificationCenter.default
    
    public var bounds: CGRect  {
        #if os(iOS) || os(tvOS) || os(watchOS)
        return UIScreen.main.bounds
        #elseif os(macOS)
        return NSScreen.main?.frame ?? CGRect.zero
        #endif
    }
    
    var orientationObserver: NSObjectProtocol?
    
    private init() {
        #if os(iOS) || os(tvOS) || os(watchOS)
        orientationObserver = notificationCenter.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?.objectWillChange.send()
            }
        )
        #endif
    }
    
    deinit {
        orientationObserver.map(notificationCenter.removeObserver(_:))
    }
}
