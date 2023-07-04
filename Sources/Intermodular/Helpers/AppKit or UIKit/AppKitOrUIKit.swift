//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS)

import UIKit

public typealias AppKitOrUIKitApplication = UIApplication
public typealias AppKitOrUIKitApplicationDelegate = UIApplicationDelegate
@available(iOS 14.0, tvOS 14.0, *)
public typealias AppKitOrUIKitApplicationDelegateAdapter = UIApplicationDelegateAdaptor
public typealias AppKitOrUIKitBezierPath = UIBezierPath
public typealias AppKitOrUIKitButton = UIButton
public typealias AppKitOrUIKitCollectionView = UICollectionView
public typealias AppKitOrUIKitCollectionViewFlowLayout = UICollectionViewFlowLayout
public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitControl = UIControl
public typealias AppKitOrUIKitControlEvent = UIControl.Event
public typealias AppKitOrUIKitEdgeInsets = UIEdgeInsets
public typealias AppKitOrUIKitEvent = UIEvent
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitHostingController<Content: View> = UIHostingController<Content>
public typealias AppKitOrUIKitHostingView<Content: View> = UIHostingView<Content>
public typealias AppKitOrUIKitImage = UIImage
public typealias AppKitOrUIKitInsets = UIEdgeInsets
public typealias AppKitOrUIKitLabel = UILabel
public typealias AppKitOrUIKitLayoutAxis = NSLayoutConstraint.Axis
public typealias AppKitOrUIKitLayoutGuide = UILayoutGuide
public typealias AppKitOrUIKitLayoutPriority = UILayoutPriority
@available(tvOS, unavailable)
public typealias AppKitOrUIKitPasteboard = UIPasteboard
public typealias AppKitOrUIKitRectCorner = UIRectCorner
public typealias AppKitOrUIKitResponder = UIResponder
public typealias AppKitOrUIKitScrollView = UIScrollView
public typealias AppKitOrUIKitSplitViewController = UISplitViewController
public typealias AppKitOrUIKitSearchBar = UISearchBar
public typealias AppKitOrUIKitTableView = UITableView
public typealias AppKitOrUIKitTableViewCell = UITableViewCell
public typealias AppKitOrUIKitTableViewController = UITableViewController
public typealias AppKitOrUIKitTextField = UITextField
public typealias AppKitOrUIKitTextView = UITextView
public typealias AppKitOrUIKitView = UIView
public typealias AppKitOrUIKitViewController = UIViewController
public typealias AppKitOrUIKitWindow = UIWindow

