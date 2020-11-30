//
// Copyright (c) Vatsal Manot
//

import Combine
import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct TimerState: DynamicProperty {
    class ValueBox: ObservableObject {
        @Published var value: Int = 0
    }
    
    private let interval: TimeInterval
    
    @State private var state = ReferenceBox<(publisher: Timer.TimerPublisher, connection: Cancellable, subscription: Cancellable)?>(nil)
    @PersistentObject private var valueBox = ValueBox()
    
    public var wrappedValue: Int {
        valueBox.value
    }
    
    /// - Parameters:
    ///   - interval: The time interval on which to publish events. For example, a value of `0.5` publishes an event approximately every half-second.
    public init(interval: TimeInterval) {
        self.interval = interval
    }
    
    public mutating func update() {
        if state.value == nil {
            let valueBox = self.valueBox
            
            let timerPublisher = Timer.publish(every: interval, on: .main, in: .common)
            let connection = timerPublisher.connect()
            let timerSubscription = timerPublisher.sink { _ in
                valueBox.value += 1
            }
            
            state.value = (timerPublisher, connection, timerSubscription)
        }
    }
}
