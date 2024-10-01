//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ActionLabelView: View {
    associatedtype Label: View

    @MainActor
    init(action: @escaping @MainActor () -> Void, @ViewBuilder label: () -> Label)
    @MainActor
    init(action: Action, @ViewBuilder label: () -> Label)
}

// MARK: - Implementation-

extension ActionLabelView {
    @_disfavoredOverload
    @MainActor
    public init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: Action(action), label: label)
    }
}

// MARK: - Extensions

extension ActionLabelView {
    @MainActor
    public init(action: Action, label: Label) {
        self.init(action: action, label: { label })
    }
    
    @MainActor
    public init(action: @escaping @MainActor () -> Void, label: Label) {
        self.init(action: .init(action), label: { label })
    }
    
    @MainActor
    public init(
        dismiss presentation: Binding<PresentationMode>,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { presentation.wrappedValue.dismiss() }, label: label)
    }
    
    @MainActor
    public init(
        dismiss presentation: PresentationManager,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { presentation.dismiss() }, label: label)
    }
    
    @MainActor
    public init(
        toggle boolean: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { boolean.wrappedValue.toggle() }, label: label)
    }
    
    @MainActor
    @available(iOS 13.0, tvOS 13.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(
        toggle editMode: Binding<EditMode>,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { editMode.wrappedValue.toggle() }, label: label)
    }
}

extension ActionLabelView where Label == Image {
    @MainActor
    public init(
        systemImage: SFSymbolName,
        action: @escaping () -> Void
    ) {
        self.init(action: action) {
            Image(systemName: systemImage)
        }
    }
}

@available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
extension ActionLabelView where Label == Text {
    @MainActor
    public init<S: StringProtocol>(
        _ title: S,
        toggle boolean: Binding<Bool>
    ) {
        self.init(title, action: { boolean.wrappedValue.toggle() })
    }
    
    @MainActor
    public init<S: StringProtocol>(
        _ title: S,
        action: @escaping () -> Void
    ) {
        self.init(action: action) {
            Text(title)
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Button where Label == SwiftUI.Label<Text, Image> {
    @MainActor
    public init(
        _ title: String,
        systemImage: SFSymbolName,
        action: @escaping () -> Void
    ) {
        self.init(action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Button {
    @MainActor
    public init<Icon: View>(
        _ title: String,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) where Label == SwiftUI.Label<Text, Icon> {
        self.init(action: action) {
            Label(title, icon: icon)
        }
    }
}

// MARK: - Conformances

extension Button: ActionLabelView {
    @_disfavoredOverload
    @MainActor
    public init(
        action: Action,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { action.perform() }, label: label)
    }
}
