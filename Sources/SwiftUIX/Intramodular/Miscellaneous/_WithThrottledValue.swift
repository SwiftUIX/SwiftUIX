//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct _WithThrottledValue<Value: Equatable, Content: View>: View {
    let value: Value
    let interval: DispatchQueue.SchedulerTimeType.Stride
    let delay: DispatchQueue.SchedulerTimeType.Stride?
    let animation: Animation
    let content: (Value) -> Content
    
    @State var effectiveValue: Value
    
    init(
        value: Value,
        interval: DispatchQueue.SchedulerTimeType.Stride,
        delay: DispatchQueue.SchedulerTimeType.Stride?,
        animation: Animation,
        content: @escaping (Value) -> Content
    ) {
        self.value = value
        self._effectiveValue = .init(initialValue: value)
        self.interval = interval
        self.delay = delay
        self.animation = animation
        self.content = content
    }
    
    var body: some View {
        content(effectiveValue)
            .withChangePublisher(for: value) { valuePublisher in
                valuePublisher
                    .removeDuplicates()
                    .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
                    .removeDuplicates()
                    .debounce(for: delay ?? .zero, scheduler: DispatchQueue.main)
                    .sink { value in
                        withAnimation(animation) {
                            effectiveValue = value
                        }
                    }
            }
    }
}

/// Delay providing a given value to a view by a chosen duration.
public func delay<Value: Equatable, Content: View>(
    _ value: Value,
    by delay: DispatchQueue.SchedulerTimeType.Stride,
    animation: Animation = .default,
    @ViewBuilder content: @escaping (Value) -> Content
) -> some View {
    _WithThrottledValue(
        value: value,
        interval: delay,
        delay: nil,
        animation: animation,
        content: content
    )
}

/// Delay providing a given value to a view by a chosen duration.
public func withThrottledValue<Value: Equatable, Content: View>(
    _ value: Value,
    interval: DispatchQueue.SchedulerTimeType.Stride,
    delay: DispatchQueue.SchedulerTimeType.Stride? = nil,
    animation: Animation = .default,
    @ViewBuilder content: @escaping (Value) -> Content
) -> some View {
    _WithThrottledValue(
        value: value,
        interval: interval,
        delay: delay,
        animation: animation,
        content: content
    )
}
