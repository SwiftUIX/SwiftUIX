//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// The properties of a `CocoaScrollView` instance.
public struct CocoaScrollViewConfiguration<Content: View> {
    var hasChanged: Bool = true
    
    // MARK: General
    
    var initialContentAlignment: Alignment? {
        didSet {
            if oldValue != initialContentAlignment {
                hasChanged = true
            }
        }
    }
    
    var axes: Axis.Set = [.vertical] {
        didSet {
            if oldValue != axes {
                hasChanged = true
            }
        }
    }
    
    var showsVerticalScrollIndicator: Bool = true {
        didSet {
            if oldValue != showsVerticalScrollIndicator {
                hasChanged = true
            }
        }
    }
    
    var showsHorizontalScrollIndicator: Bool = true {
        didSet {
            if oldValue != showsHorizontalScrollIndicator {
                hasChanged = true
            }
        }
    }
    
    var scrollIndicatorInsets: (horizontal: EdgeInsets, vertical: EdgeInsets) = (.zero, .zero) {
        didSet {
            if oldValue != scrollIndicatorInsets {
                hasChanged = true
            }
        }
    }

    var decelerationRate: UIScrollView.DecelerationRate = .normal {
        didSet {
            if oldValue != decelerationRate {
                hasChanged = true
            }
        }
    }

    var alwaysBounceVertical: Bool? = nil {
        didSet {
            if oldValue != alwaysBounceVertical {
                hasChanged = true
            }
        }
    }
    
    var alwaysBounceHorizontal: Bool? = nil {
        didSet {
            if oldValue != alwaysBounceHorizontal {
                hasChanged = true
            }
        }
    }
    
    var isDirectionalLockEnabled: Bool = false {
        didSet {
            if oldValue != isDirectionalLockEnabled {
                hasChanged = true
            }
        }
    }
    
    var isPagingEnabled: Bool = false {
        didSet {
            if oldValue != isPagingEnabled {
                hasChanged = true
            }
        }
    }
    
    var isScrollEnabled: Bool = true {
        didSet {
            if oldValue != isScrollEnabled {
                hasChanged = true
            }
        }
    }
    
    var onOffsetChange: ((ScrollView<Content>.ContentOffset) -> ())? = nil {
        didSet {
            if (oldValue == nil) != (onOffsetChange == nil) {
                hasChanged = true
            }
        }
    }
    
    // MARK: Content
    
    var contentOffset: Binding<CGPoint>? = nil {
        didSet {
            if (oldValue == nil) != (contentOffset == nil) {
                hasChanged = true
            }
        }
    }
    
    var contentInset: EdgeInsets = .zero {
        didSet {
            if oldValue != contentInset {
                hasChanged = true
            }
        }
    }
    
    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior? {
        didSet {
            if oldValue != contentInsetAdjustmentBehavior {
                hasChanged = true
            }
        }
    }
    
    var contentOffsetBehavior: ScrollContentOffsetBehavior = [] {
        didSet {
            if oldValue != contentOffsetBehavior {
                hasChanged = true
            }
        }
    }
    
    // MARK: Refresh
    
    var onRefresh: (() -> Void)? {
        didSet {
            if (oldValue == nil) != (onRefresh == nil) {
                hasChanged = true
            }
        }
    }
    
    var isRefreshing: Bool? {
        didSet {
            if oldValue != isRefreshing {
                hasChanged = true
            }
        }
    }
    
    var refreshControlTintColor: UIColor? {
        didSet {
            if oldValue != refreshControlTintColor {
                hasChanged = true
            }
        }
    }
    
    // MARK: Keyboard
    
    @available(tvOS, unavailable)
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none {
        didSet {
            if oldValue != keyboardDismissMode {
                hasChanged = true
            }
        }
    }
}

extension CocoaScrollViewConfiguration {
    mutating func update(from environment: EnvironmentValues) {
        if let initialContentAlignment = environment.initialContentAlignment {
            self.initialContentAlignment = initialContentAlignment
        }
        
        if !environment.isScrollEnabled {
            isScrollEnabled = false
        }
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        contentInsetAdjustmentBehavior = environment.contentInsetAdjustmentBehavior
        keyboardDismissMode = environment.keyboardDismissMode
        #endif
        
        if let scrollIndicatorStyle = environment.scrollIndicatorStyle as?
            HiddenScrollViewIndicatorStyle {
            showsVerticalScrollIndicator = !scrollIndicatorStyle.vertical
            showsHorizontalScrollIndicator = !scrollIndicatorStyle.horizontal
        } else if let scrollIndicatorStyle = environment.scrollIndicatorStyle as? InsetScrollViewIndicatorStyle {
            scrollIndicatorInsets = scrollIndicatorStyle.insets
        }
    }
}

// MARK: - Auxiliary Implementation -

public struct ScrollContentOffsetBehavior: OptionSet {
    public static let maintainOnChangeOfBounds = Self(rawValue: 1 << 0)
    public static let maintainOnChangeOfContentSize = Self(rawValue: 1 << 1)
    public static let maintainOnChangeOfKeyboardFrame = Self(rawValue: 1 << 2)
    public static let smartAlignOnChangeOfContentSize = Self(rawValue: 1 << 3)
    
    public let rawValue: Int8
    
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}

extension UIScrollView {
    var isScrolling: Bool {
        layer.animation(forKey: "bounds") != nil
    }
    
    func configure<Content: View>(
        with configuration: CocoaScrollViewConfiguration<Content>
    ) {
        guard configuration.hasChanged else {
            return
        }
        
        if let alwaysBounceVertical = configuration.alwaysBounceVertical {
            self.alwaysBounceVertical = alwaysBounceVertical
        }
        
        if let alwaysBounceHorizontal = configuration.alwaysBounceHorizontal {
            self.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
        
        isDirectionalLockEnabled = configuration.isDirectionalLockEnabled
        isScrollEnabled = configuration.isScrollEnabled
        showsVerticalScrollIndicator = configuration.showsVerticalScrollIndicator
        showsHorizontalScrollIndicator = configuration.showsHorizontalScrollIndicator
        horizontalScrollIndicatorInsets = .init(configuration.scrollIndicatorInsets.horizontal)
        verticalScrollIndicatorInsets = .init(configuration.scrollIndicatorInsets.vertical)
        decelerationRate = configuration.decelerationRate
        
        if contentInset != .init(configuration.contentInset) {
            contentInset = .init(configuration.contentInset)
        }
        
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
    
    func maintainScrollContentOffsetBehavior(
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

extension EnvironmentValues {
    struct _ScrollViewConfiguration: EnvironmentKey {
        static let defaultValue = CocoaScrollViewConfiguration<AnyView>()
    }
    
    var _scrollViewConfiguration: CocoaScrollViewConfiguration<AnyView> {
        get {
            var result = self[_ScrollViewConfiguration.self]
            
            result.update(from: self)
            
            return result
        } set {
            self[_ScrollViewConfiguration.self] = newValue
        }
    }
}

#endif
