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
    enum PresentationMechanism {
        case system
        case custom
    }
    
    private let destination: () -> Destination
    private let label: Label
    private let onDismiss: (() -> ())?
    
    @State private var isPresented: Bool = false
    
    @Environment(\.dynamicViewPresenter) private var dynamicViewPresenter
    
    private var mechanism: PresentationMechanism {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return (dynamicViewPresenter is CocoaPresentationCoordinator) ? .custom : .system
        #else
        return .system
        #endif
    }
    
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
        self.init(destination: destination(), onDismiss: nil, label: label)
    }
    
    public var body: some View {
        Group {
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            
            if mechanism == .system {
                Button(action: present, label: { label }).sheet(
                    isPresented: $isPresented,
                    onDismiss: { self.isPresented = false; self.onDismiss?() },
                    content: self.destination
                )
            } else if mechanism == .custom {
                Button(action: present, label: { label }).cocoaPresentation(
                    isPresented: $isPresented,
                    onDismiss: { self.isPresented = false; self.onDismiss?() },
                    style: .automatic,
                    content: self.destination
                )
            }
            
            #else
            
            Button(action: present, label: { label }).sheet(
                isPresented: $isPresented,
                onDismiss: { self.isPresented = false; self.onDismiss?() },
                content: { self.destination }
            )
            
            #endif
        }
    }
    
    private func present() {
        isPresented = true
    }
}
