//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A text-input type where `Self.Label == SwiftUI.Text`.
public protocol DefaultTextInputType {    
    init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void,
        onCommit: @escaping () -> Void
    )
    
    init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void
    )
}

// MARK: - Extensions -

extension DefaultTextInputType {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text.withDefaultValue(String()),
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String?>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            onEditingChanged: { _ in },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String?>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            onEditingChanged: { _ in },
            onCommit: onCommit
        )
    }
}

// MARK: - Conformances -

extension TextField: DefaultTextInputType where Label == Text {
    
}

extension SecureField where Label == Text {
    public init(
        text: Binding<String>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String?>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text.withDefaultValue(String()),
            onCommit: onCommit
        )
    }
}
