//
// Copyright (c) Vatsal Manot
//

import AuthenticationServices
import Swift
import SwiftUI

/// A type for the authorization button.
@_documentation(visibility: internal)
public enum AuthorizationAppleIDButtonType: Equatable {
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    case `continue`
    case signIn
    @available(iOS 13.2, tvOS 13.1, OSX 10.15.1, *)
    case signUp
    #endif
    
    case `default`
}

// MARK: - Helpers

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension ASAuthorizationAppleIDButton.ButtonType {
    public init(_ type: AuthorizationAppleIDButtonType) {
        switch type {
            case .continue:
                self = .continue
            case .signIn:
                self = .signIn
            case .signUp: do {
                if #available(iOS 13.2, tvOS 13.1, OSX 10.15.1, *) {
                    self = .signUp
                } else {
                    self = .signIn
                }
            }
            case .default:
                self = .default
        }
    }
}

#endif
