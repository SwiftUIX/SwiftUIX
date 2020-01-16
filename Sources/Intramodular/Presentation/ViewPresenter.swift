//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresenter: PresentationManager {
    func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)?,
        style: ModalViewPresentationStyle
    )
    
    func dismiss(viewNamed _: ViewName)
}

// MARK: - Extensions -

extension DynamicViewPresenter {
    public func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)?
    ) {
        present(
            view,
            onDismiss: onDismiss,
            style: .automatic
        )
    }
    
    public func dismiss<H: Hashable>(viewNamed name: H) {
        dismiss(viewNamed: .init(name))
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
