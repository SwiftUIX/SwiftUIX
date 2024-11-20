//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift
import SwiftUI

@_spi(Internal)
@_documentation(visibility: internal)
public class _AnyObservableObjectMutableBox<WrappedValue>: ObservableObject {
    public var __unsafe_opaque_base: Any? {
        get {
            fatalError()
        } set {
            fatalError()
        }
    }
    
    public var wrappedValue: WrappedValue {
        get {
            fatalError()
        } set {
            fatalError()
        }
    }
}

@_spi(Internal)
@_documentation(visibility: internal)
public final class _ObservableObjectMutableBox<Value, WrappedValue>: _AnyObservableObjectMutableBox<WrappedValue> {
    private var baseSubscription: AnyCancellable?
    
    private var _isNotNilImpl: (Value) -> Bool
    private var _equate: (Value?, Value?) -> Bool
    private var _getObjectWillChange: (Value) -> AnyPublisher<Void, Never>?
    private var _makeWrappedValueBinding: (_ObservableObjectMutableBox) -> Binding<WrappedValue>
    
    private var _isFirstSet: Bool = true
    
    private func _isNotNil(_ value: Value?) -> Bool {
        guard let value else {
            return false
        }
        
        return _isNotNilImpl(value)
    }
    
    @_spi(Private)
    public var base: Value? {
        willSet {
            if _isFirstSet {
                guard _isNotNil(base) else {
                    return
                }
            }

            _objectWillChange_send()
        } didSet {
            if _equate(oldValue, base), baseSubscription != nil {
                return
            }
                    
            subscribe()
            
            _isFirstSet = false
        }
    }
    
    override public var __unsafe_opaque_base: Any? {
        get {
            if let base {
                return base
            } else {
                return nil
            }
        } set {
            if let newValue {
                if let newValue = (newValue as? _opaque_Optional) {
                    guard newValue.isNotNil else {
                        base = nil
                        
                        return
                    }
                }
                
                base = .some(newValue as! Value)
            } else {
                base = nil
            }
        }
    }
    
    override public var wrappedValue: WrappedValue {
        get {
            _makeWrappedValueBinding(self).wrappedValue
        } set {
            _makeWrappedValueBinding(self).wrappedValue = newValue
        }
    }
    
    public init<T: ObservableObject>(
        base: T? = nil
    ) where Value == Optional<T>, WrappedValue == Value {
        _isNotNilImpl = { (object: T?) in
            object != nil
        }
        _equate = { lhs, rhs in
            if let lhs, let rhs {
                return lhs === rhs
            } else {
                return lhs == nil && rhs == nil
            }
        }
        _getObjectWillChange = { (object: T?) in
            object?.objectWillChange.map({ _ in () }).eraseToAnyPublisher()
        }
        _makeWrappedValueBinding = { box in
            Binding(
                get: { [weak box] in
                    box?.wrappedValue
                },
                set: { [weak box] newValue in
                    box?.wrappedValue = newValue
                }
            )
        }
        
        self.base = base
        
        super.init()
        
        subscribe()
    }
    
    public init(
        _unsafelyCastingBase base: Value? = nil
    ) where WrappedValue == Value? {
        _isNotNilImpl = { _ in true }
        _equate = { (lhs: Value?, rhs: Value?) -> Bool in
            guard let lhs = lhs, let rhs = rhs else {
                return lhs == nil && rhs == nil
            }
            
            return (lhs as! (any ObservableObject)) === (rhs as! (any ObservableObject))
        }
        _getObjectWillChange = { (object: Value) in
            guard let object = object as? (any ObservableObject) else {
                assertionFailure("\(object) does not conform to `ObservableObject`")
                
                return Just(()).eraseToAnyPublisher()
            }
            
            let objectWillChangePublisher = object._SwiftUIX_opaque_objectWillChange
            
            return objectWillChangePublisher
        }
        _makeWrappedValueBinding = { box in
            Binding(
                get: { [unowned box] in
                    box.base
                },
                set: { [unowned box] newValue in
                    box.base = newValue
                }
            )
        }
        
        self.base = base
        
        super.init()
        
        subscribe()
    }

    public init(
        base: Value? = nil
    ) where Value: ObservableObject, WrappedValue == Value? {
        _isNotNilImpl = { _ in true }
        _equate = { $0 === $1 }
        _getObjectWillChange = {
            $0.objectWillChange.map({ _ in () }).eraseToAnyPublisher()
        }
        _makeWrappedValueBinding = { box in
            Binding(
                get: { [unowned box] in
                    box.base
                },
                set: { [unowned box] newValue in
                    box.base = newValue
                }
            )
        }

        self.base = base
        
        super.init()

        subscribe()
    }
    
    public init(
        makeBase: @escaping () -> Value 
    ) where Value: ObservableObject, WrappedValue == Value {
        _isNotNilImpl = { _ in true }
        _equate = { $0 === $1 }
        _getObjectWillChange = { $0.objectWillChange.map({ _ in () }).eraseToAnyPublisher() }
        _makeWrappedValueBinding = { box in
            Binding(
                get: { [unowned box] in
                    let result: Value
                    
                    if let base = box.base {
                        result = base
                    } else {
                        result = makeBase()
                        
                        box.base = result
                    }
                    
                    return result
                },
                set: { [unowned box] newValue in
                    box.base = newValue
                }
            )
        }
        
        self.base = nil
        
        super.init()
        
        subscribe()
    }
    
    public init(
        base: Value? = nil,
        wrappedValue: @escaping (inout Value?) -> Binding<WrappedValue>
    ) where Value: ObservableObject {
        _isNotNilImpl = { _ in true }
        _equate = { $0 === $1 }
        _getObjectWillChange = { $0.objectWillChange.map({ _ in () }).eraseToAnyPublisher() }
        _makeWrappedValueBinding = { box in
            Binding(
                get: { [unowned box] in
                    wrappedValue(&box.base).wrappedValue
                },
                set: { [unowned box] newValue in
                    wrappedValue(&box.base).wrappedValue = newValue
                }
            )
        }
        
        self.base = base
        
        super.init()
        
        subscribe()
    }
    
    private func subscribe() {
        guard let base = base, _isNotNil(base) else {
            baseSubscription?.cancel()
            baseSubscription = nil
            
            return
        }
        
        guard let objectWillChangePublisher = _getObjectWillChange(base) else {
            assertionFailure()
            
            return
        }
        
        baseSubscription = objectWillChangePublisher
            .sink(receiveValue: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                `self`._objectWillChange_send()
            })
    }
}

extension ObservableObject {
    fileprivate var _SwiftUIX_opaque_objectWillChange: AnyPublisher<Void, Never> {
        objectWillChange.map({ _ in () }).eraseToAnyPublisher()
    }
}

private protocol _opaque_Optional {
    var isNotNil: Bool { get }
}

extension Optional: _opaque_Optional {
    fileprivate var isNotNil: Bool {
        self != nil
    }
}
