//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A button that triggers a regression.
public struct PreviousButton<Label: View>: View {
    @Environment(\.progressionController) var progressionController
    
    private let action: () -> ()
    private let label: Label
    
    public init(action: @escaping () -> () = { }, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: moveToPrevious) {
            label
        }
    }
    
    private func moveToPrevious() {
        progressionController?.moveToPrevious()
    }
}

extension PreviousButton: ActionTriggerView {
    public func onPrimaryTrigger(perform action: @escaping () -> ()) -> Self {
        .init(action: { action(); return self.action() }, label: { label })
    }
}
