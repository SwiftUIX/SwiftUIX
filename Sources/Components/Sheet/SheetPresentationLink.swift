//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

/// A control which presents content when triggered.
public struct SheetPresentationLink<Destination: View, Label: View>: View {
    public let destination: Destination
    public let label: Label

    private let onDismiss: (() -> ())?

    @Environment(\.isSheetPresented) private var isSheetPresented
    @Environment(\.onSheetPresentationDismiss) private var onSheetPresentationDismiss
    @Environment(\.presentedSheetView) private var presentedSheetView

    public init(destination: Destination, onDismiss: (() -> ())? = nil, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }

    public var body: some View {
        return Button(action: present, label: { label })
    }

    public func present() {
        onSheetPresentationDismiss!.set(onDismiss)
        presentedSheetView!.set(.init(destination))
        isSheetPresented!.set(true)
    }
}
