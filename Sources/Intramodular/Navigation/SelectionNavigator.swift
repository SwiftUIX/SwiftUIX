//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct SelectionNavigator<Selection, Destination: View>: ViewModifier {
    private let selection: Binding<Selection?>
    private let destination: Destination?
    private let onDismiss: (() -> ())?

    public init(
        selection: Binding<Selection?>,
        onDismiss: (() -> ())?,
        @ViewBuilder destination: (Selection) -> Destination
    ) {
        self.selection = selection
        self.onDismiss = onDismiss
        self.destination = selection.wrappedValue.map(destination)
    }

    private var isActive: Binding<Bool> {
        .init(
            get: { self.selection.wrappedValue != nil },
            set: { newValue in
                if !newValue {
                    self.selection.wrappedValue = nil
                    self.onDismiss?()
                } else if self.selection.wrappedValue == nil {
                    fatalError()
                }
        }
        )
    }

    public func body(content: Content) -> some View {
        ZStack {
            content
            NavigationLink(destination: destination, isActive: isActive) {
                EmptyView()
            }
        }
    }
}

extension View {
    public func navigate<Selection, Destination: View>(
        selection: Binding<Selection?>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder destination: (Selection) -> Destination
    ) -> some View {
        modifier(SelectionNavigator(
            selection: selection,
            onDismiss: onDismiss,
            destination: destination
        ))
    }
}
