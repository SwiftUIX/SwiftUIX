//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public class UIHostingPageViewController<Page: View>: UIPageViewController {
    struct PageContainer: View {
        let index: AnyIndex
        let page: Page
        
        var body: some View {
            page
        }
    }
    
    class PageContentController: UIHostingController<PageContainer> {
        override open func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .clear
        }
        
        override open func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            view.backgroundColor = .clear
        }
        
        override open func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            view.backgroundColor = .clear
        }
    }
    
    var content: AnyForEach<Page>?
    var cyclesPages: Bool = false
            
    var currentPageIndex: AnyIndex? {
        get {
            guard let currentViewController = viewControllers?.first as? PageContentController else {
                return nil
            }
            
            return currentViewController.rootView.index
        } set {
            guard let newValue = newValue else {
                return setViewControllers([], direction: .forward, animated: true, completion: nil)
            }
            
            guard let currentPageIndex = currentPageIndex else {
                return
            }
            
            guard newValue != currentPageIndex else {
                return
            }
            
            var direction: UIPageViewController.NavigationDirection
            
            if newValue < currentPageIndex {
                direction = .reverse
            } else {
                direction = .forward
            }
            
            if let viewController = viewController(for: newValue) {
                setViewControllers(
                    [viewController],
                    direction: direction,
                    animated: true
                )
            }
        }
    }
    
    var currentPageIndexOffset: Int? {
        guard let content = content else {
            return nil
        }
        
        guard let currentPageIndex = currentPageIndex else {
            return nil
        }
        
        return content.data.distance(from: content.data.startIndex, to: currentPageIndex)
    }

    var previousPageIndex: AnyIndex? {
        guard let currentPageIndex = currentPageIndex else {
            return nil
        }
        
        return content?.data.index(before: currentPageIndex)
    }
    
    var nextPageIndex: AnyIndex? {
        guard let currentPageIndex = currentPageIndex else {
            return nil
        }
        
        return content?.data.index(after: currentPageIndex)
    }
}

extension UIHostingPageViewController {
    func viewController(for index: AnyIndex) -> UIViewController? {
        guard let content = content else {
            return nil
        }
        
        return PageContentController(rootView: PageContainer(index: index, page: content.content(content.data[index])))
    }
    
    func viewController(before viewController: UIViewController) -> UIViewController? {
        guard let content = content else {
            return nil
        }
        
        guard let viewController = viewController as? PageContentController else {
            assertionFailure()
            
            return nil
        }
                
        let index = viewController.rootView.index == content.data.startIndex
            ? (cyclesPages ? content.data.indices.last : nil)
            : content.data.index(before: viewController.rootView.index)
        
        return index.map { index in
            PageContentController(rootView: PageContainer(index: index, page: content.content(content.data[index])))
        }
    }
    
    func viewController(after viewController: UIViewController) -> UIViewController? {
        guard let content = content else {
            return nil
        }
        
        guard let viewController = viewController as? PageContentController else {
            assertionFailure()
            
            return nil
        }
        
        let index = content.data.index(after: viewController.rootView.index) == content.data.endIndex
            ? (cyclesPages ? content.data.startIndex :  nil)
            : content.data.index(after: viewController.rootView.index)
        
        return index.map { index in
            PageContentController(rootView: PageContainer(index: index, page: content.content(content.data[index])))
        }
    }
}

#endif
