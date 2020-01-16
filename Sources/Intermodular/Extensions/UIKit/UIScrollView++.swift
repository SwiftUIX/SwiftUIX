//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIScrollView {
    func setContentAlignment(_ alignment: Alignment, animated: Bool) {
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
        
        setContentOffset(offset, animated: animated)
    }
}

#endif
