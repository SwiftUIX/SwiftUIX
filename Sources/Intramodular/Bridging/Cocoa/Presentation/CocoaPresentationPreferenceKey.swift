//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaPresentationLink<Destination: View, Label: View>: View {
    private let presentationStyle: ModalViewPresentationStyle
    private let destination: Destination
    private let label: Label
    private let onDismiss: (() -> ())?
    
    @State private var isPresented: Bool = false
    
    public init(
        presentationStyle: ModalViewPresentationStyle,
        destination: Destination,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.presentationStyle = presentationStyle
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        Button(action: present, label: { label })
            .cocoaPresentation(
                isPresented: $isPresented,
                onDismiss: dismiss,
                presentationStyle: presentationStyle,
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

#endif
