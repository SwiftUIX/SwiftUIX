//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaScrollViewConfiguration<Content: View> {
    @usableFromInline
    var initialContentAlignment: Alignment = .topLeading
    @usableFromInline
    var axes: Axis.Set = [.horizontal, .vertical]
    
    @usableFromInline
    var showsIndicators: Bool = true
    @usableFromInline
    var alwaysBounceVertical: Bool = false
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
    
    @available(tvOS, unavailable)
    @usableFromInline
    var setupRefreshControl: ((UIRefreshControl) -> Void)?
    
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
        alwaysBounceVertical = configuration.alwaysBounceVertical
        alwaysBounceHorizontal = configuration.alwaysBounceHorizontal
        isDirectionalLockEnabled = configuration.isDirectionalLockEnabled
        #if os(iOS) || targetEnvironment(macCatalyst)
        isPagingEnabled = configuration.isPagingEnabled
        #endif
        
        isScrollEnabled = configuration.isScrollEnabled
        
        #if !os(tvOS)
        if configuration.onRefresh != nil || configuration.isRefreshing != nil {
            let refreshControl = self.refreshControl ?? UIRefreshControl().then {
                configuration.setupRefreshControl?($0)
                
                self.refreshControl = $0
            }
            
            if let isRefreshing = configuration.isRefreshing, refreshControl.isRefreshing != isRefreshing {
                if isRefreshing {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
        }
        #endif
    }
}

#endif
