//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AlertPresentationLink<Label: View, Actions: View, Message: View>: View {
    private let title: Text
    private let label: Label
    private let actions: Actions
    private let message: Message
    
    private var onConfirm: (() -> Void)?
    
    @State private var isPresented: Bool = false
    
    public var body: some View {
        Button {
            isPresented = true
        } label: {
            label
        }
        .alert(
            title,
            isPresented: $isPresented,
            actions: {
                if Action.self == EmptyView.self {
                    Button("Cancel", role: .destructive) {
                        isPresented = false
                    }
                    
                    Button("Confirm") {
                        onConfirm?()
                        
                        isPresented = false
                    }
                } else {
                    actions
                }
            },
            message: {
                message
            }
        )
        .modify {
#if os(macOS)
            if #available(macOS 13.0, *) {
                $0.dialogIcon(Image(systemName: .clear))
            } else {
                $0
            }
#else
            $0
#endif
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AlertPresentationLink {
    public init(
        _ title: String,
        @ViewBuilder label: () -> Label,
        @ViewBuilder actions: () -> Actions,
        @ViewBuilder message: () -> Message
    ) {
        self.title = Text(title)
        self.label = label()
        self.actions = actions()
        self.message = message()
    }
    
    public init(
        _ title: String,
        @ViewBuilder label: () -> Label,
        @ViewBuilder actions: () -> Actions
    ) where Message == EmptyView {
        self.title = Text(title)
        self.label = label()
        self.actions = actions()
        self.message = EmptyView()
    }
    
    public init(
        _ title: String,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Message,
        onConfirm: @escaping () -> Void
    ) where Actions == EmptyView {
        self.title = Text(title)
        self.label = label()
        self.actions = EmptyView()
        self.message = content()
    }
}
