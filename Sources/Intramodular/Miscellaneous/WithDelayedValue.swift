//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct WithDelayedValue<Value: Equatable, Content: View>: View {
    let value: Value
    let delay: DispatchQueue.SchedulerTimeType.Stride
    let animation: Animation
    let content: (Value) -> Content
    
    @State var effectiveValue: Value
    
    init(
        value: Value,
        delay: DispatchQueue.SchedulerTimeType.Stride,
        animation: Animation,
        content: @escaping (Value) -> Content
    ) {
        self.value = value
        self._effectiveValue = .init(initialValue: value)
        self.delay = delay
        self.animation = animation
        self.content = content
    }
    
    var body: some View {
        content(effectiveValue)
            .withChangePublisher(for: value) { valuePublisher in
                valuePublisher
                    .debounce(for: delay, scheduler: DispatchQueue.main)
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
    WithDelayedValue(value: value, delay: delay, animation: animation, content: content)
}
