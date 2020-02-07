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
    private let pageIndicatorAlignment: Alignment
    private let showsIndicators: Bool
    
    @State private var currentPageIndex = 0
    
    @DelayedState private var progressionController: ProgressionController?
    
    public init(
        pages: [Page],
        initialPageIndex: Int = 0,
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        pageIndicatorAlignment: Alignment? = nil,
        showsIndicators: Bool = true
    ) {
        self.pages = pages
        self.currentPageIndex = initialPageIndex
        self.axis = axis
        self.transitionStyle = transitionStyle
        
        if let pageIndicatorAlignment = pageIndicatorAlignment {
            self.pageIndicatorAlignment = pageIndicatorAlignment
        } else {
            switch axis {
                case .horizontal:
                    self.pageIndicatorAlignment = .center
                case .vertical:
                    self.pageIndicatorAlignment = .leading
            }
        }
        
        self.showsIndicators = showsIndicators
    }
    
    public init(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        pageIndicatorAlignment: Alignment? = nil,
        showsIndicators: Bool = true,
        @ArrayBuilder<Page> content: () -> [Page]
    ) {
        self.init(
            pages: content(),
            axis: axis,
            transitionStyle: transitionStyle,
            pageIndicatorAlignment: pageIndicatorAlignment,
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
                currentPageIndex: $currentPageIndex,
                progressionController: $progressionController
            )
            
            if showsIndicators && axis == .vertical || pageIndicatorAlignment != .center {
                PageControl(
                    numberOfPages: pages.count,
                    currentPage: $currentPageIndex
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

extension PaginationView where Page == AnyView {
    public init<V: View & ViewListMaker>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        pageIndicatorAlignment: Alignment? = nil,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> V
    ) {
        self.init(
            pages: content().makeViewList(),
            transitionStyle: transitionStyle,
            pageIndicatorAlignment: pageIndicatorAlignment,
            showsIndicators: showsIndicators
        )
    }
}

#endif
