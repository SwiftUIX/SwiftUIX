//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

extension UIScrollView {
    var insetAdjustedContentSize: CGSize {
        let contentSize = self.contentSize.isAreaZero
            ? ((self as? UICollectionView)?.collectionViewLayout.collectionViewContentSize) ?? .zero
            : self.contentSize
        
        return CGSize(
            width: contentSize.width + adjustedContentInset.left + adjustedContentInset.right,
            height: contentSize.height + adjustedContentInset.bottom + contentInset.top
        )
    }
    
    var maximumContentOffset: CGPoint  {
        CGPoint(
            x: max(0, insetAdjustedContentSize.width - bounds.width),
            y: max(0, insetAdjustedContentSize.height + safeAreaInsets.top - bounds.height)
        )
    }
    
    var flippedContentOffset: CGPoint {
        get {
            .init(
                x: contentOffset.x - (contentSize.width - bounds.width),
                y: contentOffset.y - (contentSize.height - bounds.height)
            )
        } set {
            contentOffset.x = newValue.x + (contentSize.width - bounds.width)
            contentOffset.y = newValue.y + (contentSize.height - bounds.height)
        }
    }
}

#endif
