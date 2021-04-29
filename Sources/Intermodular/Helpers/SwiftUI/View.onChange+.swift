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
    let action: (Value) -> Void

    @State var model = Model()

    public var body: some View {
        if model.update(value: value) {
            DispatchQueue.main.async {
                self.action(self.value)
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
    @ViewBuilder
    public func _backport_onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        ChangeObserver(base: self, value: value, action: action)
    }
    
    @_disfavoredOverload
    @ViewBuilder
    public func onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            onChange(of: value, perform: action)
        } else {
            _backport_onChange(of: value, perform: action)
        }
        #else
        _backport_onChange(of: value, perform: action)
        #endif
    }
}
