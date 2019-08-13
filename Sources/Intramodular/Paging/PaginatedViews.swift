//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import SwiftUI
import UIKit

/// A view that paginates its children along a given axis.
public struct PaginatedViews<Child: View>: View {
    private let children: [UIHostingController<Child>]
    private let axis: Axis
    private let pageIndicatorAlignment: Alignment

    @State private var currentPageIndex = 0

    public init(
        _ pages: [Child],
        axis: Axis = .horizontal,
        pageIndicatorAlignment: Alignment? = nil
    ) {
        self.children = pages.map(UIHostingController.init)
        self.axis = axis

        switch axis {
        case .horizontal:
            self.pageIndicatorAlignment = .center
        case .vertical:
            self.pageIndicatorAlignment = .leading
        }
    }

    public var body: some View {
        ZStack(alignment: pageIndicatorAlignment) {
            PageViewController(
                children: children,
                axis: axis,
                pageIndicatorAlignment: pageIndicatorAlignment,
                currentPageIndex: $currentPageIndex
            )

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
}

#endif
