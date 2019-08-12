//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: View {
    private let label: Label
    private let action: (() -> ())?

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.isNavigationButtonActive) private var isNavigationButtonActive
    @Environment(\.isSheetPresented) private var isSheetPresented

    public init(action: (() -> ())? = nil, label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: dismiss, label: { label })
    }

    public func dismiss() {
        action?()

        if let isNavigationButtonActive = isNavigationButtonActive {
            isNavigationButtonActive.value = false
        } else if let isSheetPresented = isSheetPresented {
            isSheetPresented.value = false

            #if os(iOS)
            UIApplication
                .shared
                .windows[0]
                .rootViewController!
                .dismiss(animated: true, completion: nil) // FIXME(@vmanot): This is a hack until @Environment(\.isPresented) is fixed.
            #endif
        } else if !presentationMode.value.isPresented {
            fatalError()
        }

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
