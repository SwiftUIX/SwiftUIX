//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct CocoaScrollViewConfiguration<Content: View> {
    var alwaysBounceVertical: Bool = false
    var alwaysBounceHorizontal: Bool = false
    var isPagingEnabled: Bool = false
    var isDirectionalLockEnabled: Bool = false
    var onOffsetChange: (ScrollView<Content>.ContentOffset) -> () = { _ in }
    var onRefresh: (() -> Void)?
    var isRefreshing: Bool?
    
    @available(tvOS, unavailable)
    var setupRefreshControl: ((UIRefreshControl) -> Void)?
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIRefreshControl {
    @available(tvOS, unavailable)
    func refreshChanged<Content: View>(
        with configuration: CocoaScrollViewConfiguration<Content>
    ) {
        configuration.onRefresh?()
        
        if let isRefreshing = configuration.isRefreshing, !isRefreshing {
            endRefreshing()
        }
    }
}

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
        
        if configuration.onRefresh != nil {
            let refreshControl = self.refreshControl ?? UIRefreshControl().then {
                configuration.setupRefreshControl?($0)
            }
            
            if let isRefreshing = configuration.isRefreshing {
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
