//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

public struct PopoverPresentationLink<Destination: View, Label: View>: PresentationLinkView {
    private let destination: () -> Destination
    private let label: Label
    private let onDismiss: (() -> ())?
    
    @Environment(\.environmentBuilder) private var environmentBuilder
    
    @State private var isPresented: Bool = false
    
    public init(
        destination: @autoclosure @escaping () -> Destination,
        onDismiss: (() -> ())?,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }
    
    public init(
        destination: @autoclosure @escaping () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            destination: destination(),
            onDismiss: nil,
            label: label
        )
    }
    
    public var body: some View {
        Button(action: present, label: { label }).popover(
            isPresented: $isPresented.onSet {
                if self.isPresented == true && $0 == false {
                    self._onDismiss()
                }
            }
        ) {
            CocoaHosted(
                rootView: self.destination()
                    .mergeEnvironmentBuilder(self.environmentBuilder)
            )
        }
    }
    
    private func present() {
        isPresented = true
    }
    
    private func _onDismiss() {
        onDismiss?()
    }
}

#endif
