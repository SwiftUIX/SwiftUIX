//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// An empty `ObservableObject` for utility purposes.
public final class EmptyObservableObject: ObservableObject, Hashable {
    public init() {
        
    }
    
    public func notify() {
        objectWillChange.send()
    }
    
    public static func == (lhs: EmptyObservableObject, rhs: EmptyObservableObject) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
