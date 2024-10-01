//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ProgressionController {
    func scrollTo(_ id: AnyHashable)
    
    func moveToNext()
    func moveToPrevious()
}

// MARK: - Auxiliary

extension EnvironmentValues {
    struct ProgressionControllerEnvironmentKey: EnvironmentKey {
        static let defaultValue: ProgressionController? = nil
    }
    
    public var progressionController: ProgressionController? {
        get {
            self[ProgressionControllerEnvironmentKey.self]
        } set {
            self[ProgressionControllerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - API

/// A button that triggers a regression.
@_documentation(visibility: internal)
@MainActor
public struct PreviousButton<Label: View>: ActionLabelView, _ActionPerformingView {
    @Environment(\.progressionController) var progressionController
    
    private let action: Action
    private let label: Label
    
    public init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = Action(action)
        self.label = label()
    }

    public init(
        action: Action,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: { self.progressionController?.moveToPrevious() }) {
            label
        }
    }
    
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        Self(action: transform(action), label: { label })
    }
}

/// A button that triggers a progression.
@_documentation(visibility: internal)
@MainActor
public struct NextButton<Label: View>: ActionLabelView, _ActionPerformingView {
    @Environment(\.progressionController) var progressionController
    
    private let action: Action
    private let label: Label
    
    public init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = Action(action)
        self.label = label()
    }
    
    public init(
        action: Action,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: { self.progressionController?.moveToNext() }) {
            label
        }
    }
    
    @MainActor
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        Self(action: transform(action), label: { label })
    }
}
