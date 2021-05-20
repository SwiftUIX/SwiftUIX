//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// The properties of a `CocoaScrollView` instance.
public struct CocoaScrollViewConfiguration<Content: View> {
    @usableFromInline
    var isVanilla: Bool = true
    
    @usableFromInline
    var initialContentAlignment: Alignment? {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var axes: Axis.Set = [.horizontal, .vertical] {
        didSet {
            isVanilla = false
        }
    }
    
    @usableFromInline
    var showsIndicators: Bool = true {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var alwaysBounceVertical: Bool? = nil {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var alwaysBounceHorizontal: Bool = false {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var isDirectionalLockEnabled: Bool = false {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var isPagingEnabled: Bool = false {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var isScrollEnabled: Bool = true {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var onOffsetChange: ((ScrollView<Content>.ContentOffset) -> ())? = nil {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var onRefresh: (() -> Void)? {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var isRefreshing: Bool? {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var refreshControlTintColor: UIColor? {
        didSet {
            isVanilla = false
        }
    }
    
    @usableFromInline
    var contentOffset: Binding<CGPoint>? = nil {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var contentInset: EdgeInsets = .zero {
        didSet {
            isVanilla = false
        }
    }
    @usableFromInline
    var contentOffsetBehavior: ScrollContentOffsetBehavior = [] {
        didSet {
            isVanilla = false
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
    }
    
    func updating(from environment: EnvironmentValues) -> Self {
        var result = self
        
        result.update(from: environment)
        
        return result
    }
}

// MARK: - Auxiliary Implementation -

public struct ScrollContentOffsetBehavior: OptionSet {
    public static let maintainOnChangeOfBounds = Self(rawValue: 1 << 0)
    public static let maintainOnChangeOfContentSize = Self(rawValue: 1 << 1)
    public static let maintainOnChangeOfKeyboardFrame = Self(rawValue: 1 << 2)
    
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
        guard !configuration.isVanilla else {
            return
        }
        
        if let alwaysBounceVertical = configuration.alwaysBounceVertical {
            self.alwaysBounceVertical = alwaysBounceVertical
        }
        
        alwaysBounceHorizontal = configuration.alwaysBounceHorizontal
        isDirectionalLockEnabled = configuration.isDirectionalLockEnabled
        isScrollEnabled = configuration.isScrollEnabled
        showsVerticalScrollIndicator = configuration.showsIndicators && configuration.axes.contains(.vertical)
        showsHorizontalScrollIndicator = configuration.showsIndicators && configuration.axes.contains(.horizontal)
        
        if contentInset != .init(configuration.contentInset) {
            contentInset = .init(configuration.contentInset)
        }
        
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
                    if !configuration.contentOffsetBehavior.contains(.maintainOnChangeOfContentSize) {
                        refreshControl.beginRefreshingWithoutUserInput(adjustContentOffset: !(configuration.initialContentAlignment == .bottom))
                    }
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
    
    func updateContentSizeWithoutChangingContentOffset(_ update: () -> Void) {
        if isScrolling {
            setContentOffset(contentOffset, animated: false)
        }
        
        let beforeContentSize = contentSize
        
        update()
        
        let afterContentSize = contentSize
        
        var deltaX = contentOffset.x + (afterContentSize.width - beforeContentSize.width)
        var deltaY = contentOffset.y + (afterContentSize.height - beforeContentSize.height)
        
        deltaX = beforeContentSize.width == 0 ? 0 : max(0, deltaX)
        deltaY = beforeContentSize.height == 0 ? 0 : max(0, deltaY)
        
        let newOffset = CGPoint(
            x: contentOffset.x + deltaX,
            y: contentOffset.y + deltaY
        )
        
        if contentOffset != newOffset {
            setContentOffset(newOffset, animated: true)
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
            var result = self[_ScrollViewConfiguration]
            
            result.update(from: self)
            
            return result
        } set {
            self[_ScrollViewConfiguration] = newValue
        }
    }
}

#endif
