//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type that provides an environment for its children to inherit.
public protocol EnvironmentPropagator {
    var environmentInsertions: EnvironmentInsertions { get nonmutating set }
}

// MARK: - Implementation -

private var objc_environmentInsertionsKey: UInt8 = 0

extension EnvironmentPropagator {
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentInsertions.insert(bindable)
    }
    
    public func insertWeakEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentInsertions.insert(weak: bindable)
    }
    
    public func insert(contentsOf builder: EnvironmentInsertions) {
        environmentInsertions.merge(builder)
    }
}

extension EnvironmentPropagator where Self: AnyObject {
    public var environmentInsertions: EnvironmentInsertions {
        get {
            objc_getAssociatedObject(self, &objc_environmentInsertionsKey) as? EnvironmentInsertions ?? .init()
        } set {
            objc_setAssociatedObject(self, &objc_environmentInsertionsKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