extension UIEdgeInsets {
    var edgeInsets: EdgeInsets {
        .init(top: top, leading: left, bottom: bottom, trailing: right)
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

#if os(macOS)

import AppKit

public typealias AppKitOrUIKitApplication = NSApplication
public typealias AppKitOrUIKitApplicationDelegate = NSApplicationDelegate
@available(macOS 11, *)
public typealias AppKitOrUIKitApplicationDelegateAdapter = NSApplicationDelegateAdaptor
public typealias AppKitOrUIKitBezierPath = NSBezierPath
public typealias AppKitOrUIKitButton = NSButton
public typealias AppKitOrUIKitCollectionView = NSCollectionView
@available(macOS 11, *)
public typealias AppKitOrUIKitCollectionViewFlowLayout = NSCollectionViewFlowLayout
public typealias AppKitOrUIKitColor = NSColor
public typealias AppKitOrUIKitControl = NSControl
public typealias AppKitOrUIKitEdgeInsets = NSEdgeInsets
public typealias AppKitOrUIKitEvent = NSEvent
public typealias AppKitOrUIKitFont = NSFont
public typealias AppKitOrUIKitHostingController<Content: View> = NSHostingController<Content>
public typealias AppKitOrUIKitHostingView<Content: View> = NSHostingView<Content>
public typealias AppKitOrUIKitImage = NSImage
public typealias AppKitOrUIKitInsets = NSEdgeInsets
public typealias AppKitOrUIKitLabel = NSLabel
public typealias AppKitOrUIKitLayoutAxis = NSUserInterfaceLayoutOrientation
public typealias AppKitOrUIKitLayoutGuide = NSLayoutGuide
public typealias AppKitOrUIKitLayoutPriority = NSLayoutConstraint.Priority
public typealias AppKitOrUIKitPasteboard = NSPasteboard
public typealias AppKitOrUIKitRectCorner = NSRectCorner
public typealias AppKitOrUIKitResponder = NSResponder
public typealias AppKitOrUIKitSearchBar = NSSearchField
public typealias AppKitOrUIKitSplitViewController = NSSplitViewController
public typealias AppKitOrUIKitTableView = NSTableView
public typealias AppKitOrUIKitTableViewCell = NSTableCellView
public typealias AppKitOrUIKitTextField = NSTextField
public typealias AppKitOrUIKitTextView = NSTextView
public typealias AppKitOrUIKitView = NSView
public typealias AppKitOrUIKitViewController = NSViewController
public typealias AppKitOrUIKitWindow = NSWindow

extension NSAppearance {
    public func _SwiftUIX_toColorScheme() -> ColorScheme {
        let darkAppearances: [NSAppearance.Name] = [
            .vibrantDark,
            .darkAqua,
            .accessibilityHighContrastVibrantDark,
            .accessibilityHighContrastDarkAqua,
        ]
        
        return darkAppearances.contains(self.name) ? .dark : .light
    }
        
    public convenience init?(_SwiftUIX_from colorScheme: ColorScheme) {
        switch colorScheme {
            case .light:
                self.init(named: .aqua)
            case .dark:
                self.init(named: .darkAqua)
            default:
                return nil
        }
    }
}

extension NSEdgeInsets {
    var edgeInsets: EdgeInsets {
        .init(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

@available(iOS 15.0, macOS 10.15, watchOS 9.0, *)
@available(tvOS, unavailable)
extension NSButton.ControlSize {
    public init(_ size: SwiftUI.ControlSize) {
        switch size {
            case .mini:
                self = .mini
            case .small:
                self = .small
            case .regular:
                self = .regular
            case .large:
                if #available(macOS 11.0, *) {
                    self = .large
                } else {
                    self = .regular
                }
            default:
                assertionFailure()
                
                self = .regular
        }
    }
}

extension NSFont {
    @available(macOS 11.0, *)
    public static func preferredFont(forTextStyle textStyle: TextStyle) -> NSFont {
        .preferredFont(forTextStyle: textStyle, options: [:])
    }
}

public struct NSRectCorner: OptionSet {
    public static let allCorners: Self = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    
    public static let topLeft: Self = Self(rawValue: 1 << 0)
    public static let topRight: Self = Self(rawValue: 1 << 1)
    public static let bottomLeft: Self = Self(rawValue: 1 << 2)
    public static let bottomRight: Self = Self(rawValue: 1 << 3)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
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

extension NSView {
    public struct AnimationOptions: OptionSet {
        public static let curveEaseInOut = AnimationOptions(rawValue: 1 << 0)
        public static let curveEaseIn = AnimationOptions(rawValue: 1 << 1)
        public static let curveEaseOut = AnimationOptions(rawValue: 1 << 2)
        public static let curveLinear = AnimationOptions(rawValue: 1 << 3)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public func _toCAAnimationMediaTimingFunction() -> CAMediaTimingFunctionName {
            switch self {
                case .curveEaseIn:
                    return CAMediaTimingFunctionName.easeIn
                case .curveEaseOut:
                    return CAMediaTimingFunctionName.easeOut
                case .curveLinear:
                    return CAMediaTimingFunctionName.linear
                default:
                    return CAMediaTimingFunctionName.default
            }
        }
    }

    public static func animate(
        withDuration duration: TimeInterval,
        delay: TimeInterval = 0.0,
        options: AnimationOptions = .curveEaseInOut,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: options._toCAAnimationMediaTimingFunction())
            
            // Execute delay if specified
            if delay > 0.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    animations()
                }
            } else {
                animations()
            }
            
        } completionHandler: {
            completion?(true)
        }
    }
}

extension NSView {
    public static var layoutFittingCompressedSize: CGSize {
        .init(width: 0, height: 0)
    }
    
