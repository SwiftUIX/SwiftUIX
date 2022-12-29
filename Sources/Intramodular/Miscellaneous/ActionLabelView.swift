//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ActionLabelView: View {
    associatedtype Label: View
    
    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label)
    init(action: Action, @ViewBuilder label: () -> Label)
}

// MARK: - Implementation --

extension ActionLabelView {
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.init(action: .init(action), label: label)
    }
}

// MARK: - Extensions -

extension ActionLabelView {
    public init(action: Action, label: Label) {
        self.init(action: action, label: { label })
    }
    
    public init(action: @escaping () -> Void, label: Label) {
        self.init(action: .init(action), label: { label })
    }
    
    public init(
        dismiss presentation: Binding<PresentationMode>,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { presentation.wrappedValue.dismiss() }, label: label)
    }
    
    public init(
        dismiss presentation: PresentationManager,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { presentation.dismiss() }, label: label)
    }
    
    public init(
        toggle boolean: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { boolean.wrappedValue.toggle() }, label: label)
    }
    
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
    public init<S: StringProtocol>(
        _ title: S,
        toggle boolean: Binding<Bool>
    ) {
        self.init(title, action: { boolean.wrappedValue.toggle() })
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        action: @escaping () -> Void
    ) {
        self.init(action: action) {
            Text(title)
        }
    }
}

// FIXME: Uncomment once Xcode 13.3 fixes this segfault.
/*@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Button where Label == SwiftUI.Label<Text, Image> {
    public init(
        _ title: String,
        systemImage: SFSymbolName,
        action: @escaping () -> Void
    ) {
        self.init(action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}*/

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Button where Label == SwiftUI.Label<Text, Image> {
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

// MARK: - Conformances -

extension Button: ActionLabelView {
    public init(action: Action, @ViewBuilder label: () -> Label) {
        self.init(action: action.perform, label: label)
    }
}
