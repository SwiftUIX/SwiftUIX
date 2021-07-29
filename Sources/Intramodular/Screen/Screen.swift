//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A representation of the device's screen.
public class Screen: ObservableObject {
    public static let main = Screen()
    
    public var bounds: CGRect  {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds
        #elseif os(macOS)
        return NSScreen.main?.frame ?? CGRect.zero
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds
        #endif
    }
    
    public var scale: CGFloat {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.scale
        #elseif os(macOS)
        return NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenScale
        #endif
    }
    
    public var orientation: DeviceOrientation {
        .current
    }
    
    var orientationObserver: NSObjectProtocol?
    
    private init() {
        #if os(iOS)
        orientationObserver = NotificationCenter.default.addObserver(
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
        orientationObserver.map(NotificationCenter.default.removeObserver(_:))
    }
}

// MARK: - Extensions -

extension Screen {
    public var size: CGSize {
        bounds.size
    }
    
    public var width: CGFloat {
        bounds.width
    }
    
    public var height: CGFloat {
        bounds.height
    }
    
    public static var size: CGSize {
        main.size
    }
    
    public static var width: CGFloat {
        main.width
    }
    
    public static var height: CGFloat {
        main.height
    }
    
    public var widthMajorSize: CGSize {
        if width >= height {
            return .init(width: height, height: width)
        } else {
            return .init(width: width, height: height)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    public var screen: Screen {
        get {
            self[DefaultEnvironmentKey<Screen>.self] ?? .main
        } set {
            self[DefaultEnvironmentKey<Screen>.self] = newValue
        }
    }
}
