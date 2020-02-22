//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A SwiftUI port of `UIPageViewController`.
struct _PaginationView<Page: View> {
    private let pages: [Page]
    private let axis: Axis
    private let transitionStyle: UIPageViewController.TransitionStyle
    private let infiniteScroll: Bool = false
    private let showsIndicators: Bool
    private let pageIndicatorAlignment: Alignment
    private let initialPageIndex: Int?
    
    @Binding private var currentPageIndex: Int
    @Binding private var progressionController: ProgressionController?
    
    @Environment(\.isPanGestureEnabled) private var isPanGestureEnabled
    @Environment(\.isScrollEnabled) private var isScrollEnabled
    @Environment(\.pageIndicatorTintColor) private var pageIndicatorTintColor
    @Environment(\.currentPageIndicatorTintColor) private var currentPageIndicatorTintColor
    
    init(
        pages: [Page],
        axis: Axis,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool,
        pageIndicatorAlignment: Alignment,
        initialPageIndex: Int?,
        currentPageIndex: Binding<Int>,
        progressionController: Binding<ProgressionController?>
    ) {
        self.pages = pages
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.showsIndicators = showsIndicators
        self.pageIndicatorAlignment = pageIndicatorAlignment
        self.initialPageIndex = initialPageIndex
        self._currentPageIndex = currentPageIndex
        self._progressionController = progressionController
    }
}

// MARK: - Protocol Implementations -

extension _PaginationView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIHostingPageViewController<Page>
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let result = UIViewControllerType(
            transitionStyle: transitionStyle,
            navigationOrientation: axis == .horizontal
                ? .horizontal
                : .vertical
        )
        
        result.pages = pages
        
        result.dataSource = .some(context.coordinator as! UIPageViewControllerDataSource)
        result.delegate = .some(context.coordinator as! UIPageViewControllerDelegate)
        
        if let initialPageIndex = initialPageIndex {
            currentPageIndex = initialPageIndex
        }
        
        result.setViewControllers(
            [result.allViewControllers[initialPageIndex ?? currentPageIndex]],
            direction: .forward,
            animated: true
        )
        
        progressionController = _ProgressionController(base: result)
        
        return result
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if #available(iOS 13.1, *) {
            uiViewController.isPanGestureEnabled = isPanGestureEnabled
            uiViewController.isScrollEnabled = isScrollEnabled
            uiViewController.pageControl?.currentPageIndicatorTintColor = currentPageIndicatorTintColor?.toUIColor()
            uiViewController.pageControl?.pageIndicatorTintColor = pageIndicatorTintColor?.toUIColor()
        }
        
        uiViewController.pages = pages
        
        if uiViewController.allViewControllers[currentPageIndex] === uiViewController.viewControllers?.first {
            uiViewController.setViewControllers(
                [uiViewController.allViewControllers[currentPageIndex]],
                direction: .forward,
                animated: true
            )
        }
    }
    
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
    class Coordinator: NSObject {
        var parent: _PaginationView
        
        init(_ parent: _PaginationView) {
            self.parent = parent
        }
    }
    
    class _Coordinator_No_UIPageControl: Coordinator, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            let pageViewController = pageViewController as! UIViewControllerType
            
            return pageViewController
                .allViewControllers
                .firstIndex(of: viewController as! UIHostingController<Page>)
                .flatMap({
                    $0 == 0
                        ? (parent.infiniteScroll ? pageViewController.allViewControllers.last : nil)
                        : pageViewController.allViewControllers[$0 - 1]
                })
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            let pageViewController = pageViewController as! UIViewControllerType
            
            return pageViewController
                .allViewControllers
                .firstIndex(of: viewController as! UIHostingController<Page>)
                .flatMap({
                    $0 + 1 == pageViewController.allViewControllers.count
                        ? (parent.infiniteScroll ? pageViewController.allViewControllers.first : nil)
                        : pageViewController.allViewControllers[$0 + 1]
                })
        }
        
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
    
    private class _Coordinator_Default_UIPageControl: Coordinator, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            let pageViewController = pageViewController as! UIViewControllerType
            
            return pageViewController
                .allViewControllers
                .firstIndex(of: viewController as! UIHostingController<Page>)
                .flatMap({
                    $0 == 0
                        ? (parent.infiniteScroll ? pageViewController.allViewControllers.last : nil)
                        : pageViewController.allViewControllers[$0 - 1]
                })
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            let pageViewController = pageViewController as! UIViewControllerType
            
            return pageViewController
                .allViewControllers
                .firstIndex(of: viewController as! UIHostingController<Page>)
                .flatMap({
                    $0 + 1 == pageViewController.allViewControllers.count
                        ? (parent.infiniteScroll ? pageViewController.allViewControllers.first : nil)
                        : pageViewController.allViewControllers[$0 + 1]
                })
        }
        
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
        
        @objc func presentationCount(for pageViewController: UIPageViewController) -> Int {
            let pageViewController = pageViewController as! UIViewControllerType
            
            return pageViewController.allViewControllers.count
        }
        
        @objc func presentationIndex(for pageViewController: UIPageViewController) -> Int {
            let pageViewController = pageViewController as! UIViewControllerType
            
            guard let controller = pageViewController.allViewControllers.first else {
                return parent.currentPageIndex
            }
            
            return pageViewController
                .allViewControllers
                .firstIndex(of: controller) ?? parent.currentPageIndex
        }
    }
}

extension _PaginationView {
    struct _ProgressionController: ProgressionController {
        weak var base: UIPageViewController?
        
        func moveToNext() {
            guard
                let base = base,
                let baseDataSource = base.dataSource,
                let currentViewController = base.viewControllers?.first,
                let nextViewController = baseDataSource.pageViewController(base, viewControllerAfter: currentViewController)
                else {
                    return
            }
            
            base.setViewControllers([nextViewController], direction: .forward, animated: true)
        }
        
        func moveToPrevious() {
            guard
                let base = base,
                let baseDataSource = base.dataSource,
                let currentViewController = base.viewControllers?.first,
                let previousViewController = baseDataSource.pageViewController(base, viewControllerBefore: currentViewController)
                else {
                    return
            }
            
            base.setViewControllers([previousViewController], direction: .reverse, animated: true)
        }
    }
}

#endif
