//
// Copyright (c) Vatsal Manot
//

#if !swift(>=5.3) // workaround for Xcode 12 beta 6

import AuthenticationServices
import Swift
import SwiftUI

/// A style for the authorization button.
public enum AuthorizationAppleIDButtonStyle: Equatable {
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    /// A button with a white outline.
    case whiteOutline
    /// A black button.
    case black
    #endif
    
    #if os(watchOS)
    /// The system’s default button style.
    case `default`
    #endif
    
    /// A white button with black lettering.
    case white
}

// MARK: - Helpers -

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension ASAuthorizationAppleIDButton.Style {
    public init(_ style: AuthorizationAppleIDButtonStyle) {
        switch style {
            case .whiteOutline:
                self = .whiteOutline
            case .black:
                self = .black
            case .white:
                self = .white
        }
    }
}

#elseif os(watchOS)

extension WKInterfaceAuthorizationAppleIDButton.Style {
    public init(_ style: AuthorizationAppleIDButtonStyle) {
        switch style {
            case .default:
                self = .default
            case .white:
                self = .white
        }
    }
}

#endif

#endif
