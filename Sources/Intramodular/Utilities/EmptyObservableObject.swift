//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// An empty `ObservableObject` for utility purposes.
public final class EmptyObservableObject: ObservableObject {
    public init() {
        
    }
    
    public func notify() {
        objectWillChange.send()
    }
}
