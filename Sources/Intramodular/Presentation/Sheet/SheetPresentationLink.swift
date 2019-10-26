//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A control which presents a sheet of content when triggered.
public struct SheetPresentationLink<Destination: View, Label: View>: View {
    public let destination: Destination
    public let label: Label
    
    private let onDismiss: (() -> ())?
    
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
        Button(action: present, label: { label })
    }
    
    private func present() {
        onSheetPresentationDismiss!.wrappedValue = onDismiss
        presentedSheetView!.wrappedValue = .init(destination)
        isSheetPresented!.wrappedValue = true
    }
}
