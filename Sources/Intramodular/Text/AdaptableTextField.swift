//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct AdaptableTextField<Placeholder: View>: View {
    private let placeholder: Placeholder
    
    private let onEditingChanged: (Bool) -> ()
    private let onCommit: () -> ()
    
    @Binding private var text: String
    
    public var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
            }
            
            TextField(
                String(),
                text: $text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
        }
    }
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.placeholder = placeholder()
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    public init(
        text: Binding<String?>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.placeholder = placeholder()
        self._text = text.withDefaultValue("")
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

extension AdaptableTextField where Placeholder == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.placeholder = Text(title).foregroundColor(.placeholderText)
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        @ViewBuilder label: () -> Text
    ) {
        self.placeholder = label()
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}
