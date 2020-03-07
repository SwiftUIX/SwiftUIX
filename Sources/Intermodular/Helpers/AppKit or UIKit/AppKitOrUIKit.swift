//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)

import AppKit

public typealias AppKitOrUIKitApplication = NSApplication
public typealias AppKitOrUIKitButton = NSButton
public typealias AppKitOrUIKitColor = NSColor
public typealias AppKitOrUIKitControl = NSControl
public typealias AppKitOrUIKitEvent = NSEvent
public typealias AppKitOrUIKitFont = NSFont
public typealias AppKitOrUIKitHostingView<Content: View> = NSHostingView<Content>
public typealias AppKitOrUIKitImage = NSImage
public typealias AppKitOrUIKitLabel = NSLabel
public typealias AppKitOrUIKitLayoutAxis = NSUserInterfaceLayoutOrientation
public typealias AppKitOrUIKitLayoutGuide = NSLayoutGuide
public typealias AppKitOrUIKitLayoutPriority = NSLayoutConstraint.Priority
public typealias AppKitOrUIKitResponder = NSResponder
public typealias AppKitOrUIKitTableView = NSTableView
public typealias AppKitOrUIKitTextView = NSTextView
public typealias AppKitOrUIKitView = NSView
public typealias AppKitOrUIKitViewController = NSViewController
public typealias AppKitOrUIKitWindow = NSWindow

extension NSView {
    @objc open func hitTest(_ point: CGPoint, with event: NSEvent?) -> NSView? {
        hitTest(point)
    }
}

#endif

#if os(iOS) || os(tvOS)

import UIKit

public typealias AppKitOrUIKitApplication = UIApplication
public typealias AppKitOrUIKitButton = UIButton
public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitControl = UIControl
public typealias AppKitOrUIKitControlEvent = UIControl.Event
public typealias AppKitOrUIKitEvent = UIEvent
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitHostingView<Content: View> = UIHostingView<Content>
public typealias AppKitOrUIKitImage = UIImage
public typealias AppKitOrUIKitLabel = UILabel
public typealias AppKitOrUIKitLayoutAxis = NSLayoutConstraint.Axis
public typealias AppKitOrUIKitLayoutGuide = UILayoutGuide
public typealias AppKitOrUIKitLayoutPriority = UILayoutPriority
public typealias AppKitOrUIKitResponder = UIResponder
public typealias AppKitOrUIKitTableView = UITableView
public typealias AppKitOrUIKitTableViewController = UITableViewController
public typealias AppKitOrUIKitTextField = UITextField
public typealias AppKitOrUIKitTextView = UITextView
public typealias AppKitOrUIKitView = UIView
public typealias AppKitOrUIKitViewController = UIViewController
public typealias AppKitOrUIKitWindow = UIWindow

#elseif os(watchOS)

import UIKit
import WatchKit

public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitImage = UIImage

#endif

// MARK: - Helpers -

public enum AppKitOrUIKitLayoutAlignment: Hashable {
    case leading
    case trailing
    case center
    case fill
}

#if !os(macOS) && !targetEnvironment(macCatalyst)

public enum ControlSize: CaseIterable {
    case regular
    case small
    case mini
}

public protocol NSToolbarDelegate {
    
}

#endif
