//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type that manages an active presentation.
public protocol PresentationManager: ViewInteractor {
    var isPresented: Bool { get }
    
    func dismiss()
}

// MARK: - API -

/// A dynamic action that dismisses an active presentation.
public struct DismissPresentation: DynamicAction {
    @Environment(\.presentationManager) var presentationManager
    
    public init() {
        
    }
    
    public func perform() {
        presentationManager.dismiss()
    }
}

// MARK: - Auxiliary Implementation -

private struct _PresentationManagerEnvironmentKey: ViewInteractorEnvironmentKey {
    typealias ViewInteractor = PresentationManager
    
    static var defaultValue: PresentationManager? {
        get {
            return nil
        }
    }
}

extension EnvironmentValues {
    public var presentationManager: PresentationManager {
        get {
            self[_PresentationManagerEnvironmentKey.self] ?? presentationMode
        } set {
            self[_PresentationManagerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Concrete Implementations -

extension Binding: PresentationManager where Value == PresentationMode {
    public var isPresented: Bool {
        return wrappedValue.isPresented
    }
    
    public func dismiss() {
        wrappedValue.dismiss()
    }
}
