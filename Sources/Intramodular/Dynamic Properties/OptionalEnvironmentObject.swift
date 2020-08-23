//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

/// An `@EnvironmentObject` wrapper that affords `Optional`-ity to environment objects.
@propertyWrapper
public struct OptionalEnvironmentObject<ObjectType: ObservableObject>: DynamicProperty {
    @EnvironmentObject private var _wrappedValue: ObjectType
    
    public var wrappedValue: ObjectType? {
        __wrappedValue.isPresent ? _wrappedValue : nil
    }
    
    public var projectedValue: Wrapper {
        .init(base: self)
    }
    
    public init() {
        
    }
}

// MARK: - API -

extension View {
    public func optionalEnvironmentObject<B: ObservableObject>(_ bindable: B?) -> some View {
        bindable.map(environmentObject) ?? self
    }
}

extension OptionalEnvironmentObject {
    @dynamicMemberLookup
    @frozen
    public struct Wrapper {
        fileprivate let base: OptionalEnvironmentObject
        
        public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>) -> Binding<Subject?> {
            Binding<Subject?>(get: {
                self.base.wrappedValue?[keyPath: keyPath]
            }, set: {
                if let newValue = $0 {
                    self.base.wrappedValue?[keyPath: keyPath] = newValue
                } else {
                    assertionFailure("Cannot write back Optional.none to a non-Optional value.")
                }
            })
        }
    }
}
