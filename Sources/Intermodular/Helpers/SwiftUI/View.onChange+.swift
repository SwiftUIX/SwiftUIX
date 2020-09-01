//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

// Modified from https://stackoverflow.com/questions/58363563/swiftui-get-notified-when-binding-value-changes

public struct ChangeObserver<Base: View, Value: Equatable>: View {
    let base: Base
    let value: Value
    @State private var oldValue: Value?
    let action: (Value?, Value) -> Void

    @State var model = Model()

    public var body: some View {
        if model.update(value: value) {
            DispatchQueue.main.async {
                self.action(self.oldValue, self.value)
                oldValue = value
            }
        }
        return base
    }

    class Model {
        private var savedValue: Value?
        func update(value: Value) -> Bool {
            guard value != savedValue else {
                return false
            }
            savedValue = value
            return true
        }
    }
}

extension View {
    @available(iOS 13, *)
    @available(macOS 10.15, *)
    @available(tvOS 13.0, *)
    @available(watchOS 6.0, *)
    public func onChange<Value: Equatable>(of value: Value, perform action: @escaping (_ oldValue: Value?, _ newValue: Value) -> Void) -> ChangeObserver<Self, Value> {
        ChangeObserver(base: self, value: value, action: action)
    }
}
