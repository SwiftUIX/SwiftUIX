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
}

// MARK: - Extensions -

extension DynamicViewPresenter {
    
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
