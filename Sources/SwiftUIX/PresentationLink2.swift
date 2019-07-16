//
// Copyright (c) Vatsal Manot
//

import SwiftUI

private enum SetPresentedViewKey: EnvironmentKey {
    static var defaultValue: (AnyView?) -> () {
        fatalError()
    }
}

private extension EnvironmentValues {
    var setPresentedView: (AnyView?) -> () {
        get {
            self[SetPresentedViewKey.self]
        } set {
            self[SetPresentedViewKey.self] = newValue
        }
    }
}

/// A replacement for the buggy (as of Xcode 11 b3) `PresentationLink`.
public struct PresentationLink2<Destination: View, Label: View>: View {
    public let destination: Destination
    public let label: Label

    @Environment(\.setPresentedView) private var setPresentedView
    @State private var presentedView: AnyView? = nil

    public init(destination: Destination, @ViewBuilder _ label: () -> Label) {
        self.destination = destination
        self.label = label()
    }

    private struct _Body<Destination: View, Label: View>: View {
        @Environment(\.setPresentedView) private var setPresentedView

        let destination: Destination
        let label: Label

        init(destination: Destination, label: Label) {
            self.destination = destination
            self.label = label
        }

        var body: some View {
            Button(action: present, label: { label })
        }

        func present() {
            setPresentedView(AnyView(destination))
        }
    }

    public var body: some View {
        _Body(destination: destination, label: label)
            .environment(\.setPresentedView, { self.presentedView = $0 })
            .presentation(presentedView.map {
                Modal($0, onDismiss: { self.presentedView = nil })
            })
    }
}
