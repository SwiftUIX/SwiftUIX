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
    let content: AnyForEach<Page>
    @usableFromInline
    let axis: Axis
    @usableFromInline
    let transitionStyle: UIPageViewController.TransitionStyle
    @usableFromInline
    let showsIndicators: Bool
    @usableFromInline
    let pageIndicatorAlignment: Alignment
    @usableFromInline
    let interPageSpacing: CGFloat?
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
        content: AnyForEach<Page>,
        axis: Axis,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool,
        pageIndicatorAlignment: Alignment,
        interPageSpacing: CGFloat?,
        cyclesPages: Bool,
        initialPageIndex: Int?,
        currentPageIndex: Binding<Int>,
        progressionController: Binding<ProgressionController?>
    ) {
        self.content = content
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.showsIndicators = showsIndicators
        self.pageIndicatorAlignment = pageIndicatorAlignment
        self.interPageSpacing = interPageSpacing
        self.cyclesPages = cyclesPages
        self.initialPageIndex = initialPageIndex
        self._currentPageIndex = currentPageIndex
        self._progressionController = progressionController
    }
}

// MARK: - Protocol Conformances -

extension _PaginationView: UIViewControllerRepresentable {
    @usableFromInline
    typealias UIViewControllerType = UIHostingPageViewController<Page>
    
    @usableFromInline
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let uiViewController = UIViewControllerType(
            transitionStyle: transitionStyle,
            navigationOrientation: axis == .horizontal ? .horizontal : .vertical,
            options: interPageSpacing.map({ [.interPageSpacing: $0 as NSNumber] })
        )
        
        #if os(tvOS)
        uiViewController.view.backgroundColor = UIColor.clear
        #endif
        
        uiViewController.content = content
        
        uiViewController.dataSource = .some(context.coordinator as! UIPageViewControllerDataSource)
        uiViewController.delegate = .some(context.coordinator as! UIPageViewControllerDelegate)
        
        guard !content.isEmpty else {
            return uiViewController
        }
        
        if initialPageIndex == nil {
            uiViewController.isInitialPageIndexApplied = true
        }
        
        if content.data.indices.contains(content.data.index(content.data.startIndex, offsetBy: initialPageIndex ?? currentPageIndex)) {
            let firstIndex = content.data.index(content.data.startIndex, offsetBy: initialPageIndex ?? currentPageIndex)
            
            if let firstViewController = uiViewController.viewController(for: firstIndex) {
                uiViewController.setViewControllers(
                    [firstViewController],
                    direction: .forward,
                    animated: context.transaction.isAnimated
                )
            }
        } else {
            if !content.isEmpty {
                let firstIndex = content.data.index(content.data.startIndex, offsetBy: initialPageIndex ?? currentPageIndex)
                
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
        defer {
            uiViewController._isAnimated = true
        }
        
        uiViewController._isAnimated = context.transaction.isAnimated
        uiViewController.content = content
        
        if let initialPageIndex = initialPageIndex, !uiViewController.isInitialPageIndexApplied {
            DispatchQueue.main.async {
                uiViewController.isInitialPageIndexApplied = true
                
                currentPageIndex = initialPageIndex
            }
            
            uiViewController.currentPageIndex = content.data.index(content.data.startIndex, offsetBy: initialPageIndex)
        } else {
            uiViewController.currentPageIndex = content.data.index(content.data.startIndex, offsetBy: self.currentPageIndex)
        }
        
        if uiViewController.pageControl?.currentPage != currentPageIndex {
            uiViewController.pageControl?.currentPage = currentPageIndex
        }
        
        uiViewController.cyclesPages = cyclesPages
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
        @objc(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else {
                return
            }
            
            guard let pageViewController = pageViewController as? UIViewControllerType else {
                assertionFailure()
                
                return
            }
            
            if let offset = pageViewController.currentPageIndexOffset {
                DispatchQueue.main.async {
                    self.parent.currentPageIndex = offset
                }
            }
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
                
                self.syncCurrentPageIndex()
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
                
                self.syncCurrentPageIndex()
            }
        }
        
        @usableFromInline
        func syncCurrentPageIndex() {
            if let currentPageIndex = base?.currentPageIndexOffset {
                self.currentPageIndex.wrappedValue = currentPageIndex
            }
        }
    }
}

#endif
