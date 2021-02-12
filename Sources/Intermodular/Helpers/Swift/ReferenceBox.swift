//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@usableFromInline
final class ReferenceBox<T> {
    @usableFromInline
    var value: T
    
    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
}

@usableFromInline
final class ObservableReferenceBox<T>: ObservableObject {
    @usableFromInline
    @Published var value: T
    
    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
}
