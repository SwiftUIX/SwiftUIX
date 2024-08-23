//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
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
                actions
                
                if let onConfirm {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    
                    Button("Confirm") {
                        onConfirm()
                    }
                }
            },
            message: {
                message
            }
        )
        .modify {
            #if os(macOS)
            $0._SwiftUIX_onKeyPress(.escape) {
                if isPresented {
                    dismiss()
                    
                    return .handled
                } else {
                    return .ignored
                }
            }
            #else
            $0
            #endif
        }
    }
    
    private func dismiss() {
        isPresented = false
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
        @ViewBuilder content: () -> Actions,
        onConfirm: (() -> Void)? = nil
    ) where Message == EmptyView {
        self.title = Text(title)
        self.label = label()
        self.actions = content()
        self.message = EmptyView()
        self.onConfirm = onConfirm
    }
}
