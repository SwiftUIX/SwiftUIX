//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: View {
    public let label: Label

    private let action: (() -> ())?

    public init(action: (() -> ())? = nil, label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: dismiss) {
            label
        }
    }

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.isSheetPresented) private var isSheetPresented

    public func dismiss() {
        action?()

        if let isSheetPresented = isSheetPresented {
            // This is a hack until @Environment(\.isPresented) is fixed.
            UIApplication
                .shared
                .windows[0]
                .rootViewController!
                .dismiss(animated: true, completion: nil)

            isSheetPresented.value = false
        } else {
            presentationMode.value.dismiss()
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
