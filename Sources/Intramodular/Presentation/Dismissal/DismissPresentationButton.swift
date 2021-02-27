//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: ActionLabelView {
    @Environment(\.presentationManager) private var presentationManager
    
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
        Button(action: dismiss, label: { label })
    }
    
    public func dismiss() {
        action.perform()
        presentationManager.dismiss()
    }
}

extension DismissPresentationButton where Label == Image {
    @available(OSX 11.0, *)
    public init(action: @escaping () -> Void = { }) {
        self.init(action: action) {
            Image(systemName: .xmarkCircleFill)
        }
    }
}
