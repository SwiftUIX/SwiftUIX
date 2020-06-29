//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A SwiftUI port of `UIPageViewController`.
@usableFromInline
struct _PaginationView<Page: View> {
    @usableFromInline
    let pages: [Page]
    @usableFromInline
    let axis: Axis
    @usableFromInline
    let transitionStyle: UIPageViewController.TransitionStyle
    @usableFromInline
    let showsIndicators: Bool
    @usableFromInline
    let pageIndicatorAlignment: Alignment
    @usableFromInline
    let cyclesPages: Bool
    @usableFromInline
    let initialPageIndex: Int?
    
    @usableFromInline
    @Binding var currentPageIndex: Int
    
    @usableFromInline
    @Binding var progressionController: ProgressionController?
    
    @usableFromInline
    init(
        pages: [Page],
        axis: Axis,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool,
        pageIndicatorAlignment: Alignment,
        cyclesPages: Bool,
        initialPageIndex: Int?,
        currentPageIndex: Binding<Int>,
        progressionController: Binding<ProgressionController?>
    ) {
        self.pages = pages
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.showsIndicators = showsIndicators
        self.pageIndicatorAlignment = pageIndicatorAlignment
        self.cyclesPages = cyclesPages
        self.initialPageIndex = initialPageIndex
        self._currentPageIndex = currentPageIndex
        self._progressionController = progressionController
    }
}

// MARK: - Protocol Implementations -

extension _PaginationView: UIViewControllerRepresentable {
    @usableFromInline
    typealias UIViewControllerType = UIHostingPageViewController<Page>
    
    @usableFromInline
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let uiViewController = UIViewControllerType(
            transitionStyle: transitionStyle,
            navigationOrientation: axis == .horizontal
                ? .horizontal
                : .vertical
        )
        
        uiViewController.pages = pages
        
        uiViewController.dataSource = .some(context.coordinator as! UIPageViewControllerDataSource)
        uiViewController.delegate = .some(context.coordinator as! UIPageViewControllerDelegate)
        
        guard !pages.isEmpty else {
            return uiViewController
        }
        
        if let initialPageIndex = initialPageIndex {
            currentPageIndex = initialPageIndex
        }
        
        if uiViewController.pages.indices.contains(currentPageIndex) {
            uiViewController.setViewControllers(
                [uiViewController.allViewControllers[initialPageIndex ?? currentPageIndex]],
                direction: .forward,
                animated: true
            )
        } else {
            if !uiViewController.allViewControllers.isEmpty {
                uiViewController.setViewControllers(
                    [uiViewController.allViewControllers.first!],
                    direction: .forward,
                    animated: false
                )
                
                currentPageIndex = 0
            }
        }
        
        progressionController = _ProgressionController(base: uiViewController, currentPageIndex: $currentPageIndex)
        
        return uiViewController
    }
    
    @usableFromInline
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.pages = pages
        
        if uiViewController.pages.indices.contains(currentPageIndex) {
            if uiViewController.allViewControllers[currentPageIndex] !== uiViewController.viewControllers?.first {
                if let currentPageIndexOfViewController = uiViewController.currentPageIndex {
                    var direction: UIPageViewController.NavigationDirection
                    
                    if currentPageIndex < currentPageIndexOfViewController {
                        direction = .reverse
                    } else {
                        direction = .forward
                    }
                    
                    uiViewController.setViewControllers(
                        [uiViewController.allViewControllers[currentPageIndex]],
                        direction: direction,
                        animated: true
                    )
                } else {
                    uiViewController.setViewControllers(
                        [uiViewController.allViewControllers[currentPageIndex]],
                        direction: .forward,
                        animated: false
                    )
                }
            }
        } else {
            if !uiViewController.allViewControllers.isEmpty {
                uiViewController.setViewControllers(
                    [uiViewController.allViewControllers.first!],
                    direction: .forward,
                    animated: false
                )
                
                currentPageIndex = 0
            }
        }
        
        if uiViewController.pageControl?.currentPage != currentPageIndex {
            uiViewController.pageControl?.currentPage = currentPageIndex
        }
        
        uiViewController.cyclesPages = cyclesPages
        uiViewController.isEdgePanGestureEnabled = context.environment.isEdgePanGestureEnabled
        uiViewController.isPanGestureEnabled = context.environment.isPanGestureEnabled
        uiViewController.isScrollEnabled = context.environment.isScrollEnabled
        uiViewController.isTapGestureEnabled = context.environment.isTapGestureEnabled
        uiViewController.pageControl?.currentPageIndicatorTintColor = context.environment.currentPageIndicatorTintColor?.toUIColor()
        uiViewController.pageControl?.pageIndicatorTintColor = context.environment.pageIndicatorTintColor?.toUIColor()
    }
    
    @usableFromInline
    func makeCoordinator() -> Coordinator {
        guard showsIndicators else {
            return _Coordinator_No_UIPageControl(self)
        }
        
        if axis == .vertical || pageIndicatorAlignment != .center {
            return _Coordinator_No_UIPageControl(self)
        } else {
            return _Coordinator_Default_UIPageControl(self)
        }
    }
}

