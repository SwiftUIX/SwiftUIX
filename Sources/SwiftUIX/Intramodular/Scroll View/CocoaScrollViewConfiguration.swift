//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

/// The properties of a `CocoaScrollView` instance.
public struct CocoaScrollViewConfiguration<Content: View>: ExpressibleByNilLiteral {
    var initialContentAlignment: Alignment?
    var axes: Axis.Set = [.vertical]
    var showsVerticalScrollIndicator: Bool? = true
    var showsHorizontalScrollIndicator: Bool? = true
    var scrollIndicatorInsets: (horizontal: EdgeInsets, vertical: EdgeInsets) = (.zero, .zero)
    #if os(iOS) || os(tvOS) || os(visionOS)
    var decelerationRate: UIScrollView.DecelerationRate = .normal
    #endif
    var alwaysBounceVertical: Bool? = nil
    var alwaysBounceHorizontal: Bool? = nil
    var isDirectionalLockEnabled: Bool = false
    var isPagingEnabled: Bool = false
    var isScrollEnabled: Bool = true
    
    var onOffsetChange: ((ScrollView<Content>.ContentOffset) -> ())?
    var onDragEnd: (() -> Void)?
    var contentOffset: Binding<CGPoint>? = nil
    
    var contentInset: EdgeInsets = .zero
    #if os(iOS) || os(tvOS) || os(visionOS)
    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior?
    #endif
    var contentOffsetBehavior: ScrollContentOffsetBehavior = []
    
    var onRefresh: (() -> Void)?
    var isRefreshing: Bool?
    var refreshControlTintColor: AppKitOrUIKitColor?
    
    private var _keyboardDismissMode: Any?
    
    #if os(iOS) || os(tvOS) || os(visionOS)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode {
        get {
            _keyboardDismissMode.flatMap({ $0 as? UIScrollView.KeyboardDismissMode }) ?? .none
        } set {
            _keyboardDismissMode = newValue
        }
    }
    #endif
    
    public init(nilLiteral: ()) {
        
    }
}

extension CocoaScrollViewConfiguration {
    mutating func update(from environment: EnvironmentValues) {
        if let initialContentAlignment = environment.initialContentAlignment {
            self.initialContentAlignment = initialContentAlignment
        }
        
        if !environment._isScrollEnabled {
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

// MARK: - Auxiliary

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

extension EnvironmentValues {
    struct _ScrollViewConfiguration: EnvironmentKey {
        static let defaultValue: CocoaScrollViewConfiguration<AnyView> = nil
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
