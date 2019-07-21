//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: View {
    @Environment(\.isPresented) private var isPresented

    public let label: Label
    
    private let onDismiss: (() -> ())?

    public init(onDismiss: (() -> ())? = nil, @ViewBuilder label: () -> Label) {
        self.onDismiss = onDismiss
        self.label = label()
    }

    public var body: some View {
        Button(action: dismiss) {
            label
        }
    }

    public func dismiss() {
        isPresented?.value = false
        onDismiss?()
    }
}

extension DismissPresentationButton where Label == Image {
    public init(onDismiss: (() -> ())? = nil) {
        self.init(onDismiss: onDismiss) {
            Image(systemName: "x.circle.fill")
        }
    }
}
