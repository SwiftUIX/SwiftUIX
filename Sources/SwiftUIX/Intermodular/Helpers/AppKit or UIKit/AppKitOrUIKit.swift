//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import _SwiftUIX

import Swift
import SwiftUI

// MARK: -

#if os(iOS) || os(tvOS) || os(visionOS)

import UIKit

public typealias AppKitOrUIKitHostingView<Content: View> = UIHostingView<Content>

extension NSTextContainer {
    public var containerSize: CGSize {
        get {
            size
        } set {
            size = newValue
        }
    }
}

extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = EditActions
}

extension UIColor {
    @_disfavoredOverload
    public static var accentColor: UIColor? {
        UIColor(named: "AccentColor")
    }
}

extension UIEdgeInsets {
    var _SwiftUI_edgeInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

@_spi(Internal)
extension UIImage.Orientation {
    public init(_ orientation: CGImagePropertyOrientation) {
        switch orientation {
            case .up:
                self = .up
            case .upMirrored:
                self = .upMirrored
            case .down:
                self = .down
            case .downMirrored: 
                self = .downMirrored
            case .left:
                self = .left
            case .leftMirrored:
                self = .leftMirrored
            case .right:
                self = .right
            case .rightMirrored:
                self = .rightMirrored
        }
    }
}

extension UIUserInterfaceStyle {
    public init(from colorScheme: ColorScheme) {
        switch colorScheme {
            case .light:
                self = .light
            case .dark:
                self = .dark
            default:
                self = .unspecified
        }
    }
}

#endif

// MARK: -

#if os(macOS)

import AppKit

public typealias AppKitOrUIKitGraphicsImageRenderer = NSGraphicsImageRenderer

extension NSEdgeInsets {
    public var _SwiftUI_edgeInsets: EdgeInsets {
        EdgeInsets(
            top: top,
            leading: left,
            bottom: bottom,
            trailing: right
        )
    }
}

extension NSImage.SymbolConfiguration {
    public convenience init(pointSize: CGFloat) {
        self.init(
            pointSize: pointSize,
            weight: .regular
        )
    }
}

extension NSSize {
    public init(_ edgeInsets: EdgeInsets) {
        self.init(
            width: edgeInsets.leading + edgeInsets.trailing,
            height: edgeInsets.top + edgeInsets.bottom
        )
    }
}

extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = NSTextStorageEditActions
}

extension NSWindow {
    @objc open var isHidden: Bool {
        get {
            !isVisible
        } set {
            let isVisible = !newValue
            
            if self.isVisible != isVisible {
                self.setIsVisible(isVisible)
                
                if isVisible {
                    DispatchQueue.main.async {
                        #if os(macOS)
                        NotificationCenter.default.post(name: NSWindow.didBecomeVisibleNotification, object: self)
                        #endif
                    }
                }
            }
        }
    }
}

#endif

// MARK: -

#if targetEnvironment(macCatalyst)

@available(macCatalyst, unavailable)
extension NSWindow.Level {
    public static func + (lhs: Self, rhs: Int) -> Self {
        Self(rawValue: lhs.rawValue + rhs)
    }
    
    public static func + (lhs: Int, rhs: Self) -> Self {
        rhs + lhs
    }
}
#endif

// MARK: -

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

private var _isAnimatingAppKitOrUIKit: Bool = false

public func _withAppKitOrUIKitAnimation(
    _ animation: _AppKitOrUIKitViewAnimation? = .default,
    @_implicitSelfCapture body: @escaping () -> ()
) {
    guard !_areAnimationsDisabledGlobally, !_isAnimatingAppKitOrUIKit, let animation else {
        body()
        
        return
    }
        
    _isAnimatingAppKitOrUIKit = true
    
    AppKitOrUIKitView.animate(
        withDuration: animation.duration ?? 0.3,
        delay: 0,
        options: animation.options ?? [],
        animations: body
    )
    
    _isAnimatingAppKitOrUIKit = false
}

#if os(iOS)
extension AppKitOrUIKitFontDescriptor.SymbolicTraits {
    public static let bold: Self = Self.traitBold
    public static let italic: Self = Self.traitItalic
}
#elseif os(macOS)
extension AppKitOrUIKitFontDescriptor.SymbolicTraits {
    public static let traitBold = Self.bold
    public static let traitItalic = Self.italic
}
#endif

extension AppKitOrUIKitViewController {
    public func _SwiftUIX_setNeedsLayout() {
        view._SwiftUIX_setNeedsLayout()
    }
    
    public func _SwiftUIX_layoutIfNeeded() {
        view._SwiftUIX_layoutIfNeeded()
    }
}

extension EnvironmentValues {
    struct AppKitOrUIKitViewControllerBoxKey: EnvironmentKey {
        typealias Value = _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitViewController>?
        
        static let defaultValue: Value = nil
    }
    
    var _appKitOrUIKitViewControllerBox: AppKitOrUIKitViewControllerBoxKey.Value {
        get {
            self[AppKitOrUIKitViewControllerBoxKey.self]
        } set {
            self[AppKitOrUIKitViewControllerBoxKey.self] = newValue
        }
    }
}

#endif
