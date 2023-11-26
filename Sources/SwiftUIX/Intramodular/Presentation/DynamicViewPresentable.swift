//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresentable {
    /// The view's presentation name (if any).
    var presentationName: AnyHashable? { get }
    
    var presenter: DynamicViewPresenter? { get }
}

// MARK: - Conformances

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

extension UIView: DynamicViewPresentable {
    public var presentationName: AnyHashable? {
        return nil
    }
    
    public var presenter: DynamicViewPresenter? {
        nearestViewController
    }
}

extension UIViewController: DynamicViewPresentable {
    public var presentationName: AnyHashable? {
        presentationCoordinator.presentationName
    }
    
    public var presenter: DynamicViewPresenter? {
        presentingViewController
    }
}

#elseif os(macOS)

extension NSView: DynamicViewPresentable {
    public var presentationName: AnyHashable? {
        return nil
    }
    
    public var presenter: DynamicViewPresenter? {
        window
    }
}

extension NSViewController: DynamicViewPresentable {
    public var presentationName: AnyHashable? {
        presentationCoordinator.presentationName
    }
    
    public var presenter: DynamicViewPresenter? {
        presentingViewController ?? view.presenter
    }
}

extension NSWindow: DynamicViewPresentable {
    public var presentationName: AnyHashable? {
        return nil
    }
    
    public var presenter: DynamicViewPresenter? {
        parent
    }
}

#endif
