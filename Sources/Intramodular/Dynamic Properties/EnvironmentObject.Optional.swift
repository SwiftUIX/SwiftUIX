//
// Copyright (c) Vatsal Manot
//

import Combine
import Dispatch
import Swift
import SwiftUI

extension EnvironmentObject {
    /// An `@EnvironmentObject` wrapper that affords `Optional`-ity to environment objects.
    @propertyWrapper
    public struct Optional: DynamicProperty {
        @EnvironmentObject private var _wrappedValue: ObjectType
        
        public var wrappedValue: ObjectType? {
            __wrappedValue._SwiftUIX_isEnvironmentObjectPresent ? _wrappedValue : nil
        }
        
        public var projectedValue: Wrapper {
            .init(base: self)
        }
        
        public init() {
            
        }
    }
}

@available(*, deprecated, renamed: "EnvironmentObject.Optional")
public typealias OptionalEnvironmentObject<ObjectType: ObservableObject> = EnvironmentObject<ObjectType>.Optional

// MARK: - API

extension View {
    @available(*, deprecated)
    public func optionalEnvironmentObject<B: ObservableObject>(_ bindable: B?) -> some View {
        bindable.map(environmentObject) ?? self
    }
}

extension EnvironmentObject.Optional {
    @dynamicMemberLookup
    @frozen
    public struct Wrapper {
        fileprivate let base: EnvironmentObject.Optional
        
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

// MARK: - Auxiliary

extension EnvironmentObject {
    public var _SwiftUIX_isEnvironmentObjectPresent: Bool {
        let mirror = Mirror(reflecting: self)
        let _store = mirror.children.first(where: { $0.label == "_store" })
        
        guard let _store else {
            return false
        }
        
        return (_store.value as? ObjectType) != nil
    }
}
