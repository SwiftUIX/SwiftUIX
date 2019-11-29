//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A SwiftUI port of `UIPageViewController`.
struct _PaginationView {
    private let children: [UIViewController]
    private let axis: Axis
    private let pageIndicatorAlignment: Alignment
    
    @Binding private var currentPageIndex: Int
    @Binding private var progressionController: ProgressionController?
    
    init(
        children: [UIViewController],
        axis: Axis,
        pageIndicatorAlignment: Alignment,
        currentPageIndex: Binding<Int>,
        progressionController: Binding<ProgressionController?>
    ) {
        self.children = children
        self.axis = axis
        self.pageIndicatorAlignment = pageIndicatorAlignment
        self._currentPageIndex = currentPageIndex
        self._progressionController = progressionController
    }
}

// MARK: - Protocol Implementations -

extension _PaginationView: UIViewControllerRepresentable {
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
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: _PaginationView
        
        init(_ parent: _PaginationView) {
            self.parent = parent
        }
        
        // MARK: - Data Source
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            parent
                .children
                .firstIndex(of: viewController)
                .flatMap({
                    $0 == 0
                        ? parent.children.last
                        : parent.children[$0 - 1]
                })
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            parent
                .children
                .firstIndex(of: viewController)
                .flatMap({
                    $0 + 1 == parent.children.count
                        ? parent.children.first
                        : parent.children[$0 + 1]
                })
        }
        
        // MARK: - Delegate
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else {
                return
            }
            
            if let controller = pageViewController.viewControllers?.first {
                parent
                    .children
                    .firstIndex(of: controller)
                    .map({
                        parent.currentPageIndex = $0
                    })
            }
        }
    }
    
    private class _Coordinator_Default_UIPageControl: Coordinator {
        var currentPageIndex: Int
        
        override init(_ parent: _PaginationView) {
            self.currentPageIndex = parent.currentPageIndex
            
            super.init(parent)
        }
        
        @objc func presentationCount(for pageViewController: UIPageViewController) -> Int {
            return parent.children.count
        }
        
        @objc func presentationIndex(for pageViewController: UIPageViewController) -> Int {
            return currentPageIndex
        }
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let result = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: axis == .horizontal
                ? .horizontal
                : .vertical
        )
        
        result.dataSource = context.coordinator
        result.delegate = context.coordinator

        progressionController = _ProgressionController(base: result)
        
        return result
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        if let coordinator = context.coordinator as? _Coordinator_Default_UIPageControl {
            coordinator.currentPageIndex = currentPageIndex
        }
        
        pageViewController.setViewControllers(
            [children[currentPageIndex]],
            direction: .forward,
            animated: true
        )
    }
    
    func makeCoordinator() -> Coordinator {
        if axis == .vertical || pageIndicatorAlignment != .center {
            return Coordinator(self)
        } else {
            return _Coordinator_Default_UIPageControl(self)
        }
    }
}

#endif
