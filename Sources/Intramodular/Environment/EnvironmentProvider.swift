//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type that provides an environment for its children to inherit.
public protocol EnvironmentProvider {
    var environmentBuilder: EnvironmentBuilder { get nonmutating set }
    
    func insertEnvironmentObject<B: ObservableObject>(_ bindable: B)
    func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder)
}

// MARK: - Implementation -

private var objc_environmentBuilderKey: Void = ()

extension EnvironmentProvider {
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentBuilder.insert(bindable)
    }
    
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) {
        environmentBuilder.merge(builder)
    }
}

extension EnvironmentProvider where Self: AnyObject {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            objc_getAssociatedObject(self, &objc_environmentBuilderKey) as? EnvironmentBuilder ?? .init()
        } set {
            objc_setAssociatedObject(self, &objc_environmentBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
