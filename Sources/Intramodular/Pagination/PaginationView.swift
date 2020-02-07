//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A view that paginates its children along a given axis.
public struct PaginationView<Page: View>: View {
    private let children: [UIHostingController<Page>]
    private let axis: Axis
    private let transitionStyle: UIPageViewController.TransitionStyle
    private let pageIndicatorAlignment: Alignment
    private let showsIndicators: Bool
    
    @State private var currentPageIndex = 0
    @DelayedState private var progressionController: ProgressionController?
    
    public init(
        pages: [Page],
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        pageIndicatorAlignment: Alignment? = nil,
        showsIndicators: Bool = true
    ) {
        self.children = pages.map(_UIHostingController.init)
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
                children: children,
                axis: axis,
                transitionStyle: transitionStyle,
                pageIndicatorAlignment: pageIndicatorAlignment,
                currentPageIndex: $currentPageIndex,
                progressionController: $progressionController
            )
            if showsIndicators {
                if axis == .vertical || pageIndicatorAlignment != .center {
                    PageControl(
                        numberOfPages: children.count,
                        currentPage: $currentPageIndex
                    ).rotationEffect(
                        axis == .vertical
                            ? .init(degrees: 90)
                            : .init(degrees: 0)
                    )
                }
            }
        }
        .environment(\.progressionController, progressionController)
    }
}

#endif
