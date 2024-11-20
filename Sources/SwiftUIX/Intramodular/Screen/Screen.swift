//
// Copyright (c) Vatsal Manot
//

#if os(macOS)
import AppKit
#endif
import Combine
import Swift
import SwiftUI
#if os(iOS)
import UIKit
#endif

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)

/// A representation of the device's screen.
@_documentation(visibility: internal)
public class Screen: ObservableObject {
    public static let main = Screen()
    
    public static var bounds: CGRect {
        main.bounds
    }
    
    public var bounds: CGRect  {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds
        #elseif os(macOS)
        return NSScreen.main?.frame ?? CGRect.zero
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds
        #elseif os(visionOS)
        assertionFailure("unimplemented")
        
        return .zero
        #endif
    }
    
    public var scale: CGFloat {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.scale
        #elseif os(macOS)
        return NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenScale
        #elseif os(visionOS)
        assertionFailure("unimplemented")

        return .zero
        #endif
    }
    
    public var orientation: DeviceOrientation {
        .current
    }
    
    var orientationObserver: NSObjectProtocol?
        
    #if  os(iOS) || os(macOS) || os(tvOS)
    var appKitOrUIKitScreen: AppKitOrUIKitScreen?
    #endif
    
    private init() {
        #if os(iOS)
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?._objectWillChange_send()
            }
        )
        #endif
        
        #if  os(iOS) || os(macOS) || os(tvOS)
        self.appKitOrUIKitScreen = nil
        #endif
    }
    
    deinit {
        orientationObserver.map(NotificationCenter.default.removeObserver(_:))
    }
}

#if  os(iOS) || os(macOS) || os(tvOS)
extension Screen {
    public convenience init(_ screen: AppKitOrUIKitScreen?) {
        self.init()
        
        #if os(macOS)
        self.appKitOrUIKitScreen = screen
        #endif
    }
}
#endif

// MARK: - Extensions

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

// MARK: - Conformances

extension Screen: Hashable {
    public func hash(into hasher: inout Hasher) {
        #if os(iOS) || os(macOS) || os(tvOS)
        if let appKitOrUIKitScreen {
            hasher.combine(ObjectIdentifier(appKitOrUIKitScreen))
        } else {
            hasher.combine(ObjectIdentifier((AppKitOrUIKitScreen.main as Optional<AppKitOrUIKitScreen>)!)) // FIXME: !!!
        }
        #else
        hasher.combine(ObjectIdentifier(self)) // FIXME: !!!
        #endif
    }
    
    public static func == (lhs: Screen, rhs: Screen) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension EnvironmentValues {
    public var screen: Screen {
        get {
            self[DefaultEnvironmentKey<Screen>.self] ?? .main
        } set {
            self[DefaultEnvironmentKey<Screen>.self] = newValue
        }
    }
}

#endif
