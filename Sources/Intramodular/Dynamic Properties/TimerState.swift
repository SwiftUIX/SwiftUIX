//
// Copyright (c) Vatsal Manot
//

import Combine
import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct TimerState: DynamicProperty {
    private let interval: TimeInterval
    private let timerPublisher: Timer.TimerPublisher
    
    private var timerConnection: Cancellable?
    private var timerSubscription: AnyCancellable? = nil
    private var updateWrappedValue = MutableHeapWrapper<() -> Void>({ })
    
    @State public private(set) var wrappedValue: Int = 0
    
    /// - Parameters:
    ///   - interval: The time interval on which to publish events. For example, a value of `0.5` publishes an event approximately every half-second.
    public init(interval: TimeInterval) {
        self.interval = interval
        self.timerPublisher = Timer.publish(every: interval, on: .main, in: .common)
        self.timerSubscription = nil
        
        let updateWrappedValue = self.updateWrappedValue
        
        self.timerSubscription = timerPublisher.sink(receiveValue: { _ in
            updateWrappedValue.value()
        })
    }
    
    public mutating func update() {
        let _wrappedValue = self._wrappedValue
        
        updateWrappedValue.value = { _wrappedValue.wrappedValue += 1 }
        
        if timerConnection == nil {
            timerConnection = timerPublisher.connect()
        }
    }
}
