//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct PerformActionOnKeyboardShortcut: ViewModifier {
    /// This is needed to work around a bug in `View/keyboardShort(_:)`
    private class ActionTrampoline {
        var value: () -> Void = { }
        
        func callAsFunction() {
            value()
        }
    }
    
    let shortcut: KeyboardShortcut?
    let action: () -> Void
    let disabled: Bool
    
    @ViewStorage private var actionTrampoline = ActionTrampoline()
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(
        shortcut: KeyboardShortcut?,
        action: @escaping () -> (),
        disabled: Bool
    ) {
        self.shortcut = shortcut
        self.action = action
        self.disabled = disabled
    }
    
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    func body(content: Content) -> some View {
        content.background {
            ZStack {
                PerformAction {
                    actionTrampoline.value = action
                }
                
                if let shortcut, !disabled {
                    Button(action: performAction) {
                        ZeroSizeView()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .keyboardShortcut(shortcut)
                    .visible(false)
                }
            }
            .accessibilityHidden(true)
        }
    }
    
    private func performAction() {
        self.actionTrampoline.callAsFunction()
    }
}

// MARK: - API

extension View {
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onKeyboardShortcut(
        _ shortcut: KeyboardShortcut?,
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(
            PerformActionOnKeyboardShortcut(
                shortcut: shortcut,
                action: action,
                disabled: false
            )
        )
    }
    
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onKeyboardShortcut(
        _ shortcut: KeyboardShortcut,
        disabled: Bool = false,
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(
            PerformActionOnKeyboardShortcut(
                shortcut: shortcut,
                action: action,
                disabled: disabled
            )
        )
    }
    
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onKeyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = [.command],
        disabled: Bool = false,
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(
            PerformActionOnKeyboardShortcut(
                shortcut: .init(key, modifiers: modifiers),
                action: action,
                disabled: disabled
            )
        )
    }
    
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onKeyboardShortcut<Action: DynamicAction>(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = [.command],
        disabled: Bool = false,
        perform action: Action
    ) -> some View {
        WithDynamicAction(action) { action in
            onKeyboardShortcut(
                key,
                modifiers: modifiers,
                disabled: disabled,
                perform: action.perform
            )
        }
    }
}

extension View {
    /// Adds an action to perform when this view recognizes a keyboard shortcut.
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onKeyboardShortcut(
        _ shortcut: KeyEquivalent,
        when predicate: Bool,
        perform action: @escaping () -> Void
    ) -> some View {
        onKeyboardShortcut(shortcut, disabled: !predicate, perform: action)
    }
}

#endif
