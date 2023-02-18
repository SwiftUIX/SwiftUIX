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
        guard let characters = event.charactersIgnoringModifiers, !characters.isEmpty else {
            return nil
        }
        
        guard let key = event.charactersIgnoringModifiers.map(Character.init) else {
            return nil
        }

        self.init(KeyEquivalent(key), modifiers: EventModifiers(from: event.modifierFlags))
    }
    
    public static func ~= (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        lhs.key ~= rhs.key && rhs.modifiers.contains(lhs.modifiers)
    }
}

// MARK: - Auxiliary

extension SwiftUI.EventModifiers {
    public func toCGEventFlags() -> CGEventFlags {
        var result: CGEventFlags = []
        
        if contains(.capsLock) {
            result.insert(CGEventFlags.maskAlphaShift)
        }
        
        if contains(.shift) {
            result.insert(CGEventFlags.maskShift)
        }
        
        if contains(.control) {
            result.insert(CGEventFlags.maskControl)
        }
        
        if contains(.option) {
            result.insert(CGEventFlags.maskAlternate)
        }
        
        if contains(.command) {
            result.insert(CGEventFlags.maskCommand)
        }
        
        if contains(.numericPad) {
            result.insert(CGEventFlags.maskNumericPad)
        }
        
        return result
    }
}

extension EventModifiers {
    fileprivate var appKitModifierFlags: NSEvent.ModifierFlags {
        var result: NSEvent.ModifierFlags = []
        
        if contains(.capsLock) {
            result.insert(.capsLock)
        }
        
        if contains(.shift) {
            result.insert(.shift)
        }
        
        if contains(.control) {
            result.insert(.control)
        }
        
        if contains(.option) {
            result.insert(.option)
        }
        
        if contains(.command) {
            result.insert(.command)
        }

        if contains(.numericPad) {
            result.insert(.numericPad)
        }
        
        if contains(.function) {
            result.insert(.function)
        }
        
        return result
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
