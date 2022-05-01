//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

final class _AnyObservableObject: ObservableObject {
    private class _EmptyObservableObject: ObservableObject {
        init() {
            
        }
    }
    
    static let empty = _AnyObservableObject(_EmptyObservableObject())
    
    let base: AnyObject
    
    private let objectWillChangeImpl: () -> AnyPublisher<Void, Never>
    
    var objectWillChange: AnyPublisher<Void, Never> {
        objectWillChangeImpl()
    }
    
    init<T: ObservableObject>(_ base: T) {
        self.base = base
        self.objectWillChangeImpl = { base.objectWillChange.map({ _ in () }).eraseToAnyPublisher() }
    }
}
