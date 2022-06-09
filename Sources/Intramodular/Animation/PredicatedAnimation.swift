//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct PredicatedAnimateOnChange<Value: Equatable>: ViewModifier {
    let animation: Animation?
    let value: Value
    let predicate: ((oldValue: Value, newValue: Value)) -> Bool
    
    @ViewStorage private var lastValue: Value?

    func body(content: Content) -> some View {
        content
            .transaction { view in
                if let oldValue = lastValue {
                    if predicate((oldValue, value)) {
                        view.animation = animation
                    }
                }
            }
            .onChange(of: value) { value in
                self.lastValue = value
            }
    }
}

extension View {
    public func predicatedAnimation<Value: Equatable>(
        _ animation: Animation?,
        value: Value,
        predicate: @escaping ((oldValue: Value, newValue: Value)) -> Bool
    ) -> some View {
        modifier(PredicatedAnimateOnChange(animation: animation, value: value, predicate: predicate))
    }
}
