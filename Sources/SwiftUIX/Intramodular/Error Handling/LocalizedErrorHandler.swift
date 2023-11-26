//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftUI

/// A handler for user facing errors.
///
/// This protocol provides a means through which
public protocol LocalizedErrorHandler {
    func handle(_ error: LocalizedError)
}

// MARK: - API

extension View {
    /// Sets a localized error handler for this view.
    ///
    /// - parameter handler: The action to perform on the propagation of a localized error.
    public func onLocalizedError(_ handler: @escaping (LocalizedError) -> Void) -> some View {
        modifier(SetLocalizedErrorHandler(handleLocalizedError: handler))
    }
}

// MARK: - Auxiliary

struct SetLocalizedErrorHandler: ViewModifier {
    private struct _ErrorHandler: LocalizedErrorHandler {
        let handleErrorImpl: (LocalizedError) -> Void
        
        func handle(_ error: LocalizedError) {
            handleErrorImpl(error)
        }
    }
    
    private let errorHandler: _ErrorHandler
    
    init(handleLocalizedError: @escaping (LocalizedError) -> Void) {
        errorHandler = .init(handleErrorImpl: handleLocalizedError)
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.localizedErrorHandler, errorHandler)
    }
}

private struct DefaultLocalizedErrorHandler: LocalizedErrorHandler {
    func handle(_ error: LocalizedError) {
        debugPrint(String(describing: error))
    }
}

/// Provides functionality for handling a localized error.
public struct HandleLocalizedErrorAction {
    fileprivate let base: LocalizedErrorHandler
    
    public func callAsFunction(_ error: LocalizedError) {
        base.handle(error)
    }
}

extension EnvironmentValues {
    private struct LocalizedErrorHandlerKey: EnvironmentKey {
        static let defaultValue: LocalizedErrorHandler = DefaultLocalizedErrorHandler()
    }
    
    var localizedErrorHandler: LocalizedErrorHandler {
        get {
            self[LocalizedErrorHandlerKey.self]
        } set {
            self[LocalizedErrorHandlerKey.self] = newValue
        }
    }
    
    public var handleLocalizedError: HandleLocalizedErrorAction {
        .init(base: localizedErrorHandler)
    }
}
