//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct ChangePredicatedAnimation<Value: Equatable>: ViewModifier {
    let animation: Animation?
    let value: Value
    let predicate: ((oldValue: Value, newValue: Value)) -> Bool
    
    @ViewStorage var lastValue: Value?
    
    init(
        animation: Animation?,
        value: Value,
        initialValue: Value?,
        predicate: @escaping ((oldValue: Value, newValue: Value)) -> Bool
    ) {
        self.animation = animation
        self.value = value
        self.predicate = predicate
        
        self._lastValue = .init(wrappedValue: initialValue)
    }
    
    func body(content: Content) -> some View {
        content
            .transaction { view in
                if let oldValue = lastValue {
                    if predicate((oldValue, value)) {
                        view.animation = animation
                    }
                }
            }
            ._onChange(of: value) { value in
                self.lastValue = value
            }
    }
}

extension View {
    public func predicatedAnimation<Value: Equatable>(
        _ animation: Animation?,
        value: Value,
        initialValue: Value? = nil,
        predicate: @escaping ((oldValue: Value, newValue: Value)) -> Bool
    ) -> some View {
        modifier(ChangePredicatedAnimation(animation: animation, value: value, initialValue: initialValue, predicate: predicate))
    }
}
