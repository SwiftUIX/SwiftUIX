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
            selection.wrappedValue = nil
            
            if selection.wrappedValue != nil {
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
        ZStack {
            NavigationLink(destination: LazyView {
                self.destination(self.selection.wrappedValue!)
            }, isActive: isActive) {
                EmptyView().frame(CGSize.zero)
            }
            
            content
        }
    }
}

// MARK: - Helpers -

extension View {
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
        @ViewBuilder to destination: @escaping () -> Destination
    ) -> some View {
        navigate(
            selection:  Binding<Void?>(
                get: { isActive.wrappedValue ? () : nil },
                set: { isActive.wrappedValue = $0 != nil }
            ),
            onDismiss: onDismiss,
            destination: destination
        )
    }
    
    public func navigate<Destination: View>(
        isActive: Binding<Bool?>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder to destination: @escaping () -> Destination
    ) -> some View {
        navigate(
            selection: Binding<Void?>(
                get: { (isActive.wrappedValue ?? false) ? () : nil },
                set: { isActive.wrappedValue = $0 != nil }
            ),
            onDismiss: onDismiss,
            destination: destination
        )
    }
}
