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

extension PresentationMode {
    /// A dynamic action that dismisses an active presentation.
    public struct DismissPresentationAction: DynamicAction {
        @Environment(\.presentationManager) var presentationManager
        
        public init() {
            
        }
        
        public func perform() {
            presentationManager.dismiss()
        }
    }
    
    public static var dismiss: DismissPresentationAction {
        DismissPresentationAction()
    }
}

public struct BooleanPresentationManager: PresentationManager  {
    @Binding public var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public func dismiss() {
        isPresented = false
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
            #if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)
            if navigator == nil && presentationMode.isPresented {
                return presentationMode
            } else {
                return self[_PresentationManagerEnvironmentKey.self]
                ?? (_appKitOrUIKitViewControllerBox?.value?._cocoaPresentationCoordinator).flatMap({ CocoaPresentationMode(coordinator: $0) })
                    ?? presentationMode
            }
            #else
            return self[_PresentationManagerEnvironmentKey.self] ?? presentationMode
            #endif
        } set {
            self[_PresentationManagerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Conformances -

public struct AnyPresentationManager: PresentationManager {
    private let isPresentedImpl: () -> Bool
    private let dismissImpl: () -> Void
    
    public var isPresented: Bool {
        isPresentedImpl()
    }
    
    public init(
        isPresented: @escaping () -> Bool,
        dismiss: @escaping () -> Void
    ) {
        self.isPresentedImpl = isPresented
        self.dismissImpl = dismiss
    }

    public func dismiss() {
        dismissImpl()
    }
}

extension Binding: PresentationManager where Value == PresentationMode {
    public var isPresented: Bool {
        return wrappedValue.isPresented
    }
    
    public func dismiss() {
        wrappedValue.dismiss()
    }
}
