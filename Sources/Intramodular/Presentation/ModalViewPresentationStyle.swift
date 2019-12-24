//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view's modal presentation style.
public enum ModalViewPresentationStyle {
    case fullScreen
    case page
    case form
    case overFullScreen
    case overCurrentContext
    case popover
    case automatic
    case none
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    case custom(UIViewControllerTransitioningDelegate)
    
    public var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        if case let .custom(delegate) = self {
            return delegate
        } else {
            return nil
        }
    }
    #endif
}

// MARK: - Helpers-

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIModalPresentationStyle {
    public init(_ style: ModalViewPresentationStyle) {
        switch style {
            case .fullScreen:
                self = .fullScreen
            case .page:
                self = .pageSheet
            case .form:
                self = .formSheet
            case .overFullScreen:
                self = .overFullScreen
            case .overCurrentContext:
                self = .overCurrentContext
            case .popover:
                self = .popover
            case .automatic:
                self = .automatic
            case .none:
                self = .none
            case .custom:
                self = .custom
        }
    }
}

#endif
