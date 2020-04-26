//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresentable {
    var name: ViewName? { get }
    var presenter: DynamicViewPresenter? { get }
}

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIView: DynamicViewPresentable {
    public var name: ViewName? {
        return nil
    }
    
    public var presenter: DynamicViewPresenter? {
        nearestViewController
    }
}

extension UIViewController: DynamicViewPresentable {
    public var presenter: DynamicViewPresenter? {
        presentingViewController
    }
    
    public var name: ViewName? {
        presentationCoordinator.name
    }
}

#endif
