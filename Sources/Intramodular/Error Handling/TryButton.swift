//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A button capable of performing throwing functions.
public struct TryButton<Label: View>: ActionLabelView {
    struct UnlocalizedErrorWrapper: LocalizedError {
        let base: Error
    }
    
    @Environment(\.handleLocalizedError) var handleLocalizedError
    
    private let action: () throws -> ()
    private let label: Label
    
    public init(
        action: @escaping () throws -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
    
    public init(
        action: Action,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: action.perform, label: label)
    }
    
    public var body: some View {
        Button(action: trigger) {
            label
        }
    }
    
    public func trigger() {
        do {
            try action()
        } catch {
            handleLocalizedError(error as? LocalizedError ?? UnlocalizedErrorWrapper(base: error))
        }
    }
}

extension TryButton where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        action: @escaping () throws -> Void
    ) {
        self.init(action: action) {
            Text(title)
        }
    }
}
