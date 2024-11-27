//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import Foundation
import Swift
import SwiftUI

public protocol _AppKitOrUIKitHostingScrollViewType: NSObject {
    func scrollTo(_ edge: Edge)
}

// MARK: - Conformees

#if os(iOS) || os(tvOS) || os(visionOS)
extension UIHostingScrollView {
    public func scrollTo(_ edge: Edge) {
        let animated = _areAnimationsDisabledGlobally ? false : true
        
        switch edge {
            case .top: do {
                setContentOffset(
                    CGPoint(x: contentOffset.x, y: -contentInset.top),
                    animated: animated
                )
            }
            case .leading: do {
                guard contentSize.width > frame.width else {
                    return
                }
                
                setContentOffset(
                    CGPoint(x: contentInset.left, y: contentOffset.y),
                    animated: animated
                )
            }
            case .bottom: do {
                setContentOffset(
                    CGPoint(x: contentOffset.x, y: (contentSize.height - bounds.size.height) + contentInset.bottom),
                    animated: animated
                )
            }
            case .trailing: do {
                guard contentSize.width > frame.width else {
                    return
                }
                
                setContentOffset(
                    CGPoint(x: (contentSize.width - bounds.size.width) + contentInset.right, y: contentOffset.y),
                    animated: animated
                )
            }
        }
    }
}
#elseif os(macOS)
extension _PlatformTableViewContainer: _AppKitOrUIKitHostingScrollViewType {
    public func scrollTo(_ edge: Edge) {
        guard !isContentWithinBounds else {
            return
        }
        
        let point: NSPoint
        
        switch edge {
            case .top:
                point = NSPoint(
                    x: self.contentView.bounds.origin.x,
                    y: self.documentSize.height - self.contentView.bounds.height
                )
            case .leading:
                point = NSPoint(
                    x: 0,
                    y: self.contentView.bounds.origin.y
                )
            case .bottom:
                point = NSPoint(
                    x: self.contentView.bounds.origin.x,
                    y: 0
                )
                
                DispatchQueue.main.async {
                    self.tableView.scrollToEndOfDocument(nil)
                    
                    self.reflectScrolledClipView(self.contentView)
                }
                
                return
            case .trailing:
                point = NSPoint(
                    x: self.documentSize.width - self.contentView.bounds.width,
                    y: self.contentView.bounds.origin.y
                )
        }
        
        self.contentView.scroll(to: point)
        
        self.reflectScrolledClipView(self.contentView)
    }
}
#endif

#endif

// MARK: - Auxiliary

#if os(macOS)
extension NSScrollView {
    fileprivate var documentSize: NSSize {
        contentView.documentRect.size
    }
    
    fileprivate var isContentWithinBounds: Bool {
        let contentSize = documentSize
        let scrollViewSize = self.bounds.size
        let insets = self.contentInsets
        
        let effectiveWidth = contentSize.width + insets.left + insets.right
        let effectiveHeight = contentSize.height + insets.top + insets.bottom
        
        return effectiveWidth <= scrollViewSize.width && effectiveHeight <= scrollViewSize.height
    }
}
#endif
