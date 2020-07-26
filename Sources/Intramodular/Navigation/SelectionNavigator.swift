//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A utility view modifier that allows for dynamic navigation based on some arbitrary selection value.
fileprivate struct SelectionNavigator<Selection, Destination: View>: ViewModifier {
    private let selection: Binding<Selection?>
    private let destination: (Selection) -> Destination
    private let onDismiss: (() -> ())?
    
    public init(
        selection: Binding<Selection?>,
        onDismiss: (() -> ())?,
        @ViewBuilder destination: @escaping (Selection) -> Destination
    ) {
        self.selection = selection
        self.onDismiss = onDismiss
        self.destination = destination
    }
    
    private func setIsActive(_ isActive: Bool) {
        if !isActive {
            if selection.wrappedValue != nil {
                selection.wrappedValue = nil
                onDismiss?()
            }
        } else if selection.wrappedValue == nil {
            fatalError()
        }
    }
    
    private var isActive: Binding<Bool> {
        .init(
            get: { self.selection.wrappedValue != nil },
            set: setIsActive
        )
    }
    
    public func body(content: Content) -> some View {
        content.background(
            NavigationLink(
                destination: LazyView {
                    self.destination(self.selection.wrappedValue!)
                },
                isActive: isActive,
                label: { ZeroSizeView() }
            )
        )
    }
}

// MARK: - Helpers -

extension View {
    @available(*, deprecated, message: "This implementation is unreliable.")
    public func navigate<Selection, Destination: View>(
        selection: Binding<Selection?>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder destination: @escaping (Selection) -> Destination
    ) -> some View {
        modifier(SelectionNavigator(
            selection: selection,
            onDismiss: onDismiss,
            destination: destination
        ))
    }
    
    public func navigate<Destination: View>(
        isActive: Binding<Bool>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder to destination: () -> Destination
    ) -> some View {
        background(
            NavigationLink(
                destination: destination(),
                isActive: isActive,
                label: { ZeroSizeView() }
            )
        )
    }
}
