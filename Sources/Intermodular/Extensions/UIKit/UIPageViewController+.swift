//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIPageViewController {
    open var pageControl: UIPageControl? {
        view.findSubview(ofKind: UIPageControl.self)
    }
}

#endif
