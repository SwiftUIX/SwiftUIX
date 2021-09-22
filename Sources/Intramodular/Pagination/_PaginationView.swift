//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A SwiftUI port of `UIPageViewController`.
struct _PaginationView<Page: View> {
    let content: AnyForEach<Page>
    
    struct Configuration {
        let axis: Axis
        let transitionStyle: UIPageViewController.TransitionStyle
        let showsIndicators: Bool
        let pageIndicatorAlignment: Alignment
        let interPageSpacing: CGFloat?
        let cyclesPages: Bool
        let initialPageIndex: Int?
        let paginationState: Binding<PaginationState>?
    }
    
    let configuration: Configuration
    
    @Binding var currentPageIndex: Int
    @Binding var progressionController: ProgressionController?
    
    init(
        content: AnyForEach<Page>,
        configuration: Configuration,
        currentPageIndex: Binding<Int>,
        progressionController: Binding<ProgressionController?>
    ) {
        self.content = content
        self.configuration = configuration
        self._currentPageIndex = currentPageIndex
        self._progressionController = progressionController
    }
}

// MARK: - Conformances -

extension _PaginationView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIHostingPageViewController<Page>
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let uiViewController = UIViewControllerType(
            transitionStyle: configuration.transitionStyle,
            navigationOrientation: configuration.axis == .horizontal ? .horizontal : .vertical,
            options: configuration.interPageSpacing.map({ [.interPageSpacing: $0 as NSNumber] })
        )
        
        #if os(tvOS)
        uiViewController.view.backgroundColor = UIColor.clear
        #endif
        
        uiViewController.paginationState = configuration.paginationState
        uiViewController.content = content
        
        uiViewController.dataSource = .some(context.coordinator as! UIPageViewControllerDataSource)
        uiViewController.delegate = .some(context.coordinator as! UIPageViewControllerDelegate)
        
        guard !content.isEmpty else {
            return uiViewController
        }
        
        if configuration.initialPageIndex == nil {
            context.coordinator.isInitialPageIndexApplied = true
        }
        
        if content.data.indices.contains(content.data.index(content.data.startIndex, offsetBy: configuration.initialPageIndex ?? currentPageIndex)) {
            let firstIndex = content.data.index(content.data.startIndex, offsetBy: configuration.initialPageIndex ?? currentPageIndex)
            
            if let firstViewController = uiViewController.viewController(for: firstIndex) {
                uiViewController.setViewControllers(
                    [firstViewController],
                    direction: .forward,
                    animated: context.transaction.isAnimated
                )
            }
        } else {
            if !content.isEmpty {
                let firstIndex = content.data.index(content.data.startIndex, offsetBy: configuration.initialPageIndex ?? currentPageIndex)
                
                if let firstViewController = uiViewController.viewController(for: firstIndex) {
                    uiViewController.setViewControllers(
                        [firstViewController],
                        direction: .forward,
                        animated: context.transaction.isAnimated
                    )
                }
                
                currentPageIndex = 0
            }
        }
        
        progressionController = _ProgressionController(base: uiViewController, currentPageIndex: $currentPageIndex)
        
        return uiViewController
    }
    
    @usableFromInline
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        var shouldUpdateContent = true
        
        defer {
            if shouldUpdateContent {
                uiViewController.content = content
            }
        }
        
        uiViewController._isSwiftUIRuntimeUpdateActive = true
        
        defer {
            uiViewController._isAnimated = true
            uiViewController._isSwiftUIRuntimeUpdateActive = false
        }
        
        if let _paginationViewProxy = context.environment._paginationViewProxy {
            if _paginationViewProxy.wrappedValue.hostingPageViewController !== uiViewController || (_paginationViewProxy.wrappedValue.progressionController as? _ProgressionController)?.base == nil {
                DispatchQueue.main.async {
                    _paginationViewProxy.wrappedValue.hostingPageViewController = uiViewController
                    _paginationViewProxy.wrappedValue.progressionController = _ProgressionController(base: uiViewController, currentPageIndex: $currentPageIndex)
                }
            }
        }
        
        let oldContentDataEndIndex = uiViewController.content?.data.endIndex
        
        uiViewController._isAnimated = context.transaction.isAnimated
        
        updateScrollViewConfiguration: do {
            let scrollViewConfiguration = context.environment._scrollViewConfiguration
            
            uiViewController.internalScrollView?.isScrollEnabled = scrollViewConfiguration.isScrollEnabled
        }
        
        if let initialPageIndex = configuration.initialPageIndex, !context.coordinator.isInitialPageIndexApplied {
            DispatchQueue.main.async {
                context.coordinator.isInitialPageIndexApplied = true
                
                if currentPageIndex != initialPageIndex {
                    currentPageIndex = initialPageIndex
                }
            }
            
            uiViewController.currentPageIndex = content.data.index(content.data.startIndex, offsetBy: initialPageIndex)
        } else {
            var currentPageIndex = self.currentPageIndex
            
            clampPageIndexIfNecessary: do {
                if let oldContentDataEndIndex = oldContentDataEndIndex {
                    if content.data.endIndex < oldContentDataEndIndex, !(content.data.index(content.data.startIndex, offsetBy: currentPageIndex) < content.data.endIndex) {
                        currentPageIndex = max(content.data.count - 1, 0)
                        
                        DispatchQueue.main.async {
                            self.currentPageIndex = currentPageIndex
                        }
                    }
                }
            }
            
            let newCurrentPageIndex = content.data.index(content.data.startIndex, offsetBy: currentPageIndex)
            
            if uiViewController.currentPageIndex != newCurrentPageIndex, uiViewController.content?.count == content.count {
                shouldUpdateContent = false
            }
            
            if !context.coordinator.isTransitioning {
                if context.coordinator.didJustCompleteTransition {
                    DispatchQueue.main.async {
                        context.coordinator.didJustCompleteTransition = false
                    }
                } else {
                    uiViewController.currentPageIndex = newCurrentPageIndex
                }
            }
        }
        
        if uiViewController.pageControl?.currentPage != currentPageIndex {
            uiViewController.pageControl?.currentPage = currentPageIndex
        }
        
        uiViewController.cyclesPages = configuration.cyclesPages
        uiViewController.isEdgePanGestureEnabled = context.environment.isEdgePanGestureEnabled
        uiViewController.isPanGestureEnabled = context.environment.isPanGestureEnabled
        uiViewController.isScrollEnabled = context.environment.isScrollEnabled
        uiViewController.isTapGestureEnabled = context.environment.isTapGestureEnabled
        
        if #available(iOS 14.0, tvOS 14.0, *) {
            if let backgroundStyle = context.environment.pageControlBackgroundStyle {
                uiViewController.pageControl?.backgroundStyle = backgroundStyle
            }
        }
        
        uiViewController.pageControl?.currentPageIndicatorTintColor = context.environment.currentPageIndicatorTintColor?.toUIColor()
        uiViewController.pageControl?.pageIndicatorTintColor = context.environment.pageIndicatorTintColor?.toUIColor()
    }
    
    @usableFromInline
    func makeCoordinator() -> Coordinator {
        guard configuration.showsIndicators else {
            return _Coordinator_No_UIPageControl(self)
        }
        
        if configuration.axis == .vertical || configuration.pageIndicatorAlignment != .center {
            return _Coordinator_No_UIPageControl(self)
        } else {
            return _Coordinator_Default_UIPageControl(self)
        }
    }
}

