//
// Copyright (c) Vatsal Manot
//

import AuthenticationServices
import Swift
import SwiftUI

/// A control you add to your interface that enables users to initiate the Sign In with Apple flow.
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
public struct AuthorizationAppleIDButton {
    @usableFromInline
    let type: AuthorizationAppleIDButtonType
    @usableFromInline
    let style: AuthorizationAppleIDButtonStyle
    
    @usableFromInline
    var onAuthorization: (Result<ASAuthorization, Error>) -> Void = { _ in }
    @usableFromInline
    var requestedScopes: [ASAuthorization.Scope]?
    
    public init(
        type: AuthorizationAppleIDButtonType,
        style: AuthorizationAppleIDButtonStyle
    ) {
        self.type = type
        self.style = style
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AuthorizationAppleIDButton: UIViewRepresentable {
    public typealias UIViewType = ASAuthorizationAppleIDButton
    
    public func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: .init(type), style: .init(style)).then {
            $0.addTarget(context.coordinator, action: #selector(Coordinator.authenticate), for: .touchUpInside)
        }
    }
    
    public func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        context.coordinator.base = self
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
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
        ASAuthorizationAppleIDButton(type: .init(type), style: .init(style)).then {
            $0.action = #selector(Coordinator.authenticate)
            $0.target = context.coordinator
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
            return WKInterfaceAuthorizationAppleIDButton(style: .init(style), target: context.coordinator, action: #selector(Coordinator.authenticate))
        } else {
            return WKInterfaceAuthorizationAppleIDButton(target: context.coordinator, action: #selector(Coordinator.authenticate))
        }
    }
    
    public func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceAuthorizationAppleIDButton, context: Context) {
        context.coordinator.base = self
    }
}

#endif

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
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

// MARK: - API

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AuthorizationAppleIDButton {
    public func onAuthorization(perform action: @escaping (Result<ASAuthorization, Error>) -> Void) -> Self {
        then({ $0.onAuthorization = action })
    }
    
    public func requestedScopes(_ requestedScopes: [ASAuthorization.Scope]) -> Self {
        then({ $0.requestedScopes = requestedScopes })
    }
}
#endif
