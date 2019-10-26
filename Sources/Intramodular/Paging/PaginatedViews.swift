//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A view that paginates its children along a given axis.
public struct PaginatedViews<Content: View>: View {
    private let children: [UIHostingController<Content>]
    private let axis: Axis
    private let pageIndicatorAlignment: Alignment
    
    @State private var currentPageIndex = 0
    
    public init(
        _ pages: [Content],
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
            _PaginatedContent(
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
