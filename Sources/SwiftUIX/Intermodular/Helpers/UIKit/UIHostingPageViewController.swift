//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
import Swift
import SwiftUI
import UIKit

protocol _opaque_UIHostingPageViewController: NSObject {
    var _pageUpdateDriver: _PageUpdateDriver { get }
    var internalPaginationState: PaginationState { get }
}

class _PageUpdateDriver: ObservableObject {
    
}

class UIHostingPageViewController<Page: View>: UIPageViewController, _opaque_UIHostingPageViewController, UIScrollViewDelegate {
    var _pageUpdateDriver = _PageUpdateDriver()
    var internalScrollView: UIScrollView?
    var cachedChildren: [Int: PageContentController] = [:]
    
    var _isSwiftUIRuntimeUpdateActive: Bool = false
    var _isAnimated: Bool = true
    var cyclesPages: Bool = false
    var internalPaginationState = PaginationState() {
        didSet {
            paginationState?.wrappedValue = internalPaginationState
        }
    }
    var paginationState: Binding<PaginationState>?
    
    var content: AnyForEach<Page>? {
        didSet {
            if let content = content {
                preheatViewControllersCache()

                if let oldValue = oldValue, oldValue.count != content.count {
                    cachedChildren = [:]
                    
                    if let firstViewController = viewController(for: content.data.startIndex) {
                        setViewControllers(
                            [firstViewController],
                            direction: .forward,
                            animated: false
                        )
                    }
                } else {
                    if let viewControllers = viewControllers?.compactMap({ $0 as? PageContentController }), let firstViewController = viewControllers.first, !viewControllers.isEmpty {
                        for viewController in viewControllers {
                            _withoutAppKitOrUIKitAnimation(!(viewController === firstViewController)) {
                                viewController.mainView.page = content.content(content.data[viewController.mainView.index])
                            }
                        }
                    }
                }
            }
        }
    }
    
    var currentPageIndex: AnyIndex? {
        get {
            guard let currentViewController = viewControllers?.first as? PageContentController else {
                return nil
            }
            
            return currentViewController.mainView.index
        } set {
            guard let newValue = newValue else {
                return setViewControllers([], direction: .forward, animated: _isAnimated, completion: nil)
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
            
            if internalPaginationState.activePageTransitionProgress == 0.0 {
                if let viewController = viewController(for: newValue) {
                    setViewControllers(
                        [viewController],
                        direction: direction,
                        animated: _isAnimated
                    )
                }
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
    
    private func preheatViewControllersCache() {
        guard let content = content else {
            return
        }
        
        if content.data.count <= 4 {
            for index in content.data.indices {
                _ = viewController(for: index)
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                internalScrollView = scrollView
                scrollView.delegate = self
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !_isSwiftUIRuntimeUpdateActive else {
            return
        }
        
        let activePageTransitionProgress = (scrollView.contentOffset.x - view.frame.size.width) / view.frame.size.width

        if paginationState != nil {
            // _pageUpdateDriver._objectWillChange_send() // FIXME: This does not perform well.
        }
        
        if activePageTransitionProgress == 0 {
            internalPaginationState.activePageTransitionDirection = nil
        } else {
            internalPaginationState.activePageTransitionDirection = activePageTransitionProgress < 0 ? .backward : .forward
        }
        
        internalPaginationState.activePageTransitionProgress = abs(Double(activePageTransitionProgress))
    }
}

extension UIHostingPageViewController {
    func viewController(for index: AnyIndex) -> UIViewController? {
        guard let content = content else {
            return nil
        }
        
        guard index < content.data.endIndex else {
            return nil
        }
        
        let indexOffset = content.data.distance(from: content.data.startIndex, to: index)
        
        if let cachedResult = cachedChildren[indexOffset] {
            return cachedResult
        }
        
        let result = PageContentController(
            mainView: PageContainer(
                index: index,
                page: content.content(content.data[index]),
                _updateDriver: _pageUpdateDriver
            )
        )
        
        cachedChildren[indexOffset] = result
        
        return result
    }
    
    func viewController(before viewController: UIViewController) -> UIViewController? {
        guard let content = content else {
            return nil
        }
        
        guard let viewController = viewController as? PageContentController else {
            assertionFailure()
            
            return nil
        }
        
        let index = viewController.mainView.index == content.data.startIndex
            ? (cyclesPages ? content.data.indices.last : nil)
            : content.data.index(before: viewController.mainView.index)
        
        return index.flatMap { index in
            self.viewController(for: index)
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
        
        let index = content.data.index(after: viewController.mainView.index) == content.data.endIndex
            ? (cyclesPages ? content.data.startIndex :  nil)
            : content.data.index(after: viewController.mainView.index)
        
        return index.flatMap { index in
            self.viewController(for: index)
        }
    }
}

extension UIHostingPageViewController {
    struct PageContainer: View {
        let index: AnyIndex
        var page: Page

        @ObservedObject var _updateDriver: _PageUpdateDriver

        var body: some View {
            page
        }
    }
    
    class PageContentController: CocoaHostingController<PageContainer> {
        init(mainView: PageContainer) {
            super.init(mainView: mainView)
            
            _disableSafeAreaInsetsIfNecessary()
            
            view.backgroundColor = .clear
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#endif
