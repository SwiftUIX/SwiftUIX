//
// Copyright (c) Vatsal Manot
//

import AuthenticationServices
import Swift
import SwiftUI

/// A control you add to your interface that enables users to initiate the Sign In with Apple flow.
public struct AuthorizationAppleIDButton {
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    @usableFromInline
    let type: ASAuthorizationAppleIDButton.ButtonType
    @usableFromInline
    let style: ASAuthorizationAppleIDButton.Style
    #endif

    #if os(watchOS)
    @usableFromInline
    let style: WKInterfaceAuthorizationAppleIDButton.Style
    #endif
    
    @usableFromInline
    var onAuthorization: (Result<ASAuthorization, Error>) -> Void = { _ in }
    @usableFromInline
    var requestedScopes: [ASAuthorization.Scope]?

    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public init(
        type: ASAuthorizationAppleIDButton.ButtonType,
        style: ASAuthorizationAppleIDButton.Style
    ) {
        self.type = type
        self.style = style
    }
    #endif

    #if os(watchOS)
    public init(
        style: WKInterfaceAuthorizationAppleIDButton.Style
    ) {
        self.style = style
    }
    #endif
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension AuthorizationAppleIDButton: UIViewRepresentable {
    public typealias UIViewType = ASAuthorizationAppleIDButton
    
    public func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style).then {
            $0.addTarget(context.coordinator, action: #selector(Coordinator.authenticate), for: .touchUpInside)
        }
    }
    
    public func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        context.coordinator.base = self
    }
}

extension AuthorizationAppleIDButton.Coordinator: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.firstKeyWindow else {
            assertionFailure()

            return UIWindow()
        }

        return window
    }
}

#elseif os(macOS)

extension AuthorizationAppleIDButton: NSViewRepresentable {
    public typealias NSViewType = ASAuthorizationAppleIDButton

    public func makeNSView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style).then {
            $0.target = context.coordinator
            $0.action = #selector(Coordinator.authenticate)
        }
    }

    public func updateNSView(_ nsView: ASAuthorizationAppleIDButton, context: Context) {
        context.coordinator.base = self
    }
}

extension AuthorizationAppleIDButton.Coordinator: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = NSApplication.shared.firstKeyWindow else {
            assertionFailure()

            return NSWindow()
        }

        return window
    }
}

#elseif os(watchOS)

extension AuthorizationAppleIDButton: WKInterfaceObjectRepresentable {
    public typealias WKInterfaceObjectType = WKInterfaceAuthorizationAppleIDButton

    public func makeWKInterfaceObject(context: Context) -> WKInterfaceAuthorizationAppleIDButton {
        if #available(watchOS 6.1, *) {
            return WKInterfaceAuthorizationAppleIDButton(style: style, target: context.coordinator, action: #selector(Coordinator.authenticate))
        } else {
            return WKInterfaceAuthorizationAppleIDButton(target: context.coordinator, action: #selector(Coordinator.authenticate))
        }
    }

    public func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceAuthorizationAppleIDButton, context: Context) {
        context.coordinator.base = self
    }
}

#endif

extension AuthorizationAppleIDButton {
    public class Coordinator: NSObject, ASAuthorizationControllerDelegate {
        var base: AuthorizationAppleIDButton

        init(base: AuthorizationAppleIDButton) {
            self.base = base
        }

        @objc func authenticate() {
            let request = ASAuthorizationAppleIDProvider().createRequest().then {
                $0.requestedScopes = base.requestedScopes
            }

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])

            authorizationController.delegate = self
            #if os(iOS)
            authorizationController.presentationContextProvider = self
            #endif

            authorizationController.performRequests()
        }

        public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            base.onAuthorization(.success(authorization))
        }

        public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            base.onAuthorization(.failure(error))
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

// MARK: - API -

extension AuthorizationAppleIDButton {
    public func onAuthorization(perform action: @escaping (Result<ASAuthorization, Error>) -> Void) -> Self {
        then({ $0.onAuthorization = action })
    }

    public func requestedScopes(_ requestedScopes: [ASAuthorization.Scope]) -> Self {
        then({ $0.requestedScopes = requestedScopes })
    }
}
