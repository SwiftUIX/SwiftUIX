//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A utility view modifier that allows for dynamic navigation based on some arbitrary selection value.
fileprivate struct SelectionNavigator<Selection: Identifiable, Destination: View>: ViewModifier {
    private let selection: Binding<Selection?>
    private let destination: (Selection) -> Destination
    private let onDismiss: (() -> Void)?
    
    public init(
        selection: Binding<Selection?>,
        onDismiss: (() -> Void)?,
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
        #if !os(watchOS)
        return content.background(
            selection.wrappedValue.ifSome { selection in
                NavigationLink(
                    destination: self.destination(selection)
                        ._resolveAppKitOrUIKitViewControllerIfAvailable(),
                    isActive: isActive,
                    label: { ZeroSizeView() }
                )
                .id(selection.id)
                .accessibility(hidden: true)
            }
        )
        #else
        return content.background(
            selection.wrappedValue.ifSome { selection in
                NavigationLink(
                    destination: self.destination(selection),
                    isActive: isActive,
                    label: { ZeroSizeView() }
                )
                .id(selection.id)
                .accessibility(hidden: true)
            }
        )
        #endif
    }
}

// MARK: - API -

extension View {
    public func navigate<Destination: View>(
        to destination: Destination,
        isActive: Binding<Bool>
    ) -> some View {
        background(
            NavigationLink(
                destination: destination,
                isActive: isActive,
                label: { ZeroSizeView() }
            )
            .accessibility(hidden: true)
        )
    }
    
    public func navigate<Destination: View, Selection: Equatable>(
        to destination: Destination,
        tag: Selection,
        selection: Binding<Selection?>
    ) -> some View {
        background(
            NavigationLink(
                destination: destination,
                isActive: .init(
                    get: { selection.wrappedValue == tag },
                    set: { newValue in
                        if newValue {
                            selection.wrappedValue = tag
                        } else {
                            selection.wrappedValue = nil
                        }
                    }
                ),
                label: { ZeroSizeView() }
            )
            .accessibility(hidden: true)
        )
    }
        
    public func navigate<Destination: View>(
        isActive: Binding<Bool>,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        navigate(to: destination(), isActive: isActive)
    }
}

extension View {
    /// Adds a destination to present when this view is pressed.
    public func onPress<Destination: View>(
        navigateTo destination: Destination,
        onDismiss: (() -> ())? = nil
    ) -> some View {
        modifier(NavigateOnPress(destination: destination, onDismiss: onDismiss))
    }
    
    /// Adds a destination to present when this view is pressed.
    public func onPress<Destination: View>(
        navigateTo destination: Destination,
        isActive: Binding<Bool>,
        onDismiss: (() -> ())? = nil
    ) -> some View {
        modifier(NavigateOnPress(destination: destination, isActive: isActive, onDismiss: onDismiss))
    }
}

extension View {
    public func navigate<Selection: Identifiable, Destination: View>(
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
}

// MARK: - Auxiliary Implementation -

fileprivate struct NavigateOnPress<Destination: View>: ViewModifier {
    let destination: Destination
    let isActive: Binding<Bool>?
    let onDismiss: (() -> Void)?
    
    @State var _internal_isActive: Bool = false
    
    init(
        destination: Destination,
        isActive: Binding<Bool>? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.destination = destination
        self.isActive = isActive
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        Button(toggle: isActive ?? $_internal_isActive) {
            content.contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            NavigationLink(
                destination: destination,
                isActive: isActive ?? $_internal_isActive,
                label: { EmptyView() }
            )
            .hidden()
            .accessibility(hidden: true)
        )
    }
}
