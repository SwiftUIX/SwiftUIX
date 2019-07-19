//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

private enum SetIsPresentingEnvironmentKey: EnvironmentKey {
    static var defaultValue: (Bool) -> () {
        { _ in }
    }
}

private extension EnvironmentValues {
    var setIsPresenting: (Bool) -> () {
        get {
            self[SetIsPresentingEnvironmentKey.self]
        } set {
            self[SetIsPresentingEnvironmentKey.self] = newValue
        }
    }
}

/// A bug-free revival of `PresentationLink`.
public struct PresentationLink2<Destination: View, Label: View>: View {
    public let destination: Destination
    public let label: Label

    @Environment(\.setIsPresenting) private var setIsPresenting

    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }

    private struct _Body<Destination: View, Label: View>: View {
        @Environment(\.setIsPresenting) private var setIsPresenting

        let destination: Destination
        let label: Label

        init(destination: Destination, label: Label) {
            self.destination = destination
            self.label = label
        }

        var body: some View {
            Button(action: { self.setIsPresenting(true) }, label: { label })
        }
    }

    @State private var isPresented: Bool = false

    public var body: some View {
        _Body(destination: destination, label: label)
            .environment(\.setIsPresenting, { self.isPresented = $0 })
            .environment(\.isPresented, $isPresented)
            .sheet(
                isPresented: $isPresented,
                onDismiss: { self.isPresented = false },
                content: { self.destination }
            )
    }
}
