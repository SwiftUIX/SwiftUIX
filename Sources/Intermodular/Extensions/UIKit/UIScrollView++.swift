//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

extension UIScrollView {
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
