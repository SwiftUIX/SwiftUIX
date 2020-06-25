//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresentable {
    /// The view's presentation name (if any).
    var presentationName: ViewName? { get }
    
    var presenter: DynamicViewPresenter? { get }
}

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIView: DynamicViewPresentable {
    public var presentationName: ViewName? {
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
    
    public var presentationName: ViewName? {
        presentationCoordinator.presentationName
    }
}

#endif
