//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A control which dismisses an active sheet presentation when triggered.
public struct DismissSheetPresentationButton<Label: View>: View {
    @Environment(\.isSheetPresented) private var isSheetPresented
    @Environment(\.onSheetPresentationDismiss) private var onSheetPresentationDismiss

    public let label: Label
    
    private let onDismiss: (() -> ())?

    public init(onDismiss: (() -> ())? = nil, @ViewBuilder label: () -> Label) {
        self.onDismiss = onDismiss
        self.label = label()
    }

    public var body: some View {
        Button(action: dismiss) {
            label
        }.onAppear(perform: setupOnSheetPresentationDismiss)
    }

    public func setupOnSheetPresentationDismiss() {
        let onDismiss = onSheetPresentationDismiss!

        if let value = onDismiss.value {
            onDismiss.value = { value(); self.onDismiss?() }
        } else {
            onDismiss.value = self.onDismiss
        }
    }

    public func dismiss() {
        isSheetPresented!.value = false
    }
}

extension DismissSheetPresentationButton where Label == Image {
    public init(onDismiss: (() -> ())? = nil) {
        self.init(onDismiss: onDismiss) {
            Image(systemName: "x.circle.fill")
        }
    }
}
