//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Carbon
import Combine
import Swift
import SwiftUI

@_documentation(visibility: internal)
public enum NSEventMonitorContext {
    case local
    case global
}

public protocol _NSEventMonitorType: AnyObject {
    init(
        context: NSEventMonitorContext,
        matching: NSEvent.EventTypeMask,
        handleEvent: @escaping (NSEvent) -> NSEvent?
    ) throws
    
    static func addGlobalMonitorForEvents(
        matching mask: NSEvent.EventTypeMask,
        handler block: @escaping (NSEvent) -> Void
    ) -> Any?
    
    func start() throws
    func stop() throws
}

@available(macOS 12.0, *)
extension _NSEventMonitorType {
    public init(
        matching shortcuts: [KeyboardShortcut],
        context: NSEventMonitor.Context = .local,
        perform action: @escaping (KeyboardShortcut) -> Void
    ) throws {
        let shortcuts = Set(shortcuts)
        
        try self.init(context: context, matching: [.keyDown]) { event -> NSEvent? in
            guard let shortcut = KeyboardShortcut(from: event) else {
                return event
            }
            
            guard shortcuts.contains(shortcut) else {
                return event
            }
            
            _ = action(shortcut)
            
            return nil
        }
    }
    
    public init(
        matching shortcuts: [KeyboardShortcut],
        context: NSEventMonitor.Context = .local,
        perform action: @escaping (KeyboardShortcut) -> _SwiftUIX_KeyPress.Result
    ) throws {
        let shortcuts = Set(shortcuts)
        
        try self.init(context: context, matching: [.keyDown]) { event -> NSEvent? in
            guard let shortcut = KeyboardShortcut(from: event) else {
                return event
            }
            
            guard shortcuts.contains(shortcut) else {
                return event
            }
            
            let result = action(shortcut)
            
            switch result {
                case .handled:
                    return nil
                case .ignored:
                    return event
            }
        }
    }
}

extension _NSEventMonitorType {
    public static func addGlobalMonitorForEvents(
        matching mask: NSEvent.EventTypeMask,
        handler block: @escaping (NSEvent) -> Void
    ) -> Any? {
        try? Self(context: .global, matching: mask, handleEvent: { (event: NSEvent) in
            block(event)
            
            return event
        })
    }
}

@_documentation(visibility: internal)
public final class NSEventMonitor: _NSEventMonitorType {
    public typealias Context = NSEventMonitorContext
    
    private let context: Context
    private let eventTypeMask: NSEvent.EventTypeMask
    private var monitor: Any?
    
    public var handleEvent: (NSEvent) -> NSEvent? = { $0 }
    
    private enum State {
        case active
        case inactive
    }
    
    @Published private var state: State = .active
    
    public init(
        context: Context,
        matching mask: NSEvent.EventTypeMask,
        handleEvent: @escaping (NSEvent) -> NSEvent? = { $0 }
    ) {
        self.context = context
        self.eventTypeMask = mask
        self.handleEvent = handleEvent
        
        start()
    }
    
    public func start() {
        guard monitor == nil else {
            return
        }
        
        defer {
            state = .active
        }
        
        switch self.context {
            case .local:
                monitor = NSEvent.addLocalMonitorForEvents(matching: eventTypeMask) { [weak self] event in
                    guard let `self` = self else {
                        return event
                    }
                    
                    return self.handleEvent(event)
                }
            case .global:
                monitor = NSEvent.addGlobalMonitorForEvents(matching: eventTypeMask) { [weak self] event in
                    let e = self?.handleEvent(event)
                    
                    assert(event === e)
                }
        }
    }
    
    public func stop() {
        guard let monitor = monitor else {
            return
        }
        
        defer {
            state = .inactive
        }
        
        NSEvent.removeMonitor(monitor)
        
        self.monitor = nil
    }
    
    deinit {
        stop()
    }
}

// MARK: - API

@available(macOS 11.0, *)
extension View {
    /// Return `nil` to prevent the event from being passed on.
    public func onAppKitEvent(
        context: NSEventMonitor.Context = .local,
        matching mask: NSEvent.EventTypeMask,
        using eventMonitorType: _NSEventMonitorType.Type = NSEventMonitor.self,
        perform action: @escaping (NSEvent) -> NSEvent?
    ) -> some View {
        modifier(
            _AttachNSEventMonitor(
                context: context,
                eventMask: mask,
                handleEvent: action,
                eventMonitorType: eventMonitorType
            )
        )
    }
    
