//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(visionOS)

import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct _SwiftUIX_KeyPress: Hashable, Sendable {
    public let phase: Phases
    public let key: KeyEquivalent
    public let characters: String
    public let modifiers: EventModifiers
    
    public init(
        phase: Phases,
        key: KeyEquivalent,
        characters: String,
        modifiers: EventModifiers
    ) {
        self.phase = phase
        self.key = key
        self.characters = characters
        self.modifiers = modifiers
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(phase)
        hasher.combine(key.character)
        hasher.combine(characters)
        hasher.combine(modifiers.rawValue)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.phase == rhs.phase && lhs.key.character == rhs.key.character && lhs.characters == rhs.characters && lhs.modifiers.rawValue == rhs.modifiers.rawValue
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension _SwiftUIX_KeyPress {
    public struct Phases: OptionSet, Hashable, Sendable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let down = Self(rawValue: 1 << 0)
        public static let `repeat` = Self(rawValue: 1 << 1)
        public static let up = Self(rawValue: 1 << 2)
        public static let all: Self = [.down, .repeat, .up]
    }
    
    public enum Result: Hashable, Sendable {
        /// The action consumed the event, preventing dispatch from continuing.
        case handled
        /// The action ignored the event, allowing dispatch to continue.
        case ignored
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func _SwiftUIX_onKeyPress(
        phases: _SwiftUIX_KeyPress.Phases = [.down, .repeat],
        action: @escaping (_SwiftUIX_KeyPress) -> _SwiftUIX_KeyPress.Result
    ) -> some View {
        // assertionFailure("unimplemented")
        
        return EmptyView()
    }
}
#elseif os(macOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func _SwiftUIX_onKeyPress(
        phases: _SwiftUIX_KeyPress.Phases = [.down, .repeat],
        action: @escaping (_SwiftUIX_KeyPress) -> _SwiftUIX_KeyPress.Result
    ) -> some View {
        self.onAppKitEvent(matching: .init(from: phases)) { (event: NSEvent) -> NSEvent? in
            guard let keyPress = _SwiftUIX_KeyPress(from: event) else {
                return event
            }
            
            let result = action(keyPress)
            
            switch result {
                case .handled:
                    return nil
                case .ignored:
                    return event
            }
        }
    }
}
#endif

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func _SwiftUIX_onKeyPress(
        _ key: KeyEquivalent,
        action: @escaping () -> _SwiftUIX_KeyPress.Result
    ) -> some View {
        _SwiftUIX_onKeyPress { (keyPress: _SwiftUIX_KeyPress) -> _SwiftUIX_KeyPress.Result in
            guard keyPress.key == key else {
                assert(keyPress.key.character != key.character)
                
                return .ignored
            }
            
            return action()
        }
    }
    
    public func _SwiftUIX_onKeyPress(
        _ key: KeyEquivalent,
        modifiers: EventModifiers,
        action: @escaping () -> _SwiftUIX_KeyPress.Result
    ) -> some View {
        _SwiftUIX_onKeyPress { (keyPress: _SwiftUIX_KeyPress) -> _SwiftUIX_KeyPress.Result in
            guard keyPress.key == key else {
                assert(keyPress.key.character != key.character)
                
                return .ignored
            }
            
            guard keyPress.modifiers == modifiers else {
                return .ignored
            }
            
            return action()
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func _overrideOnMoveCommand(
        perform action: ((_SwiftUIX_MoveCommandDirection) -> _SwiftUIX_KeyPress.Result)?
    ) -> some View {
        _SwiftUIX_onKeyPress { keyPress in
            guard let action else {
                return .ignored
            }
            
            guard let command = _SwiftUIX_MoveCommandDirection(from: .init(keyPress.key)) else {
                return .ignored
            }
            
            return action(command)
        }
    }
    
    public func _overrideOnExitCommand(
        perform action: (() -> _SwiftUIX_KeyPress.Result)?
    ) -> some View {
        _SwiftUIX_onKeyPress { keyPress in
            guard let action else {
                return .ignored
            }
            
            guard keyPress.key == .escape else {
                return .ignored
            }
            
            return action()
        }
    }
    
    public func _overrideOnExitCommand(
        perform action: (() -> Void)?
    ) -> some View {
        _overrideOnExitCommand { () -> _SwiftUIX_KeyPress.Result in
            guard let action = action else {
                return .ignored
            }
            
            action()
            
            return .handled
        }
    }
    
    public func _overrideOnDeleteCommand(
        perform action: (() -> _SwiftUIX_KeyPress.Result)?
    ) -> some View {
        _SwiftUIX_onKeyPress { keyPress in
            guard let action else {
                return .ignored
            }
            
            guard keyPress.key._isDeleteOrBackspace else {
                return .ignored
            }
            
            return action()
        }
    }
    
    public func _overrideOnDeleteCommand(
        perform action: (() -> Void)?
    ) -> some View {
        _overrideOnDeleteCommand { () -> _SwiftUIX_KeyPress.Result in
            guard let action = action else {
                return .ignored
            }
            
            action()
            
            return .handled
        }
    }
}

// MARK: Auxiliary

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension _SwiftUIX_MoveCommandDirection {
    public init?(from keyPress: _SwiftUIX_KeyPress) {
        switch keyPress.key {
            case .leftArrow:
                self = .left
            case .rightArrow:
                self = .right
            case .downArrow:
                self = .down
            case .upArrow:
                self = .up
            default:
                return nil
        }
    }
}

#if os(macOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension _SwiftUIX_KeyPress {
    public init?(from event: NSEvent) {
        guard let phase = Phases(from: event) else {
            return nil
        }
        
        guard let characters = event.charactersIgnoringModifiers, !characters.isEmpty else {
            return nil
        }
        
        guard let character = event.charactersIgnoringModifiers.map(Character.init) else {
            return nil
        }
        
        self.init(
            phase: phase,
            key: .init(character),
            characters: characters,
            modifiers: .init(_appKitModifierFlags: event.modifierFlags)
        )
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension NSEvent.EventTypeMask {
    public init(from phases: _SwiftUIX_KeyPress.Phases) {
        self.init()
        
        if phases.contains(.down) {
            insert(.keyDown)
        }
        
        if phases.contains(.up) {
            insert(.keyUp)
        }
        
        if phases.contains(.repeat) {
            // TODO: Handle repeat.
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension _SwiftUIX_KeyPress.Phases {
    // TODO: Handle repeat.
    public init?(from event: NSEvent) {
        switch event.type {
            case .keyDown:
                self = .down
            case .keyUp:
                self = .up
            default:
                return nil
        }
    }
    
    // TODO: Handle repeat.
    public init(from mask: NSEvent.EventTypeMask) {
        self.init()
        
        if mask.contains(.keyDown) {
            insert(.down)
        }
        
        if mask.contains(.keyUp) {
            insert(.up)
        }
    }
}
#endif

#endif
