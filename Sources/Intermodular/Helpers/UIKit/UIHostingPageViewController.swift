//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public class UIHostingPageViewController<Page: View>: UIPageViewController {
    var allViewControllers: [UIHostingController<Page>] = []
    var cyclesPages: Bool = false
    
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
    
    var currentPageIndex: Int? {
        guard let currentViewController = viewControllers?.first else {
            return nil
        }
        
        return allViewControllers.firstIndex(of: currentViewController as! UIHostingController<Page>)
    }
    
    var previousPageIndex: Int? {
        guard let currentPageIndex = currentPageIndex else {
            return nil
        }
        
        guard currentPageIndex > 0 else {
            return nil
        }
        
        return currentPageIndex - 1
    }
    
    var nextPageIndex: Int? {
        guard let currentPageIndex = currentPageIndex else {
            return nil
        }
        
        guard currentPageIndex < (pages.count - 1) else {
            return nil
        }
        
        return currentPageIndex + 1
    }
}

extension UIHostingPageViewController {
    func viewController(before viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? UIHostingController<Page> else {
            assertionFailure()
            
            return nil
        }
        
        return allViewControllers
            .firstIndex(of: viewController)
            .flatMap({ (index: Int) -> UIViewController? in
                index == 0
                    ? (cyclesPages ? allViewControllers.last : nil)
                    : allViewControllers[index - 1]
            })
    }
    
    func viewController(after viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? UIHostingController<Page> else {
            assertionFailure()
            
            return nil
        }
        
        return  allViewControllers
            .firstIndex(of: viewController)
            .flatMap { (index: Int) -> UIViewController? in
                let viewController = (index + 1) == allViewControllers.count
                    ? (cyclesPages ? allViewControllers.first : nil)
                    : allViewControllers[index + 1]
                
                return viewController
            }
    }
}

#endif
