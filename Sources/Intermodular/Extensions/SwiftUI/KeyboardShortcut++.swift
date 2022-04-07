//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyboardShortcut {
    public var appKitKeyEquivalent: (key: Character, modifiers: NSEvent.ModifierFlags) {
        return (key.character, modifiers.appKitModifierFlags)
    }

    public init?(from event: NSEvent) {
        guard let key = event.charactersIgnoringModifiers.map(Character.init) else {
            return nil
        }

        self.init(KeyEquivalent(key), modifiers: EventModifiers(from: event.modifierFlags))
    }
    
    public static func ~= (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        lhs.key ~= rhs.key && rhs.modifiers.contains(lhs.modifiers)
    }
}

// MARK: - Auxiliary Implementation -

extension EventModifiers {
    fileprivate var appKitModifierFlags: NSEvent.ModifierFlags {
        switch self {
            case .capsLock:
                return .capsLock
            case .shift:
                return .shift
            case .control:
                return .control
            case .option:
                return .control
            case .command:
                return .command
            case .numericPad:
                return .numericPad
            case .function:
                return .function
            default:
                fatalError()
        }
    }

    fileprivate init(from modifierFlags: NSEvent.ModifierFlags) {
        self.init()

        if modifierFlags.contains(.capsLock) {
            insert(.capsLock)
        }

        if modifierFlags.contains(.shift) {
            insert(.shift)
        }

        if modifierFlags.contains(.control) {
            insert(.control)
        }

        if modifierFlags.contains(.command) {
            insert(.command)
        }

        if modifierFlags.contains(.numericPad) {
            insert(.numericPad)
        }

        if modifierFlags.contains(.function) {
            insert(.function)
        }
    }
}

#endif
