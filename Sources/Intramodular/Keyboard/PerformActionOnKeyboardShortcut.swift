//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@usableFromInline
struct PerformActionOnKeyboardShortcut: ViewModifier {
    /// This is needed to work around a bug in `View/keyboardShort(_:)`
    private class ActionTrampoline {
        var value: () -> Void = { }
        
        func callAsFunction() {
            value()
        }
    }
    
    let shortcut: KeyboardShortcut
    let action: () -> Void
    
    @State private var actionTrampoline = ActionTrampoline()
    
    @usableFromInline
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(shortcut: KeyboardShortcut, action: @escaping () -> ()) {
        self.shortcut = shortcut
        self.action = action
    }
    
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @usableFromInline
    func body(content: Content) -> some View {
        content.background {
            ZStack {
                PerformAction {
                    actionTrampoline.value = action
                }

                Button(action: { self.actionTrampoline.callAsFunction() }) {
                    ZeroSizeView()
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(shortcut)
                .visible(false)
            }
        }
    }
}

// MARK: - API -

extension View {
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @inlinable
    public func onKeyboardShortcut(
        _ shortcut: KeyboardShortcut,
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(PerformActionOnKeyboardShortcut(shortcut: shortcut, action: action))
    }
    
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @inlinable
    public func onKeyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = [],
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(PerformActionOnKeyboardShortcut(shortcut: .init(key, modifiers: modifiers), action: action))
    }
    
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @inlinable
    public func onKeyboardShortcut<Action: DynamicAction>(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = [],
        perform action: Action
    ) -> some View {
        WithDynamicAction(action) { action in
            onKeyboardShortcut(key, modifiers: modifiers, perform: action.perform)
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct OnKeyboardShortcut: PerformActionView {
    public let shortcut: KeyboardShortcut
    public let action: Action
    
    public init(_ shortcut: KeyboardShortcut, perform action: Action) {
        self.shortcut = shortcut
        self.action = action
    }
    
    public init(_ shortcut: KeyboardShortcut, perform action: @escaping () -> Void) {
        self.init(shortcut, perform: .init(action))
    }
    
    public init(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = [],
        action: @escaping () -> Void
    ) {
        self.init(.init(key, modifiers: modifiers), perform: .init(action))
    }
    
    public var body: some View {
        Button(action: action.perform) {
            ZeroSizeView()
        }
        .keyboardShortcut(shortcut)
        .visible(false)
        .frameZeroClipped()
    }
    
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        .init(shortcut, perform: action.map(transform))
    }
}

extension View {
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @inlinable
    public func onKeyboardShortcut(
        _ shortcut: KeyEquivalent,
        when predicate: Bool,
        perform action: @escaping () -> Void
    ) -> some View {
        background {
            if predicate {
                OnKeyboardShortcut(shortcut) {
                    action()
                }
            }
        }
    }
}

#endif
