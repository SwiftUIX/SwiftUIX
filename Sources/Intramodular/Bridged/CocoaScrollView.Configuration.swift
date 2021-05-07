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
    
    @usableFromInline
    var contentOffset: Binding<CGPoint>? = nil
    @usableFromInline
    var contentInset: EdgeInsets = .zero
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
        showsVerticalScrollIndicator = configuration.showsIndicators && configuration.axes.contains(.vertical)
        showsHorizontalScrollIndicator = configuration.showsIndicators && configuration.axes.contains(.horizontal)
        contentInset = .init(configuration.contentInset)
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        isPagingEnabled = configuration.isPagingEnabled
        #endif
        
        #if !os(tvOS)
        if configuration.onRefresh != nil || configuration.isRefreshing != nil {
            let refreshControl: _UIRefreshControl
            
            if let _refreshControl = self.refreshControl as? _UIRefreshControl {
                _refreshControl.onRefresh = configuration.onRefresh ?? { }
                
                refreshControl = _refreshControl
            } else {
                refreshControl = _UIRefreshControl(onRefresh: configuration.onRefresh ?? { })
                
                self.alwaysBounceVertical = true
                self.refreshControl = refreshControl
                
                if refreshControl.superview == nil {
                    addSubview(refreshControl)
                }
            }
            
            refreshControl.tintColor = configuration.refreshControlTintColor
            
            if let isRefreshing = configuration.isRefreshing, refreshControl.isRefreshing != isRefreshing {
                if isRefreshing {
                    refreshControl.beginRefreshingWithoutUserInput()
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

#if !os(tvOS)

final class _UIRefreshControl: UIRefreshControl {
    var onRefresh: () -> Void
    
    var isRefreshingWithoutUserInteraction: Bool = false
    var lastContentInset: UIEdgeInsets?
    var lastContentOffset: CGPoint?
    
    init(onRefresh: @escaping () -> Void) {
        self.onRefresh = onRefresh
        
        super.init()
        
        addTarget(
            self,
            action: #selector(self.refreshChanged),
            for: .valueChanged
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func beginRefreshing() {
        if let superview = superview as? UIScrollView {
            lastContentInset = superview.contentInset
            lastContentOffset = superview.contentOffset
        }

        super.beginRefreshing()
    }
    
    func beginRefreshingWithoutUserInput() {
        beginRefreshing()
        
        isRefreshingWithoutUserInteraction = true
        
        if let superview = superview as? UIScrollView {
            superview.setContentOffset(CGPoint(x: 0, y: superview.contentOffset.y - frame.height), animated: true)
        }
        
        sendActions(for: .valueChanged)
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        if isRefreshingWithoutUserInteraction {
            isRefreshingWithoutUserInteraction = false
        }
        
        if let superview = superview as? UIScrollView {
            if let lastContentInset = lastContentInset, superview.contentInset != lastContentInset {
                superview.contentInset = lastContentInset
            }
            
            if let lastContentOffset = lastContentOffset {
                superview.setContentOffset(lastContentOffset, animated: true)
            }
        }
    }
    
    @objc func refreshChanged(_ sender: UIRefreshControl) {
        guard !isRefreshingWithoutUserInteraction else {
            return
        }
        
        onRefresh()
    }
}

#endif

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
