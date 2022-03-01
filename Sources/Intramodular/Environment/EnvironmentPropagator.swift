//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type that provides an environment for its children to inherit.
public protocol EnvironmentPropagator {
    var environmentInsertions: EnvironmentInsertions { get nonmutating set }
    
    func insertEnvironmentObject<B: ObservableObject>(_ bindable: B)
    func environment(_ builder: EnvironmentInsertions)
}

// MARK: - Implementation -

private var objc_environmentInsertionsKey: UInt8 = 0

extension EnvironmentPropagator {
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentInsertions.insert(bindable)
    }
    
    public func environment(_ builder: EnvironmentInsertions) {
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
