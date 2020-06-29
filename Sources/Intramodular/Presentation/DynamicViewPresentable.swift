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
    public var presentationName: ViewName? {
        presentationCoordinator.presentationName
    }
    
    public var presenter: DynamicViewPresenter? {
        presentingViewController
    }
}

#elseif os(macOS)

extension NSView: DynamicViewPresentable {
    public var presentationName: ViewName? {
        return nil
    }
    
    public var presenter: DynamicViewPresenter? {
        window
    }
}

extension NSViewController: DynamicViewPresentable {
    public var presentationName: ViewName? {
        presentationCoordinator.presentationName
    }
    
    public var presenter: DynamicViewPresenter? {
        presentingViewController
    }
}

extension NSWindow: DynamicViewPresentable {
    public var presentationName: ViewName? {
        return nil
    }
    
    public var presenter: DynamicViewPresenter? {
        parent
    }
}

#endif
