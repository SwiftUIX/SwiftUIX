//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public class UIHostingPageViewController<Page: View>: UIPageViewController {
    var allViewControllers: [UIHostingController<Page>] = []
    
    var pages: [Page] {
        get {
            allViewControllers.map({ $0.rootView })
        } set {
            if newValue.count != allViewControllers.count {
                allViewControllers = newValue.map(UITransparentHostingController.init)
            } else {
                for index in newValue.indices {
                    allViewControllers[index].rootView = newValue[index]
                }
            }
        }
    }
}

#endif
