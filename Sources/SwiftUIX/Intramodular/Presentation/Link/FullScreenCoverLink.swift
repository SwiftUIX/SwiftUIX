//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
public struct FullScreenCoverLink<Destination: View, Label: View>: PresentationLinkView {
    private let destination: Destination
    private let label: Label
    private let onDismiss: (() -> ())?
    
    @State private var isPresented: Bool = false
    
    public init(
        destination: Destination,
        onDismiss: (() -> ())?,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }
    
    public init(
        destination: Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            destination: destination,
            onDismiss: nil,
            label: label
        )
    }
    
    public var body: some View {
        Button(toggle: $isPresented, label: { label })
            .fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
                destination
                    ._resolveAppKitOrUIKitViewControllerIfAvailable()
            }
    }
}
