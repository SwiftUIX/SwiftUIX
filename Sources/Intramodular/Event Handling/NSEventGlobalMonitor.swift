//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Combine
import SwiftUI
import Swift

public final class NSEventGlobalMonitor: ObservableObject {
    private let mask: NSEvent.EventTypeMask
    private var monitor: Any?
    
    public let objectWillChange = PassthroughSubject<NSEvent, Never>()
    
    public init(matching mask: NSEvent.EventTypeMask) {
        self.mask = mask
    }
    
    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] in
            self?.objectWillChange.send($0)
        }
    }
    
    public func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            
            self.monitor = nil
        }
    }
    
    deinit {
        stop()
    }
}

#endif
