//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct ThrottledDelayedState<Value>: DynamicProperty {
    let delay: DispatchTimeInterval?
    
    @State private var _wrappedValue: Value
    @State private var _wrappedValueSetWorkItem = MutableDispatchWorkItem()
    
    /// The current state value.
    public var wrappedValue: Value {
        get {
            _wrappedValue
        } nonmutating set {
            self._wrappedValueSetWorkItem.setBlock {
                self._wrappedValue = newValue
            }
            
            if let delay = delay {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: _wrappedValueSetWorkItem.base)
            } else {
                DispatchQueue.main.async(execute: _wrappedValueSetWorkItem.base)
            }
        }
    }
    
    public var unsafelyUnwrapped: Value {
        get {
            _wrappedValue
        } nonmutating set {
            _wrappedValue = newValue
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    /// Initialize with the provided initial value.
    public init(
        wrappedValue value: Value,
        delay: DispatchTimeInterval?
    ) {
        self.__wrappedValue = .init(initialValue: value)
        self.delay = delay
    }
    
    /// Initialize with the provided initial value.
    public init(wrappedValue value: Value) {
        self.__wrappedValue = .init(initialValue: value)
        self.delay = nil
    }
    
    public mutating func update() {
        self.__wrappedValue.update()
    }
}

// MARK: - Helpers -

private class MutableDispatchWorkItem {
    var base: DispatchWorkItem
    
    init() {
        self.base = DispatchWorkItem(block: { })
    }
    
    func cancel() {
        base.cancel()
    }
    
    func setBlock(_ block: @escaping () -> Void) {
        cancel()
        
        base = DispatchWorkItem(block: block)
    }
    
    deinit {
        base.cancel()
    }
}
