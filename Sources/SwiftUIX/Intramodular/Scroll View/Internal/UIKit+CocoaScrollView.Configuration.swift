//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
extension UIScrollView {
    var isScrolling: Bool {
        layer.animation(forKey: "bounds") != nil
    }
    
    func configure<Content: View>(
        with configuration: CocoaScrollViewConfiguration<Content>
    ) {
        if configuration.axes != [.vertical] {
            if configuration.axes == [.horizontal] {
                _assignIfNotEqual(true, to: \.isDirectionalLockEnabled)
            }
        } else {
            _assignIfNotEqual(false, to: \.isDirectionalLockEnabled)
        }
        
        if let alwaysBounceVertical = configuration.alwaysBounceVertical {
            _assignIfNotEqual(alwaysBounceVertical, to: \.alwaysBounceVertical)
        }
        
        if let alwaysBounceHorizontal = configuration.alwaysBounceHorizontal {
            _assignIfNotEqual(alwaysBounceHorizontal, to: \.alwaysBounceHorizontal)
        }
           
        if alwaysBounceVertical || alwaysBounceHorizontal {
            bounces = true
        } else if !alwaysBounceVertical && !alwaysBounceHorizontal {
            bounces = false
        }
        
        _assignIfNotEqual(configuration.isDirectionalLockEnabled, to: \.isDirectionalLockEnabled)
        _assignIfNotEqual(configuration.isScrollEnabled, to: \.isScrollEnabled)
        _assignIfNotEqual(configuration.showsVerticalScrollIndicator, to: \.showsVerticalScrollIndicator)
        _assignIfNotEqual(configuration.showsHorizontalScrollIndicator, to: \.showsHorizontalScrollIndicator)
        _assignIfNotEqual(.init(configuration.scrollIndicatorInsets.horizontal), to: \.horizontalScrollIndicatorInsets)
        _assignIfNotEqual(.init(configuration.scrollIndicatorInsets.vertical), to: \.verticalScrollIndicatorInsets)
        _assignIfNotEqual(configuration.decelerationRate, to: \.decelerationRate)
        _assignIfNotEqual(.init(configuration.contentInset), to: \.contentInset)
        
        if let contentInsetAdjustmentBehavior = configuration.contentInsetAdjustmentBehavior {
            self.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        } else {
            self.contentInsetAdjustmentBehavior = .automatic
        }
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        isPagingEnabled = configuration.isPagingEnabled
        #endif
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        keyboardDismissMode = configuration.keyboardDismissMode
        #endif
        
        if let contentOffset = configuration.contentOffset?.wrappedValue {
            if self.contentOffset.ceil != contentOffset.ceil {
                setContentOffset(contentOffset, animated: true)
            }
        }
        
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
                    if !configuration.contentOffsetBehavior.contains(.maintainOnChangeOfContentSize) {
                        refreshControl.beginRefreshingWithoutUserInput(adjustContentOffset: !(configuration.initialContentAlignment == .bottom))
                    }
                } else {
                    refreshControl.endRefreshing()
                }
            }
        }
        #endif
    }
    
    func performEnforcingScrollOffsetBehavior(
        _ behavior: ScrollContentOffsetBehavior,
        animated: Bool,
        _ update: () -> Void
    ) {
        if behavior.contains(.maintainOnChangeOfContentSize) {
            if isScrolling {
                setContentOffset(contentOffset, animated: false)
            }
        }
        
        let beforeVerticalAlignment = currentVerticalAlignment
        let beforeContentSize = contentSize
        
        update()
        
        let afterContentSize = contentSize
        
        if behavior.contains(.maintainOnChangeOfContentSize) {
            guard afterContentSize != beforeContentSize else {
                return
            }
            
            var deltaX = contentOffset.x + (afterContentSize.width - beforeContentSize.width)
            var deltaY = contentOffset.y + (afterContentSize.height - beforeContentSize.height)
            
            deltaX = beforeContentSize.width == 0 ? 0 : max(0, deltaX)
            deltaY = beforeContentSize.height == 0 ? 0 : max(0, deltaY)
            
            let newOffset = CGPoint(
                x: contentOffset.x + deltaX,
                y: contentOffset.y + deltaY
            )
            
            if contentOffset != newOffset {
                setContentOffset(newOffset, animated: animated)
            }
        } else if behavior.contains(.smartAlignOnChangeOfContentSize) {
            if beforeVerticalAlignment == .bottom {
                setContentAlignment(.bottom, animated: animated)
            }
        }
    }
}
#endif

#if os(iOS) || os(visionOS)
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
    
    func beginRefreshingWithoutUserInput(adjustContentOffset: Bool) {
        beginRefreshing()
        
        isRefreshingWithoutUserInteraction = true
        
        if let superview = superview as? UIScrollView {
            if adjustContentOffset {
                superview.setContentOffset(CGPoint(x: 0, y: superview.contentOffset.y - frame.height), animated: true)
            } else {
                self.lastContentOffset = nil
            }
        }
        
        sendActions(for: .valueChanged)
    }
    
    override func endRefreshing() {
        defer {
            isRefreshingWithoutUserInteraction = false
        }
        
        super.endRefreshing()
        
        if let superview = superview as? UIScrollView {
            if let lastContentInset = lastContentInset, superview.contentInset != lastContentInset {
                superview.contentInset = lastContentInset
            }
            
            if let lastContentOffset = lastContentOffset, isRefreshingWithoutUserInteraction {
                superview.setContentOffset(lastContentOffset, animated: true)
                
                self.lastContentOffset = nil
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
