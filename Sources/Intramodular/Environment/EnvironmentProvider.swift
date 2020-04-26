//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type that provides an environment for its children to inherit.
public protocol EnvironmentProvider {
    var environmentBuilder: EnvironmentBuilder { get nonmutating set }
}

// MARK: - Extensions -

extension EnvironmentProvider {
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentBuilder.insert(bindable)
    }
    
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) {
        environmentBuilder.merge(builder)
    }
}

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

private var environmentBuilderKey: Void = ()

extension UIViewController {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            objc_getAssociatedObject(self, &environmentBuilderKey) as? EnvironmentBuilder ?? .init()
        } set {
            objc_setAssociatedObject(self, &environmentBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIWindow {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            objc_getAssociatedObject(self, &environmentBuilderKey) as? EnvironmentBuilder ?? .init()
        } set {
            objc_setAssociatedObject(self, &environmentBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

#endif
