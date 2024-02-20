//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct PaginationState: Hashable {
    public enum TransitionDirection: Hashable {
        case backward
        case forward
    }
    
    public var activePageTransitionDirection: TransitionDirection?
    public var activePageTransitionProgress: Double = 0.0
    
    public init() {
        
    }
}

/// A view that paginates its children along a given axis.
@frozen
public struct PaginationView<Page: View>: View {
    @usableFromInline
    let content: AnyForEach<Page>
    @usableFromInline
    let axis: Axis
    @usableFromInline
    let transitionStyle: UIPageViewController.TransitionStyle
    @usableFromInline
    let showsIndicators: Bool
    
    @usableFromInline
    var pageIndicatorAlignment: Alignment
    @usableFromInline
    var interPageSpacing: CGFloat?
    @usableFromInline
    var cyclesPages: Bool = false
    @usableFromInline
    var initialPageIndex: Int?
    @usableFromInline
    var currentPageIndex: Binding<Int>?
    
    /// The current page index internally used by `PaginationView`.
    /// Never access this directly, it is marked public as a workaround to a compiler bug.
    @inlinable
    @State public var _currentPageIndex = 0
    
    /// Never access this directly, it is marked public as a workaround to a compiler bug.
    @inlinable
    @DelayedState public var _progressionController: ProgressionController?
    
    private var _scrollViewConfiguration: CocoaScrollViewConfiguration<AnyView> = nil
    
    var paginationState: Binding<PaginationState>?
    
    @inlinable
    public init(
        content: AnyForEach<Page>,
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true
    ) {
        self.content = content
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
    
    @inlinable
    public init<Data, ID>(
        content: ForEach<Data, ID, Page>,
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true
    ) {
        self.init(
            content: .init(content),
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    public var body: some View {
        if content.isEmpty {
            EmptyView()
        } else {
            ZStack(alignment: pageIndicatorAlignment) {
                _PaginationView(
                    content: content,
                    configuration: .init(
                        axis: axis,
                        transitionStyle: transitionStyle,
                        showsIndicators: showsIndicators,
                        pageIndicatorAlignment: pageIndicatorAlignment,
                        interPageSpacing: interPageSpacing,
                        cyclesPages: cyclesPages,
                        initialPageIndex: initialPageIndex,
                        paginationState: paginationState
                    ),
                    currentPageIndex: currentPageIndex ?? $_currentPageIndex,
                    progressionController: $_progressionController
                )
                
                if showsIndicators && (axis == .vertical || pageIndicatorAlignment != .center) {
                    PageControl(
                        numberOfPages: content.count,
                        currentPage: currentPageIndex ?? $_currentPageIndex
                    ).rotationEffect(
                        axis == .vertical
                        ? .init(degrees: 90)
                        : .init(degrees: 0)
                    )
                }
            }
            .environment(\.progressionController, _progressionController)
            .environment(\._scrollViewConfiguration, _scrollViewConfiguration)
        }
    }
}

// MARK: - Initializers

extension PaginationView {
    @inlinable
    public init<Data: RandomAccessCollection, ID: Hashable>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping (Data.Element) -> Page
    ) {
        self.init(
            content: .init(data, id: id, content: content),
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<Data, ID>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> ForEach<Data, ID, Page>
    ) {
        self.init(
            content: .init(content()),
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<Data, ID>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> ForEach<Data, ID, Page>
    ) where Data.Element: Identifiable {
        self.init(
            content: .init(content()),
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
}

extension PaginationView {
    @inlinable
    public init(
        pages: [Page],
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true
    ) {
        self.init(
            content: AnyForEach(pages.indices, id: \.self, content: { pages[$0] }),
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @_disfavoredOverload
    @inlinable
    public init(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @_ArrayBuilder<Page> content: () -> [Page]
    ) {
        self.init(
            pages: content(),
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View, C3: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2, C3)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView(),
                content.value.3.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View, C3: View, C4: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2, C3, C4)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView(),
                content.value.3.eraseToAnyView(),
                content.value.4.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2, C3, C4, C5)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView(),
                content.value.3.eraseToAnyView(),
                content.value.4.eraseToAnyView(),
                content.value.5.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2, C3, C4, C5, C6)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView(),
                content.value.3.eraseToAnyView(),
                content.value.4.eraseToAnyView(),
                content.value.5.eraseToAnyView(),
                content.value.6.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView(),
                content.value.3.eraseToAnyView(),
                content.value.4.eraseToAnyView(),
                content.value.5.eraseToAnyView(),
                content.value.6.eraseToAnyView(),
                content.value.7.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView(),
                content.value.3.eraseToAnyView(),
                content.value.4.eraseToAnyView(),
                content.value.5.eraseToAnyView(),
                content.value.6.eraseToAnyView(),
                content.value.7.eraseToAnyView(),
                content.value.8.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
    
    @inlinable
    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(
        axis: Axis = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>
    ) where Page == AnyView {
        let content = content()
        
        self.init(
            pages: [
                content.value.0.eraseToAnyView(),
                content.value.1.eraseToAnyView(),
                content.value.2.eraseToAnyView(),
                content.value.3.eraseToAnyView(),
                content.value.4.eraseToAnyView(),
                content.value.5.eraseToAnyView(),
                content.value.6.eraseToAnyView(),
                content.value.7.eraseToAnyView(),
                content.value.8.eraseToAnyView(),
                content.value.9.eraseToAnyView()
            ],
            axis: axis,
            transitionStyle: transitionStyle,
            showsIndicators: showsIndicators
        )
    }
}

// MARK: - API

extension PaginationView {
    @inlinable
    public func pageIndicatorAlignment(_ alignment: Alignment) -> Self {
        then({ $0.pageIndicatorAlignment = alignment })
    }
    
    @inlinable
    public func interPageSpacing(_ interPageSpacing: CGFloat) -> Self {
        then({ $0.interPageSpacing = interPageSpacing })
    }
    
    @inlinable
    public func cyclesPages(_ cyclesPages: Bool) -> Self {
        then({ $0.cyclesPages = cyclesPages })
    }
}

extension PaginationView {
    @inlinable
    public func initialPageIndex(_ initialPageIndex: Int) -> Self {
        then({ $0.initialPageIndex = initialPageIndex })
    }
    
    @inlinable
    public func currentPageIndex(_ currentPageIndex: Binding<Int>) -> Self {
        then({ $0.currentPageIndex = currentPageIndex })
    }
}

extension PaginationView {
    public func paginationState(_ paginationState: Binding<PaginationState>) -> Self {
        then({ $0.paginationState = paginationState })
    }
}

extension PaginationView {
    /// Adds a modifier for this view that fires an action when the scroll content offset changes.
    public func onOffsetChange(
        _ body: @escaping (ScrollView<AnyView>.ContentOffset) -> ()
    ) -> Self {
        then {
            $0._scrollViewConfiguration.onOffsetChange = body
        }
    }
}

#endif