    public func onAppKitKeyboardShortcutEvent(
        context: NSEventMonitor.Context = .local,
        using eventMonitorType: _NSEventMonitorType.Type = NSEventMonitor.self,
        perform action: @escaping (KeyboardShortcut) -> Bool
    ) -> some View {
        onAppKitEvent(context: context, matching: [.keyDown], using: eventMonitorType) { event in
            guard let shortcut = KeyboardShortcut(from: event) else {
                return event
            }
            
            let wasEventHandled = action(shortcut)
            
            return wasEventHandled ? nil : event
        }
    }
    
    @available( macOS 12.0, *)
    public func onAppKitKeyboardShortcutEvent(
        _ shortcutToMatch: KeyboardShortcut,
        context: NSEventMonitor.Context = .local,
        using eventMonitorType: _NSEventMonitorType.Type = NSEventMonitor.self,
        perform action: @escaping () -> Void
    ) -> some View {
        onAppKitEvent(
            context: .local,
            matching: [.keyDown],
            using: eventMonitorType
        ) { (event: NSEvent) in
            guard let shortcut = KeyboardShortcut(from: event) else {
                return event
            }
            
            guard shortcut == shortcutToMatch else {
                return event
            }
            
            _ = action()
            
            return nil
        }
    }
    
    @available(macOS 12.0, *)
    public func onAppKitKeyboardShortcutEvents(
        _ shortcuts: [KeyboardShortcut],
        context: NSEventMonitor.Context = .local,
        using eventMonitorType: _NSEventMonitorType.Type = NSEventMonitor.self,
        perform action: @escaping (KeyboardShortcut) -> Void
    ) -> some View {
        let shortcuts = Set(shortcuts)
        
        return onAppKitEvent(
            context: .local,
            matching: [.keyDown],
            using: eventMonitorType
        ) { (event: NSEvent) in
            guard let shortcut = KeyboardShortcut(from: event) else {
                return event
            }
            
            guard shortcuts.contains(shortcut) else {
                return event
            }
            
            _ = action(shortcut)
            
            return nil
        }
    }
    
    @available( macOS 12.0, *)
    public func onAppKitKeyboardShortcutEvent(
        _ key: KeyEquivalent,
        modifiers: SwiftUI.EventModifiers = [.command],
        context: NSEventMonitor.Context = .local,
        using eventMonitorType: _NSEventMonitorType.Type = NSEventMonitor.self,
        perform action: @escaping () -> Void
    ) -> some View {
        onAppKitKeyboardShortcutEvent(
            KeyboardShortcut(key, modifiers: modifiers),
            context: context,
            using: eventMonitorType,
            perform: action
        )
    }
}

// MARK: - Auxiliary

private struct _AttachNSEventMonitor: ViewModifier {
    let context: NSEventMonitor.Context
    let eventMask: NSEvent.EventTypeMask
    let handleEvent: (NSEvent) -> NSEvent?
    
    let eventMonitorType: any _NSEventMonitorType.Type
    
    @ViewStorage private var handleEventTrampoline: (NSEvent) -> NSEvent?
    @ViewStorage private var eventMonitor: (any _NSEventMonitorType)!
    
    init(
        context: NSEventMonitor.Context,
        eventMask: NSEvent.EventTypeMask,
        handleEvent: @escaping (NSEvent) -> NSEvent?,
        eventMonitorType: any _NSEventMonitorType.Type
    ) {
        self.context = context
        self.eventMask = eventMask
        self.handleEvent = handleEvent
        self.eventMonitorType = eventMonitorType
        self._handleEventTrampoline = .init(wrappedValue: handleEvent)
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                PerformAction(deferred: false) {
                    self.handleEventTrampoline = handleEvent
                    
                    if self.eventMonitor == nil {
                        self.eventMonitor = try! eventMonitorType.init(context: context, matching: eventMask, handleEvent: {
                            self.handleEventTrampoline($0)
                        })
                    }
                }
            }
            .onAppear {
                do {
                    try self.eventMonitor?.start()
                } catch {
                    assertionFailure(String(describing: error))
                }
            }
            .onDisappear {
                do {
                    try self.eventMonitor?.stop()
                } catch {
                    assertionFailure(String(describing: error))
                }
            }
    }
}

extension NSEvent {
    public var _SwiftUIX_isEscapeCharacter: Bool {
        guard let characters, characters.count == 1 else {
            return false
        }
        
        guard characters.first! == KeyEquivalent.escape.character else {
            return false
        }
        
        guard keyCode == kVK_Escape else {
            return false
        }
        
        return true
    }
}

#endif