extension _PaginationView {
    @usableFromInline
    class Coordinator: NSObject {
        var parent: _PaginationView
        var isInitialPageIndexApplied: Bool = false
        var isTransitioning: Bool = false
        var didJustCompleteTransition: Bool = false
        
        @usableFromInline
        init(_ parent: _PaginationView) {
            self.parent = parent
        }
        
        @objc(pageViewController:viewControllerBeforeViewController:)
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
        
        @objc(pageViewController:viewControllerAfterViewController:)
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
        @objc(pageViewController:willTransitionToViewControllers:)
        func pageViewController(
            _ pageViewController: UIPageViewController,
            willTransitionTo pendingViewControllers: [UIViewController]
        ) {
            isTransitioning = true
        }
        
        @usableFromInline
        @objc(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            if completed {
                guard let pageViewController = pageViewController as? UIViewControllerType else {
                    assertionFailure()
                    
                    return
                }
                
                if let offset = pageViewController.currentPageIndexOffset {
                    self.parent.currentPageIndex = offset
                }
                
                didJustCompleteTransition = true
            }
                        
            isTransitioning = false
        }
    }
    
    @usableFromInline
    class _Coordinator_No_UIPageControl: Coordinator, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
    }
    
    @usableFromInline
    class _Coordinator_Default_UIPageControl: Coordinator, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        @usableFromInline
        @objc func presentationCount(for pageViewController: UIPageViewController) -> Int {
            return parent.content.data.count
        }
        
        @usableFromInline
        @objc func presentationIndex(for pageViewController: UIPageViewController) -> Int {
            guard let pageViewController = pageViewController as? UIViewControllerType else {
                assertionFailure()
                
                return 0
            }
            
            return pageViewController.currentPageIndexOffset ?? 0
        }
    }
}

extension _PaginationView {
    @usableFromInline
    struct _ProgressionController: ProgressionController {
        weak var base: UIHostingPageViewController<Page>?
        
        var currentPageIndex: Binding<Int>
        
        func scrollTo(_ id: AnyHashable) {
            guard let base = base else {
                assertionFailure("Could not resolve a pagination view")
                return
            }
            
            guard let currentPageIndex = base.currentPageIndexOffset, let data = base.content?.data, let index = data.firstIndex(where: { $0.id == id }).map({ data.distance(from: data.startIndex, to: $0) }) else {
                return
            }
            
            guard
                let baseDataSource = base.dataSource,
                let currentViewController = base.viewControllers?.first,
                let nextViewController = baseDataSource.pageViewController(base, viewControllerAfter: currentViewController)
            else {
                return
            }
            
            base.setViewControllers(
                [nextViewController],
                direction: index > currentPageIndex ? .forward : .reverse,
                animated: true
            ) { finished in
                guard finished else {
                    return
                }
                
                self.syncCurrentPageIndex()
            }
        }
        
        func moveToNext() {
            guard let base = base else {
                assertionFailure("Could not resolve a pagination view")
                return
            }
            
            guard
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
                
                self.syncCurrentPageIndex()
            }
        }
        
        func moveToPrevious() {
            guard let base = base else {
                assertionFailure("Could not resolve a pagination view")
                return
            }
            
            guard
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
                
                self.syncCurrentPageIndex()
            }
        }
        
        private func syncCurrentPageIndex() {
            if let currentPageIndex = base?.currentPageIndexOffset {
                self.currentPageIndex.wrappedValue = currentPageIndex
            }
        }
    }
}

#endif
