//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension EnvironmentValues {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    private struct ContentInsetAdjustmentBehaviorKey: EnvironmentKey {
        static let defaultValue: UIScrollView.ContentInsetAdjustmentBehavior? = nil
    }
    
    public var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior? {
        get {
            self[ContentInsetAdjustmentBehaviorKey.self]
        } set {
            self[ContentInsetAdjustmentBehaviorKey.self] = newValue
        }
    }
    
    @available(tvOS, unavailable)
    private struct KeyboardDismissModeKey: EnvironmentKey {
        static let defaultValue: UIScrollView.KeyboardDismissMode = .none
    }
    
    @available(tvOS, unavailable)
    public var keyboardDismissMode: UIScrollView.KeyboardDismissMode {
        get {
            self[KeyboardDismissModeKey.self]
        } set {
            self[KeyboardDismissModeKey.self] = newValue
        }
    }
    #endif
    
    private struct IsScrollEnabledEnvironmentKey: EnvironmentKey {
        static let defaultValue = true
    }
    
    public var isScrollEnabled: Bool {
        get {
            self[IsScrollEnabledEnvironmentKey.self]
        } set {
            self[IsScrollEnabledEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - API -

extension View {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func contentInsetAdjustmentBehavior(_ behavior: UIScrollView.ContentInsetAdjustmentBehavior) -> some View {
        environment(\.contentInsetAdjustmentBehavior, behavior)
    }
    
    /// Sets the keyboard dismiss mode for this view.
    @available(tvOS, unavailable)
    public func keyboardDismissMode(_ keyboardDismissMode: UIScrollView.KeyboardDismissMode) -> some View {
        environment(\.keyboardDismissMode, keyboardDismissMode)
    }
    #endif
    
    /// Adds a condition that controls whether users can scroll within this view.
    public func scrollDisabled(_ disabled: Bool) -> some View {
        environment(\.isScrollEnabled, !disabled)
    }
    
    @available(*, message: "isScrollEnabled(_:) is deprecated, use scrollDisabled(_:) instead")
    public func isScrollEnabled(_ isEnabled: Bool) -> some View {
        environment(\.isScrollEnabled, isEnabled)
    }
}