extension _PaginationView {
    @usableFromInline
    class Coordinator: NSObject {
        @usableFromInline
        var parent: _PaginationView
        
        @usableFromInline
        init(_ parent: _PaginationView) {
            self.parent = parent
        }
    }
    
    @usableFromInline
    class _Coordinator_No_UIPageControl: Coordinator, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        @usableFromInline
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let pageViewController = pageViewController as? UIViewControllerType else {
                assertionFailure()
                
                return nil
            }
            
            return pageViewController.viewController(before: viewController)
        }
        
        @usableFromInline
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let pageViewController = pageViewController as? UIViewControllerType else {
                assertionFailure()
                
                return nil
            }
            
            return pageViewController.viewController(after: viewController)
        }
        
        @usableFromInline
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else {
                return
            }
            
            let pageViewController = pageViewController as! UIViewControllerType
            
            if let controller = pageViewController.viewControllers?.first {
                pageViewController
                    .allViewControllers
                    .firstIndex(of: controller as! UIHostingController<Page>)
                    .map({ parent.currentPageIndex = $0 })
            }
        }
    }
    
    @usableFromInline
    class _Coordinator_Default_UIPageControl: Coordinator, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        @usableFromInline
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let pageViewController = pageViewController as? UIViewControllerType else {
                assertionFailure()
                
                return nil
            }
            
            return pageViewController.viewController(before: viewController)
        }
        
        @usableFromInline
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let pageViewController = pageViewController as? UIViewControllerType else {
                assertionFailure()
                
                return nil
            }
            
            return pageViewController.viewController(after: viewController)
        }
        
        @usableFromInline
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else {
                return
            }
            
            let pageViewController = pageViewController as! UIViewControllerType
            
            if let controller = pageViewController.viewControllers?.first {
                pageViewController
                    .allViewControllers
                    .firstIndex(of: controller as! UIHostingController<Page>)
                    .map({ parent.currentPageIndex = $0 })
            }
        }
        
        @usableFromInline
        @objc func presentationCount(for pageViewController: UIPageViewController) -> Int {
            let pageViewController = pageViewController as! UIViewControllerType
            
            return pageViewController.allViewControllers.count
        }
        
        @usableFromInline
        @objc func presentationIndex(for pageViewController: UIPageViewController) -> Int {
            (pageViewController as? UIHostingPageViewController<Page>)?.currentPageIndex ?? 0
        }
    }
}

extension _PaginationView {
    @usableFromInline
    struct _ProgressionController: ProgressionController {
        @usableFromInline
        weak var base: UIHostingPageViewController<Page>?
        
        @usableFromInline
        var currentPageIndex: Binding<Int>
        
        @usableFromInline
        func moveToNext() {
            guard
                let base = base,
                let baseDataSource = base.dataSource,
                let currentViewController = base.viewControllers?.first,
                let nextViewController = baseDataSource.pageViewController(base, viewControllerAfter: currentViewController)
            else {
                return
            }
            
            base.setViewControllers([nextViewController], direction: .forward, animated: true) { finished in
                guard finished else {
                    return
                }
                
                if let currentPageIndex = base.currentPageIndex {
                    self.currentPageIndex.wrappedValue = currentPageIndex
                }
            }
        }
        
        @usableFromInline
        func moveToPrevious() {
            guard
                let base = base,
                let baseDataSource = base.dataSource,
                let currentViewController = base.viewControllers?.first,
                let previousViewController = baseDataSource.pageViewController(base, viewControllerBefore: currentViewController)
            else {
                return
            }
            
            base.setViewControllers([previousViewController], direction: .reverse, animated: true) { finished in
                guard finished else {
                    return
                }
                
                if let currentPageIndex = base.currentPageIndex {
                    self.currentPageIndex.wrappedValue = currentPageIndex
                }
            }
        }
    }
}

#endif
