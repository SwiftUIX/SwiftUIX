//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct SelectionNavigator<Selection, Destination: View>: ViewModifier {
    private let selection: Binding<Selection?>
    private let destination: Destination?

    public init(
        selection: Binding<Selection?>,
        @ViewBuilder destination: (Selection) -> Destination
    ) {
        self.selection = selection
        self.destination = selection.wrappedValue.map(destination)
    }

    private var isActive: Binding<Bool> {
        .init(
            get: { self.selection.wrappedValue != nil },
            set: { newValue in
                if !newValue {
                    self.selection.wrappedValue = nil
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
        @ViewBuilder destination: (Selection) -> Destination
    ) -> some View {
        modifier(SelectionNavigator(
            selection: selection,
            destination: destination
        ))
    }
}
