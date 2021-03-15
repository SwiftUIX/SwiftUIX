//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// The properties of a `CocoaScrollView` instance.
public struct CocoaScrollViewConfiguration<Content: View> {
    @usableFromInline
    var initialContentAlignment: Alignment?
    @usableFromInline
    var axes: Axis.Set = [.horizontal, .vertical]
    
    @usableFromInline
    var showsIndicators: Bool = true
    @usableFromInline
    var alwaysBounceVertical: Bool? = nil
    @usableFromInline
    var alwaysBounceHorizontal: Bool = false
    @usableFromInline
    var isDirectionalLockEnabled: Bool = false
    @usableFromInline
    var isPagingEnabled: Bool = false
    @usableFromInline
    var isScrollEnabled: Bool = true
    @usableFromInline
    var onOffsetChange: (ScrollView<Content>.ContentOffset) -> () = { _ in }
    @usableFromInline
    var onRefresh: (() -> Void)?
    @usableFromInline
    var isRefreshing: Bool?
    @usableFromInline
    var refreshControlTintColor: UIColor?
    
    @available(tvOS, unavailable)
    @usableFromInline
    var setupRefreshControl: ((UIRefreshControl) -> Void)?
    
    @usableFromInline
    var contentOffset: Binding<CGPoint>? = nil
    
    @usableFromInline
    var contentInset: UIEdgeInsets = .zero
}

extension CocoaScrollViewConfiguration {
    mutating func update(from environment: EnvironmentValues) {
        initialContentAlignment = environment.initialContentAlignment
        isScrollEnabled = environment.isScrollEnabled
    }
    
    func updating(from environment: EnvironmentValues) -> Self {
        var result = self
        
        result.update(from: environment)
        
        return result
    }
}

// MARK: - Auxiliary Implementation -

#if !os(tvOS)

extension UIRefreshControl {
    func refreshChanged<Content: View>(
        with configuration: CocoaScrollViewConfiguration<Content>
    ) {
        configuration.onRefresh?()
        
        if let isRefreshing = configuration.isRefreshing, !isRefreshing {
            endRefreshing()
        }
    }
}

#endif

extension UIScrollView {
    func configure<Content: View>(
        with configuration: CocoaScrollViewConfiguration<Content>
    ) {
        if let alwaysBounceVertical = configuration.alwaysBounceVertical {
            self.alwaysBounceVertical = alwaysBounceVertical
        }
        
        alwaysBounceHorizontal = configuration.alwaysBounceHorizontal
        isDirectionalLockEnabled = configuration.isDirectionalLockEnabled
        isScrollEnabled = configuration.isScrollEnabled
        showsVerticalScrollIndicator = configuration.showsIndicators
        showsHorizontalScrollIndicator = configuration.showsIndicators
        contentInset = configuration.contentInset
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        isPagingEnabled = configuration.isPagingEnabled
        #endif
        
        #if !os(tvOS)
        if configuration.onRefresh != nil || configuration.isRefreshing != nil {
            let refreshControl = self.refreshControl ?? UIRefreshControl().then {
                configuration.setupRefreshControl?($0)
                
                self.refreshControl = $0
            }

            refreshControl.tintColor = configuration.refreshControlTintColor

            if let isRefreshing = configuration.isRefreshing, refreshControl.isRefreshing != isRefreshing {
                if isRefreshing {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
        }
        #endif
        
        if let contentOffset = configuration.contentOffset?.wrappedValue {
            if self.contentOffset.ceil != contentOffset.ceil {
                setContentOffset(contentOffset, animated: true)
            }
        }
    }
}

extension EnvironmentValues {
    struct _ScrollViewConfiguration: EnvironmentKey {
        static let defaultValue = CocoaScrollViewConfiguration<AnyView>()
    }
    
    var _scrollViewConfiguration: CocoaScrollViewConfiguration<AnyView> {
        get {
            self[_ScrollViewConfiguration]
        } set {
            self[_ScrollViewConfiguration] = newValue
        }
    }
}

#endif
