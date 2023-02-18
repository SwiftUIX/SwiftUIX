//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Combine
import Swift
import SwiftUI

public final class NSEventMonitor {
    public enum Context {
        case local
        case global
    }
    
    private let context: Context
    private let mask: NSEvent.EventTypeMask
    private var monitor: Any?
    
    public var eventHandler: (NSEvent) -> NSEvent? = { $0 }
    
    public init(
        context: Context,
        matching mask: NSEvent.EventTypeMask
    ) {
        self.context = context
        self.mask = mask
        
        start()
    }
    
    private func start() {
        switch self.context {
            case .local:
                monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
                    guard let `self` = self else {
                        return event
                    }
                    
                    return self.eventHandler(event)
                }
            case .global:
                monitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
                    _ = self?.eventHandler(event)
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
    public func onAppKitEvent(
        context: NSEventMonitor.Context = .local,
        matching mask: NSEvent.EventTypeMask,
        peform action: @escaping (NSEvent) -> NSEvent?
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
}

// MARK: - Auxiliary

private struct _AttachNSEventMonitor: ViewModifier {
    @State var eventMonitor: NSEventMonitor
    
    let handleEvent: (NSEvent) -> NSEvent?
    
    func body(content: Content) -> some View {
        content.background {
            PerformAction {
                eventMonitor.eventHandler = handleEvent
            }
        }
    }
}

#endif
