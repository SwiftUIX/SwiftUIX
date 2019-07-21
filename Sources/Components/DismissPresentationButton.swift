//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: View {
    @Environment(\.isPresented) private var isPresented

    public let label: Label

    private let action: (() -> ())?

    public init(action: (() -> ())? = nil, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public func dismiss() {
        action?()

        isPresented!.value = false
    }

    public var body: some View {
        Button(action: dismiss) {
            label
        }
    }
}

extension DismissPresentationButton where Label == Image {
    public init(action: (() -> ())? = nil) {
        self.init(action: action) {
            Image(systemName: "x.circle.fill")
        }
    }
}
