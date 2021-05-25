//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ProgressionController: ViewInteractor {
    func scrollTo(_ id: AnyHashable)

    func moveToNext()
    func moveToPrevious()
}

// MARK: - Auxiliary Implementation -

public struct ProgressionControllerEnvironmentKey: ViewInteractorEnvironmentKey {
    public typealias ViewInteractor = ProgressionController
}

extension EnvironmentValues {
    public var progressionController: ProgressionController? {
        get {
            self[ProgressionControllerEnvironmentKey.self]
        } set {
            self[ProgressionControllerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - API -

/// A button that triggers a regression.
public struct PreviousButton<Label: View>: ActionLabelView, PerformActionView {
    @Environment(\.progressionController) var progressionController
    
    private let action: Action
    private let label: Label
    
    public init(action: Action, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: { self.progressionController?.moveToPrevious() }) {
            label
        }
    }
    
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        .init(action: transform(action), label: { label })
    }
}

/// A button that triggers a progression.
public struct NextButton<Label: View>: ActionLabelView, PerformActionView {
    @Environment(\.progressionController) var progressionController
    
    private let action: Action
    private let label: Label
    
    public init(action: Action, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: { self.progressionController?.moveToNext() }) {
            label
        }
    }
    
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        .init(action: transform(action), label: { label })
    }
}
