//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresentable {
    var environmentBuilder: EnvironmentBuilder { get nonmutating set }
    
    var presenter: DynamicViewPresenter? { get }
}

// MARK: - Extensions -

extension DynamicViewPresentable {
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

extension UIView: DynamicViewPresentable {
    public var presenter: DynamicViewPresenter? {
        nearestViewController
    }
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            objc_getAssociatedObject(self, &environmentBuilderKey) as? EnvironmentBuilder ?? .init()
        } set {
            objc_setAssociatedObject(self, &environmentBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIViewController: DynamicViewPresentable {
    public var presenter: DynamicViewPresenter? {
        presentingViewController
    }
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            objc_getAssociatedObject(self, &environmentBuilderKey) as? EnvironmentBuilder ?? .init()
        } set {
            objc_setAssociatedObject(self, &environmentBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

#endif
