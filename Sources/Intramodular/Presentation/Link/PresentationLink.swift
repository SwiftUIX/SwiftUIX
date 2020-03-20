//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A control which presents content when triggered.
///
/// A revival of `PresentationLink` (from Xcode 11 beta 3).
public struct PresentationLink<Destination: View, Label: View>: PresentationLinkView {
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
        Group {
            Button(action: present, label: { label }).sheet(
                isPresented: $isPresented,
                onDismiss: _onDismiss
            ) {
                CocoaHosted(
                    rootView: self.destination()
                        .mergeEnvironmentBuilder(self.environmentBuilder)
                )
            }
        }
    }
    
    private func present() {
        isPresented = true
    }
    
    private func _onDismiss() {
        onDismiss?()
        
        isPresented = false
    }
}
