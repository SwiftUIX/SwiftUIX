//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view's modal presentation style.
public enum ModalViewPresentationStyle: Equatable {
    case fullScreen
    case page
    case form
    case currentContext
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
    
    public static func == (lhs: ModalViewPresentationStyle, rhs: ModalViewPresentationStyle) -> Bool {
        switch (lhs, rhs) {
            case (.fullScreen, .fullScreen):
                return true
            case (.page, .page):
                return true
            case (.form, .form):
                return true
            case (.overFullScreen, .overFullScreen):
                return true
            case (.overCurrentContext, .overCurrentContext):
                return true
            case (.popover, .popover):
                return true
            case (.automatic, .automatic):
                return true
            case (.none, .none):
                return true
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            case let (.custom(lhsDelegate), .custom(rhsDelegate)):
                return lhsDelegate.isEqual(rhsDelegate)
            #endif
            default:
                return false
        }
    }
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
            case .currentContext:
                self = .currentContext
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

extension UIViewController {
    public var modalViewPresentationStyle: ModalViewPresentationStyle {
        switch modalPresentationStyle {
            case .fullScreen:
                return .fullScreen
            case .pageSheet:
                return .page
            case .formSheet:
                return .form
            case .currentContext:
                return .currentContext
            case .overFullScreen:
                return .overFullScreen
            case .overCurrentContext:
                return .overCurrentContext
            case .popover:
                return .popover
            case .automatic:
                return .automatic
            case .none:
                return .none
            case .custom:
                return .custom(transitioningDelegate!)
            @unknown default:
                return .automatic
        }
    }
}
#endif
