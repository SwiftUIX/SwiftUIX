//
// Copyright (c) Vatsal Manot
//

import _SwiftUIX
import Combine
import Swift
import SwiftUI

/// An abstract base class for an observable value box.
@dynamicMemberLookup
@_documentation(visibility: internal)
public class AnyObservableValue<Value>: _SwiftUIX_AnyIndirectValueBox, ObservableObject {
    public struct Configuration {
        public var deferUpdates: Bool
        
        public init(
            deferUpdates: Bool?
        ) {
            self.deferUpdates = deferUpdates ?? false
        }
        
        public init() {
            self.init(
                deferUpdates: nil
            )
        }
    }
    
    public var configuration = Configuration()
    
    public var wrappedValue: Value {
        get {
            fatalError() // abstract
        } set {
            fatalError() // abstract
        }
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }

    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> AnyObservableValue<Subject> {
        ObservableValues.ValueMember(root: self, keyPath: keyPath)
    }
    
    @_disfavoredOverload
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        return Binding<Subject>(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}

enum ObservableValues {
    final class Root<Root>: AnyObservableValue<Root> {
        public var root: Root
        
        private let _objectDidChange = PassthroughSubject<Void, Never>()
        
        public var objectDidChange: AnyPublisher<Void, Never> {
            _objectDidChange.eraseToAnyPublisher()
        }
        
        override var wrappedValue: Root {
            get {
                root
            } set {
                _objectWillChange_send(deferred: configuration.deferUpdates)

                root = newValue
                
                _objectDidChange.send()
            }
        }
        
        public init(
            root: Root,
            configuration: AnyObservableValue<Root>.Configuration = .init()
        ) {
            self.root = root
            
            super.init(configuration: configuration)
        }
    }
    
    final class ValueMember<Root, Value>: AnyObservableValue<Value> {
        unowned let root: AnyObservableValue<Root>
        
        let keyPath: WritableKeyPath<Root, Value>
        var subscription: AnyCancellable?
        
        override var wrappedValue: Value {
            get {
                root.wrappedValue[keyPath: keyPath]
            } set {
                _objectWillChange_send(deferred: configuration.deferUpdates)

                root.wrappedValue[keyPath: keyPath] = newValue
            }
        }
        
        public init(
            root: AnyObservableValue<Root>,
            keyPath: WritableKeyPath<Root, Value>,
            configuration: AnyObservableValue<Value>.Configuration = .init()
        ) {
            self.root = root
            self.keyPath = keyPath
            self.subscription = nil
            
            super.init(configuration: configuration)
            
            subscription = root.objectWillChange.sink(receiveValue: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                self._objectWillChange_send(deferred: self.configuration.deferUpdates)
            })
        }
    }
    
    final class ObjectMember<Root: ObservableObject, Value>: AnyObservableValue<Value> {
        unowned let root: Root
        
        let keyPath: ReferenceWritableKeyPath<Root, Value>
        
        var subscription: AnyCancellable?
        
        override var wrappedValue: Value {
            get {
                root[keyPath: keyPath]
            } set {
                _objectWillChange_send(deferred: configuration.deferUpdates)
                
                root[keyPath: keyPath] = newValue
            }
        }
        
        public init(
            root: Root,
            keyPath: ReferenceWritableKeyPath<Root, Value>,
            configuration: AnyObservableValue<Value>.Configuration = .init()
        ) {
            self.root = root
            self.keyPath = keyPath
            self.subscription = nil
            
            super.init(configuration: configuration)
            
            subscription = root.objectWillChange.sink(receiveValue: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                self._objectWillChange_send(deferred: self.configuration.deferUpdates)
            })
        }
    }
}
