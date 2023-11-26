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
        return (key.character, modifiers._appKitModifierFlags)
    }
    
    public init?(from event: NSEvent) {
        guard event.type == .keyDown else {
            return nil
        }
        
        guard let characters = event.charactersIgnoringModifiers, !characters.isEmpty else {
            return nil
        }
        
        guard let key = event.charactersIgnoringModifiers.map(Character.init) else {
            return nil
        }
        
        self.init(
            KeyEquivalent(key),
            modifiers: EventModifiers(_appKitModifierFlags: event.modifierFlags)
        )
    }
    
    public static func ~= (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        lhs.key ~= rhs.key && rhs.modifiers == lhs.modifiers
    }
}
#endif

// MARK: - Auxiliary

#if os(macOS)
extension SwiftUI.EventModifiers {
    public func _toCGEventFlags() -> CGEventFlags {
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
#endif

#if os(macOS)
extension SwiftUI.EventModifiers {
    public var _appKitModifierFlags: NSEvent.ModifierFlags {
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
    
    public init(_appKitModifierFlags flags: NSEvent.ModifierFlags) {
        self.init()
        
        if flags.contains(.capsLock) {
            insert(.capsLock)
        }
        
        if flags.contains(.shift) {
            insert(.shift)
        }
        
        if flags.contains(.control) {
            insert(.control)
        }
        
        if flags.contains(.command) {
            insert(.command)
        }
        
        if flags.contains(.numericPad) {
            insert(.numericPad)
        }
        
        if flags.contains(.function) {
            insert(.function)
        }
    }
}
#endif

#if os(macOS)
import Carbon

extension SwiftUI.EventModifiers {
    public var _carbonEventModifierFlags: UInt32 {
        var result: UInt32 = 0
        
        if contains(.command) {
            result |= UInt32(Carbon.cmdKey)
        }
        
        if contains(.option) {
            result |= UInt32(Carbon.optionKey)
        }
        
        if contains(.control) {
            result |= UInt32(Carbon.controlKey)
        }
        
        if contains(.shift) {
            result |= UInt32(Carbon.shiftKey)
        }
        
        return result
    }
    
    public init(_carbonEventModifierFlags flags: UInt32) {
        self.init()
        
        if flags & UInt32(Carbon.cmdKey) == UInt32(Carbon.cmdKey) {
            insert(.command)
        }
        
        if flags & UInt32(Carbon.optionKey) == UInt32(Carbon.optionKey) {
            insert(.option)
        }
        
        if flags & UInt32(Carbon.controlKey) == UInt32(Carbon.controlKey) {
            insert(.control)
        }
        
        if flags & UInt32(Carbon.shiftKey) == UInt32(Carbon.shiftKey) {
            insert(.shift)
        }
    }
}
#endif
