//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresenter: PresentationManager {
    var presenting: DynamicViewPresenter? { get }
    var presented: DynamicViewPresenter? { get }
    
    func present(_ presentation: AnyModalPresentation)
    
    func dismiss(completion: @escaping () -> Void)
    func dismissView(named _: ViewName, completion: @escaping () -> Void)
}

// MARK: - Implementation -

extension DynamicViewPresenter {
    public var topmostPresented: DynamicViewPresenter? {
        var presented = self.presented
        
        while let _presented = presented?.presented {
            presented = _presented
        }
        
        return presented
    }
    
    public var isPresented: Bool {
        return presented != nil
    }
    
    public func present<V: View>(
        _ view: V,
        named name: ViewName? = nil,
        onDismiss: @escaping () -> Void = { },
        presentationStyle: ModalViewPresentationStyle = .automatic,
        completion: @escaping () -> () = { }
    ) {
        present(
            .init(
                content: { view },
                contentName: name,
                completion: completion,
                shouldDismiss: { true },
                onDismiss: onDismiss,
                resetBinding: { },
                presentationStyle: presentationStyle
            )
        )
    }
    
    public func dismissTopmost() {
        topmostPresented?.presenting?.dismiss()
    }
    
    public func dismissView<H: Hashable>(named name: H) {
        dismissView(named: .init(name), completion: { })
    }
}

// MARK: - Auxiliary Implementation -

private struct DynamicViewPresenterEnvironmentKey: EnvironmentKey {
    static let defaultValue: DynamicViewPresenter? = nil
}

extension EnvironmentValues {
    public var dynamicViewPresenter: DynamicViewPresenter? {
        get {
            self[DynamicViewPresenterEnvironmentKey.self]
        } set {
            self[DynamicViewPresenterEnvironmentKey.self] = newValue
        }
    }
}
