//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: ActionLabelView {
    @Environment(\.presentationMode) private var presentationMode
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
        defer {
            action.perform()
        }
        
        if presentationMode.isPresented {
            presentationMode.dismiss()
        } else {
            presentationManager.dismiss()
        }
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

extension DismissPresentationButton where Label == Text {
    public init<S: StringProtocol>(_ title: S) {
        self.init {
            Text(title)
        }
    }
}
