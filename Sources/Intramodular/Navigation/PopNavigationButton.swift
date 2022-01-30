//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A control which pops a view in a navigation stack.
public struct PopNavigationButton<Label: View>: ActionLabelView {    
    private let action: Action
    private let label: Label
    
    public init(action: Action, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public init(@ViewBuilder label: () -> Label) {
        self.init(action: .empty, label: label)
    }
    
    public var body: some View {
        EnvironmentValueAccessView(\.navigator) { navigator in
            Button {
                action.perform()
                navigator?.pop()
            } label: {
                label
            }
        }
        ._resolveAppKitOrUIKitViewControllerIfAvailable()
    }
}