    public static var layoutFittingExpandedSize: CGSize {
        .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude) // FIXME
    }
    
    @objc open func hitTest(_ point: CGPoint, with event: NSEvent?) -> NSView? {
        hitTest(point)
    }
}

extension NSWindow {
    public var isHidden: Bool {
        !isVisible
    }
}

#endif

#if os(watchOS)

import UIKit
import WatchKit

public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitImage = UIImage

#endif

#if targetEnvironment(macCatalyst)

@objc public protocol NSAlertProtocol: NSObjectProtocol {
    @objc var alertStyle: UInt { get set }
    @objc var messageText: String { get set }
    @objc var informativeText: String { get set }
    
    @objc func addButton(withTitle: String)
    @objc func runModal()
    
    init()
}

@objc public protocol NSOpenPanelProtocol: NSObjectProtocol {
    @objc var directoryURL: URL? { get set }
    @objc var message: String? { get set }
    @objc var prompt: String? { get set }
    @objc var allowedFileTypes: [String]? { get set }
    @objc var allowsOtherFileTypes: Bool { get set }
    @objc var canChooseDirectories: Bool { get set }
    @objc var urls: [URL] { get set }
    
    @objc func runModal()
    
    init()
}

public let NSAlert_Type = unsafeBitCast(NSClassFromString("NSAlert"), to: NSAlertProtocol.Type.self)
public let NSOpenPanel_Type = unsafeBitCast(NSClassFromString("NSOpenPanel"), to: NSOpenPanelProtocol.Type.self)

#endif

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

#if os(macOS)
extension AppKitOrUIKitViewController {    
    public func _setNeedsLayout() {
        view.needsLayout = true
    }
}
#else
extension AppKitOrUIKitViewController {
    public func _setNeedsLayout() {
        view.setNeedsLayout()
    }
}
#endif

extension EnvironmentValues {
    struct AppKitOrUIKitViewControllerBoxKey: EnvironmentKey {
        typealias Value = ObservableWeakReferenceBox<AppKitOrUIKitViewController>?
          
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

public struct AppKitOrUIKitViewControllerAdaptor<AppKitOrUIKitViewControllerType: AppKitOrUIKitViewController>: AppKitOrUIKitViewControllerRepresentable {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public typealias UIViewControllerType = AppKitOrUIKitViewControllerType
    #elseif os(macOS)
    public typealias NSViewControllerType = AppKitOrUIKitViewControllerType
    #endif
    
    private let makeAppKitOrUIKitViewControllerImpl: (Context) -> AppKitOrUIKitViewControllerType
    private let updateAppKitOrUIKitViewControllerImpl: (AppKitOrUIKitViewControllerType, Context) -> ()
    
    public init(
        _ makeController: @autoclosure @escaping () -> AppKitOrUIKitViewControllerType
    ) {
        self.makeAppKitOrUIKitViewControllerImpl = { _ in makeController() }
        self.updateAppKitOrUIKitViewControllerImpl = { _, _ in }
    }
    
    public init(
        _ makeController: @escaping () -> AppKitOrUIKitViewControllerType
    ) {
        self.makeAppKitOrUIKitViewControllerImpl = { _ in makeController() }
        self.updateAppKitOrUIKitViewControllerImpl = { _, _ in }
    }
    
    public func makeAppKitOrUIKitViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewControllerImpl(context)
    }
    
    public func updateAppKitOrUIKitViewController(
        _ uiViewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewControllerImpl(uiViewController, context)
    }
}

#endif
