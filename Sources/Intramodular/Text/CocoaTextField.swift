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
    
    private var isFirstResponder: Bool?
    
    private var autocapitalization: UITextAutocapitalizationType?
    private var font: UIFont?
    private var kerning: CGFloat?
    private var keyboardType: UIKeyboardType = .default
    private var placeholder: String?
    private var textAlignment: TextAlignment = .leading
    
    public var body: some View {
        return ZStack(alignment: .topLeading) {
            if placeholder == nil {
                label.opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
            }
            
            _CocoaTextField(
                text: text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                isFirstResponder: isFirstResponder,
                autocapitalization: autocapitalization,
                font: font,
                kerning: kerning,
                keyboardType: keyboardType,
                placeholder: placeholder,
                textAlignment: textAlignment
            )
        }
    }
}

public struct _CocoaTextField: UIViewRepresentable {
    public typealias UIViewType = UITextField
    
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    
    var isFirstResponder: Bool?
    
    var autocapitalization: UITextAutocapitalizationType?
    var font: UIFont?
    var kerning: CGFloat?
    var keyboardType: UIKeyboardType
    var placeholder: String?
    var textAlignment: TextAlignment
    
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
        
        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {            base.onCommit()
            
            return true
        }
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = _UITextField()
        
        uiView.configure(for: self)
        uiView.delegate = context.coordinator
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.configure(for: self)
        
        if let isFirstResponder = isFirstResponder, uiView.window != nil {
            if isFirstResponder {
                if !uiView.isFirstResponder {
                    uiView.becomeFirstResponder()
                }
            } else {
                if uiView.isFirstResponder {
                    uiView.resignFirstResponder()
                }
            }
        }
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
}

extension CocoaTextField {
    public func isFirstResponder(_ isFirstResponder: Bool) -> Self {
        then({ $0.isFirstResponder = isFirstResponder })
    }
    
    public func autocapitalization(_ autocapitalization: UITextAutocapitalizationType) -> Self {
        then({ $0.autocapitalization = autocapitalization })
    }
    
    public func font(_ font: UIFont) -> Self {
        then({ $0.font = font })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.keyboardType = keyboardType })
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }
}

extension CocoaTextField where Label == Text {
    public func kerning(_ kerning: CGFloat) -> Self {
        then {
            $0.kerning = kerning
            $0.label = $0.label.kerning(kerning)
        }
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.label = Text(placeholder).kerning(kerning) })
    }
}

// MARK: - Helpers -

extension UITextField {
    public func configure(for textField: _CocoaTextField) {
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        if let autocapitalization = textField.autocapitalization {
            autocapitalizationType = autocapitalization
        }
        
        font = textField.font
        
        if let kerning = textField.kerning {
            defaultTextAttributes.updateValue(kerning, forKey: .kern)
        }
        
        keyboardType = textField.keyboardType
        
        if let placeholder = textField.placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholder, attributes: [
                    .paragraphStyle: NSMutableParagraphStyle().then {
                        $0.alignment = .init(textField.textAlignment)
                    }
                ]
            )
        } else {
            attributedPlaceholder = nil
            placeholder = nil
        }
        
        text = textField.text
        textAlignment = .init(textField.textAlignment)
    }
}

#endif
