//
// Copyright (c) Vatsal Manot
//

import Swift

#if canImport(AppKit)

import AppKit

public typealias AppKitOrUIKitApplication = NSApplication
public typealias AppKitOrUIKitButton = NSButton
public typealias AppKitOrUIKitColor = NSColor
public typealias AppKitOrUIKitControl = NSControl
public typealias AppKitOrUIKitFont = NSFont
public typealias AppKitOrUIKitImage = NSImage
public typealias AppKitOrUIKitLayoutAxis = NSUserInterfaceLayoutOrientation
public typealias AppKitOrUIKitLayoutGuide = NSLayoutGuide
public typealias AppKitOrUIKitLayoutPriority = NSLayoutConstraint.Priority
public typealias AppKitOrUIKitResponder = NSResponder
public typealias AppKitOrUIKitTableView = NSTableView
public typealias AppKitOrUIKitView = NSView
public typealias AppKitOrUIKitViewController = NSViewController
public typealias AppKitOrUIKitWindow = NSWindow

#endif

#if canImport(UIKit)

import UIKit

public typealias AppKitOrUIKitApplication = UIApplication
public typealias AppKitOrUIKitButton = UIButton
public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitControl = UIControl
public typealias AppKitOrUIKitControlEvent = UIControl.Event
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitImage = UIImage
public typealias AppKitOrUIKitLayoutAxis = NSLayoutConstraint.Axis
public typealias AppKitOrUIKitLayoutGuide = UILayoutGuide
public typealias AppKitOrUIKitLayoutPriority = UILayoutPriority
public typealias AppKitOrUIKitResponder = UIResponder
public typealias AppKitOrUIKitTableView = UITableView
public typealias AppKitOrUIKitTableViewController = UITableViewController
public typealias AppKitOrUIKitView = UIView
public typealias AppKitOrUIKitViewController = UIViewController
public typealias AppKitOrUIKitWindow = UIWindow

#endif

// MARK: - Helpers -

public enum AppKitOrUIKitLayoutAlignment: Hashable {
    case leading
    case trailing
    case center
    case fill
}

#if canImport(UIKit)

extension UIControl.Event: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

#endif
