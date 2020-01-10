//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view's modal presentation style.
public enum ModalViewPresentationStyle: Equatable {
    case fullScreen
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    case page
    case form
    #endif
    
    case currentContext
    case overFullScreen
    case overCurrentContext
    
    #if os(tvOS)
    case blurOverFullScreen
    #endif
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    case popover
    #endif
    
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
    
    private var _automatic: ModalViewPresentationStyle {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return .page
        #else
        return .automatic
        #endif
    }
    
    public static func == (lhs: ModalViewPresentationStyle, rhs: ModalViewPresentationStyle) -> Bool {
        switch (lhs, rhs) {
            case (.fullScreen, .fullScreen):
                return true
            #if os(iOS) || targetEnvironment(macCatalyst)
            case (.page, .page):
                return true
            case (.form, .form):
                return true
            #endif
            case (.currentContext, .currentContext):
                return true
            case (.overFullScreen, .overFullScreen):
                return true
            case (.overCurrentContext, .overCurrentContext):
                return true
            #if os(tvOS)
            case (.blurOverFullScreen, .blurOverFullScreen):
                return true
            #endif
            #if os(iOS) || targetEnvironment(macCatalyst)
            case (.popover, .popover):
                return true
            #endif
            case (.automatic, .automatic):
                return true
            case (lhs._automatic, .automatic):
                return true
            case (.automatic, rhs._automatic):
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
            #if os(iOS) || targetEnvironment(macCatalyst)
            case .page:
                self = .pageSheet
            case .form:
                self = .formSheet
            #endif
            case .currentContext:
                self = .currentContext
            case .overFullScreen:
                self = .overFullScreen
            case .overCurrentContext:
                self = .overCurrentContext
            #if os(tvOS)
            case .blurOverFullScreen:
                self = .blurOverFullScreen
            #endif
            #if os(iOS) || targetEnvironment(macCatalyst)
            case .popover:
                self = .popover
            #endif
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
            #if os(iOS) || targetEnvironment(macCatalyst)
            case .pageSheet:
                return .page
            case .formSheet:
                return .form
            #endif
            case .currentContext:
                return .currentContext
            case .overFullScreen:
                return .overFullScreen
            case .overCurrentContext:
                return .overCurrentContext
            case .blurOverFullScreen:
                return .blurOverFullScreen
            #if os(iOS) || targetEnvironment(macCatalyst)
            case .popover:
                return .popover
            #endif
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
