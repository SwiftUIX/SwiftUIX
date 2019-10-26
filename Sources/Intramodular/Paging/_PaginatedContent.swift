//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A SwiftUI port of `UIPageViewController`.
struct _PaginatedContent {
    private let children: [UIViewController]
    private let axis: Axis
    private let pageIndicatorAlignment: Alignment
    
    @Binding private var currentPageIndex: Int
    
    init(
        children: [UIViewController],
        axis: Axis,
        pageIndicatorAlignment: Alignment,
        currentPageIndex: Binding<Int>
    ) {
        self.children = children
        self.axis = axis
        self.pageIndicatorAlignment = pageIndicatorAlignment
        self._currentPageIndex = currentPageIndex
    }
}

// MARK: - Protocol Implementations -

extension _PaginatedContent: UIViewControllerRepresentable {
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: _PaginatedContent
        
        init(_ parent: _PaginatedContent) {
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
        
        override init(_ parent: _PaginatedContent) {
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
        
        return result
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
            [children[currentPageIndex]],
            direction: .forward,
            animated: true
        )
    }
    
    func makeCoordinator() -> Coordinator {
        if axis == .vertical || pageIndicatorAlignment != .center {
            return _Coordinator_Default_UIPageControl(self)
        } else {
            return Coordinator(self)
        }
    }
}

#endif
