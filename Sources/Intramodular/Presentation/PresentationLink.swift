//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A control which presents content when triggered.
///
/// A revival of `PresentationLink` (from Xcode 11 beta 3).
public struct PresentationLink<Destination: View, Label: View>: View {
    public let destination: Destination
    public let label: Label

    private let onDismiss: (() -> ())?

    @State private var isPresented: Bool = false

    public init(destination: Destination, onDismiss: (() -> ())? = nil, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Button(action: present, label: { label })
            .sheet(
                isPresented: $isPresented,
                onDismiss: dismiss,
                content: { self.destination }
        )
    }

    private func present() {
        isPresented = true
    }

    private func dismiss() {
        isPresented = false

        onDismiss?()
    }
}
