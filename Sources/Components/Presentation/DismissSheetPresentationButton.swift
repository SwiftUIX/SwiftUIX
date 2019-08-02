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
        }.onAppear {
            self.onSheetPresentationDismiss!.value = self.onDismiss
        }
    }

    public func dismiss() {
        // This is a hack until @Environment(\.isPresented) is fixed.
        UIApplication
            .shared
            .windows[0]
            .rootViewController!
            .dismiss(animated: true, completion: nil)

        // isSheetPresented!.value = false
    }
}

extension DismissSheetPresentationButton where Label == Image {
    public init(onDismiss: (() -> ())? = nil) {
        self.init(onDismiss: onDismiss) {
            Image(systemName: "x.circle.fill")
        }
    }
}
