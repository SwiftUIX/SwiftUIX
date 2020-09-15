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
}

#if (os(iOS) || os(watchOS) || os(tvOS)) && !targetEnvironment(macCatalyst)

@available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
extension ActionLabelView where Label == SwiftUI.Label<Text, Image> {
    public init<S: StringProtocol>(
        _ title: S,
        systemImage: SanFranciscoSymbolName,
        action: @escaping () -> Void
    ) {
        self.init(action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

#endif

// MARK: - Concrete Implementaitons -

extension Button: ActionLabelView {
    public init(action: Action, @ViewBuilder label: () -> Label) {
        self.init(action: action.perform, label: label)
    }
}
