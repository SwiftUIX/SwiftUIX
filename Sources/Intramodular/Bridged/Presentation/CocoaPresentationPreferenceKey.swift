//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaPresentationLink<Destination: View, Label: View>: View {
    private let destination: Destination
    private let label: Label
    private let onDismiss: (() -> ())?
    
    private var presentationStyle: ModalViewPresentationStyle = .automatic
    
    @Environment(\.self) var environment
    @State private var isPresented: Bool = false
    
    public init(
        destination: Destination,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        Button(action: present, label: { label }).cocoaPresentation(
            isPresented: $isPresented,
            onDismiss: dismiss,
            style: presentationStyle,
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

extension CocoaPresentationLink {
    public func presentationStyle(_ style: ModalViewPresentationStyle) -> Self {
        then({ $0.presentationStyle = style })
    }
}

#endif
