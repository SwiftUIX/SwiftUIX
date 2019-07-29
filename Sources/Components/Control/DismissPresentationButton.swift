//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: View {
    public let label: Label

    private let action: (() -> ())?

    public init(action: (() -> ())? = nil, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: dismiss) {
            label
        }
    }

    @Environment(\.presentationMode) private var presentationMode

    public func dismiss() {
        action?()
        presentationMode.value.dismiss()
    }
}

extension DismissPresentationButton where Label == Image {
    public init(action: (() -> ())? = nil) {
        self.init(action: action) {
            Image(systemName: "x.circle.fill")
        }
    }
}
