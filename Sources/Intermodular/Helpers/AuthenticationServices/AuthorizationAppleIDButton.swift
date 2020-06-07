//
// Copyright (c) Vatsal Manot
//

import AuthenticationServices
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control you add to your interface that enables users to initiate the Sign In with Apple flow.
public struct AuthorizationAppleIDButton {
    @usableFromInline
    let type: ASAuthorizationAppleIDButton.ButtonType
    @usableFromInline
    let style: ASAuthorizationAppleIDButton.Style
    
    @usableFromInline
    var onAuthorization: (Result<ASAuthorization, Error>) -> Void = { _ in }
    @usableFromInline
    var requestedScopes: [ASAuthorization.Scope]?
    
    public init(
        type: ASAuthorizationAppleIDButton.ButtonType,
        style: ASAuthorizationAppleIDButton.Style
    ) {
        self.type = type
        self.style = style
    }
}

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
    
    public class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
            authorizationController.presentationContextProvider = self
            
            authorizationController.performRequests()
        }
        
        public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let window = UIApplication.shared.firstKeyWindow else {
                assertionFailure()
                
                return UIWindow()
            }
            
            return window
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

#endif
