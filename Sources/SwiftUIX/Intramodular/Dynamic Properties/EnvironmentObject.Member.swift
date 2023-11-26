//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

extension EnvironmentObject {
    @propertyWrapper
    public struct Member<Value>: DynamicProperty {
        @EnvironmentObject var base: ObjectType
        
        private let keyPath: KeyPath<ObjectType, Value>
        
        public var wrappedValue: Value {
            get {
                base[keyPath: keyPath]
            }
        }
                
        public init(_ root: ObjectType.Type, _ member: KeyPath<ObjectType, Value>) {
            self.keyPath = member
        }
        
        public init(_ member: KeyPath<ObjectType, Value>) {
            self.keyPath = member
        }
    }

    @propertyWrapper
    public struct WritableMember<Value>: DynamicProperty {
        @EnvironmentObject var base: ObjectType
        
        private let keyPath: ReferenceWritableKeyPath<ObjectType, Value>
        
        public var wrappedValue: Value {
            get {
                base[keyPath: keyPath]
            } nonmutating set {
                base[keyPath: keyPath] = newValue
            }
        }
        
        public var projectedValue: Binding<Value> {
            $base[dynamicMember: keyPath]
        }
        
        public init(_ root: ObjectType.Type, _ member: ReferenceWritableKeyPath<ObjectType, Value>) {
            self.keyPath = member
        }
        
        public init(_ member: ReferenceWritableKeyPath<ObjectType, Value>) {
            self.keyPath = member
        }
    }
}
