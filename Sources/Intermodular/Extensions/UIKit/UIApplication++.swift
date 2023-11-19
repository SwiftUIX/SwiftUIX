//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIApplication {
    public var firstKeyWindow: UIWindow? {
        windows.first(where: { $0.isKeyWindow })
    }
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public var topmostViewController: UIViewController? {
        UIApplication.shared.firstKeyWindow?.rootViewController?.topmostViewController
    }
}

#endif
