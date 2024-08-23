//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@propertyWrapper
@_documentation(visibility: internal)
public struct ExistentialStateObject<ObjectType>: DynamicProperty {
    fileprivate class Box: ObservableObject {
        let base: ObjectType
        let objectWillChange: AnyPublisher<Void, Never>
        
        init(base: ObjectType) {
            self.base = base
            self.objectWillChange = ((base as! any ObservableObject).objectWillChange as any Publisher)
                ._mapToVoidAnyPublisherDiscardingError()
        }
    }
    
    @StateObject private var valueBox: Box
    
    public var wrappedValue: ObjectType {
        get {
            valueBox.base
        }
    }
    
    public init(wrappedValue: @autoclosure @escaping () -> ObjectType) {
        self._valueBox = StateObject(wrappedValue: .init(base: wrappedValue()))
    }
}

extension Publisher {
    fileprivate func _mapToVoidAnyPublisherDiscardingError() -> AnyPublisher<Void, Never> {
        map({ _ in () }).catch({ _ in Just(()) }).eraseToAnyPublisher()
    }
}
