//
//  AuthorizationAppleIDButton.swift
//  
//
//  Created by Siddarth on 6/7/20.
//

import Swift
import SwiftUI
import AuthenticationServices

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS)

/// A control you add to your interface that enables users to initiate the Sign In with Apple flow.
public struct AuthorizationAppleIDButton {
    // MARK: - Properties

    private let type: ASAuthorizationAppleIDButton.ButtonType
    private let style: ASAuthorizationAppleIDButton.Style

    // MARK: - Actions

    private var requestedScopes: [ASAuthorization.Scope]?
    private var onAuthorization: (ASAuthorization) -> Void = { _ in }
    private var onError: (Error) -> Void = { _ in }

    // MARK: - Lifecycle

    public init(
        type: ASAuthorizationAppleIDButton.ButtonType,
        style: ASAuthorizationAppleIDButton.Style
    ) {
        self.type = type
        self.style = style
    }
}

// MARK: - API

extension AuthorizationAppleIDButton {
    public func requestedScopes(_ requestedScopes: [ASAuthorization.Scope]) -> Self {
        then { $0.requestedScopes = requestedScopes }
    }

    public func onAuthorization(perform action: @escaping (ASAuthorization) -> Void) -> Self {
        then { $0.onAuthorization = action }
    }

    public func onError(perform action: @escaping (Error) -> Void) -> Self {
        then { $0.onError = action }
    }
}

// MARK: - UIViewRepresentable Protocol Implementation

extension AuthorizationAppleIDButton: UIViewRepresentable {
    public typealias UIViewType = ASAuthorizationAppleIDButton

    public func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button: ASAuthorizationAppleIDButton = .init(type: type, style: style)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        return button
    }

    public func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        context.coordinator.base = self
    }

    public class Coordinator: NSObject, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
        var base: AuthorizationAppleIDButton

        init(base: AuthorizationAppleIDButton) {
            self.base = base
        }

        @objc func didTap() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = base.requestedScopes
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.presentationContextProvider = self
            authorizationController.delegate = self
            authorizationController.performRequests()
        }

        public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let presentationAnchor = UIApplication.shared.windows.last?.rootViewController?.view.window else { fatalError() }
            return presentationAnchor
        }

        public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            base.onAuthorization(authorization)
        }

        public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            base.onError(error)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

#endif
