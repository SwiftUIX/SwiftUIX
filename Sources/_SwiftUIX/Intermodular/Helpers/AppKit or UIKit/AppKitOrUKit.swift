//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS)

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
public typealias AppKitOrUIKitSearchBar = NSSearchField
public typealias AppKitOrUIKitSplitViewController = NSSplitViewController
public typealias AppKitOrUIKitTableView = NSTableView
public typealias AppKitOrUIKitTableViewCell = NSTableCellView
public typealias AppKitOrUIKitTextField = NSTextField
public typealias AppKitOrUIKitTextView = NSTextView
public typealias AppKitOrUIKitView = NSView
public typealias AppKitOrUIKitViewController = NSViewController
public typealias AppKitOrUIKitWindow = NSWindow

#elseif os(watchOS)

import UIKit
import WatchKit

public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitImage = UIImage

#endif
