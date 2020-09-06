//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct TryButton<Label: View>: ActionLabelView {
    private let action: () throws -> ()
    private let label: Label
    
    @State var error: Error?
    
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
        .pushError(error)
    }
    
    public func trigger() {
        do {
            error = nil
            
            try action()
        } catch {
            self.error = error
        }
    }
}
