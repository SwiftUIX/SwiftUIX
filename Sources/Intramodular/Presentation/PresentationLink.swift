//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A control which presents content when triggered.
///
/// A revival of `PresentationLink` (from Xcode 11 beta 3).
public struct PresentationLink<Destination: View, Label: View>: View {
    enum PresentationMechanism {
        case system
        case patch
    }
    
    private var mechanism: PresentationMechanism {
        isSheetPresented == nil ? .system : .patch
    }
    
    private let destination: Destination
    private let label: Label
    private let onDismiss: (() -> ())?
    
    @State private var isPresented: Bool = false
    
    @Environment(\.isSheetPresented) private var isSheetPresented
    @Environment(\.onSheetPresentationDismiss) private var onSheetPresentationDismiss
    @Environment(\.presentedSheetView) private var presentedSheetView
    
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
        return Button(action: present, label: { label }).sheet(
            isPresented: $isPresented,
            onDismiss: { self.isPresented = false; self.onDismiss?() },
            content: { self.destination }
        )
    }
    
    private func present() {
        switch mechanism {
            case .system: do {
                isPresented = true
            }
            
            case .patch: do {
                onSheetPresentationDismiss!.wrappedValue = onDismiss
                presentedSheetView!.wrappedValue = .init(destination)
                isSheetPresented!.wrappedValue = true
            }
        }
    }
}
