//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UITabBarController {
    public var _SwiftUIX_tabBarIsHidden: Bool {
        tabBar.frame.origin.y >= UIScreen.main.bounds.height
    }
    
    public func _SwiftUIX_setTabBarIsHidden(
        _ isHidden: Bool,
        animated: Bool
    ) {
        if _SwiftUIX_tabBarIsHidden == isHidden {
            return
        }
        
        let offsetY = (isHidden ? tabBar.frame.height : -tabBar.frame.height)
                    
        UIView.animate(withDuration: (animated ? 0.3 : 0.0)) {
            self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        }
    }
}

#endif
