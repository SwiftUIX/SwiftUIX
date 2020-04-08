//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaScrollViewConfiguration<Content: View> {
    @usableFromInline
    var alwaysBounceVertical: Bool = false
    @usableFromInline
    var alwaysBounceHorizontal: Bool = false
    @usableFromInline
    var isPagingEnabled: Bool = false
    @usableFromInline
    var isDirectionalLockEnabled: Bool = false
    @usableFromInline
    var onOffsetChange: (ScrollView<Content>.ContentOffset) -> () = { _ in }
    @usableFromInline
    var onRefresh: (() -> Void)?
    @usableFromInline
    var isRefreshing: Bool?
    
    @available(tvOS, unavailable)
    @usableFromInline
    var setupRefreshControl: ((UIRefreshControl) -> Void)?
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
