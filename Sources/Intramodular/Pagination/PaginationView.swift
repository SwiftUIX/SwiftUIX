//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A view that paginates its children along a given axis.
public struct PaginationView<Page: View>: View {
    private let pages: [Page]
    private let axis: Axis
    private let transitionStyle: UIPageViewController.TransitionStyle
    private let showsIndicators: Bool
    
    private var pageIndicatorAlignment: Alignment
    private var initialPageIndex: Int?
    private var currentPageIndex: Binding<Int>?
    
    @State private var _currentPageIndex = 0
    
    @DelayedState private var progressionController: ProgressionController?
    
    public init(
        pages: [Page],
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true
    ) {
        self.pages = pages
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.showsIndicators = showsIndicators
        
        switch axis {
            case .horizontal:
                self.pageIndicatorAlignment = .center
            case .vertical:
                self.pageIndicatorAlignment = .leading
        }
    }
    
    public init(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ArrayBuilder<Page> content: () -> [Page]
    ) {
        self.init(
            pages: content(),
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    public var body: some View {
        ZStack(alignment: pageIndicatorAlignment) {
            _PaginationView(
                pages: pages,
                axis: axis,
                transitionStyle: transitionStyle,
                showsIndicators: showsIndicators,
                pageIndicatorAlignment: pageIndicatorAlignment,
                initialPageIndex: initialPageIndex,
                currentPageIndex: currentPageIndex ?? $_currentPageIndex,
                progressionController: $progressionController
            )
            
            if showsIndicators && axis == .vertical || pageIndicatorAlignment != .center {
                PageControl(
                    numberOfPages: pages.count,
                    currentPage: currentPageIndex ?? $_currentPageIndex
                ).rotationEffect(
                    axis == .vertical
                        ? .init(degrees: 90)
                        : .init(degrees: 0)
                )
            }
        }
        .environment(\.progressionController, progressionController)
    }
}

extension PaginationView {
    public func pageIndicatorAlignment(_ alignment: Alignment) -> Self {
        then({ $0.pageIndicatorAlignment = alignment })
    }
}

extension PaginationView {
    public func initialPageIndex(_ currentPageIndex: Binding<Int>) -> Self {
        then({ $0.initialPageIndex = initialPageIndex })
    }
    
    public func currentPageIndex(_ currentPageIndex: Binding<Int>) -> Self {
        then({ $0.currentPageIndex = currentPageIndex })
    }
}

#endif
