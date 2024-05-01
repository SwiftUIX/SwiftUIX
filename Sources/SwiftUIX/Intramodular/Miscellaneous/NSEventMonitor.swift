//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Carbon
import Combine
import Swift
import SwiftUI

public enum NSEventMonitorContext {
    case local
    case global
}

public protocol _NSEventMonitorType {
    init(
        context: NSEventMonitorContext,
        matching: NSEvent.EventTypeMask,
        handleEvent: @escaping (NSEvent) -> NSEvent?
    ) throws
}

public final class NSEventMonitor: _NSEventMonitorType {
    public typealias Context = NSEventMonitorContext
    
    private let context: Context
    private let eventTypeMask: NSEvent.EventTypeMask
    private var monitor: Any?
    
    public var handleEvent: (NSEvent) -> NSEvent? = { $0 }
    
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
    
    private func start() {
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
    
    private func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            
            self.monitor = nil
        }
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
        perform action: @escaping (NSEvent) -> NSEvent?
    ) -> some View {
        modifier(
            _AttachNSEventMonitor(
                eventMonitor: .init(context: context, matching: mask),
                handleEvent: action
            )
        )
    }
    
    public func onAppKitKeyboardShortcutEvent(
        context: NSEventMonitor.Context = .local,
        perform action: @escaping (KeyboardShortcut) -> Bool
    ) -> some View {
        onAppKitEvent(context: context, matching: [.keyDown]) { event in
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
        perform action: @escaping () -> Void
    ) -> some View {
        onAppKitEvent(context: .local, matching: [.keyDown]) { event in
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
    
    @available( macOS 12.0, *)
    public func onAppKitKeyboardShortcutEvent(
        _ key: KeyEquivalent,
        modifiers: SwiftUI.EventModifiers = [.command],
        perform action: @escaping () -> Void
    ) -> some View {
        onAppKitKeyboardShortcutEvent(
            .init(key, modifiers: modifiers),
            perform: action
        )
    }
}

// MARK: - Auxiliary

private struct _AttachNSEventMonitor: ViewModifier {
    @State var eventMonitor: NSEventMonitor
    
    let handleEvent: (NSEvent) -> NSEvent?
    
    func body(content: Content) -> some View {
        content.background {
            PerformAction {
                eventMonitor.handleEvent = handleEvent
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
