//
// Copyright (c) Vatsal Manot
//

// MARK: - iOS or tvOS or visionOS

#if os(iOS) || os(tvOS) || os(visionOS)

import Foundation
import SwiftUI
import UIKit

public typealias AppKitOrUIKitApplication = UIApplication
public typealias AppKitOrUIKitApplicationDelegate = UIApplicationDelegate
@available(iOS 14.0, tvOS 14.0, *)
public typealias AppKitOrUIKitApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
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
public typealias AppKitOrUIKitFontDescriptor = UIFontDescriptor
public typealias AppKitOrUIKitGraphicsImageRenderer = UIGraphicsImageRenderer
public typealias AppKitOrUIKitHostingController<Content: View> = UIHostingController<Content>
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
@available(visionOS, unavailable)
public typealias AppKitOrUIKitScreen = UIScreen
public typealias AppKitOrUIKitScrollView = UIScrollView
public typealias AppKitOrUIKitSplitViewController = UISplitViewController
public typealias AppKitOrUIKitSearchBar = UISearchBar
public typealias AppKitOrUIKitTableView = UITableView
public typealias AppKitOrUIKitTableViewCell = UITableViewCell
public typealias AppKitOrUIKitTableViewController = UITableViewController
public typealias AppKitOrUIKitTextField = UITextField
public typealias AppKitOrUIKitTextInputDelegate = UITextInputDelegate
public typealias AppKitOrUIKitTextRange = UITextRange
public typealias AppKitOrUIKitTextView = UITextView
public typealias AppKitOrUIKitView = UIView
public typealias AppKitOrUIKitViewController = UIViewController
public typealias AppKitOrUIKitWindow = UIWindow

#endif

// MARK: - macOS

#if os(macOS)

import AppKit
import Foundation
import SwiftUI

@objc public protocol NSTextInputDelegate: NSObjectProtocol {
    
}

public typealias AppKitOrUIKitApplication = NSApplication
public typealias AppKitOrUIKitApplicationDelegate = NSApplicationDelegate
@available(macOS 11, *)
public typealias AppKitOrUIKitApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
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
public typealias AppKitOrUIKitFontDescriptor = NSFontDescriptor
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
public typealias AppKitOrUIKitScreen = NSScreen
public typealias AppKitOrUIKitSearchBar = NSSearchField
public typealias AppKitOrUIKitSplitViewController = NSSplitViewController
public typealias AppKitOrUIKitTableView = NSTableView
public typealias AppKitOrUIKitTableViewCell = NSTableCellView
public typealias AppKitOrUIKitTextField = NSTextField
public typealias AppKitOrUIKitTextInput = NSTextInput
public typealias AppKitOrUIKitTextInputDelegate = NSTextInputDelegate
@available(macOS 12.0, *)
public typealias AppKitOrUIKitTextRange = NSTextRange
public typealias AppKitOrUIKitTextView = NSTextView
public typealias AppKitOrUIKitView = NSView
public typealias AppKitOrUIKitViewController = NSViewController
public typealias AppKitOrUIKitWindow = NSWindow

// MARK: - watchOS

#elseif os(watchOS)

import UIKit
import WatchKit

public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitImage = UIImage

#endif

// MARK: - macOS or macCatalyst

#if os(macOS) || targetEnvironment(macCatalyst)

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
