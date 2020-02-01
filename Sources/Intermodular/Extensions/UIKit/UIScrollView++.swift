//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

extension UIScrollView {
    var percentContentOffset: CGPoint {
        return .init(
            x: contentOffset.x / (contentSize.width - frame.width),
            y: contentOffset.y / (contentSize.height - frame.height)
        )
    }
}

extension UIScrollView {
    var contentAlignment: Alignment? {
        switch contentOffset {
            case contentOffset(for: .center):
                return .center
            case contentOffset(for: .leading):
                return .leading
            case contentOffset(for: .trailing):
                return .trailing
            case contentOffset(for: .top):
                return .top
            case contentOffset(for: .bottom):
                return .bottom
            case contentOffset(for: .topLeading):
                return .topLeading
            case contentOffset(for: .topTrailing):
                return .topTrailing
            case contentOffset(for: .bottomLeading):
                return .topTrailing
            case contentOffset(for: .bottomTrailing):
                return .topTrailing
            
            default:
                return nil
        }
    }
    
    func setContentAlignment(_ alignment: Alignment, animated: Bool) {
        setContentOffset(contentOffset(for: alignment), animated: animated)
    }
    
    private func contentOffset(for alignment: Alignment) -> CGPoint {
        var offset: CGPoint = .zero
        
        switch alignment.horizontal {
            case .leading:
                offset.x = 0
            case .center:
                offset.x = (contentSize.width - bounds.size.width) / 2
            case .trailing:
                offset.x = contentSize.width - bounds.size.width
            default:
                fatalError()
        }
        
        switch alignment.vertical {
            case .top:
                offset.y = 0
            case .center:
                offset.y = (contentSize.height - bounds.size.height) / 2
            case .bottom:
                offset.y = contentSize.height - bounds.size.height
            default:
                fatalError()
        }
        
        return offset
    }
}

#endif
