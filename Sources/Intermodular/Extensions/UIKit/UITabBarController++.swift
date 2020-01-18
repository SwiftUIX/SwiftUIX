//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UITabBarController {
    public var tabBarIsHidden: Bool {
        tabBar.frame.origin.y >= UIScreen.main.bounds.height
    }
    
    public func setTabBarIsHidden(_ isHidden: Bool, animated: Bool) {
        if tabBarIsHidden == isHidden {
            return
        }
        
        let offsetY = (isHidden ? tabBar.frame.height : -tabBar.frame.height)
                    
        UIView.animate(withDuration: (animated ? 0.3 : 0.0)) {
            self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        }
    }
}

#endif
