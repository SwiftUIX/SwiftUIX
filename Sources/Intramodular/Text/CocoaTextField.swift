//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaTextField<Label: View>: View {
    private var label: Label
    
    private var text: Binding<String>
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
    private var font: UIFont?
    private var placeholder: String?
    private var kerning: CGFloat?
    private var keyboardType: UIKeyboardType = .default
    
    public var body: some View {
        return ZStack {
            label.opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
            
            _CocoaTextField(
                text: text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                font: font,
                keyboardType: keyboardType,
                placeholder: placeholder,
                kerning: kerning
            )
        }
    }
    
    public func font(_ font: UIFont) -> Self {
        then({ $0.font = font })
    }
    
    public func kerning(_ kerning: CGFloat) -> Self {
        then({ $0.kerning = kerning })
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.keyboardType = keyboardType })
    }
}

public struct _CocoaTextField: UIViewRepresentable {
    public typealias UIViewType = UITextField
    
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    var font: UIFont?
    var keyboardType: UIKeyboardType
    var placeholder: String?
    var kerning: CGFloat?
    
    @Environment(\.multilineTextAlignment) var multilineTextAlignment
    
    init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        font: UIFont?,
        keyboardType: UIKeyboardType,
        placeholder: String?,
        kerning: CGFloat?
    ) {
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.font = font
        self.keyboardType = keyboardType
        self.placeholder = placeholder
        self.kerning = kerning
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var base: _CocoaTextField
        
        init(base: _CocoaTextField) {
            self.base = base
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            base.text = textField.text ?? ""
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            base.onEditingChanged(false)
            base.onCommit()
        }
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let textField = _UITextField()
        
        textField.delegate = context.coordinator
        textField.configure(for: self)
        
        return textField
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.configure(for: self)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

// MARK: - Extensions -

extension CocoaTextField where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title).foregroundColor(.placeholderText)
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        @ViewBuilder label: () -> Text
    ) {
        self.label = label()
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    public func kerning(_ kerning: CGFloat) -> Self {
        then {
            $0.kerning = kerning
            $0.label = $0.label.kerning(kerning)
        }
    }
}

// MARK: - Helpers -

extension UITextField {
    public func configure(for textField: _CocoaTextField) {
        font = textField.font
        
        if let kerning = textField.kerning {
            defaultTextAttributes.updateValue(kerning, forKey: .kern)
        }
        
        keyboardType = textField.keyboardType
        placeholder = textField.placeholder
        text = textField.text
        textAlignment = .init(textField.multilineTextAlignment)
    }
}

#endif
