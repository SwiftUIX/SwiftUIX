//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol PresentationManager: ViewInteractor {
    var isPresented: Bool { get }
    
    func dismiss()
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

extension Binding: PresentationManager where Value: PresentationModeProtocol {
    public var isPresented: Bool {
        return wrappedValue.isPresented
    }
    
    public func dismiss() {
        wrappedValue.dismiss()
    }
}
