//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view's modal presentation style.
public enum ModalPresentationStyle: Equatable {
    case fullScreen
    
    #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
    case page
    case form
    #endif
    
    case currentContext
    case overFullScreen
    case overCurrentContext
    
    #if os(tvOS)
    case blurOverFullScreen
    #endif
    
    #if os(iOS) || os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)
    case popover(
        permittedArrowDirections: PopoverArrowDirection = .all,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds)
    )
    #endif
    
    case automatic
    case none
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    case custom(UIViewControllerTransitioningDelegate)
    #endif
        
    #if os(iOS) || os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public static var popover: Self {
        .popover(permittedArrowDirections: .all, attachmentAnchor: .rect(.bounds))
    }
    #endif
    
    public static func == (lhs: ModalPresentationStyle, rhs: ModalPresentationStyle) -> Bool {
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
            case (.none, .none):
                return true
            #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
            case let (.custom(lhsDelegate), .custom(rhsDelegate)):
                return lhsDelegate.isEqual(rhsDelegate)
            #endif
            default:
                return false
        }
    }
}

// MARK: - API

extension View {
    public func modalPresentationStyle(
        _ style: ModalPresentationStyle
    ) -> some View {
        environment(\.modalPresentationStyle, style)
    }
}

// MARK: - Auxiliary

extension ModalPresentationStyle {
    public enum _Comparison {
        case popover
    }
    
    public static func == (lhs: Self, rhs: _Comparison) -> Bool {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        switch (lhs, rhs) {
            case (.popover, .popover):
                return true
            default:
                return false
        }
        #else
        return false
        #endif
    }
}

extension ModalPresentationStyle {
    @usableFromInline
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        @usableFromInline
        static let defaultValue: ModalPresentationStyle = .automatic
    }
}

extension EnvironmentValues {
    public var modalPresentationStyle: ModalPresentationStyle {
        get {
            self[ModalPresentationStyle.EnvironmentKey.self]
        } set {
            self[ModalPresentationStyle.EnvironmentKey.self] = newValue
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

extension ModalPresentationStyle {
    public func toTransitioningDelegate() -> UIViewControllerTransitioningDelegate? {
        if case let .custom(delegate) = self {
            return delegate
        } else {
            return nil
        }
    }
}

extension UIModalPresentationStyle {
    public init(_ style: ModalPresentationStyle) {
        switch style {
            case .fullScreen:
                self = .fullScreen
            #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
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
            #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
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
    public var modalViewPresentationStyle: ModalPresentationStyle {
        switch modalPresentationStyle {
            case .fullScreen:
                return .fullScreen
            #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
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
            #if os(tvOS)
            case .blurOverFullScreen:
                return .blurOverFullScreen
            #endif
            #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
            case .popover:
                return .popover(
                    permittedArrowDirections: .init(popoverPresentationController?.permittedArrowDirections ?? .any)
                )
            #endif
            case .automatic:
                return .automatic
            case .none:
                return .none
            case .custom:
                if let transitioningDelegate = transitioningDelegate {
                    return .custom(transitioningDelegate)
                } else {
                    assertionFailure("transitioningDelegate is nil")
                    
                    return .automatic
                }
            @unknown default:
                return .automatic
        }
    }
}

#endif
