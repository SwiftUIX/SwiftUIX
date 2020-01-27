//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresenter: PresentationManager {
    func present<V: View>(
        _ view: V,
        named _: ViewName?,
        onDismiss: (() -> Void)?,
        style: ModalViewPresentationStyle,
        completion: (() -> Void)?
    )
    
    func dismiss(completion: (() -> Void)?)
    func dismissView(named _: ViewName)
}

// MARK: - Extensions -

extension DynamicViewPresenter {
    public func present<V: View>(
        _ view: V,
        named name: ViewName? = nil,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle = .automatic
    ) {
        present(
            view,
            named: name,
            onDismiss: onDismiss,
            style: style,
            completion: nil
        )
    }
        
    public func dismissView<H: Hashable>(named name: H) {
        dismissView(named: .init(name))
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
