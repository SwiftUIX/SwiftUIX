//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
extension AppKitOrUIKitScrollView {
    var verticalScrollPosition: CGFloat {
        get {
            contentOffset.y
        } set {
            let newOffset = max(0, min(newValue, bounds.height - contentSize.height))
            
            if abs(newOffset - contentOffset.y) > 0.0001 {
                setContentOffset(CGPoint(x: contentOffset.x, y: newOffset), animated: false)
            }
        }
    }
}
#elseif os(macOS)
extension NSScrollView {
    var verticalScrollPosition: CGFloat {
        get {
            documentVisibleRect.origin.y
        } set {
            // (documentView as? NSTextView)?.textLayoutManager?.textViewportLayoutController.layoutViewport()
            
            let newOffset = max(0, min(newValue, (documentView?.bounds.height ?? 0) - contentSize.height))
            
            if abs(newOffset - documentVisibleRect.origin.y) > 0.0001 {
                contentView.scroll(to: CGPoint(x: documentVisibleRect.origin.x, y: newOffset))
            }
            
            reflectScrolledClipView(contentView)
        }
    }
    
    var contentOffset: CGPoint {
        get {
            contentView.documentVisibleRect.origin
        } set {
            contentView.scroll(to: newValue)
            
            reflectScrolledClipView(contentView)
        }
    }
    
    var contentInset: NSEdgeInsets {
        get {
            contentInsets
        } set {
            contentInsets = newValue
        }
    }
    
    var currentVerticalAlignment: Alignment? {
        let visibleRect = documentVisibleRect
        
        guard let documentView = documentView else {
            return nil
        }
        
        let totalHeight = documentView.bounds.height
        let visibleHeight = visibleRect.height
        
        // Check if the content is larger than the visible area
        if totalHeight > visibleHeight {
            let topContentOffset = contentInsets.top
            let bottomContentOffset = totalHeight - visibleHeight - contentInsets.bottom
            
            // Near the top
            if abs(visibleRect.minY - topContentOffset) < 5 {
                return .top
            }
            // Near the bottom
            else if abs(visibleRect.maxY - bottomContentOffset) < 5 {
                return .bottom
            }
        } else {
            return .center
        }
        
        return nil
    }
}

#endif
